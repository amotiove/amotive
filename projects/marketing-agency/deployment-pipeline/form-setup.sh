#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Google Forms Embed Setup
# Injects form iframe into all site pages
# ============================================================================

FORM_ID="" SITE_DIR=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --form-id)  FORM_ID="$2"; shift 2 ;;
    --site-dir) SITE_DIR="$2"; shift 2 ;;
    -h|--help)
      cat <<EOF
Usage: $(basename "$0") --form-id FORM_ID --site-dir DIR

Embeds a Google Form iframe into site pages.

Setup Guide:
  1. Go to https://forms.google.com → Create blank form
  2. Title: "Contact Us" or "[Business] — Get In Touch"
  3. Add fields:
     - Full Name (Short answer, required)
     - Email (Short answer, required, email validation)
     - Phone (Short answer, optional)
     - Service Interest (Dropdown: Website, Marketing, Premium, Other)
     - Message (Paragraph, optional)
  4. Settings → Responses → Collect email addresses
  5. Settings → Responses → Send email notification
  6. Get form ID from URL: docs.google.com/forms/d/e/<FORM_ID>/viewform
  7. Run: $(basename "$0") --form-id <FORM_ID> --site-dir /path/to/site

To link responses to a spreadsheet:
  - Open form → Responses tab → Link to Sheets
  - Share the sheet with client admin
EOF
      exit 0 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

[[ -z "$FORM_ID" || -z "$SITE_DIR" ]] && { echo "Missing --form-id or --site-dir"; exit 1; }

EMBED_URL="https://docs.google.com/forms/d/e/${FORM_ID}/viewform?embedded=true"

FORM_HTML="
    <section id=\"contact\" style=\"padding: 60px 0;\">
      <div class=\"container\">
        <h2 style=\"text-align: center; margin-bottom: 32px;\">Get In Touch</h2>
        <iframe
          src=\"${EMBED_URL}\"
          width=\"100%\"
          height=\"800\"
          frameborder=\"0\"
          marginheight=\"0\"
          marginwidth=\"0\"
          style=\"border-radius: 12px; background: rgba(255,255,255,0.05);\"
        >Loading…</iframe>
      </div>
    </section>"

INJECTED=0
for page in index.html website/index.html marketing/index.html premium/index.html; do
  local_file="${SITE_DIR}/${page}"
  [[ -f "$local_file" ]] || continue

  if grep -q "google.com/forms" "$local_file" 2>/dev/null; then
    echo "  ⏭ ${page} — form already embedded"
    continue
  fi

  # Insert before </main> or before <footer>
  if grep -q '</main>' "$local_file"; then
    sed -i "s|</main>|${FORM_HTML}\n  </main>|" "$local_file"
  elif grep -q '<footer>' "$local_file"; then
    sed -i "s|<footer>|${FORM_HTML}\n  <footer>|" "$local_file"
  else
    echo "$FORM_HTML" >> "$local_file"
  fi

  echo "  ✓ ${page} — form embedded"
  ((INJECTED++))
done

echo ""
echo "✓ Form embedded in ${INJECTED} page(s)"
echo "  Form URL: https://docs.google.com/forms/d/e/${FORM_ID}/viewform"
echo "  Embed URL: ${EMBED_URL}"
