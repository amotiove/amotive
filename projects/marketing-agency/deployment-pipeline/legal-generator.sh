#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Legal Page Generator — Privacy Policy + Terms of Service
# Generates HTML pages matching the site's design system
# ============================================================================

DOMAIN="" BUSINESS="" EMAIL="" OUTPUT_DIR="."

while [[ $# -gt 0 ]]; do
  case $1 in
    --domain)     DOMAIN="$2"; shift 2 ;;
    --business)   BUSINESS="$2"; shift 2 ;;
    --email)      EMAIL="$2"; shift 2 ;;
    --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $(basename "$0") --domain DOMAIN --business NAME --email EMAIL [--output-dir DIR]"
      exit 0 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

[[ -z "$DOMAIN" || -z "$BUSINESS" || -z "$EMAIL" ]] && { echo "Missing required args"; exit 1; }

DATE=$(date +"%B %d, %Y")
YEAR=$(date +%Y)

mkdir -p "${OUTPUT_DIR}/privacy" "${OUTPUT_DIR}/terms"

# ── Privacy Policy ───────────────────────────────────────────────────────────

cat > "${OUTPUT_DIR}/privacy/index.html" <<PRIVEOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Privacy Policy — ${BUSINESS}</title>
  <link rel="stylesheet" href="/css/style.css">
  <style>.legal { max-width: 800px; margin: 0 auto; } .legal h2 { margin-top: 40px; color: var(--accent); } .legal p, .legal li { color: var(--text-muted); line-height: 1.8; } .legal ul { padding-left: 24px; margin: 12px 0; }</style>
</head>
<body>
  <header>
    <div class="container">
      <a href="/" class="logo">${BUSINESS}</a>
      <nav><a href="/">Home</a><a href="/website/">Website</a><a href="/marketing/">Marketing</a><a href="/premium/">Premium</a></nav>
    </div>
  </header>
  <main>
    <section class="hero" style="padding: 40px 0 0;">
      <div class="container"><h1>Privacy Policy</h1><p style="color:var(--text-muted)">Effective: ${DATE}</p></div>
    </section>
    <section>
      <div class="container legal">
        <h2>1. Information We Collect</h2>
        <p>${BUSINESS} ("we," "us," or "our") collects information you provide directly, including:</p>
        <ul>
          <li>Name, email address, phone number via contact forms</li>
          <li>Information you provide in messages or inquiries</li>
          <li>Usage data collected automatically (IP address, browser type, pages visited)</li>
        </ul>

        <h2>2. How We Use Your Information</h2>
        <p>We use collected information to:</p>
        <ul>
          <li>Respond to your inquiries and provide requested services</li>
          <li>Improve our website and services</li>
          <li>Send service-related communications</li>
          <li>Comply with legal obligations</li>
        </ul>

        <h2>3. Information Sharing</h2>
        <p>We do not sell your personal information. We may share information with:</p>
        <ul>
          <li>Service providers who assist in operating our website (hosting, analytics)</li>
          <li>Legal authorities when required by law</li>
        </ul>

        <h2>4. Data Security</h2>
        <p>We implement reasonable security measures to protect your information. However, no method of transmission over the Internet is 100% secure.</p>

        <h2>5. Cookies</h2>
        <p>Our website may use cookies and similar technologies to improve your experience. You can control cookies through your browser settings.</p>

        <h2>6. Third-Party Services</h2>
        <p>Our site may contain links to third-party websites or use embedded services (e.g., Google Forms). These services have their own privacy policies.</p>

        <h2>7. Your Rights</h2>
        <p>You may request to access, correct, or delete your personal information by contacting us at <a href="mailto:${EMAIL}" style="color:var(--accent)">${EMAIL}</a>.</p>

        <h2>8. Children's Privacy</h2>
        <p>Our services are not directed to individuals under 13. We do not knowingly collect information from children.</p>

        <h2>9. Changes to This Policy</h2>
        <p>We may update this policy periodically. Changes will be posted on this page with an updated effective date.</p>

        <h2>10. Contact Us</h2>
        <p>For privacy-related questions, contact us at <a href="mailto:${EMAIL}" style="color:var(--accent)">${EMAIL}</a>.</p>
      </div>
    </section>
  </main>
  <footer>
    <div class="container">
      <p>&copy; ${YEAR} ${BUSINESS}. All rights reserved.</p>
      <p><a href="/privacy/">Privacy Policy</a> | <a href="/terms/">Terms of Service</a></p>
    </div>
  </footer>
</body>
</html>
PRIVEOF

# ── Terms of Service ─────────────────────────────────────────────────────────

cat > "${OUTPUT_DIR}/terms/index.html" <<TOSEOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Terms of Service — ${BUSINESS}</title>
  <link rel="stylesheet" href="/css/style.css">
  <style>.legal { max-width: 800px; margin: 0 auto; } .legal h2 { margin-top: 40px; color: var(--accent); } .legal p, .legal li { color: var(--text-muted); line-height: 1.8; } .legal ul { padding-left: 24px; margin: 12px 0; }</style>
</head>
<body>
  <header>
    <div class="container">
      <a href="/" class="logo">${BUSINESS}</a>
      <nav><a href="/">Home</a><a href="/website/">Website</a><a href="/marketing/">Marketing</a><a href="/premium/">Premium</a></nav>
    </div>
  </header>
  <main>
    <section class="hero" style="padding: 40px 0 0;">
      <div class="container"><h1>Terms of Service</h1><p style="color:var(--text-muted)">Effective: ${DATE}</p></div>
    </section>
    <section>
      <div class="container legal">
        <h2>1. Acceptance of Terms</h2>
        <p>By accessing or using ${DOMAIN} ("the Site"), you agree to be bound by these Terms of Service. If you do not agree, do not use the Site.</p>

        <h2>2. Services</h2>
        <p>${BUSINESS} provides digital marketing, web development, and related professional services as described on the Site.</p>

        <h2>3. User Conduct</h2>
        <p>You agree not to:</p>
        <ul>
          <li>Use the Site for any unlawful purpose</li>
          <li>Attempt to gain unauthorized access to any part of the Site</li>
          <li>Interfere with or disrupt the Site's operation</li>
          <li>Submit false or misleading information</li>
        </ul>

        <h2>4. Intellectual Property</h2>
        <p>All content on the Site, including text, graphics, logos, and design, is the property of ${BUSINESS} and is protected by applicable intellectual property laws.</p>

        <h2>5. Disclaimer of Warranties</h2>
        <p>The Site and services are provided "as is" without warranties of any kind, either express or implied. We do not guarantee that the Site will be uninterrupted or error-free.</p>

        <h2>6. Limitation of Liability</h2>
        <p>${BUSINESS} shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the Site or services.</p>

        <h2>7. Indemnification</h2>
        <p>You agree to indemnify and hold harmless ${BUSINESS} from any claims, damages, or expenses arising from your use of the Site or violation of these Terms.</p>

        <h2>8. Third-Party Links</h2>
        <p>The Site may contain links to third-party websites. We are not responsible for the content or practices of these sites.</p>

        <h2>9. Modifications</h2>
        <p>We reserve the right to modify these Terms at any time. Continued use of the Site after changes constitutes acceptance.</p>

        <h2>10. Governing Law</h2>
        <p>These Terms are governed by applicable law. Any disputes shall be resolved in the appropriate jurisdiction.</p>

        <h2>11. Contact</h2>
        <p>Questions about these Terms? Contact us at <a href="mailto:${EMAIL}" style="color:var(--accent)">${EMAIL}</a>.</p>
      </div>
    </section>
  </main>
  <footer>
    <div class="container">
      <p>&copy; ${YEAR} ${BUSINESS}. All rights reserved.</p>
      <p><a href="/privacy/">Privacy Policy</a> | <a href="/terms/">Terms of Service</a></p>
    </div>
  </footer>
</body>
</html>
TOSEOF

echo "✓ Legal pages generated:"
echo "  ${OUTPUT_DIR}/privacy/index.html"
echo "  ${OUTPUT_DIR}/terms/index.html"
