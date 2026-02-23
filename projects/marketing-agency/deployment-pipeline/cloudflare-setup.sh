#!/usr/bin/env bash
###############################################################################
# cloudflare-setup.sh — Cloudflare CDN + optional Tunnel setup
# Usage: ./cloudflare-setup.sh --domain example.com [--tunnel --port 3000]
#
# Requires: cloudflare API token in ~/.secrets/cloudflare.yaml
#           cloudflared CLI (for tunnels)
###############################################################################
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

DOMAIN=""
ENABLE_TUNNEL=false
TUNNEL_PORT=3000
TUNNEL_SUBDOMAIN="api"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --domain)    DOMAIN="$2"; shift 2 ;;
        --tunnel)    ENABLE_TUNNEL=true; shift ;;
        --port)      TUNNEL_PORT="$2"; shift 2 ;;
        --subdomain) TUNNEL_SUBDOMAIN="$2"; shift 2 ;;
        *) die "Unknown: $1" ;;
    esac
done

[[ -z "$DOMAIN" ]] && die "Missing --domain"
load_secrets

banner "Cloudflare Setup: ${DOMAIN}"

###############################################################################
# Zone Setup (via API if token available)
###############################################################################
if [[ -n "${CF_API_TOKEN:-}" ]]; then
    require_cmd curl jq

    section "Adding Zone to Cloudflare"
    ZONE_RESULT=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones" \
        -H "Authorization: Bearer ${CF_API_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"${DOMAIN}\",\"account\":{\"id\":\"${CF_ACCOUNT_ID}\"},\"type\":\"full\"}")

    if echo "$ZONE_RESULT" | jq -r '.success' | grep -q 'true'; then
        ZONE_ID=$(echo "$ZONE_RESULT" | jq -r '.result.id')
        ok "Zone created: ${ZONE_ID}"

        # Get nameservers
        NS=$(echo "$ZONE_RESULT" | jq -r '.result.name_servers[]')
        echo -e "\n${BOLD}Update nameservers at your registrar to:${NC}"
        echo "$NS" | while read -r ns; do echo "  → $ns"; done

    else
        # Zone might exist already
        warn "Zone creation response: $(echo "$ZONE_RESULT" | jq -r '.errors[0].message // "unknown"')"
        info "Attempting to find existing zone..."
        ZONE_ID=$(curl -s "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}" \
            -H "Authorization: Bearer ${CF_API_TOKEN}" | jq -r '.result[0].id // empty')
        [[ -n "$ZONE_ID" ]] && ok "Found zone: ${ZONE_ID}" || die "Cannot find or create zone"
    fi

    # Import DNS records (GitHub Pages A records + CNAME)
    section "Configuring DNS Records"
    GITHUB_IPS=("185.199.108.153" "185.199.109.153" "185.199.110.153" "185.199.111.153")

    for ip in "${GITHUB_IPS[@]}"; do
        curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
            -H "Authorization: Bearer ${CF_API_TOKEN}" \
            -H "Content-Type: application/json" \
            -d "{\"type\":\"A\",\"name\":\"@\",\"content\":\"${ip}\",\"proxied\":true,\"ttl\":1}" > /dev/null
        info "A @ → ${ip} (proxied)"
    done

    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
        -H "Authorization: Bearer ${CF_API_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "{\"type\":\"CNAME\",\"name\":\"www\",\"content\":\"amotiove.github.io\",\"proxied\":true,\"ttl\":1}" > /dev/null
    info "CNAME www → amotiove.github.io (proxied)"

    # SSL settings
    section "SSL Configuration"
    curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/settings/ssl" \
        -H "Authorization: Bearer ${CF_API_TOKEN}" \
        -H "Content-Type: application/json" \
        -d '{"value":"full"}' > /dev/null
    ok "SSL mode: Full"

    # Always HTTPS
    curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/settings/always_use_https" \
        -H "Authorization: Bearer ${CF_API_TOKEN}" \
        -H "Content-Type: application/json" \
        -d '{"value":"on"}' > /dev/null
    ok "Always HTTPS: On"

    # Auto minify
    curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/settings/minify" \
        -H "Authorization: Bearer ${CF_API_TOKEN}" \
        -H "Content-Type: application/json" \
        -d '{"value":{"js":"on","css":"on","html":"on"}}' > /dev/null
    ok "Auto Minify: On"

else
    warn "No Cloudflare API token found. Manual setup required:"
    cat <<EOF
    1. Go to https://dash.cloudflare.com
    2. Add site: ${DOMAIN} (Free plan)
    3. Import DNS records or add manually:
       - 4x A records → 185.199.108-111.153 (Proxied)
       - CNAME www → amotiove.github.io (Proxied)
    4. Update nameservers at Porkbun to Cloudflare's
    5. SSL/TLS → Full
    6. Enable "Always Use HTTPS"
EOF
fi

###############################################################################
# Cloudflare Tunnel (optional)
###############################################################################
if [[ "$ENABLE_TUNNEL" == true ]]; then
    section "Cloudflare Tunnel"
    require_cmd cloudflared

    TUNNEL_NAME="${DOMAIN%%.*}-tunnel"
    TUNNEL_HOSTNAME="${TUNNEL_SUBDOMAIN}.${DOMAIN}"

    info "Creating tunnel: ${TUNNEL_NAME}"
    TUNNEL_OUTPUT=$(cloudflared tunnel create "${TUNNEL_NAME}" 2>&1) || true
    TUNNEL_ID=$(echo "$TUNNEL_OUTPUT" | grep -oP '[a-f0-9-]{36}' | head -1)

    if [[ -z "$TUNNEL_ID" ]]; then
        # Tunnel might exist, try to get ID
        TUNNEL_ID=$(cloudflared tunnel list | grep "${TUNNEL_NAME}" | awk '{print $1}')
    fi

    [[ -z "$TUNNEL_ID" ]] && die "Failed to create or find tunnel"
    ok "Tunnel ID: ${TUNNEL_ID}"

    # Write tunnel config
    TUNNEL_CONFIG="${HOME}/.cloudflared/${TUNNEL_NAME}.yml"
    cat > "${TUNNEL_CONFIG}" <<YAML
tunnel: ${TUNNEL_ID}
credentials-file: ${HOME}/.cloudflared/${TUNNEL_ID}.json

ingress:
  - hostname: ${TUNNEL_HOSTNAME}
    service: http://localhost:${TUNNEL_PORT}
  - service: http_status:404
YAML
    ok "Config written: ${TUNNEL_CONFIG}"

    # Route DNS
    info "Routing DNS: ${TUNNEL_HOSTNAME} → tunnel"
    cloudflared tunnel route dns "${TUNNEL_NAME}" "${TUNNEL_HOSTNAME}" 2>/dev/null || true

    # Create systemd service
    SERVICE_FILE="/etc/systemd/system/cloudflared-${TUNNEL_NAME}.service"
    info "Creating systemd service..."
    sudo tee "${SERVICE_FILE}" > /dev/null <<SERVICE
[Unit]
Description=Cloudflare Tunnel for ${DOMAIN}
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$(whoami)
ExecStart=/usr/local/bin/cloudflared tunnel --config ${TUNNEL_CONFIG} run ${TUNNEL_NAME}
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

    sudo systemctl daemon-reload
    sudo systemctl enable "cloudflared-${TUNNEL_NAME}" 2>/dev/null
    sudo systemctl start "cloudflared-${TUNNEL_NAME}" 2>/dev/null
    ok "Tunnel service started: cloudflared-${TUNNEL_NAME}"

    echo -e "\n  API endpoint: https://${TUNNEL_HOSTNAME} → localhost:${TUNNEL_PORT}"
fi

ok "Cloudflare setup complete for ${DOMAIN}"
