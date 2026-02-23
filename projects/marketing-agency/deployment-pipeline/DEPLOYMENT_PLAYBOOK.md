# Amotive — Client Website Deployment Playbook

## Quick Start

```bash
# Full deployment
./deploy.sh --domain clientdomain.com --repo client-name --template service

# With API backend tunnel
./deploy.sh --domain clientdomain.com --repo client-name --tunnel --port 3000

# Verify deployment
./verify.sh --domain clientdomain.com

# Offboard client
./teardown.sh --domain clientdomain.com --repo client-name
```

---

## Architecture Overview

```
Client Browser → Cloudflare CDN (proxy/SSL) → GitHub Pages (static site)
                                             → Cloudflare Tunnel → localhost (API/backend)
```

**Stack:** GitHub Pages (hosting) + Porkbun (domains) + Cloudflare (CDN/SSL/tunnels)

---

## Phase-by-Phase Manual Guide

### Phase 1: Domain Registration (~5 min)

**Where:** [Porkbun](https://porkbun.com) (can't automate purchase via API)

1. Search and register domain
2. Cost: $10-28/yr depending on TLD
3. Keep default Porkbun nameservers initially (we'll change to Cloudflare later)

**API can handle:** DNS record management, but NOT domain purchase.

### Phase 2: GitHub Repository (~5 min)

```bash
# Create repo under amotiove org
gh repo create amotiove/client-name --public --description "Website for client.com"

# Clone, add files, push
git clone https://github.com/amotiove/client-name
cd client-name
# ... add website files ...
touch .nojekyll          # Prevent Jekyll processing
echo "client.com" > CNAME # Custom domain
git add -A && git commit -m "Initial deploy" && git push

# Enable GitHub Pages via API
gh api --method POST /repos/amotiove/client-name/pages \
  -f source[branch]=main -f source[path]=/
```

### Phase 3: DNS Configuration (~5 min)

Run: `./dns-setup.sh --domain client.com`

**Manual equivalent (Porkbun API):**

| Type  | Name | Content |
|-------|------|---------|
| A     | @    | 185.199.108.153 |
| A     | @    | 185.199.109.153 |
| A     | @    | 185.199.110.153 |
| A     | @    | 185.199.111.153 |
| CNAME | www  | amotiove.github.io |
| TXT   | _github-pages-challenge-amotiove | (verification code) |

### Phase 4: Cloudflare Setup (~10 min)

Run: `./cloudflare-setup.sh --domain client.com`

**Manual steps:**
1. Add site at dash.cloudflare.com (Free plan)
2. Import/add DNS records (same as above, enable orange cloud/proxy)
3. Get assigned nameservers → update at Porkbun
4. SSL/TLS → Full mode
5. Enable "Always Use HTTPS"

**For API/backend tunnels:**
```bash
cloudflared tunnel create client-tunnel
# Configure ~/.cloudflared/client-tunnel.yml
cloudflared tunnel route dns client-tunnel api.client.com
# Create systemd service for persistence
```

### Phase 5: Verification (~5 min + propagation)

Run: `./verify.sh --domain client.com --verbose`

**Checks:** DNS resolution, HTTPS response, SSL cert, www redirect, server headers.

**DNS propagation:** Usually <1 hour, can take up to 48h for nameserver changes.

---

## Costs

| Item | Cost | Frequency |
|------|------|-----------|
| Domain (.com) | ~$10/yr | Annual |
| Domain (.io) | ~$28/yr | Annual |
| GitHub Pages | Free | - |
| Cloudflare Free | Free | - |
| Cloudflare Tunnel | Free | - |
| **Total per client** | **$10-28/yr** | - |

---

## Timing

| Phase | Automated | Manual |
|-------|-----------|--------|
| Domain purchase | N/A (manual) | 5 min |
| GitHub + DNS + Cloudflare | ~2 min | 30 min |
| DNS propagation | 5 min–48h | Same |
| **Total** | **~10 min** | **~45 min** |

---

## Troubleshooting

### DNS not resolving
- Check nameservers: `dig NS domain.com`
- If still Porkbun's → haven't switched to Cloudflare yet
- Flush local DNS: `sudo systemd-resolve --flush-caches`
- Wait — nameserver changes can take 24-48h

### HTTPS not working / certificate error
- Cloudflare SSL must be "Full" (not "Flexible")
- GitHub Pages needs CNAME file in repo
- Wait for Cloudflare to issue edge certificate (~15 min)

### 404 on GitHub Pages
- Check `.nojekyll` exists in repo root
- Check CNAME file contains the correct domain
- Verify Pages is enabled: repo Settings → Pages
- Check branch: must be `main` (not `master`)

### Tunnel not connecting
- Check service: `systemctl status cloudflared-{name}`
- Check config: `~/.cloudflared/{name}.yml`
- Check credentials: `~/.cloudflared/{tunnel-id}.json`
- Test manually: `cloudflared tunnel --config {config} run {name}`

### "Too many redirects"
- Cloudflare SSL mode must be "Full", not "Flexible"
- Check for redirect loops in Cloudflare Page Rules

---

## File Structure

```
deployment-pipeline/
├── deploy.sh              # Master orchestrator
├── dns-setup.sh           # Porkbun DNS configuration
├── cloudflare-setup.sh    # Cloudflare CDN + tunnels
├── verify.sh              # Post-deploy verification
├── teardown.sh            # Client offboarding
├── lib/
│   └── common.sh          # Shared functions & secret loading
├── templates/             # Website templates
│   └── default/
├── configs/               # Generated configs
├── DEPLOYMENT_PLAYBOOK.md # This file
└── CLIENT_TEMPLATE.md     # Onboarding checklist
```
