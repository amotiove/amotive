/* ============================================
   AMOTIVE — Effects Engine
   Particles, Magnetic Buttons, Tilt Cards, Spotlight, Cursor
   ============================================ */

(function () {
  'use strict';

  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const isTouchDevice = 'ontouchstart' in window || navigator.maxTouchPoints > 0;

  /* === PARTICLE SYSTEM === */
  function initParticles(canvas, options = {}) {
    if (prefersReducedMotion || !canvas) return;

    const ctx = canvas.getContext('2d');
    const isMobile = window.innerWidth < 768;
    const count = options.count || (isMobile ? 35 : 70);
    const color = options.color || { r: 201, g: 168, b: 76 };
    const lineDistance = options.lineDistance || 120;
    const speed = options.speed || 0.3;
    const dotSize = options.dotSize || 2;
    const particles = [];
    let animId;
    let isVisible = true;

    function resize() {
      const rect = canvas.parentElement.getBoundingClientRect();
      canvas.width = rect.width * window.devicePixelRatio;
      canvas.height = rect.height * window.devicePixelRatio;
      canvas.style.width = rect.width + 'px';
      canvas.style.height = rect.height + 'px';
      ctx.scale(window.devicePixelRatio, window.devicePixelRatio);
    }

    function createParticle() {
      const rect = canvas.parentElement.getBoundingClientRect();
      return {
        x: Math.random() * rect.width,
        y: Math.random() * rect.height,
        vx: (Math.random() - 0.5) * speed,
        vy: (Math.random() - 0.5) * speed,
        size: Math.random() * dotSize + 0.5,
        alpha: Math.random() * 0.4 + 0.1
      };
    }

    for (let i = 0; i < count; i++) {
      particles.push(createParticle());
    }

    function draw() {
      if (!isVisible) { animId = requestAnimationFrame(draw); return; }

      const w = canvas.width / window.devicePixelRatio;
      const h = canvas.height / window.devicePixelRatio;

      ctx.clearRect(0, 0, canvas.width, canvas.height);

      for (let i = 0; i < particles.length; i++) {
        const p = particles[i];
        p.x += p.vx;
        p.y += p.vy;

        if (p.x < 0 || p.x > w) p.vx *= -1;
        if (p.y < 0 || p.y > h) p.vy *= -1;

        ctx.beginPath();
        ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(${color.r},${color.g},${color.b},${p.alpha})`;
        ctx.fill();

        for (let j = i + 1; j < particles.length; j++) {
          const q = particles[j];
          const dx = p.x - q.x;
          const dy = p.y - q.y;
          const dist = Math.sqrt(dx * dx + dy * dy);
          if (dist < lineDistance) {
            const alpha = (1 - dist / lineDistance) * 0.12;
            ctx.beginPath();
            ctx.moveTo(p.x, p.y);
            ctx.lineTo(q.x, q.y);
            ctx.strokeStyle = `rgba(${color.r},${color.g},${color.b},${alpha})`;
            ctx.lineWidth = 0.5;
            ctx.stroke();
          }
        }
      }

      animId = requestAnimationFrame(draw);
    }

    // Pause when off-screen
    const observer = new IntersectionObserver(([entry]) => {
      isVisible = entry.isIntersecting;
    }, { threshold: 0 });
    observer.observe(canvas.parentElement);

    resize();
    draw();
    window.addEventListener('resize', resize);

    return () => {
      cancelAnimationFrame(animId);
      window.removeEventListener('resize', resize);
      observer.disconnect();
    };
  }

  /* === MAGNETIC BUTTONS === */
  function initMagneticButtons() {
    if (isTouchDevice || prefersReducedMotion) return;

    document.querySelectorAll('.btn').forEach(btn => {
      btn.addEventListener('mousemove', (e) => {
        const rect = btn.getBoundingClientRect();
        const cx = rect.left + rect.width / 2;
        const cy = rect.top + rect.height / 2;
        const dx = (e.clientX - cx) * 0.15;
        const dy = (e.clientY - cy) * 0.15;
        btn.style.transform = `translate(${dx}px, ${dy}px)`;
      });

      btn.addEventListener('mouseleave', () => {
        btn.style.transform = '';
        btn.style.transition = `transform var(--duration-normal) var(--ease-spring)`;
        setTimeout(() => { btn.style.transition = ''; }, 400);
      });

      btn.addEventListener('click', (e) => {
        if (prefersReducedMotion) return;
        const rect = btn.getBoundingClientRect();
        const size = Math.max(btn.offsetWidth, btn.offsetHeight) * 2;
        const ripple = document.createElement('span');
        ripple.className = 'btn-ripple';
        ripple.style.width = size + 'px';
        ripple.style.height = size + 'px';
        ripple.style.left = (e.clientX - rect.left - size / 2) + 'px';
        ripple.style.top = (e.clientY - rect.top - size / 2) + 'px';
        btn.appendChild(ripple);
        ripple.addEventListener('animationend', () => ripple.remove());
      });
    });
  }

  /* === TILT + GLARE HOVER ON CARDS === */
  function initTiltCards() {
    if (isTouchDevice || prefersReducedMotion) return;

    document.querySelectorAll('.glass-card').forEach(card => {
      const glare = document.createElement('div');
      glare.className = 'card-glare';
      card.appendChild(glare);

      card.addEventListener('mousemove', (e) => {
        const rect = card.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        // Glare follows cursor
        glare.style.background = `radial-gradient(300px circle at ${x}px ${y}px, rgba(255,255,255,0.06), transparent 60%)`;

        // 3D tilt (-8 to +8 deg)
        const rotateY = ((x / rect.width) - 0.5) * 16;
        const rotateX = ((y / rect.height) - 0.5) * -16;
        card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg)`;
        card.style.boxShadow = `${-rotateY * 1.5}px ${rotateX * 1.5}px 30px rgba(0,0,0,0.3), 0 0 40px rgba(201,168,76,0.08)`;
      });

      card.addEventListener('mouseleave', () => {
        card.style.transition = 'transform 600ms cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 600ms cubic-bezier(0.34, 1.56, 0.64, 1)';
        card.style.transform = '';
        card.style.boxShadow = '';
        setTimeout(() => { card.style.transition = ''; }, 600);
      });
    });
  }

  /* === SPOTLIGHT CURSOR === */
  function initSpotlightCursor() {
    if (isTouchDevice || prefersReducedMotion) return;

    const spotlight = document.querySelector('.cursor-spotlight');
    if (!spotlight) return;

    let rafId;
    document.addEventListener('mousemove', (e) => {
      if (rafId) return;
      rafId = requestAnimationFrame(() => {
        spotlight.style.setProperty('--spot-x', e.clientX + 'px');
        spotlight.style.setProperty('--spot-y', e.clientY + 'px');
        if (!spotlight.classList.contains('active')) {
          spotlight.classList.add('active');
        }
        rafId = null;
      });
    });

    document.addEventListener('mouseleave', () => {
      spotlight.classList.remove('active');
    });
  }

  /* === EXPOSE === */
  window.AmotiveEffects = {
    initParticles,
    initMagneticButtons,
    initTiltCards,
    initSpotlightCursor
  };
})();
