#!/usr/bin/env bash
###############################################################################
# common.sh — Shared functions for deployment pipeline
###############################################################################

SECRETS_DIR="/home/aiden/.openclaw/workspace/.secrets"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()      { echo -e "${GREEN}[  OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()     { echo -e "${RED}[ERR ]${NC} $*" >&2; }
die()     { err "$*"; exit 1; }
banner()  { echo -e "\n${BOLD}${BLUE}════════════════════════════════════════${NC}"; echo -e "${BOLD}  $*${NC}"; echo -e "${BOLD}${BLUE}════════════════════════════════════════${NC}\n"; }
section() { echo -e "\n${BOLD}${CYAN}── $* ──${NC}\n"; }

# Load secrets from YAML files (simple key: value parsing)
load_secrets() {
    # Porkbun
    if [[ -f "${SECRETS_DIR}/porkbun.yaml" ]]; then
        export PORKBUN_API_KEY=$(grep '^apikey:' "${SECRETS_DIR}/porkbun.yaml" | awk '{print $2}')
        export PORKBUN_SECRET_KEY=$(grep '^secretapikey:' "${SECRETS_DIR}/porkbun.yaml" | awk '{print $2}')
    else
        warn "Porkbun secrets not found at ${SECRETS_DIR}/porkbun.yaml"
    fi

    # GitHub
    if [[ -f "${SECRETS_DIR}/github.yaml" ]]; then
        export AMOTIOVE_GITHUB_TOKEN=$(grep -A1 'amotiove:' "${SECRETS_DIR}/github.yaml" | grep 'token:' | awk '{print $2}')
        export GH_TOKEN="${AMOTIOVE_GITHUB_TOKEN}"
    else
        warn "GitHub secrets not found at ${SECRETS_DIR}/github.yaml"
    fi

    # Cloudflare (if exists)
    if [[ -f "${SECRETS_DIR}/cloudflare.yaml" ]]; then
        export CF_API_TOKEN=$(grep '^api_token:' "${SECRETS_DIR}/cloudflare.yaml" | awk '{print $2}')
        export CF_ACCOUNT_ID=$(grep '^account_id:' "${SECRETS_DIR}/cloudflare.yaml" | awk '{print $2}')
    fi
}

# Porkbun API helper
porkbun_api() {
    local endpoint="$1"
    local data="$2"
    curl -s -X POST "https://api.porkbun.com/api/json/v3${endpoint}" \
        -H "Content-Type: application/json" \
        -d "$data"
}

# Check if command exists
require_cmd() {
    for cmd in "$@"; do
        command -v "$cmd" &>/dev/null || die "Required command not found: ${cmd}"
    done
}
