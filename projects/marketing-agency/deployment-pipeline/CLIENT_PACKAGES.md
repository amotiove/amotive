# Client Service Packages

---

## 🥉 Basic — $1,500 (one-time)

**Perfect for:** Startups and small businesses needing a professional web presence.

### What's Included
- **Single-page responsive website** — custom design, mobile-optimized
- **Domain registration** — 1 year included
- **DNS configuration** — A records, CNAME, SSL via GitHub Pages
- **Hosting** — GitHub Pages (free, reliable, global CDN)
- **SSL certificate** — automatic HTTPS enforcement
- **Legal pages** — Privacy Policy + Terms of Service
- **Basic SEO** — meta tags, Open Graph, sitemap

### Deliverables
- Live website at `client.com`
- Source code in client's GitHub repo
- DNS fully configured
- Legal compliance pages

### Timeline
- 1–2 business days

### What's NOT Included
- Multi-page site, contact forms, email setup
- Ongoing maintenance or updates
- Analytics, monitoring

---

## 🥈 Standard — $2,500 setup + $200/month

**Perfect for:** Growing businesses that need lead capture and ongoing support.

### What's Included (everything in Basic, plus)
- **Multi-page website** — Home, Services, About, Contact (up to 6 pages)
- **Google Forms lead capture** — embedded on all relevant pages
- **Response notifications** — email alerts on form submissions
- **Google Sheets integration** — responses auto-logged to spreadsheet
- **Legal pages** — Privacy Policy + Terms of Service (matching design)
- **Monthly maintenance** — content updates, bug fixes, uptime monitoring

### Monthly Retainer ($200/mo) Covers
- Up to 4 content updates per month
- Bug fixes and compatibility updates
- Uptime monitoring and incident response
- Monthly performance report
- Priority support (24h response time)

### Deliverables
- Live multi-page website
- Working contact/lead form with notifications
- Response tracking spreadsheet
- Monthly maintenance reports

### Timeline
- 2–3 business days initial setup

---

## 🥇 Premium — $3,500/month (all-inclusive)

**Perfect for:** Businesses wanting a fully managed digital presence with professional email and automation.

### What's Included (everything in Standard, plus)
- **Google Workspace setup** — professional email (`you@client.com`)
- **MX + DKIM + SPF records** — full email authentication
- **Google OAuth integration** — automated API access
- **Token auto-refresh** — cron job, zero-maintenance authentication
- **Gmail API integration** — programmatic email capabilities
- **Google Calendar API** — scheduling automation ready
- **Cloudflare integration** — DDoS protection, CDN, analytics
- **Advanced analytics** — traffic, conversion, form response tracking
- **Priority support** — 4-hour response time, dedicated contact
- **Unlimited content updates**
- **Quarterly strategy review** — performance analysis + recommendations

### Monthly Retainer ($3,500/mo) Covers
- All Standard maintenance items
- Google Workspace administration
- Email deliverability monitoring
- OAuth token management
- Cloudflare configuration and monitoring
- Unlimited content and design updates
- Analytics dashboard and monthly deep-dive report
- Quarterly strategy session (1 hour)

### Deliverables
- Complete digital infrastructure
- Professional email with full authentication
- Automated lead pipeline
- Monthly analytics reports
- Quarterly strategy recommendations

### Timeline
- 3–5 business days initial setup

---

## Package Comparison

| Feature | Basic | Standard | Premium |
|---------|:-----:|:--------:|:-------:|
| **Price** | $1,500 | $2,500 + $200/mo | $3,500/mo |
| Custom domain + SSL | ✓ | ✓ | ✓ |
| Responsive design | ✓ | ✓ | ✓ |
| GitHub Pages hosting | ✓ | ✓ | ✓ |
| Legal pages | ✓ | ✓ | ✓ |
| Multi-page site | — | ✓ (up to 6) | ✓ (unlimited) |
| Lead capture forms | — | ✓ | ✓ |
| Response tracking | — | ✓ | ✓ |
| Monthly maintenance | — | ✓ | ✓ |
| Google Workspace email | — | — | ✓ |
| Email authentication | — | — | ✓ |
| OAuth + API automation | — | — | ✓ |
| Cloudflare CDN/security | — | — | ✓ |
| Advanced analytics | — | — | ✓ |
| Unlimited updates | — | — | ✓ |
| Strategy reviews | — | — | Quarterly |
| Support response | — | 24h | 4h |

---

## Add-Ons (any tier)

| Add-On | Price |
|--------|-------|
| Additional pages (per page) | $200 |
| Google Workspace setup (Basic/Standard) | $500 |
| Cloudflare setup (Basic/Standard) | $300 |
| Logo/brand design | $500–$1,500 |
| SEO audit + optimization | $750 |
| Custom form/automation | $300–$800 |
| Domain transfer assistance | $100 |
| Emergency support (off-hours) | $150/hr |

---

## Deployment Tools

All packages use our automated pipeline:

```bash
# Basic
./premium-deploy.sh --domain client.com --business "Name" --email admin@client.com --with-legal

# Standard
./premium-deploy.sh --domain client.com --business "Name" --email admin@client.com --with-forms --with-legal

# Premium
./premium-deploy.sh --domain client.com --business "Name" --email admin@client.com --with-forms --with-legal --with-email
```

---

*Prices effective $(date +%Y). All packages include source code ownership. Domains renew annually at registrar cost (~$10–50/yr).*
