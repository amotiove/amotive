#!/usr/bin/env bash
###############################################################################
# deploy.sh — Master Client Website Deployment
# Usage: ./deploy.sh --domain example.com --repo client-name [--template service]
#        ./deploy.sh --domain example.com --repo client-name --tunnel --port 3000
#
# Orchestrates: GitHub repo → DNS (Porkbun) → Cloudflare → SSL verify
###############################################################################
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

# Defaults
DOMAIN=""
REPO=""
TEMPLATE="default"
GITHUB_ORG="amotiove"
SITE_DIR=""
ENABLE_TUNNEL=false
TUNNEL_PORT=3000
SKIP_DNS=false
SKIP_CLOUDFLARE=false
SKIP_GITHUB=false
DRY_RUN=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Required:
  --domain DOMAIN       Client domain (e.g., example.com)
  --repo NAME           GitHub repo name (e.g., client-name)

Optional:
  --template NAME       Site template: default, service, landing, ecommerce
  --site-dir PATH       Path to existing website files (skip template)
  --tunnel              Enable Cloudflare Tunnel for API/backend
  --port PORT           Backend port for tunnel (default: 3000)
  --skip-dns            Skip DNS setup (already configured)
  --skip-cloudflare     Skip Cloudflare setup
  --skip-github         Skip GitHub repo creation
  --dry-run             Show what would happen without doing it
  -h, --help            Show this help

Examples:
  ./deploy.sh --domain atrades.io --repo atrades --template service
  ./deploy.sh --domain client.com --repo client --site-dir ./builds/client --tunnel --port 8080
EOF
    exit 0
}

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --domain)    DOMAIN="$2"; shift 2 ;;
        --repo)      REPO="$2"; shift 2 ;;
        --template)  TEMPLATE="$2"; shift 2 ;;
        --site-dir)  SITE_DIR="$2"; shift 2 ;;
        --tunnel)    ENABLE_TUNNEL=true; shift ;;
        --port)      TUNNEL_PORT="$2"; shift 2 ;;
        --skip-dns)  SKIP_DNS=true; shift ;;
        --skip-cloudflare) SKIP_CLOUDFLARE=true; shift ;;
        --skip-github)     SKIP_GITHUB=true; shift ;;
        --dry-run)   DRY_RUN=true; shift ;;
        -h|--help)   usage ;;
        *) die "Unknown option: $1" ;;
    esac
done

[[ -z "$DOMAIN" ]] && die "Missing --domain"
[[ -z "$REPO" ]] && die "Missing --repo"

# Load credentials
load_secrets

banner "Deploying ${DOMAIN} → ${GITHUB_ORG}/${REPO}"

# Track timing
START_TIME=$(date +%s)

###############################################################################
# Phase 1: GitHub Repository
###############################################################################
if [[ "$SKIP_GITHUB" == false ]]; then
    section "Phase 1: GitHub Repository"

    WORK_DIR=$(mktemp -d)
    trap "rm -rf ${WORK_DIR}" EXIT

    # Create repo
    info "Creating repo ${GITHUB_ORG}/${REPO}..."
    if [[ "$DRY_RUN" == false ]]; then
        gh repo create "${GITHUB_ORG}/${REPO}" --public --clone \
            --description "Website for ${DOMAIN} — Built by Amotive" \
            2>/dev/null && info "Repo created" || warn "Repo may already exist"

        cd "${WORK_DIR}"
        git clone "https://github.com/${GITHUB_ORG}/${REPO}.git" site 2>/dev/null || true
        cd site

        # Populate with template or provided site
        if [[ -n "$SITE_DIR" && -d "$SITE_DIR" ]]; then
            info "Copying site files from ${SITE_DIR}..."
            cp -r "${SITE_DIR}"/* . 2>/dev/null || true
            cp -r "${SITE_DIR}"/.* . 2>/dev/null || true
        elif [[ -d "${SCRIPT_DIR}/templates/${TEMPLATE}" ]]; then
            info "Using template: ${TEMPLATE}"
            cp -r "${SCRIPT_DIR}/templates/${TEMPLATE}"/* . 2>/dev/null || true
        fi

        # Essential files for GitHub Pages
        touch .nojekyll
        echo "${DOMAIN}" > CNAME

        # Commit and push
        git add -A
        git commit -m "Initial deploy for ${DOMAIN}" 2>/dev/null || true
        git push origin main 2>/dev/null || git push origin master 2>/dev/null || true

        # Enable GitHub Pages
        info "Enabling GitHub Pages..."
        GITHUB_TOKEN="${AMOTIOVE_GITHUB_TOKEN}" gh api \
            --method POST \
            -H "Accept: application/vnd.github+json" \
            "/repos/${GITHUB_ORG}/${REPO}/pages" \
            -f "source[branch]=main" -f "source[path]=/" 2>/dev/null \
            || warn "Pages may already be enabled"

        ok "GitHub repo ready"
    else
        info "[DRY RUN] Would create ${GITHUB_ORG}/${REPO} and push site files"
    fi
else
    info "Skipping GitHub setup"
fi

###############################################################################
# Phase 2: DNS Setup (Porkbun)
###############################################################################
if [[ "$SKIP_DNS" == false ]]; then
    section "Phase 2: DNS Configuration"
    if [[ "$DRY_RUN" == false ]]; then
        bash "${SCRIPT_DIR}/dns-setup.sh" --domain "${DOMAIN}"
    else
        info "[DRY RUN] Would configure DNS for ${DOMAIN}"
    fi
else
    info "Skipping DNS setup"
fi

###############################################################################
# Phase 3: Cloudflare Setup
###############################################################################
if [[ "$SKIP_CLOUDFLARE" == false ]]; then
    section "Phase 3: Cloudflare CDN"
    CF_ARGS="--domain ${DOMAIN}"
    if [[ "$ENABLE_TUNNEL" == true ]]; then
        CF_ARGS="${CF_ARGS} --tunnel --port ${TUNNEL_PORT}"
    fi
    if [[ "$DRY_RUN" == false ]]; then
        bash "${SCRIPT_DIR}/cloudflare-setup.sh" ${CF_ARGS}
    else
        info "[DRY RUN] Would configure Cloudflare for ${DOMAIN}"
    fi
else
    info "Skipping Cloudflare setup"
fi

###############################################################################
# Phase 4: Verification
###############################################################################
section "Phase 4: Verification"
if [[ "$DRY_RUN" == false ]]; then
    info "Waiting 30s for DNS propagation..."
    sleep 30
    bash "${SCRIPT_DIR}/verify.sh" --domain "${DOMAIN}" || warn "Some checks failed — may need more propagation time"
else
    info "[DRY RUN] Would verify ${DOMAIN}"
fi

###############################################################################
# Summary
###############################################################################
END_TIME=$(date +%s)
ELAPSED=$(( END_TIME - START_TIME ))

banner "Deployment Complete"
cat <<EOF
  Domain:     ${DOMAIN}
  Repo:       https://github.com/${GITHUB_ORG}/${REPO}
  Site:       https://${DOMAIN}
  Tunnel:     $(if $ENABLE_TUNNEL; then echo "api.${DOMAIN} → localhost:${TUNNEL_PORT}"; else echo "None"; fi)
  Time:       ${ELAPSED}s
  
  Next steps:
    1. Update nameservers to Cloudflare (shown in cloudflare-setup output)
    2. Wait for DNS propagation (up to 48h, usually <1h)
    3. Run ./verify.sh --domain ${DOMAIN} to confirm everything
EOF
