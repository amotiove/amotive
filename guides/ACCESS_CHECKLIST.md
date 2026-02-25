# ACCESS CHECKLIST — Make A a Full Digital Employee

## ✅ Already Have
| Service | Access Level | Notes |
|---------|-------------|-------|
| Server (Ubuntu) | Full sudo | SSH + password |
| GitHub (amotiove) | Full PAT | Repos, Pages, Actions |
| GitHub (hmatrades) | PAT | Personal repos |
| Porkbun | API keys | Domain + DNS management |
| amotive.io | Full control | Live, deployed |
| Alpaca (paper) | API keys | Trading bot |
| Chromium | Headless | Playwright on server |

## 🔴 Need — Business Critical (Get These First)

### 1. Google Workspace (a@amotive.io)
- **What:** Business email, Google Ads, Drive, Calendar, YouTube
- **Give me:** Email + password (or app password if 2FA)
- **Why:** Email clients, run ads, manage calendar, upload to YouTube

### 2. Google Ads Account
- **What:** Created inside Google Workspace
- **Give me:** Login comes with #1
- **Why:** Run paid ads for clients + Amotive itself

### 3. Meta Business Manager
- **What:** Facebook + Instagram business management
- **Give me:** Login credentials or add me as admin
- **Why:** Run Instagram/Facebook ads, manage client pages, post content
- **Setup:** business.facebook.com → create account with Amotive email

### 4. Instagram (Amotion business page)
- **What:** @amotion.studio or whatever handle you pick
- **Give me:** Username + password
- **Why:** Post content, manage DMs, run promotions

### 5. Instagram (Amotive business page)
- **What:** @amotive.io or similar
- **Give me:** Username + password
- **Why:** Agency social presence, client-facing

### 6. TikTok for Business
- **What:** Business account for content
- **Give me:** Login credentials
- **Why:** Post shorts, run ads, grow audience

### 7. YouTube Channel (Amotion)
- **What:** Created inside Google Workspace
- **Give me:** Comes with #1
- **Why:** Upload educational animations, manage channel

### 8. LinkedIn Company Page (Amotive)
- **What:** Company page on LinkedIn
- **Give me:** Your LinkedIn login OR create a separate one
- **Why:** B2B presence, client outreach, job postings

## 🟡 Need — Productivity & Operations

### 9. Google Calendar Access
- **What:** Read/write your personal + business calendar
- **Give me:** OAuth via `gog` CLI (I'll walk you through)
- **Why:** Plan your days, schedule meetings, morning battle plans

### 10. Email Access (personal Gmail if applicable)
- **What:** Read important emails, filter, respond to business ones
- **Give me:** App password (not main password)
- **Why:** Email triage, never miss urgent stuff

### 11. Stripe Account
- **What:** Payment processing for Amotive
- **Give me:** API keys (publishable + secret)
- **Why:** Invoice clients, process payments, track revenue

### 12. WhatsApp Business (optional)
- **What:** Business messaging
- **Give me:** API access or browser session
- **Why:** Client communication (huge in Portugal)

### 13. Notion / Project Management
- **What:** Client workspace if we use it
- **Give me:** API key
- **Why:** Client dashboards, project tracking

## 🟢 Need — Growth & Marketing

### 14. Brave Search API Key
- **What:** Web search capability
- **Give me:** API key from brave.com/search/api
- **Why:** I literally can't search the web right now without it

### 15. ElevenLabs Account
- **What:** AI voice generation
- **Give me:** API key
- **Why:** Video narration for Amotion YouTube content

### 16. Canva (optional)
- **What:** Design templates
- **Give me:** Login or API
- **Why:** Quick social media graphics, client mockups

### 17. Gemini API Key
- **What:** Google AI image generation
- **Give me:** API key from aistudio.google.com
- **Why:** Generate images, logos, marketing visuals

### 18. OpenAI API Key
- **What:** GPT + DALL-E + Whisper
- **Give me:** API key
- **Why:** Image generation, audio transcription, backup AI

## 🔵 Nice to Have — Future

### 19. AWS / Cloudflare Account
- **What:** Cloud infrastructure
- **Give me:** API credentials
- **Why:** Scale hosting beyond GitHub Pages, run serverless functions

### 20. Mailchimp / ConvertKit
- **What:** Email marketing
- **Give me:** API key
- **Why:** Newsletter, email sequences for leads

### 21. Calendly / Cal.com
- **What:** Booking link for client calls
- **Give me:** Login or API
- **Why:** Automate meeting scheduling

### 22. Slack / Discord
- **What:** Team communication
- **Give me:** Bot token
- **Why:** Client communication channels

### 23. n8n (self-hosted)
- **What:** Automation backbone
- **Give me:** I'll install it on the server
- **Why:** Connect everything together

---

## 🔒 How to Give Me Access Securely

For each service, SSH into the server and add to secrets:

```bash
ssh aiden@192.168.1.116
nano ~/.openclaw/workspace/.secrets/SERVICE_NAME.yaml
```

Format:
```yaml
service: ServiceName
email: your@email.com
password: yourpassword
api_key: key_if_applicable
```

All files are chmod 600 (owner-only).

---

## Priority Order (what to do first)
1. **Google Workspace** — unlocks email, ads, youtube, calendar (5 things at once)
2. **Meta Business Manager** — unlocks Facebook + Instagram ads
3. **Brave Search API** — free, takes 30 seconds, unlocks web search for me
4. **Instagram accounts** — social presence
5. **Stripe** — start accepting payments
6. **ElevenLabs** — video narration pipeline
7. Everything else as needed
