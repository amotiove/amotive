# Premium Deployment Playbook — amotive.io Reference

> Full-service client deployment: domain → site → email → automation → legal.
> Estimated time: 2–4 hours for experienced operator.

---

## Prerequisites

| Tool | Purpose |
|------|---------|
| Porkbun account + API keys | Domain registration & DNS |
| GitHub account + token | Repo creation & Pages hosting |
| Google Workspace admin | Business email setup |
| Google Cloud project | OAuth + API access |
| `yq`, `jq`, `curl`, `gh` CLI | Automation |

Credentials expected at:
- `.secrets/porkbun.yaml` — `apiKey`, `secretApiKey`
- `.secrets/github.yaml` — `token`, `org`
- `.secrets/google-credentials-desktop.json` — OAuth client

---

## Phase 1: Domain + DNS (Porkbun) — ~15 min

### 1.1 Register Domain
```bash
# Check availability
curl -s -X POST https://porkbun.com/api/json/v3/pricing/get \
  -d '{"apikey":"KEY","secretapikey":"SECRET"}'

# Register (if not already owned)
curl -s -X POST https://porkbun.com/api/json/v3/domain/register \
  -d '{"apikey":"KEY","secretapikey":"SECRET","domain":"client.com","years":1}'
```

### 1.2 Configure DNS Records

| Type | Host | Value | TTL |
|------|------|-------|-----|
| A | @ | 185.199.108.153 | 600 |
| A | @ | 185.199.109.153 | 600 |
| A | @ | 185.199.110.153 | 600 |
| A | @ | 185.199.111.153 | 600 |
| CNAME | www | `<user>.github.io` | 600 |
| TXT | @ | `google-site-verification=...` | 600 |
| MX | @ | (see Phase 3) | 600 |

```bash
# Example: Add A record
curl -s -X POST https://porkbun.com/api/json/v3/dns/create/client.com \
  -d '{"apikey":"KEY","secretapikey":"SECRET","type":"A","content":"185.199.108.153","ttl":"600"}'
```

Repeat for all 4 GitHub Pages IPs.

### 1.3 Verify DNS Propagation
```bash
dig +short client.com A
dig +short www.client.com CNAME
# Expect 4 IPs and the github.io CNAME
```

---

## Phase 2: GitHub Repo + Pages — ~30 min

### 2.1 Create Repository
```bash
gh repo create org/client-site --public --clone
cd client-site
```

### 2.2 Site Structure
```
client-site/
├── index.html          # Landing page
├── CNAME               # Custom domain
├── .nojekyll           # Bypass Jekyll
├── css/
│   └── style.css       # Shared design system
├── website/
│   └── index.html      # Main website page
├── marketing/
│   └── index.html      # Marketing services
├── premium/
│   └── index.html      # Premium tier
├── privacy/
│   └── index.html      # Privacy policy
└── terms/
    └── index.html      # Terms of service
```

### 2.3 CNAME File
```
client.com
```

### 2.4 .nojekyll
```bash
touch .nojekyll
```

### 2.5 Enable GitHub Pages
```bash
gh api repos/org/client-site/pages -X POST \
  -f source='{"branch":"main","path":"/"}'
```

### 2.6 Push & Verify
```bash
git add -A && git commit -m "Initial site" && git push
# Wait 2-5 min, then check https://client.com
```

### 2.7 Enforce HTTPS
Settings → Pages → Enforce HTTPS ✓ (auto after DNS propagates)

---

## Phase 3: Google Workspace — ~30 min

### 3.1 Create Workspace Account
1. Go to [workspace.google.com](https://workspace.google.com)
2. Sign up with `client.com`
3. Create admin account (e.g., `admin@client.com`)

### 3.2 Domain Verification
1. Google provides a TXT record: `google-site-verification=XXXX`
2. Add to Porkbun DNS (already done in Phase 1)
3. Click Verify in Google Admin

### 3.3 MX Records (Porkbun)

| Priority | Host | Value |
|----------|------|-------|
| 1 | @ | ASPMX.L.GOOGLE.COM |
| 5 | @ | ALT1.ASPMX.L.GOOGLE.COM |
| 5 | @ | ALT2.ASPMX.L.GOOGLE.COM |
| 10 | @ | ALT3.ASPMX.L.GOOGLE.COM |
| 10 | @ | ALT4.ASPMX.L.GOOGLE.COM |

### 3.4 DKIM Setup
1. Google Admin → Apps → Google Workspace → Gmail → Authenticate email
2. Generate DKIM key
3. Add CNAME record at Porkbun: `google._domainkey` → value from Google
4. Start authentication in Google Admin

### 3.5 Verify Email
```bash
# Send test email, check headers for DKIM pass
echo "Test" | mail -s "DKIM Test" test@gmail.com
```

---

## Phase 4: Google OAuth + API — ~30 min

### 4.1 Create Cloud Project
1. [console.cloud.google.com](https://console.cloud.google.com) → New Project
2. Name: `client-automation`

### 4.2 Enable APIs
- Gmail API
- Google Calendar API
- Google Forms API

### 4.3 Create OAuth Client
1. APIs & Services → Credentials → Create Credentials → OAuth client ID
2. Application type: **Desktop app**
3. Download JSON → `.secrets/google-credentials-desktop.json`

### 4.4 Configure Consent Screen
- User type: Internal (if Workspace) or External
- App name, support email, scopes (Gmail, Calendar, Forms)

### 4.5 Manual Token Exchange

```bash
CLIENT_ID=$(jq -r '.installed.client_id' .secrets/google-credentials-desktop.json)
CLIENT_SECRET=$(jq -r '.installed.client_secret' .secrets/google-credentials-desktop.json)

# Step 1: Get auth code (open in browser)
echo "https://accounts.google.com/o/oauth2/v2/auth?client_id=${CLIENT_ID}&redirect_uri=urn:ietf:wg:oauth:2.0:oob&response_type=code&scope=https://www.googleapis.com/auth/gmail.send+https://www.googleapis.com/auth/calendar+https://www.googleapis.com/auth/forms&access_type=offline&prompt=consent"

# Step 2: Exchange code for tokens
AUTH_CODE="paste-code-here"
curl -s -X POST https://oauth2.googleapis.com/token \
  -d "code=${AUTH_CODE}&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&redirect_uri=urn:ietf:wg:oauth:2.0:oob&grant_type=authorization_code" \
  | jq . > .secrets/google-tokens.json
```

### 4.6 Auto-Refresh Cron (Every 30 min)

```bash
# Add to crontab
*/30 * * * * /path/to/refresh-token.sh

# refresh-token.sh:
#!/bin/bash
CLIENT_ID=$(jq -r '.installed.client_id' /path/.secrets/google-credentials-desktop.json)
CLIENT_SECRET=$(jq -r '.installed.client_secret' /path/.secrets/google-credentials-desktop.json)
REFRESH_TOKEN=$(jq -r '.refresh_token' /path/.secrets/google-tokens.json)

RESPONSE=$(curl -s -X POST https://oauth2.googleapis.com/token \
  -d "client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&refresh_token=${REFRESH_TOKEN}&grant_type=refresh_token")

echo "$RESPONSE" | jq --arg rt "$REFRESH_TOKEN" '. + {refresh_token: $rt}' > /path/.secrets/google-tokens.json
```

---

## Phase 5: Google Forms (Lead Capture) — ~20 min

### 5.1 Create Form
1. Go to [forms.google.com](https://forms.google.com)
2. Create form with fields: Name, Email, Phone, Message, Service Interest
3. Set up email notifications for responses

### 5.2 Get Embed URL
- Form URL: `https://docs.google.com/forms/d/e/FORM_ID/viewform`
- Embed: `https://docs.google.com/forms/d/e/FORM_ID/viewform?embedded=true`

### 5.3 Embed in Site Pages
```html
<iframe
  src="https://docs.google.com/forms/d/e/FORM_ID/viewform?embedded=true"
  width="100%"
  height="800"
  frameborder="0"
  marginheight="0"
  marginwidth="0"
  style="border-radius: 12px;"
>Loading…</iframe>
```

Add to: `index.html`, `website/index.html`, `marketing/index.html`, `premium/index.html`

### 5.4 Response Spreadsheet
- Form → Responses → Link to Sheets
- Share sheet with client admin

---

## Phase 6: Legal Pages — ~15 min

### 6.1 Generate Pages
```bash
./legal-generator.sh --domain client.com --business "Business Name" --email admin@client.com
```

### 6.2 Output Files
- `privacy/index.html` — Privacy Policy
- `terms/index.html` — Terms of Service

### 6.3 Design
- Match site's CSS design system
- Include effective date
- Link from footer on all pages

---

## Post-Deployment Checklist

- [ ] Domain resolves to site (HTTPS)
- [ ] www redirects properly
- [ ] All pages load without errors
- [ ] Google Workspace email sends/receives
- [ ] DKIM passes (check email headers)
- [ ] OAuth tokens refresh automatically
- [ ] Google Form submissions arrive
- [ ] Form notification emails work
- [ ] Privacy Policy accessible
- [ ] Terms of Service accessible
- [ ] Footer links on all pages
- [ ] Mobile responsive
- [ ] Lighthouse score > 90

---

## Maintenance Schedule

| Task | Frequency |
|------|-----------|
| Token refresh verification | Weekly |
| Form response check | Daily |
| SSL cert renewal | Auto (GitHub) |
| Content updates | As requested |
| Analytics review | Monthly |
| DNS health check | Monthly |
| Dependency updates | Quarterly |
