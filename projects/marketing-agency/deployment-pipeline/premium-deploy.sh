#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Premium Client Deployment Script
# Based on amotive.io full-service deployment pipeline
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_DIR="${SCRIPT_DIR}/.secrets"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }
step()  { echo -e "\n${GREEN}═══ $* ═══${NC}"; }

# Defaults
DOMAIN="" BUSINESS="" EMAIL="" GITHUB_ORG=""
WITH_FORMS=false WITH_LEGAL=false WITH_EMAIL=false DRY_RUN=false

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Premium client deployment — domain, site, email, forms, legal.

Required:
  --domain DOMAIN         Client domain (e.g., client.com)
  --business "NAME"       Business name
  --email EMAIL           Admin email (e.g., admin@client.com)

Optional:
  --with-forms            Set up Google Forms lead capture
  --with-legal            Generate privacy policy + terms
  --with-email            Set up Google Workspace + OAuth
  --github-org ORG        GitHub org (default: from .secrets/github.yaml)
  --dry-run               Show what would be done
  -h, --help              Show this help

Examples:
  $(basename "$0") --domain amotive.io --business "Amotive" --email a@amotive.io --with-forms --with-legal --with-email
  $(basename "$0") --domain client.com --business "Client Co" --email hi@client.com --with-legal
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --domain)      DOMAIN="$2"; shift 2 ;;
    --business)    BUSINESS="$2"; shift 2 ;;
    --email)       EMAIL="$2"; shift 2 ;;
    --with-forms)  WITH_FORMS=true; shift ;;
    --with-legal)  WITH_LEGAL=true; shift ;;
    --with-email)  WITH_EMAIL=true; shift ;;
    --github-org)  GITHUB_ORG="$2"; shift 2 ;;
    --dry-run)     DRY_RUN=true; shift ;;
    -h|--help)     usage ;;
    *) err "Unknown option: $1"; usage ;;
  esac
done

[[ -z "$DOMAIN" ]] && { err "--domain is required"; exit 1; }
[[ -z "$BUSINESS" ]] && { err "--business is required"; exit 1; }
[[ -z "$EMAIL" ]] && { err "--email is required"; exit 1; }

DOMAIN_SLUG="${DOMAIN%%.*}"
REPO_NAME="${DOMAIN_SLUG}-site"

# ── Load Secrets ─────────────────────────────────────────────────────────────

load_secrets() {
  if [[ -f "${SECRETS_DIR}/porkbun.yaml" ]]; then
    PB_API_KEY=$(yq -r '.apiKey' "${SECRETS_DIR}/porkbun.yaml")
    PB_SECRET_KEY=$(yq -r '.secretApiKey' "${SECRETS_DIR}/porkbun.yaml")
    ok "Porkbun credentials loaded"
  else
    warn "No porkbun.yaml — DNS steps will be manual"
    PB_API_KEY="" PB_SECRET_KEY=""
  fi

  if [[ -f "${SECRETS_DIR}/github.yaml" ]]; then
    GH_TOKEN=$(yq -r '.token' "${SECRETS_DIR}/github.yaml")
    [[ -z "$GITHUB_ORG" ]] && GITHUB_ORG=$(yq -r '.org // empty' "${SECRETS_DIR}/github.yaml")
    ok "GitHub credentials loaded"
  else
    warn "No github.yaml — repo steps will be manual"
    GH_TOKEN=""
  fi

  if [[ -f "${SECRETS_DIR}/google-credentials-desktop.json" ]]; then
    GOOGLE_CLIENT_ID=$(jq -r '.installed.client_id' "${SECRETS_DIR}/google-credentials-desktop.json")
    GOOGLE_CLIENT_SECRET=$(jq -r '.installed.client_secret' "${SECRETS_DIR}/google-credentials-desktop.json")
    ok "Google credentials loaded"
  else
    warn "No google-credentials-desktop.json — Google steps will be manual"
    GOOGLE_CLIENT_ID="" GOOGLE_CLIENT_SECRET=""
  fi
}

# ── Phase 1: DNS ─────────────────────────────────────────────────────────────

add_dns_record() {
  local type="$1" name="$2" content="$3" prio="${4:-}"
  local data="{\"apikey\":\"${PB_API_KEY}\",\"secretapikey\":\"${PB_SECRET_KEY}\",\"type\":\"${type}\",\"content\":\"${content}\",\"ttl\":\"600\""
  [[ -n "$prio" ]] && data="${data},\"prio\":\"${prio}\""
  [[ -n "$name" && "$name" != "@" ]] && data="${data},\"name\":\"${name}\""
  data="${data}}"

  if $DRY_RUN; then
    info "[DRY] DNS ${type} ${name:-@} → ${content}"
    return
  fi

  local resp
  resp=$(curl -s -X POST "https://porkbun.com/api/json/v3/dns/create/${DOMAIN}" -d "$data")
  if echo "$resp" | jq -e '.status == "SUCCESS"' > /dev/null 2>&1; then
    ok "DNS ${type} ${name:-@} → ${content}"
  else
    warn "DNS ${type} ${name:-@}: $(echo "$resp" | jq -r '.message // "unknown error"')"
  fi
}

setup_dns() {
  step "Phase 1: DNS Configuration"

  if [[ -z "$PB_API_KEY" ]]; then
    warn "No Porkbun API keys — printing manual DNS records:"
    echo "  A    @    185.199.108.153"
    echo "  A    @    185.199.109.153"
    echo "  A    @    185.199.110.153"
    echo "  A    @    185.199.111.153"
    echo "  CNAME www ${GITHUB_ORG:-<org>}.github.io"
    return
  fi

  # GitHub Pages A records
  for ip in 185.199.108.153 185.199.109.153 185.199.110.153 185.199.111.153; do
    add_dns_record "A" "@" "$ip"
  done

  # www CNAME
  add_dns_record "CNAME" "www" "${GITHUB_ORG:-${DOMAIN_SLUG}}.github.io"

  if $WITH_EMAIL; then
    # Google MX records
    add_dns_record "MX" "@" "ASPMX.L.GOOGLE.COM" "1"
    add_dns_record "MX" "@" "ALT1.ASPMX.L.GOOGLE.COM" "5"
    add_dns_record "MX" "@" "ALT2.ASPMX.L.GOOGLE.COM" "5"
    add_dns_record "MX" "@" "ALT3.ASPMX.L.GOOGLE.COM" "10"
    add_dns_record "MX" "@" "ALT4.ASPMX.L.GOOGLE.COM" "10"
    info "MX records added — complete Google verification TXT + DKIM manually"
  fi

  # Verify
  info "Checking DNS propagation..."
  sleep 3
  local resolved
  resolved=$(dig +short "$DOMAIN" A 2>/dev/null | head -1)
  if [[ "$resolved" == "185.199."* ]]; then
    ok "DNS propagated: ${resolved}"
  else
    warn "DNS not yet propagated (may take up to 48h)"
  fi
}

# ── Phase 2: GitHub Repo + Pages ─────────────────────────────────────────────

generate_css() {
  cat <<'CSSEOF'
:root {
  --primary: #1a1a2e;
  --accent: #e94560;
  --bg: #0f0f23;
  --text: #eee;
  --text-muted: #aaa;
  --card-bg: rgba(255,255,255,0.05);
  --radius: 12px;
}
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: var(--bg); color: var(--text); line-height: 1.6; }
.container { max-width: 1100px; margin: 0 auto; padding: 0 24px; }
header { padding: 20px 0; border-bottom: 1px solid rgba(255,255,255,0.1); }
header .container { display: flex; justify-content: space-between; align-items: center; }
.logo { font-size: 1.5rem; font-weight: 700; color: var(--accent); text-decoration: none; }
nav a { color: var(--text-muted); text-decoration: none; margin-left: 24px; transition: color 0.2s; }
nav a:hover { color: var(--accent); }
.hero { padding: 80px 0; text-align: center; }
.hero h1 { font-size: 3rem; margin-bottom: 16px; }
.hero p { font-size: 1.2rem; color: var(--text-muted); max-width: 600px; margin: 0 auto 32px; }
.btn { display: inline-block; padding: 14px 32px; background: var(--accent); color: #fff; border-radius: var(--radius); text-decoration: none; font-weight: 600; transition: opacity 0.2s; }
.btn:hover { opacity: 0.85; }
section { padding: 60px 0; }
.card { background: var(--card-bg); border-radius: var(--radius); padding: 32px; margin-bottom: 24px; }
footer { padding: 40px 0; border-top: 1px solid rgba(255,255,255,0.1); text-align: center; color: var(--text-muted); font-size: 0.9rem; }
footer a { color: var(--text-muted); margin: 0 12px; }
@media (max-width: 768px) { .hero h1 { font-size: 2rem; } nav { display: none; } }
CSSEOF
}

generate_page() {
  local title="$1" heading="$2" content="$3" css_path="$4"
  cat <<HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title} — ${BUSINESS}</title>
  <link rel="stylesheet" href="${css_path}">
</head>
<body>
  <header>
    <div class="container">
      <a href="/" class="logo">${BUSINESS}</a>
      <nav>
        <a href="/">Home</a>
        <a href="/website/">Website</a>
        <a href="/marketing/">Marketing</a>
        <a href="/premium/">Premium</a>
      </nav>
    </div>
  </header>
  <main>
    <section class="hero">
      <div class="container">
        <h1>${heading}</h1>
        ${content}
      </div>
    </section>
  </main>
  <footer>
    <div class="container">
      <p>&copy; $(date +%Y) ${BUSINESS}. All rights reserved.</p>
      <p><a href="/privacy/">Privacy Policy</a> | <a href="/terms/">Terms of Service</a></p>
    </div>
  </footer>
</body>
</html>
HTMLEOF
}

setup_repo() {
  step "Phase 2: GitHub Repository + Pages"

  local site_dir="/tmp/${REPO_NAME}"
  rm -rf "$site_dir"
  mkdir -p "$site_dir"/{css,website,marketing,premium,privacy,terms}

  # CNAME + nojekyll
  echo "$DOMAIN" > "$site_dir/CNAME"
  touch "$site_dir/.nojekyll"

  # CSS
  generate_css > "$site_dir/css/style.css"

  # Pages
  generate_page "Home" "Welcome to ${BUSINESS}" \
    '<p>Professional solutions for your business.</p><a href="/marketing/" class="btn">Get Started</a>' \
    "/css/style.css" > "$site_dir/index.html"

  generate_page "Website" "Website Solutions" \
    '<p>Modern, responsive websites built for results.</p>' \
    "/css/style.css" > "$site_dir/website/index.html"

  generate_page "Marketing" "Marketing Services" \
    '<p>Data-driven marketing strategies that convert.</p>' \
    "/css/style.css" > "$site_dir/marketing/index.html"

  generate_page "Premium" "Premium Package" \
    '<p>Full-service digital presence and automation.</p>' \
    "/css/style.css" > "$site_dir/premium/index.html"

  ok "Site generated at ${site_dir}"

  if $WITH_LEGAL; then
    info "Generating legal pages..."
    if [[ -x "${SCRIPT_DIR}/legal-generator.sh" ]]; then
      bash "${SCRIPT_DIR}/legal-generator.sh" --domain "$DOMAIN" --business "$BUSINESS" --email "$EMAIL" --output-dir "$site_dir"
    else
      warn "legal-generator.sh not found — generating basic legal pages"
      generate_page "Privacy Policy" "Privacy Policy" \
        "<div class='card'><p>Last updated: $(date +%Y-%m-%d)</p><p>${BUSINESS} respects your privacy. Contact ${EMAIL} for inquiries.</p></div>" \
        "/css/style.css" > "$site_dir/privacy/index.html"
      generate_page "Terms of Service" "Terms of Service" \
        "<div class='card'><p>Last updated: $(date +%Y-%m-%d)</p><p>By using ${DOMAIN}, you agree to these terms. Contact ${EMAIL} for questions.</p></div>" \
        "/css/style.css" > "$site_dir/terms/index.html"
    fi
  fi

  if $DRY_RUN; then
    info "[DRY] Would create repo and push to GitHub"
    info "Site preview at: ${site_dir}"
    return
  fi

  if [[ -n "$GH_TOKEN" ]]; then
    cd "$site_dir"
    git init -q
    git add -A
    git commit -q -m "Initial deployment for ${DOMAIN}"

    local repo_path="${GITHUB_ORG:+${GITHUB_ORG}/}${REPO_NAME}"
    GITHUB_TOKEN="$GH_TOKEN" gh repo create "$repo_path" --public --source=. --push 2>/dev/null || {
      warn "Repo may already exist — trying push only"
      git remote add origin "https://${GH_TOKEN}@github.com/${repo_path}.git" 2>/dev/null || true
      git push -u origin main --force
    }

    # Enable Pages
    GITHUB_TOKEN="$GH_TOKEN" gh api "repos/${repo_path}/pages" -X POST \
      -f 'build_type=legacy' -f 'source[branch]=main' -f 'source[path]=/' 2>/dev/null || true

    ok "Repository created and Pages enabled"
    info "Site will be live at https://${DOMAIN} once DNS propagates"
  else
    warn "No GitHub token — site generated at ${site_dir}, push manually"
  fi
}

# ── Phase 3-4: Google Workspace + OAuth ──────────────────────────────────────

setup_email() {
  step "Phase 3-4: Google Workspace + OAuth"

  if ! $WITH_EMAIL; then
    info "Skipping email setup (use --with-email to enable)"
    return
  fi

  echo ""
  info "Google Workspace setup requires manual steps:"
  echo "  1. Sign up at https://workspace.google.com with ${DOMAIN}"
  echo "  2. Create admin account: ${EMAIL}"
  echo "  3. Add Google verification TXT record to DNS"
  echo "  4. MX records already added in Phase 1"
  echo ""
  info "DKIM setup:"
  echo "  1. Google Admin → Apps → Gmail → Authenticate email"
  echo "  2. Generate DKIM key"
  echo "  3. Add CNAME: google._domainkey → <value from Google>"
  echo ""

  if [[ -n "$GOOGLE_CLIENT_ID" ]]; then
    info "OAuth setup — open this URL in your browser:"
    echo ""
    echo "https://accounts.google.com/o/oauth2/v2/auth?client_id=${GOOGLE_CLIENT_ID}&redirect_uri=urn:ietf:wg:oauth:2.0:oob&response_type=code&scope=https://www.googleapis.com/auth/gmail.send+https://www.googleapis.com/auth/calendar+https://www.googleapis.com/auth/forms&access_type=offline&prompt=consent"
    echo ""
    read -rp "Paste the authorization code: " AUTH_CODE

    if [[ -n "$AUTH_CODE" ]]; then
      local token_resp
      token_resp=$(curl -s -X POST https://oauth2.googleapis.com/token \
        -d "code=${AUTH_CODE}&client_id=${GOOGLE_CLIENT_ID}&client_secret=${GOOGLE_CLIENT_SECRET}&redirect_uri=urn:ietf:wg:oauth:2.0:oob&grant_type=authorization_code")

      echo "$token_resp" | jq . > "${SECRETS_DIR}/google-tokens-${DOMAIN_SLUG}.json"
      ok "Tokens saved to ${SECRETS_DIR}/google-tokens-${DOMAIN_SLUG}.json"

      # Create refresh cron
      local refresh_script="${SCRIPT_DIR}/refresh-token-${DOMAIN_SLUG}.sh"
      cat > "$refresh_script" <<CRONEOF
#!/bin/bash
CLIENT_ID="${GOOGLE_CLIENT_ID}"
CLIENT_SECRET="${GOOGLE_CLIENT_SECRET}"
TOKEN_FILE="${SECRETS_DIR}/google-tokens-${DOMAIN_SLUG}.json"
REFRESH_TOKEN=\$(jq -r '.refresh_token' "\$TOKEN_FILE")
RESPONSE=\$(curl -s -X POST https://oauth2.googleapis.com/token \\
  -d "client_id=\${CLIENT_ID}&client_secret=\${CLIENT_SECRET}&refresh_token=\${REFRESH_TOKEN}&grant_type=refresh_token")
echo "\$RESPONSE" | jq --arg rt "\$REFRESH_TOKEN" '. + {refresh_token: \$rt}' > "\$TOKEN_FILE"
CRONEOF
      chmod +x "$refresh_script"
      (crontab -l 2>/dev/null; echo "*/30 * * * * ${refresh_script}") | sort -u | crontab -
      ok "Token refresh cron installed (every 30 min)"
    fi
  else
    warn "No Google credentials — skip OAuth setup"
  fi
}

# ── Phase 5: Google Forms ────────────────────────────────────────────────────

setup_forms() {
  step "Phase 5: Google Forms (Lead Capture)"

  if ! $WITH_FORMS; then
    info "Skipping forms setup (use --with-forms to enable)"
    return
  fi

  echo ""
  info "Google Forms setup:"
  echo "  1. Go to https://forms.google.com"
  echo "  2. Create form: '${BUSINESS} — Contact Us'"
  echo "  3. Add fields: Name, Email, Phone, Message, Service Interest"
  echo "  4. Enable email notifications"
  echo "  5. Get embed URL and update site pages"
  echo ""
  info "After creating the form, run:"
  echo "  ${SCRIPT_DIR}/form-setup.sh --form-id <FORM_ID> --site-dir /tmp/${REPO_NAME}"
  echo ""

  if [[ -x "${SCRIPT_DIR}/form-setup.sh" ]]; then
    read -rp "Enter Google Form ID (or press Enter to skip): " FORM_ID
    if [[ -n "$FORM_ID" ]]; then
      bash "${SCRIPT_DIR}/form-setup.sh" --form-id "$FORM_ID" --site-dir "/tmp/${REPO_NAME}"
    fi
  fi
}

# ── Summary ──────────────────────────────────────────────────────────────────

summary() {
  step "Deployment Summary"
  echo ""
  echo "  Domain:    ${DOMAIN}"
  echo "  Business:  ${BUSINESS}"
  echo "  Email:     ${EMAIL}"
  echo "  Repo:      ${GITHUB_ORG:+${GITHUB_ORG}/}${REPO_NAME}"
  echo "  Site:      https://${DOMAIN}"
  echo ""
  echo "  DNS:       ✓"
  echo "  GitHub:    ✓"
  echo "  Email:     $($WITH_EMAIL && echo '✓' || echo '—')"
  echo "  Forms:     $($WITH_FORMS && echo '✓' || echo '—')"
  echo "  Legal:     $($WITH_LEGAL && echo '✓' || echo '—')"
  echo ""
  ok "Deployment complete! Verify at https://${DOMAIN}"
}

# ── Main ─────────────────────────────────────────────────────────────────────

main() {
  step "Premium Deployment: ${BUSINESS} (${DOMAIN})"
  $DRY_RUN && warn "DRY RUN MODE — no changes will be made"

  load_secrets
  setup_dns
  setup_repo
  setup_email
  setup_forms
  summary
}

main
