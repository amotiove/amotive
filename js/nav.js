/* ============================================
   AMOTIVE — Navigation
   Scroll shrink, mobile menu
   ============================================ */

(function () {
  'use strict';

  const nav = document.querySelector('.nav');
  const toggle = document.querySelector('.nav-mobile-toggle');
  const overlay = document.querySelector('.nav-overlay');

  /* === SCROLL SHRINK === */
  if (nav) {
    let ticking = false;
    window.addEventListener('scroll', () => {
      if (!ticking) {
        requestAnimationFrame(() => {
          nav.classList.toggle('scrolled', window.scrollY > 80);

          const progressBar = document.querySelector('.scroll-progress');
          if (progressBar) {
            const max = document.documentElement.scrollHeight - window.innerHeight;
            const progress = max > 0 ? Math.min(window.scrollY / max, 1) : 0;
            progressBar.style.transform = 'scaleX(' + progress + ')';
          }

          ticking = false;
        });
        ticking = true;
      }
    });
  }

  /* Hamburger icon lines */
  function makeHamburgerIcon() {
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.setAttribute('viewBox', '0 0 24 24');
    svg.setAttribute('fill', 'none');
    svg.setAttribute('stroke-width', '2');
    svg.setAttribute('stroke-linecap', 'round');

    [6, 12, 18].forEach(y => {
      const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
      line.setAttribute('x1', '3'); line.setAttribute('y1', String(y));
      line.setAttribute('x2', '21'); line.setAttribute('y2', String(y));
      svg.appendChild(line);
    });
    return svg;
  }

  /* Close X icon */
  function makeCloseIcon() {
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.setAttribute('viewBox', '0 0 24 24');
    svg.setAttribute('fill', 'none');
    svg.setAttribute('stroke-width', '2');
    svg.setAttribute('stroke-linecap', 'round');

    [[6,6,18,18],[6,18,18,6]].forEach(([x1,y1,x2,y2]) => {
      const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
      line.setAttribute('x1', String(x1)); line.setAttribute('y1', String(y1));
      line.setAttribute('x2', String(x2)); line.setAttribute('y2', String(y2));
      svg.appendChild(line);
    });
    return svg;
  }

  function setIcon(isOpen) {
    if (!toggle) return;
    const oldSvg = toggle.querySelector('svg');
    if (oldSvg) oldSvg.remove();
    toggle.appendChild(isOpen ? makeCloseIcon() : makeHamburgerIcon());
  }

  /* === MOBILE MENU === */
  if (toggle && overlay) {
    toggle.addEventListener('click', () => {
      const isOpen = overlay.classList.toggle('open');
      toggle.setAttribute('aria-expanded', String(isOpen));
      document.body.style.overflow = isOpen ? 'hidden' : '';
      setIcon(isOpen);
    });

    // Close on link click
    overlay.querySelectorAll('a').forEach(a => {
      a.addEventListener('click', () => {
        overlay.classList.remove('open');
        toggle.setAttribute('aria-expanded', 'false');
        document.body.style.overflow = '';
        setIcon(false);
      });
    });

    // Close on escape
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && overlay.classList.contains('open')) {
        toggle.click();
      }
    });
  }
})();
