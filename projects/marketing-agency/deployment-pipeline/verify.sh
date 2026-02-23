#!/usr/bin/env bash
###############################################################################
# verify.sh — Post-deployment verification
# Usage: ./verify.sh --domain example.com [--verbose]
###############################################################################
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

DOMAIN=""
VERBOSE=false
PASS=0; FAIL=0; WARN_COUNT=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --domain)  DOMAIN="$2"; shift 2 ;;
        --verbose) VERBOSE=true; shift ;;
        *) die "Unknown: $1" ;;
    esac
done

[[ -z "$DOMAIN" ]] && die "Missing --domain"
require_cmd dig curl

check() {
    local desc="$1" result="$2"
    if [[ "$result" == "pass" ]]; then
        ok "$desc"; ((PASS++))
    elif [[ "$result" == "warn" ]]; then
        warn "$desc"; ((WARN_COUNT++))
    else
        err "$desc"; ((FAIL++))
    fi
}

banner "Verifying: ${DOMAIN}"

# DNS A Records
section "DNS Records"
A_RECORDS=$(dig +short A "${DOMAIN}" 2>/dev/null)
EXPECTED_IPS="185.199.108.153 185.199.109.153 185.199.110.153 185.199.111.153"
A_COUNT=$(echo "$A_RECORDS" | grep -c '185.199' || true)
if [[ $A_COUNT -ge 4 ]]; then
    check "A records (${A_COUNT}/4 GitHub IPs)" "pass"
elif [[ $A_COUNT -ge 1 ]]; then
    check "A records (${A_COUNT}/4 — partial, may be behind Cloudflare proxy)" "warn"
else
    check "A records — none found pointing to GitHub" "fail"
fi
$VERBOSE && echo "  Records: $(echo $A_RECORDS | tr '\n' ' ')"

# CNAME www
WWW_CNAME=$(dig +short CNAME "www.${DOMAIN}" 2>/dev/null)
if echo "$WWW_CNAME" | grep -qi 'github\|cloudflare'; then
    check "CNAME www → ${WWW_CNAME}" "pass"
else
    check "CNAME www — unexpected: ${WWW_CNAME:-none}" "warn"
fi

# HTTP Response
section "HTTP/HTTPS"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -L "https://${DOMAIN}" --max-time 10 2>/dev/null || echo "000")
if [[ "$HTTP_CODE" == "200" ]]; then
    check "HTTPS ${DOMAIN} → ${HTTP_CODE}" "pass"
elif [[ "$HTTP_CODE" == "301" || "$HTTP_CODE" == "302" ]]; then
    check "HTTPS ${DOMAIN} → ${HTTP_CODE} (redirect)" "warn"
else
    check "HTTPS ${DOMAIN} → ${HTTP_CODE}" "fail"
fi

# www redirect
WWW_CODE=$(curl -s -o /dev/null -w "%{http_code}" -L "https://www.${DOMAIN}" --max-time 10 2>/dev/null || echo "000")
if [[ "$WWW_CODE" == "200" ]]; then
    check "HTTPS www.${DOMAIN} → ${WWW_CODE}" "pass"
else
    check "HTTPS www.${DOMAIN} → ${WWW_CODE}" "fail"
fi

# SSL Certificate
section "SSL Certificate"
SSL_INFO=$(echo | openssl s_client -connect "${DOMAIN}:443" -servername "${DOMAIN}" 2>/dev/null)
SSL_ISSUER=$(echo "$SSL_INFO" | openssl x509 -noout -issuer 2>/dev/null | sed 's/issuer=//')
SSL_EXPIRY=$(echo "$SSL_INFO" | openssl x509 -noout -enddate 2>/dev/null | sed 's/notAfter=//')

if [[ -n "$SSL_ISSUER" ]]; then
    check "SSL valid — Issuer: ${SSL_ISSUER}" "pass"
    info "  Expires: ${SSL_EXPIRY}"
else
    check "SSL certificate not found" "fail"
fi

# GitHub Pages
section "GitHub Pages"
GH_HEADERS=$(curl -sI "https://${DOMAIN}" --max-time 10 2>/dev/null)
if echo "$GH_HEADERS" | grep -qi 'github\|cloudflare'; then
    SERVER=$(echo "$GH_HEADERS" | grep -i '^server:' | head -1)
    check "Served by: ${SERVER}" "pass"
else
    check "Server header not GitHub/Cloudflare" "warn"
fi

# Summary
banner "Results"
echo -e "  ${GREEN}Passed:${NC}  ${PASS}"
echo -e "  ${YELLOW}Warnings:${NC} ${WARN_COUNT}"
echo -e "  ${RED}Failed:${NC}  ${FAIL}"
echo ""

[[ $FAIL -gt 0 ]] && exit 1 || exit 0
