/* ============================================
   AMOTIVE — Animations
   Scroll reveal, text split, blur text, countUp
   ============================================ */

(function () {
  'use strict';

  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* === SCROLL REVEAL === */
  function initScrollReveal() {
    if (prefersReducedMotion) {
      document.querySelectorAll('[data-animate]').forEach(el => el.classList.add('visible'));
      return;
    }

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (!entry.isIntersecting) return;

        const el = entry.target;
        const parent = el.closest('[data-stagger]');

        if (parent && !parent._staggerInit) {
          parent._staggerInit = true;
          const children = parent.querySelectorAll('[data-animate]');
          const delay = parseInt(parent.dataset.stagger) || 100;
          children.forEach((child, i) => {
            setTimeout(() => child.classList.add('visible'), i * delay);
          });
        } else if (!parent) {
          el.classList.add('visible');
        }

        observer.unobserve(el);
      });
    }, { threshold: 0.15, rootMargin: '0px 0px -50px 0px' });

    document.querySelectorAll('[data-animate]').forEach(el => observer.observe(el));
  }

  /* === TEXT SPLIT (character stagger) === */
  function initTextSplit() {
    if (prefersReducedMotion) return;

    document.querySelectorAll('[data-split-chars]').forEach(el => {
      const text = el.textContent;
      const delay = parseInt(el.dataset.splitDelay) || 40;

      // Clear and set accessible label
      el.setAttribute('aria-label', text);

      // Build spans using DOM API (no innerHTML)
      const fragment = document.createDocumentFragment();
      const lines = text.split('\n');
      lines.forEach((line, lineIdx) => {
        for (let i = 0; i < line.length; i++) {
          const span = document.createElement('span');
          span.className = 'char-animate';
          span.textContent = line[i] === ' ' ? '\u00A0' : line[i];
          span.setAttribute('aria-hidden', 'true');
          fragment.appendChild(span);
        }
        if (lineIdx < lines.length - 1) {
          fragment.appendChild(document.createElement('br'));
        }
      });
      el.textContent = '';
      el.appendChild(fragment);

      const observer = new IntersectionObserver(([entry]) => {
        if (!entry.isIntersecting) return;
        const chars = el.querySelectorAll('.char-animate');
        chars.forEach((ch, i) => {
          setTimeout(() => ch.classList.add('visible'), i * delay);
        });
        observer.unobserve(el);
      }, { threshold: 0.2 });

      observer.observe(el);
    });
  }

  /* === BLUR TEXT (word stagger) === */
  function initBlurText() {
    if (prefersReducedMotion) return;

    document.querySelectorAll('[data-blur-words]').forEach(el => {
      const text = el.textContent;
      const delay = parseInt(el.dataset.blurDelay) || 80;
      const words = text.split(' ');

      el.setAttribute('aria-label', text);

      // Build spans using DOM API (no innerHTML)
      const fragment = document.createDocumentFragment();
      words.forEach((word, i) => {
        const span = document.createElement('span');
        span.className = 'word-blur';
        span.textContent = word;
        span.setAttribute('aria-hidden', 'true');
        fragment.appendChild(span);
        if (i < words.length - 1) {
          const space = document.createElement('span');
          space.className = 'word-blur';
          space.textContent = '\u00A0';
          space.style.width = '0.3em';
          fragment.appendChild(space);
        }
      });
      el.textContent = '';
      el.appendChild(fragment);

      const observer = new IntersectionObserver(([entry]) => {
        if (!entry.isIntersecting) return;
        const spans = el.querySelectorAll('.word-blur');
        spans.forEach((sp, i) => {
          setTimeout(() => sp.classList.add('visible'), i * delay);
        });
        observer.unobserve(el);
      }, { threshold: 0.2 });

      observer.observe(el);
    });
  }

  /* === COUNT UP === */
  function initCountUp() {
    document.querySelectorAll('[data-count]').forEach(el => {
      const target = parseFloat(el.dataset.count);
      const suffix = el.dataset.countSuffix || '';
      const prefix = el.dataset.countPrefix || '';
      const decimals = (target % 1 !== 0) ? 1 : 0;
      const duration = 2000;

      const observer = new IntersectionObserver(([entry]) => {
        if (!entry.isIntersecting) return;
        observer.unobserve(el);

        const start = performance.now();
        function update(now) {
          const elapsed = now - start;
          const progress = Math.min(elapsed / duration, 1);
          // easeOutExpo
          const eased = progress === 1 ? 1 : 1 - Math.pow(2, -10 * progress);
          const value = eased * target;
          el.textContent = prefix + value.toFixed(decimals) + suffix;
          if (progress < 1) requestAnimationFrame(update);
        }
        requestAnimationFrame(update);
      }, { threshold: 0.3 });

      observer.observe(el);
    });
  }

  /* === INIT ALL === */
  function init() {
    initScrollReveal();
    initTextSplit();
    initBlurText();
    initCountUp();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  window.AmotiveAnimations = { initScrollReveal, initTextSplit, initBlurText, initCountUp };
})();
