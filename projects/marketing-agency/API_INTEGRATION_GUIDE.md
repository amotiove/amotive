# API Integration Guide for Amotive Digital Marketing Agency

## Overview

This guide provides comprehensive integration instructions for major digital marketing platforms. Each section includes setup steps, authentication flows, key endpoints, rate limits, Python code examples, and cost analysis.

**Target Integration Timeline: 3-6 weeks**  
**Total Estimated Development: 120-200 hours**

---

## 1. Google Ads API

### Status
✅ **Generally Available** | Last Updated: 2026-01-28

### Authentication & Setup

#### Prerequisites
- Google Ads Manager account
- Developer token (apply at Google Ads API Center)
- 10-digit client customer ID
- OAuth 2.0 credentials

#### Setup Steps
1. **Enable API Access**
   ```bash
   # Install Python client library
   pip install google-ads==24.1.0
   ```

2. **Create OAuth Application**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create new project or select existing
   - Enable Google Ads API
   - Create OAuth 2.0 credentials (Web application)

3. **Apply for Developer Token**
   - Visit Google Ads API Center
   - Apply for Basic or Standard access
   - Basic: Test accounts only
   - Standard: Production access (requires review)

#### Authentication Flow
```python
from google.ads.googleads.client import GoogleAdsClient

# Configuration file approach
client = GoogleAdsClient.load_from_storage("google-ads.yaml")

# Manual configuration
client = GoogleAdsClient.load_from_dict({
    "developer_token": "YOUR_DEVELOPER_TOKEN",
    "refresh_token": "YOUR_REFRESH_TOKEN", 
    "client_id": "YOUR_CLIENT_ID",
    "client_secret": "YOUR_CLIENT_SECRET",
    "login_customer_id": "YOUR_LOGIN_CUSTOMER_ID"
})
```

### Key Endpoints & Operations

#### Campaign Management
```python
# Create campaign
def create_campaign(client, customer_id, campaign_name, budget_amount):
    campaign_service = client.get_service("CampaignService")
    campaign_operation = client.get_type("CampaignOperation")
    
    campaign = campaign_operation.create
    campaign.name = campaign_name
    campaign.advertising_channel_type = client.enums.AdvertisingChannelTypeEnum.SEARCH
    campaign.status = client.enums.CampaignStatusEnum.ENABLED
    
    # Budget
    budget_service = client.get_service("CampaignBudgetService")
    budget_operation = client.get_type("CampaignBudgetOperation")
    budget = budget_operation.create
    budget.name = f"Budget for {campaign_name}"
    budget.amount_micros = budget_amount * 1_000_000  # Convert to micros
    budget.delivery_method = client.enums.BudgetDeliveryMethodEnum.STANDARD
    
    budget_response = budget_service.mutate_campaign_budgets(
        customer_id=customer_id, operations=[budget_operation]
    )
    
    campaign.campaign_budget = budget_response.results[0].resource_name
    
    response = campaign_service.mutate_campaigns(
        customer_id=customer_id, operations=[campaign_operation]
    )
    
    return response.results[0].resource_name

# Get campaigns
def get_campaigns(client, customer_id):
    ga_service = client.get_service("GoogleAdsService")
    
    query = """
        SELECT
            campaign.id,
            campaign.name,
            campaign.status,
            campaign.serving_status,
            campaign_budget.amount_micros,
            metrics.impressions,
            metrics.clicks,
            metrics.cost_micros
        FROM campaign 
        WHERE campaign.status != 'REMOVED'
        ORDER BY campaign.name
    """
    
    response = ga_service.search_stream(customer_id=customer_id, query=query)
    
    campaigns = []
    for batch in response:
        for row in batch.results:
            campaigns.append({
                'id': row.campaign.id,
                'name': row.campaign.name,
                'status': row.campaign.status.name,
                'budget': row.campaign_budget.amount_micros / 1_000_000,
                'impressions': row.metrics.impressions,
                'clicks': row.metrics.clicks,
                'cost': row.metrics.cost_micros / 1_000_000
            })
    
    return campaigns
```

### Rate Limits & Quotas
- **Standard Tier**: 15,000 operations per day
- **Basic Tier**: 10,000 operations per day  
- **Read operations**: 1 point each
- **Write operations**: 50 points each
- **Search operations**: 100 points each

### Cost Structure
- **API Access**: Free
- **Ad Spend**: Standard Google Ads billing
- **Rate Limit Extensions**: Request through support

### Integration Timeline
**Estimated: 2-3 weeks (80-120 hours)**

---

## 2. Meta/Instagram Graph API

### Status  
✅ **Generally Available** | Latest Version: v19.0

### Authentication & Setup

#### Prerequisites
- Facebook Business Manager account
- Instagram Business/Creator account
- Meta App with appropriate permissions
- Business verification (for advanced features)

#### Setup Steps
1. **Create Meta App**
   ```bash
   # Install Facebook SDK
   pip install facebook-sdk==3.1.0
   ```

2. **Configure Business Manager**
   - Link Instagram account to Facebook Page
   - Grant necessary permissions in Business Settings
   - Generate long-lived access tokens

#### Authentication Flow
```python
import facebook

class MetaAPIClient:
    def __init__(self, access_token, app_id, app_secret):
        self.graph = facebook.GraphAPI(access_token=access_token, version="19.0")
        self.app_id = app_id
        self.app_secret = app_secret
    
    def extend_access_token(self, short_token):
        """Convert short-lived to long-lived token (60 days)"""
        return self.graph.extend_access_token(self.app_id, self.app_secret)
```

### Key Endpoints & Operations

#### Content Publishing
```python
# Schedule Instagram post
def create_instagram_post(client, instagram_account_id, image_url, caption):
    # Step 1: Create media container
    media_response = client.graph.put_object(
        parent_object=instagram_account_id,
        connection_name="media",
        image_url=image_url,
        caption=caption,
        media_type="IMAGE"
    )
    
    # Step 2: Publish media
    publish_response = client.graph.put_object(
        parent_object=instagram_account_id,
        connection_name="media_publish",
        creation_id=media_response["id"]
    )
    
    return publish_response["id"]

# Get Instagram insights
def get_instagram_insights(client, media_id):
    insights = client.graph.get_object(
        id=media_id,
        fields="insights.metric(reach,impressions,saved,video_views)"
    )
    return insights["insights"]["data"]

# Create Facebook ad via Marketing API
def create_facebook_ad(client, ad_account_id, campaign_id, creative):
    ad_set_data = {
        "name": "Test AdSet",
        "campaign_id": campaign_id,
        "daily_budget": 1000,  # $10.00 in cents
        "billing_event": "IMPRESSIONS",
        "optimization_goal": "REACH",
        "bid_amount": 2,
        "targeting": {
            "geo_locations": {"countries": ["US"]},
            "age_min": 18,
            "age_max": 65
        },
        "status": "ACTIVE"
    }
    
    ad_set = client.graph.put_object(
        parent_object=f"act_{ad_account_id}",
        connection_name="adsets",
        **ad_set_data
    )
    
    return ad_set["id"]
```

### Rate Limits & Best Practices
- **Standard Rate Limit**: 200 calls per hour per user
- **Business Use Case**: 600 calls per hour  
- **Batch Requests**: Up to 50 operations per batch
- **Webhook Rate Limit**: 1000 calls per app per hour

### Webhook Setup
```python
# Instagram webhook handler
@app.route('/webhook', methods=['POST'])
def handle_instagram_webhook():
    data = request.get_json()
    
    for entry in data.get('entry', []):
        for change in entry.get('changes', []):
            if change['field'] == 'comments':
                # Handle new comment
                process_comment(change['value'])
            elif change['field'] == 'mentions':
                # Handle mention
                process_mention(change['value'])
    
    return 'OK', 200
```

### Cost Structure
- **API Access**: Free up to rate limits
- **Ad spend**: Facebook Ads Manager billing
- **Business Verification**: Free but required for advanced features

### Integration Timeline  
**Estimated: 2-3 weeks (60-90 hours)**

---

## 3. TikTok Marketing API

### Status
✅ **Generally Available** | Business API v1.3

### Authentication & Setup

#### Prerequisites
- TikTok for Business account
- App registered in TikTok Developers portal
- Business verification for ad management
- Advertiser account setup

#### Setup Steps
1. **Register Application**
   ```bash
   pip install requests==2.31.0
   ```

2. **OAuth 2.0 Setup**
   - Authorization Code flow for user consent
   - Access token refresh mechanism
   - Scope management for different permissions

#### Authentication Flow
```python
import requests
import time

class TikTokBusinessAPI:
    def __init__(self, app_id, secret, access_token=None):
        self.app_id = app_id
        self.secret = secret
        self.access_token = access_token
        self.base_url = "https://business-api.tiktok.com/open_api/v1.3"
    
    def get_authorization_url(self, redirect_uri, state):
        """Generate OAuth authorization URL"""
        auth_url = f"https://business-api.tiktok.com/open_api/audit/oauth.html"
        params = {
            "app_id": self.app_id,
            "state": state,
            "redirect_uri": redirect_uri,
            "scope": "ad_management,audience_management"
        }
        return f"{auth_url}?" + "&".join([f"{k}={v}" for k, v in params.items()])
    
    def exchange_code_for_token(self, auth_code):
        """Exchange authorization code for access token"""
        url = f"{self.base_url}/oauth2/access_token/"
        data = {
            "app_id": self.app_id,
            "secret": self.secret,
            "auth_code": auth_code
        }
        
        response = requests.post(url, json=data)
        return response.json()
```

### Key Endpoints & Operations

#### Campaign Management
```python
def create_tiktok_campaign(client, advertiser_id, campaign_name, budget):
    """Create TikTok ad campaign"""
    url = f"{client.base_url}/campaign/create/"
    
    payload = {
        "advertiser_id": advertiser_id,
        "campaign_name": campaign_name,
        "objective_type": "TRAFFIC",
        "campaign_type": "REGULAR_CAMPAIGN",
        "budget_mode": "BUDGET_MODE_DAY",
        "budget": budget * 100,  # Convert to cents
        "status": "ENABLE"
    }
    
    headers = {
        "Access-Token": client.access_token,
        "Content-Type": "application/json"
    }
    
    response = requests.post(url, json=payload, headers=headers)
    return response.json()

# Get campaign performance
def get_campaign_insights(client, advertiser_id, campaign_ids, start_date, end_date):
    url = f"{client.base_url}/report/integrated/get/"
    
    payload = {
        "advertiser_id": advertiser_id,
        "report_type": "AUDIENCE",
        "data_level": "AUCTION_CAMPAIGN",
        "service_type": "AUCTION",
        "dimensions": ["campaign_id", "stat_time_day"],
        "metrics": ["spend", "impressions", "clicks", "ctr", "cpc", "conversion"],
        "filters": {
            "campaign_ids": campaign_ids
        },
        "start_date": start_date,
        "end_date": end_date,
        "page_size": 1000
    }
    
    headers = {"Access-Token": client.access_token}
    response = requests.post(url, json=payload, headers=headers)
    return response.json()

# Spark Ads (boost organic content)
def create_spark_ad(client, advertiser_id, item_id, spark_type="ITEM"):
    """Create Spark Ad from existing TikTok content"""
    url = f"{client.base_url}/creative/spark_ads/create/"
    
    payload = {
        "advertiser_id": advertiser_id,
        "spark_type": spark_type,
        "item_id": item_id,
        "ad_name": f"Spark Ad - {item_id}",
        "call_to_action": "LEARN_MORE"
    }
    
    headers = {"Access-Token": client.access_token}
    response = requests.post(url, json=payload, headers=headers)
    return response.json()
```

### Rate Limits & Quotas
- **Default QPS**: 10 requests per second
- **Daily Limit**: 1,000,000 requests per day
- **Reporting API**: 10 requests per minute
- **Batch Operations**: Up to 20 items per request

### Cost Structure
- **API Access**: Free
- **Ad Spend**: TikTok Ads Manager billing (minimum $20/day)
- **Spark Ads**: Standard ad pricing + creator collaboration

### Integration Timeline
**Estimated: 1-2 weeks (40-60 hours)**

---

## 4. YouTube Data API v3 + Shorts

### Status
✅ **Generally Available** | Version 3

### Authentication & Setup

#### Prerequisites  
- Google Cloud Project with YouTube Data API enabled
- OAuth 2.0 credentials or Service Account
- YouTube channel for content management

#### Setup Steps
```bash
# Install Google API client
pip install google-api-python-client==2.110.0
pip install google-auth-httplib2==0.2.0
pip install google-auth-oauthlib==1.0.0
```

#### Authentication Flow
```python
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import Flow
from google.auth.transport.requests import Request
import pickle
import os

class YouTubeAPIClient:
    def __init__(self, credentials_file, token_file="token.pickle"):
        self.credentials_file = credentials_file
        self.token_file = token_file
        self.scopes = ['https://www.googleapis.com/auth/youtube.upload',
                      'https://www.googleapis.com/auth/youtube']
        self.youtube = self._authenticate()
    
    def _authenticate(self):
        creds = None
        if os.path.exists(self.token_file):
            with open(self.token_file, 'rb') as token:
                creds = pickle.load(token)
        
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(Request())
            else:
                flow = Flow.from_client_secrets_file(
                    self.credentials_file, self.scopes)
                flow.redirect_uri = 'http://localhost:8080/callback'
                
                auth_url, _ = flow.authorization_url(prompt='consent')
                print(f'Please visit: {auth_url}')
                
                code = input('Enter authorization code: ')
                flow.fetch_token(code=code)
                creds = flow.credentials
            
            with open(self.token_file, 'wb') as token:
                pickle.dump(creds, token)
        
        return build('youtube', 'v3', credentials=creds)
```

### Key Endpoints & Operations

#### Video Upload (Including Shorts)
```python
def upload_video(client, title, description, tags, video_file, is_short=False):
    """Upload video or YouTube Short"""
    
    # Shorts requirements: ≤60s, vertical (9:16), #Shorts in title/description
    if is_short:
        title = f"#Shorts {title}"
        if "#Shorts" not in description:
            description = f"#Shorts {description}"
    
    body = {
        'snippet': {
            'title': title,
            'description': description,
            'tags': tags,
            'categoryId': '22'  # People & Blogs
        },
        'status': {
            'privacyStatus': 'public',  # or 'private', 'unlisted'
            'selfDeclaredMadeForKids': False
        }
    }
    
    # Upload video
    insert_request = client.youtube.videos().insert(
        part=','.join(body.keys()),
        body=body,
        media_body=MediaFileUpload(
            video_file,
            chunksize=1024*1024,  # 1MB chunks
            resumable=True
        )
    )
    
    response = None
    error = None
    retry = 0
    
    while response is None:
        try:
            print("Uploading file...")
            status, response = insert_request.next_chunk()
            if status:
                print(f"Uploaded {int(status.progress() * 100)}%")
        except Exception as e:
            error = e
            retry += 1
            if retry > 3:
                break
            time.sleep(2**retry)
    
    return response

# Get channel analytics
def get_channel_analytics(client, channel_id, start_date, end_date):
    """Get YouTube Analytics data"""
    analytics_service = build('youtubeAnalytics', 'v2', credentials=client.youtube._http.credentials)
    
    response = analytics_service.reports().query(
        ids=f'channel=={channel_id}',
        startDate=start_date,
        endDate=end_date,
        metrics='views,estimatedMinutesWatched,averageViewDuration,subscribersGained',
        dimensions='day',
        sort='day'
    ).execute()
    
    return response

# Manage playlists
def create_playlist(client, title, description, privacy_status='public'):
    playlists_insert_response = client.youtube.playlists().insert(
        part='snippet,status',
        body=dict(
            snippet=dict(
                title=title,
                description=description
            ),
            status=dict(
                privacyStatus=privacy_status
            )
        )
    ).execute()
    
    return playlists_insert_response['id']
```

### Quota Management
- **Default Quota**: 10,000 units/day (free)
- **Video Upload**: 100 units
- **Search Request**: 100 units  
- **List Videos**: 1 unit
- **Insert Playlist**: 50 units

#### Quota Optimization
```python
def batch_video_details(client, video_ids, batch_size=50):
    """Efficiently get video details in batches"""
    all_videos = []
    
    for i in range(0, len(video_ids), batch_size):
        batch_ids = video_ids[i:i + batch_size]
        
        response = client.youtube.videos().list(
            part='snippet,statistics,contentDetails',
            id=','.join(batch_ids)
        ).execute()
        
        all_videos.extend(response['items'])
    
    return all_videos
```

### YouTube Shorts Specifics
- **Duration**: ≤60 seconds
- **Aspect Ratio**: Vertical (9:16 recommended)
- **Title/Description**: Include #Shorts hashtag
- **Thumbnail**: Auto-generated for shorts
- **Discovery**: Shorts shelf, mobile feed

### Cost Structure
- **API Access**: Free (10K units/day)
- **Additional Quota**: Request through Quota extension form
- **Content**: Free to upload and monetize

### Integration Timeline
**Estimated: 1-2 weeks (30-50 hours)**

---

## 5. Google Business Profile API

### Status
⚠️ **Transitioning** | My Business API v4 → Business Profile API

### Authentication & Setup

#### Prerequisites
- Google Business Profile account
- Business verification completed
- Google Cloud Project with API enabled
- Location management permissions

#### Setup Steps
```bash
# Install Google My Business client
pip install google-api-python-client==2.110.0
```

#### Authentication Flow
```python
from googleapiclient.discovery import build
from google.oauth2.credentials import Credentials

class BusinessProfileAPI:
    def __init__(self, credentials):
        self.credentials = credentials
        self.service = build('mybusiness', 'v4', credentials=credentials)
    
    def list_accounts(self):
        """List all business accounts"""
        try:
            accounts = self.service.accounts().list().execute()
            return accounts.get('accounts', [])
        except Exception as e:
            print(f"Error listing accounts: {e}")
            return []
```

### Key Endpoints & Operations

#### Location Management
```python
def get_locations(client, account_id):
    """Get all locations for an account"""
    locations = client.service.accounts().locations().list(
        parent=f'accounts/{account_id}'
    ).execute()
    
    return locations.get('locations', [])

def update_business_hours(client, location_name, hours):
    """Update business hours"""
    location_update = {
        'regularHours': {
            'periods': hours
        }
    }
    
    response = client.service.accounts().locations().patch(
        name=location_name,
        body=location_update,
        updateMask='regularHours'
    ).execute()
    
    return response

# Create business post
def create_business_post(client, location_name, post_type, content, media_url=None):
    """Create a Google Business Profile post"""
    post_body = {
        'languageCode': 'en-US',
        'summary': content[:1500],  # 1500 char limit
        'callToAction': {
            'actionType': 'LEARN_MORE',
            'url': 'https://your-website.com'
        }
    }
    
    if media_url:
        post_body['media'] = [{'mediaFormat': 'PHOTO', 'sourceUrl': media_url}]
    
    if post_type == 'OFFER':
        post_body['offer'] = {
            'couponCode': 'SAVE20',
            'redeemOnlineUrl': 'https://your-website.com/offer'
        }
    
    response = client.service.accounts().locations().localPosts().create(
        parent=location_name,
        body=post_body
    ).execute()
    
    return response

# Get insights
def get_location_insights(client, location_name, start_date, end_date):
    """Get business insights"""
    request_body = {
        'locationNames': [location_name],
        'basicRequest': {
            'metricRequests': [
                {'metric': 'QUERIES_DIRECT'},
                {'metric': 'QUERIES_INDIRECT'},
                {'metric': 'VIEWS_MAPS'},
                {'metric': 'VIEWS_SEARCH'},
                {'metric': 'ACTIONS_WEBSITE'},
                {'metric': 'ACTIONS_PHONE'}
            ],
            'timeRange': {
                'startTime': start_date + 'T00:00:00Z',
                'endTime': end_date + 'T23:59:59Z'
            }
        }
    }
    
    response = client.service.accounts().locations().reportInsights(
        name=f'accounts/{account_id}',
        body=request_body
    ).execute()
    
    return response
```

#### Review Management
```python
def get_reviews(client, location_name):
    """Get customer reviews"""
    reviews = client.service.accounts().locations().reviews().list(
        parent=location_name,
        orderBy='createTime desc'
    ).execute()
    
    return reviews.get('reviews', [])

def reply_to_review(client, review_name, reply_text):
    """Reply to a customer review"""
    reply_body = {
        'comment': reply_text
    }
    
    response = client.service.accounts().locations().reviews().updateReply(
        name=review_name,
        body=reply_body
    ).execute()
    
    return response
```

### Multi-Location Management
```python
def batch_update_locations(client, account_id, updates):
    """Update multiple locations efficiently"""
    
    # Group updates by operation type
    location_updates = []
    
    for location_id, update_data in updates.items():
        location_updates.append({
            'location': {
                'name': f'accounts/{account_id}/locations/{location_id}',
                **update_data
            },
            'updateMask': ','.join(update_data.keys())
        })
    
    # Process in batches of 10
    batch_size = 10
    results = []
    
    for i in range(0, len(location_updates), batch_size):
        batch = location_updates[i:i + batch_size]
        
        # Note: Actual batch API may vary - check latest documentation
        for update in batch:
            result = client.service.accounts().locations().patch(
                name=update['location']['name'],
                body=update['location'],
                updateMask=update['updateMask']
            ).execute()
            results.append(result)
    
    return results
```

### Rate Limits & Quotas
- **Read Operations**: 1,000 requests per 100 seconds
- **Write Operations**: 100 requests per 100 seconds  
- **Insights API**: 50 requests per 100 seconds
- **Review Replies**: 10 per day per location

### Cost Structure
- **API Access**: Free
- **Google Business Profile**: Free
- **Advanced features**: Included with verification

### Integration Timeline
**Estimated: 1-2 weeks (20-40 hours)**

---

## Implementation Strategy

### Phase 1: Foundation (Week 1-2)
1. **Google Ads API** - Core campaign management
2. **YouTube Data API** - Video upload and analytics
3. **Authentication infrastructure** - OAuth flows, token refresh

### Phase 2: Social Platforms (Week 3-4)  
1. **Meta/Instagram Graph API** - Content publishing and ads
2. **TikTok Marketing API** - Campaign management and Spark Ads
3. **Webhook handlers** - Real-time notifications

### Phase 3: Local & Analytics (Week 5-6)
1. **Google Business Profile API** - Multi-location management  
2. **Comprehensive reporting** - Cross-platform analytics
3. **Error handling & monitoring** - Production readiness

### Testing Strategy
- **Sandbox Environment**: Use test accounts for all platforms
- **Rate Limit Testing**: Implement proper backoff strategies
- **Data Validation**: Verify all API responses and error handling
- **Integration Testing**: End-to-end workflow validation

### Monitoring & Maintenance
```python
# Example monitoring setup
import logging
from datetime import datetime, timedelta

def setup_api_monitoring():
    """Setup comprehensive API monitoring"""
    
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler('api_integration.log'),
            logging.StreamHandler()
        ]
    )
    
    # Track API usage quotas
    quota_tracker = {
        'google_ads': {'daily_limit': 15000, 'current_usage': 0},
        'youtube': {'daily_limit': 10000, 'current_usage': 0},
        'meta': {'hourly_limit': 600, 'current_usage': 0},
        'tiktok': {'daily_limit': 1000000, 'current_usage': 0}
    }
    
    return quota_tracker

# Health check endpoint
@app.route('/health')
def health_check():
    """API health status endpoint"""
    status = {
        'timestamp': datetime.utcnow().isoformat(),
        'apis': {}
    }
    
    # Test each API connection
    apis = ['google_ads', 'youtube', 'meta', 'tiktok', 'business_profile']
    
    for api_name in apis:
        try:
            # Perform lightweight API call
            status['apis'][api_name] = 'healthy'
        except Exception as e:
            status['apis'][api_name] = f'error: {str(e)}'
    
    return jsonify(status)
```

### Security Best Practices
1. **Token Storage**: Use secure credential storage (e.g., Google Secret Manager)
2. **API Keys**: Never commit credentials to version control
3. **Rate Limiting**: Implement client-side rate limiting
4. **Error Logging**: Sanitize logs to avoid credential exposure
5. **Access Control**: Use least privilege principle for API permissions

### Total Cost Estimate
- **Development**: $15,000 - $25,000 (120-200 hours @ $125/hr)
- **Monthly API Costs**: $0-$50 (most APIs free up to generous limits)
- **Ad Spend**: Variable based on client campaigns
- **Maintenance**: $2,000-$3,000/month (monitoring, updates, support)

### Success Metrics
- **API Response Times**: <2 seconds average
- **Error Rate**: <1% of requests  
- **Uptime**: 99.9% availability
- **Data Accuracy**: 100% API response validation
- **Campaign Performance**: 20%+ improvement in cross-platform efficiency

---

*This guide reflects current API capabilities as of February 2026. Always verify with official documentation before implementation as APIs frequently update.*