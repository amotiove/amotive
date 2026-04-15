/**
 * Amotive visitor fingerprinting — consent-gated.
 *
 * Depends on /js/consent.js (must load first). Loads FingerprintJS v4
 * from openfpcdn.io ONLY after the user grants consent. Stores the
 * resulting visitor ID in localStorage['amotive_vid'] so it can be
 * attached to contact form submissions for conversion attribution.
 *
 * No third-party POST and no server call — intentional. Tracking is
 * local until a form submit carries the ID to our inbox.
 *
 * Accuracy note: FingerprintJS OSS is ~60% — adequate for conversion
 * stitching, not suitable for fraud prevention or authentication.
 */
(function () {
  'use strict';

  var VID_KEY = 'amotive_vid';
  var FP_URL = 'https://openfpcdn.io/fingerprintjs/v4';

  function hasStoredId() {
    try { return !!localStorage.getItem(VID_KEY); } catch (e) { return false; }
  }

  function storeId(id) {
    try { localStorage.setItem(VID_KEY, id); } catch (e) { /* noop */ }
  }

  async function loadAndIdentify() {
    if (hasStoredId()) return;
    try {
      var module = await import(FP_URL);
      var agent = await module.load();
      var result = await agent.get();
      if (result && result.visitorId) {
        storeId(result.visitorId);
      }
    } catch (e) {
      // Silently ignore — not business-critical.
    }
  }

  function init() {
    if (!window.amotiveConsent) {
      // Consent script didn't load (or loaded in wrong order). Refuse
      // to fingerprint without the gate — fail closed.
      return;
    }
    window.amotiveConsent.onGrant(loadAndIdentify);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
