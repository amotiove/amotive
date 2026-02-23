#!/usr/bin/env bash
###############################################################################
# dns-setup.sh — Configure DNS records via Porkbun API
# Usage: ./dns-setup.sh --domain example.com [--verify-code XXXX]
###############################################################################
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

DOMAIN=""
VERIFY_CODE=""
GITHUB_ORG="amotiove"

# GitHub Pages IPs
GITHUB_IPS=("185.199.108.153" "185.199.109.153" "185.199.110.153" "185.199.111.153")

while [[ $# -gt 0 ]]; do
    case "$1" in
        --domain) DOMAIN="$2"; shift 2 ;;
        --verify-code) VERIFY_CODE="$2"; shift 2 ;;
        *) die "Unknown: $1" ;;
    esac
done

[[ -z "$DOMAIN" ]] && die "Missing --domain"
require_cmd curl jq
load_secrets

[[ -z "${PORKBUN_API_KEY:-}" ]] && die "Porkbun API key not loaded"

# Helper: create DNS record
create_record() {
    local type="$1" name="$2" content="$3" ttl="${4:-600}"
    info "Creating ${type} record: ${name} → ${content}"

    local sub=""
    [[ "$name" != "$DOMAIN" && "$name" != "" ]] && sub="$name"

    local result
    result=$(porkbun_api "/dns/create/${DOMAIN}" "{
        \"apikey\": \"${PORKBUN_API_KEY}\",
        \"secretapikey\": \"${PORKBUN_SECRET_KEY}\",
        \"type\": \"${type}\",
        \"name\": \"${sub}\",
        \"content\": \"${content}\",
        \"ttl\": \"${ttl}\"
    }")

    if echo "$result" | jq -r '.status' | grep -q 'SUCCESS'; then
        ok "${type} ${name} created"
    else
        local msg=$(echo "$result" | jq -r '.message // "Unknown error"')
        warn "Failed: ${msg} (may already exist)"
    fi
}

# Delete existing records first (clean slate)
delete_existing() {
    local type="$1" name="$2"
    local sub=""
    [[ "$name" != "$DOMAIN" && "$name" != "" ]] && sub="$name"

    local records
    records=$(porkbun_api "/dns/retrieveByNameType/${DOMAIN}/${type}/${sub}" "{
        \"apikey\": \"${PORKBUN_API_KEY}\",
        \"secretapikey\": \"${PORKBUN_SECRET_KEY}\"
    }")

    echo "$records" | jq -r '.records[]?.id // empty' 2>/dev/null | while read -r id; do
        info "Deleting old ${type} record (ID: ${id})..."
        porkbun_api "/dns/delete/${DOMAIN}/${id}" "{
            \"apikey\": \"${PORKBUN_API_KEY}\",
            \"secretapikey\": \"${PORKBUN_SECRET_KEY}\"
        }" > /dev/null
    done
}

banner "DNS Setup: ${DOMAIN}"

# Step 1: A records for GitHub Pages (root domain)
section "A Records (GitHub Pages)"
delete_existing "A" ""
for ip in "${GITHUB_IPS[@]}"; do
    create_record "A" "" "$ip"
done

# Step 2: CNAME for www
section "CNAME Record (www)"
delete_existing "CNAME" "www"
create_record "CNAME" "www" "${GITHUB_ORG}.github.io"

# Step 3: GitHub Pages verification TXT
if [[ -n "$VERIFY_CODE" ]]; then
    section "GitHub Pages Verification TXT"
    create_record "TXT" "_github-pages-challenge-${GITHUB_ORG}" "$VERIFY_CODE"
fi

# Step 4: Show current records
section "Current DNS Records"
RECORDS=$(porkbun_api "/dns/retrieve/${DOMAIN}" "{
    \"apikey\": \"${PORKBUN_API_KEY}\",
    \"secretapikey\": \"${PORKBUN_SECRET_KEY}\"
}")
echo "$RECORDS" | jq -r '.records[] | "\(.type)\t\(.name)\t\(.content)"' 2>/dev/null | column -t

ok "DNS configuration complete for ${DOMAIN}"
