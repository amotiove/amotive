#!/usr/bin/env bash
###############################################################################
# teardown.sh — Client offboarding / cleanup
# Usage: ./teardown.sh --domain example.com --repo client-name [--confirm]
###############################################################################
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

DOMAIN=""
REPO=""
GITHUB_ORG="amotiove"
CONFIRMED=false
KEEP_REPO=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --domain)    DOMAIN="$2"; shift 2 ;;
        --repo)      REPO="$2"; shift 2 ;;
        --confirm)   CONFIRMED=true; shift ;;
        --keep-repo) KEEP_REPO=true; shift ;;
        *) die "Unknown: $1" ;;
    esac
done

[[ -z "$DOMAIN" ]] && die "Missing --domain"
[[ -z "$REPO" ]] && die "Missing --repo"

load_secrets

banner "⚠️  Teardown: ${DOMAIN}"
echo -e "${RED}${BOLD}This will:${NC}"
echo "  1. Delete DNS records at Porkbun"
echo "  2. Remove Cloudflare zone"
echo "  3. Remove Cloudflare tunnel + systemd service"
[[ "$KEEP_REPO" == false ]] && echo "  4. Archive GitHub repo" || echo "  4. Keep GitHub repo (--keep-repo)"
echo ""

if [[ "$CONFIRMED" == false ]]; then
    read -p "Type '${DOMAIN}' to confirm: " input
    [[ "$input" != "$DOMAIN" ]] && die "Aborted"
fi

# 1. DNS cleanup
section "Removing DNS Records"
if [[ -n "${PORKBUN_API_KEY:-}" ]]; then
    RECORDS=$(porkbun_api "/dns/retrieve/${DOMAIN}" "{
        \"apikey\": \"${PORKBUN_API_KEY}\",
        \"secretapikey\": \"${PORKBUN_SECRET_KEY}\"
    }")
    echo "$RECORDS" | jq -r '.records[]?.id // empty' 2>/dev/null | while read -r id; do
        porkbun_api "/dns/delete/${DOMAIN}/${id}" "{
            \"apikey\": \"${PORKBUN_API_KEY}\",
            \"secretapikey\": \"${PORKBUN_SECRET_KEY}\"
        }" > /dev/null
        info "Deleted record ${id}"
    done
    ok "DNS records removed"
fi

# 2. Cloudflare zone
section "Removing Cloudflare Zone"
if [[ -n "${CF_API_TOKEN:-}" ]]; then
    ZONE_ID=$(curl -s "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}" \
        -H "Authorization: Bearer ${CF_API_TOKEN}" | jq -r '.result[0].id // empty')
    if [[ -n "$ZONE_ID" ]]; then
        curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}" \
            -H "Authorization: Bearer ${CF_API_TOKEN}" > /dev/null
        ok "Zone deleted"
    fi
fi

# 3. Tunnel cleanup
section "Removing Tunnel"
TUNNEL_NAME="${DOMAIN%%.*}-tunnel"
if command -v cloudflared &>/dev/null; then
    sudo systemctl stop "cloudflared-${TUNNEL_NAME}" 2>/dev/null || true
    sudo systemctl disable "cloudflared-${TUNNEL_NAME}" 2>/dev/null || true
    sudo rm -f "/etc/systemd/system/cloudflared-${TUNNEL_NAME}.service"
    sudo systemctl daemon-reload 2>/dev/null
    cloudflared tunnel delete "${TUNNEL_NAME}" 2>/dev/null || true
    rm -f "${HOME}/.cloudflared/${TUNNEL_NAME}.yml"
    ok "Tunnel removed"
fi

# 4. GitHub repo
section "GitHub Repository"
if [[ "$KEEP_REPO" == false ]]; then
    info "Archiving ${GITHUB_ORG}/${REPO}..."
    gh repo archive "${GITHUB_ORG}/${REPO}" --yes 2>/dev/null || warn "Could not archive repo"
    ok "Repo archived (not deleted — delete manually if needed)"
else
    info "Keeping repo as requested"
fi

banner "Teardown Complete"
echo "  Domain ${DOMAIN} has been decommissioned."
echo "  Note: Domain registration remains active until expiry."
