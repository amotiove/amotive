/**
 * Amotive consent banner — lightweight, no dependencies.
 *
 * Exposes window.amotiveConsent:
 *   .isGranted()  -> boolean
 *   .isDenied()   -> boolean
 *   .onGrant(cb)  -> fires cb() immediately if already granted,
 *                    otherwise fires cb() when user grants later.
 *   .revoke()     -> clears stored consent and clears amotive_vid
 *
 * Storage: localStorage['amotive_consent'] = 'granted' | 'denied' | null
 */
(function () {
  'use strict';

  var STORAGE_KEY = 'amotive_consent';
  var VID_KEY = 'amotive_vid';
  var pendingCallbacks = [];

  function read() {
    try { return localStorage.getItem(STORAGE_KEY); } catch (e) { return null; }
  }

  function write(v) {
    try { localStorage.setItem(STORAGE_KEY, v); } catch (e) { /* noop */ }
  }

  function isGranted() { return read() === 'granted'; }
  function isDenied()  { return read() === 'denied'; }

  function onGrant(cb) {
    if (typeof cb !== 'function') return;
    if (isGranted()) { cb(); return; }
    pendingCallbacks.push(cb);
  }

  function flushCallbacks() {
    while (pendingCallbacks.length) {
      var cb = pendingCallbacks.shift();
      try { cb(); } catch (e) { /* swallow */ }
    }
  }

  function grant() {
    write('granted');
    removeBanner();
    flushCallbacks();
  }

  function deny() {
    write('denied');
    removeBanner();
  }

  function revoke() {
    try {
      localStorage.removeItem(STORAGE_KEY);
      localStorage.removeItem(VID_KEY);
    } catch (e) { /* noop */ }
    // Show the banner again on next load; don't re-render here.
  }

  function removeBanner() {
    var el = document.getElementById('amotive-consent-banner');
    if (el && el.parentNode) el.parentNode.removeChild(el);
  }

  function renderBanner() {
    if (document.getElementById('amotive-consent-banner')) return;

    var banner = document.createElement('div');
    banner.id = 'amotive-consent-banner';
    banner.setAttribute('role', 'dialog');
    banner.setAttribute('aria-label', 'Cookie consent');
    banner.style.cssText = [
      'position:fixed', 'left:1rem', 'right:1rem', 'bottom:1rem',
      'max-width:640px', 'margin:0 auto',
      'padding:1rem 1.25rem',
      'background:rgba(10,22,40,0.96)',
      'color:#f7f8fc',
      'border:1px solid rgba(201,168,76,0.3)',
      'border-radius:12px',
      'box-shadow:0 12px 40px rgba(0,0,0,0.35)',
      'z-index:9999',
      'font-family:Inter,system-ui,-apple-system,sans-serif',
      'font-size:14px', 'line-height:1.55',
      'display:flex', 'flex-wrap:wrap', 'gap:0.75rem',
      'align-items:center', 'justify-content:space-between'
    ].join(';');

    var text = document.createElement('div');
    text.style.cssText = 'flex:1 1 280px;';
    var p = document.createElement('p');
    p.style.cssText = 'margin:0;';
    p.textContent = 'We use visitor analytics to improve the site and stitch conversions. ';
    var link = document.createElement('a');
    link.href = '/privacy/';
    link.textContent = 'Privacy policy';
    link.style.cssText = 'color:#C9A84C;text-decoration:underline;';
    p.appendChild(link);
    text.appendChild(p);

    var actions = document.createElement('div');
    actions.style.cssText = 'display:flex;gap:0.5rem;flex-shrink:0;';

    var btnDeny = document.createElement('button');
    btnDeny.type = 'button';
    btnDeny.textContent = 'Decline';
    btnDeny.style.cssText = 'padding:0.5rem 1rem;background:transparent;color:#f7f8fc;border:1px solid rgba(247,248,252,0.3);border-radius:8px;cursor:pointer;font:inherit;';
    btnDeny.addEventListener('click', deny);

    var btnAccept = document.createElement('button');
    btnAccept.type = 'button';
    btnAccept.textContent = 'Accept';
    btnAccept.style.cssText = 'padding:0.5rem 1.25rem;background:#C9A84C;color:#0A1628;border:0;border-radius:8px;cursor:pointer;font:inherit;font-weight:600;';
    btnAccept.addEventListener('click', grant);

    actions.appendChild(btnDeny);
    actions.appendChild(btnAccept);
    banner.appendChild(text);
    banner.appendChild(actions);

    (document.body || document.documentElement).appendChild(banner);
  }

  function maybeRenderBanner() {
    var choice = read();
    if (choice === 'granted' || choice === 'denied') return;
    renderBanner();
  }

  // Support re-surfacing via /privacy#preferences anchor.
  function handlePreferencesAnchor() {
    if (window.location.hash === '#preferences') {
      revoke();
      renderBanner();
    }
  }

  window.amotiveConsent = {
    isGranted: isGranted,
    isDenied: isDenied,
    onGrant: onGrant,
    revoke: revoke
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () {
      maybeRenderBanner();
      handlePreferencesAnchor();
    });
  } else {
    maybeRenderBanner();
    handlePreferencesAnchor();
  }

  window.addEventListener('hashchange', handlePreferencesAnchor);
})();
