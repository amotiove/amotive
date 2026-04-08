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
        } else {
          el.classList.add('visible');
        }

        observer.unobserve(el);
      });
    }, { threshold: 0.15, rootMargin: '0px 0px -50px 0px' });

    document.querySelectorAll('[data-animate]').forEach(el => observer.observe(el));

    // Safety net: force all elements visible after 3s if observer fails
    setTimeout(() => {
      document.querySelectorAll('[data-animate]:not(.visible)').forEach(el => {
        el.classList.add('visible');
      });
    }, 3000);
  }

  /* === TEXT SPLIT (character stagger) === */
  function initTextSplit() {
    if (prefersReducedMotion) return;

    const splitElements = document.querySelectorAll('[data-split-chars]');
    let globalCharOffset = 0;

    splitElements.forEach(el => {
      const text = el.textContent.trim();
      const delay = parseInt(el.dataset.splitDelay) || 40;
      const offset = globalCharOffset;

      // Track chars for staggering across sibling elements
      globalCharOffset += text.replace(/\s/g, '').length + 5;

      // Clear and set accessible label
      el.setAttribute('aria-label', text);

      // Build spans using DOM API — split by words to preserve wrapping
      const fragment = document.createDocumentFragment();
      const words = text.split(' ');
      words.forEach((word, wIdx) => {
        // Wrap each word in a span to keep characters together
        const wordWrap = document.createElement('span');
        wordWrap.style.display = 'inline-block';
        wordWrap.style.whiteSpace = 'nowrap';
        for (let i = 0; i < word.length; i++) {
          const span = document.createElement('span');
          span.className = 'char-animate';
          span.textContent = word[i];
          span.setAttribute('aria-hidden', 'true');
          wordWrap.appendChild(span);
        }
        fragment.appendChild(wordWrap);
        // Add a real space between words (allows line break)
        if (wIdx < words.length - 1) {
          fragment.appendChild(document.createTextNode(' '));
        }
      });
      el.textContent = '';
      el.appendChild(fragment);

      const observer = new IntersectionObserver(([entry]) => {
        if (!entry.isIntersecting) return;
        const chars = el.querySelectorAll('.char-animate');
        chars.forEach((ch, i) => {
          setTimeout(() => ch.classList.add('visible'), (i + offset) * delay);
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

  /* === SCROLL PARALLAX === */
  function initParallax() {
    if (prefersReducedMotion) return;

    const elements = document.querySelectorAll('[data-parallax]');
    if (!elements.length) return;

    const isMobile = window.innerWidth < 768;

    let ticking = false;
    function onScroll() {
      if (ticking) return;
      ticking = true;
      requestAnimationFrame(() => {
        const scrollY = window.scrollY;
        elements.forEach(el => {
          const speed = parseFloat(el.dataset.parallax) || 1;
          const multiplier = isMobile ? (1 - speed) * 0.5 : (1 - speed);
          const offset = scrollY * multiplier;
          el.style.transform = 'translate3d(0,' + offset + 'px,0)';
        });
        ticking = false;
      });
    }

    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }

  /* === SCROLL FLOAT TEXT === */
  function initScrollFloat() {
    if (prefersReducedMotion) return;

    const elements = document.querySelectorAll('[data-scroll-float]');
    if (!elements.length) return;

    // Split each element's text into character spans
    elements.forEach(el => {
      const text = el.textContent.trim();
      el.setAttribute('aria-label', text);

      const fragment = document.createDocumentFragment();
      const words = text.split(' ');
      words.forEach((word, wIdx) => {
        const wordWrap = document.createElement('span');
        wordWrap.style.display = 'inline-block';
        wordWrap.style.whiteSpace = 'nowrap';
        for (let i = 0; i < word.length; i++) {
          const span = document.createElement('span');
          span.className = 'scroll-float-char';
          span.textContent = word[i];
          span.setAttribute('aria-hidden', 'true');
          wordWrap.appendChild(span);
        }
        fragment.appendChild(wordWrap);
        if (wIdx < words.length - 1) {
          fragment.appendChild(document.createTextNode(' '));
        }
      });
      el.textContent = '';
      el.appendChild(fragment);
    });

    const isMobile = window.innerWidth < 768;
    const scaleMin = isMobile ? 0.96 : 0.92;
    const opacityMin = 0.7;

    let ticking = false;
    function onScroll() {
      if (ticking) return;
      ticking = true;
      requestAnimationFrame(() => {
        const viewCenter = window.innerHeight / 2;
        document.querySelectorAll('.scroll-float-char').forEach(ch => {
          const rect = ch.getBoundingClientRect();
          const charCenter = rect.top + rect.height / 2;
          const distance = Math.abs(charCenter - viewCenter);
          const maxDist = window.innerHeight * 0.6;
          const t = Math.min(distance / maxDist, 1);
          const scale = 1 - t * (1 - scaleMin);
          const opacity = 1 - t * (1 - opacityMin);
          ch.style.transform = 'scale(' + scale.toFixed(3) + ')';
          ch.style.opacity = opacity.toFixed(3);
        });
        ticking = false;
      });
    }

    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }

  /* === INIT ALL === */
  function init() {
    initScrollReveal();
    initTextSplit();
    initBlurText();
    initCountUp();
    initParallax();
    initScrollFloat();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  window.AmotiveAnimations = { initScrollReveal, initTextSplit, initBlurText, initCountUp, initParallax, initScrollFloat };
})();
