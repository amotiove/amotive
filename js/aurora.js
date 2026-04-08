/**
 * AmotiveAurora — WebGL aurora borealis background effect
 * Dark luxury atmospheric shader for amotive.io hero section
 *
 * Zero dependencies. Raw WebGL2 with WebGL1 fallback.
 * Simplex noise driven. Mouse-reactive. Performance-aware.
 *
 * Usage:
 *   const cleanup = AmotiveAurora.init(document.getElementById('aurora-canvas'));
 *   // later: cleanup();
 */
(function () {
  'use strict';

  // ---------------------------------------------------------------------------
  // Shader sources — WebGL2 (GLSL 300 es)
  // ---------------------------------------------------------------------------

  var VERT_300 = '#version 300 es\n' +
    'in vec2 aPosition;\n' +
    'void main() {\n' +
    '  gl_Position = vec4(aPosition, 0.0, 1.0);\n' +
    '}\n';

  var FRAG_300 = '#version 300 es\n' +
    'precision highp float;\n' +
    '\n' +
    'uniform float uTime;\n' +
    'uniform vec2  uResolution;\n' +
    'uniform vec2  uMouse;\n' +
    'uniform float uAmplitude;\n' +
    '\n' +
    'out vec4 fragColor;\n' +
    '\n' +
    '// --- Simplex 2D noise (Ashima Arts) ---\n' +
    'vec3 permute(vec3 x) { return mod(((x * 34.0) + 1.0) * x, 289.0); }\n' +
    '\n' +
    'float snoise(vec2 v) {\n' +
    '  const vec4 C = vec4(\n' +
    '    0.211324865405187,\n' +
    '    0.366025403784439,\n' +
    '   -0.577350269189626,\n' +
    '    0.024390243902439\n' +
    '  );\n' +
    '  vec2 i  = floor(v + dot(v, C.yy));\n' +
    '  vec2 x0 = v - i + dot(i, C.xx);\n' +
    '  vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);\n' +
    '  vec4 x12 = x0.xyxy + C.xxzz;\n' +
    '  x12.xy -= i1;\n' +
    '  i = mod(i, 289.0);\n' +
    '  vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0))\n' +
    '                          + i.x + vec3(0.0, i1.x, 1.0));\n' +
    '  vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy),\n' +
    '                          dot(x12.zw, x12.zw)), 0.0);\n' +
    '  m = m * m;\n' +
    '  m = m * m;\n' +
    '  vec3 x_  = 2.0 * fract(p * C.www) - 1.0;\n' +
    '  vec3 h   = abs(x_) - 0.5;\n' +
    '  vec3 ox  = floor(x_ + 0.5);\n' +
    '  vec3 a0  = x_ - ox;\n' +
    '  m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);\n' +
    '  vec3 g;\n' +
    '  g.x  = a0.x * x0.x  + h.x * x0.y;\n' +
    '  g.yz = a0.yz * x12.xz + h.yz * x12.yw;\n' +
    '  return 130.0 * dot(m, g);\n' +
    '}\n' +
    '\n' +
    '// --- FBM (3 octaves) ---\n' +
    'float fbm(vec2 p) {\n' +
    '  float value = 0.0;\n' +
    '  float amp   = 0.5;\n' +
    '  float freq  = 1.0;\n' +
    '  for (int i = 0; i < 3; i++) {\n' +
    '    value += amp * snoise(p * freq);\n' +
    '    freq  *= 2.0;\n' +
    '    amp   *= 0.5;\n' +
    '  }\n' +
    '  return value;\n' +
    '}\n' +
    '\n' +
    'void main() {\n' +
    '  vec2 uv = gl_FragCoord.xy / uResolution;\n' +
    '  float aspect = uResolution.x / uResolution.y;\n' +
    '\n' +
    '  // Navy background\n' +
    '  vec3 navy      = vec3(0.0392, 0.0549, 0.102);  // #0a0e1a\n' +
    '  vec3 gold      = vec3(0.788,  0.659,  0.298);  // #c9a84c\n' +
    '  vec3 lightGold = vec3(0.910,  0.831,  0.545);  // #e8d48b\n' +
    '\n' +
    '  // Subtle mouse warp — offset noise sampling by ±0.1\n' +
    '  vec2 mouseOff = (uMouse - 0.5) * 0.1;\n' +
    '\n' +
    '  // Noise coordinates — slow drift, horizontally stretched for aurora bands\n' +
    '  float t = uTime * 0.08;\n' +
    '  vec2 nCoord = vec2(\n' +
    '    uv.x * aspect * 0.8 + mouseOff.x,\n' +
    '    uv.y * 2.0 + t + mouseOff.y\n' +
    '  );\n' +
    '\n' +
    '  // Three octaves of noise for layered aurora\n' +
    '  float n1 = fbm(nCoord * 1.0 + vec2(0.0, t * 0.5));\n' +
    '  float n2 = fbm(nCoord * 1.5 + vec2(3.7, t * 0.3));\n' +
    '  float n3 = snoise(nCoord * 0.5 + vec2(-1.3, t * 0.2));\n' +
    '\n' +
    '  // Combine into aurora bands — favor the upper portion of the canvas\n' +
    '  float aurora = n1 * 0.5 + n2 * 0.3 + n3 * 0.2;\n' +
    '\n' +
    '  // Remap to 0..1 and add vertical bias (stronger in upper half)\n' +
    '  aurora = aurora * 0.5 + 0.5;\n' +
    '  aurora = smoothstep(0.35, 0.75, aurora);\n' +
    '\n' +
    '  // Vertical gradient — aurora lives in the upper 70%, fades at bottom\n' +
    '  float vertFade = smoothstep(0.0, 0.35, uv.y) * smoothstep(1.0, 0.65, uv.y);\n' +
    '  // Push aurora upward — stronger presence in top half\n' +
    '  vertFade *= smoothstep(0.0, 0.5, uv.y);\n' +
    '\n' +
    '  // Horizontal vignette — fade at left and right edges\n' +
    '  float horizFade = smoothstep(0.0, 0.25, uv.x) * smoothstep(1.0, 0.75, uv.x);\n' +
    '\n' +
    '  // Combined vignette\n' +
    '  float vignette = vertFade * horizFade;\n' +
    '\n' +
    '  // Color ramp — mix between gold tones based on noise intensity\n' +
    '  vec3 auroraColor = mix(gold, lightGold, smoothstep(0.3, 0.7, aurora));\n' +
    '\n' +
    '  // Add subtle navy tint at low intensities for depth\n' +
    '  auroraColor = mix(navy, auroraColor, smoothstep(0.0, 0.4, aurora));\n' +
    '\n' +
    '  // Atmospheric intensity — keep it LOW (0.35 multiplier)\n' +
    '  float intensity = aurora * vignette * uAmplitude * 0.35;\n' +
    '\n' +
    '  // Final composite — navy base with aurora overlay\n' +
    '  vec3 color = mix(navy, auroraColor, intensity);\n' +
    '\n' +
    '  // Alpha fades at edges for compositing over the page background\n' +
    '  float alpha = intensity * vignette;\n' +
    '  // Ensure we always output at least a tiny bit of navy so the canvas\n' +
    '  // does not look like a hole when composited\n' +
    '  alpha = max(alpha, 0.0);\n' +
    '\n' +
    '  fragColor = vec4(color, 1.0);\n' +
    '}\n';

  // ---------------------------------------------------------------------------
  // Shader sources — WebGL1 fallback (GLSL 100)
  // ---------------------------------------------------------------------------

  var VERT_100 =
    'attribute vec2 aPosition;\n' +
    'void main() {\n' +
    '  gl_Position = vec4(aPosition, 0.0, 1.0);\n' +
    '}\n';

  var FRAG_100 =
    'precision highp float;\n' +
    '\n' +
    'uniform float uTime;\n' +
    'uniform vec2  uResolution;\n' +
    'uniform vec2  uMouse;\n' +
    'uniform float uAmplitude;\n' +
    '\n' +
    '// --- Simplex 2D noise (Ashima Arts) ---\n' +
    'vec3 permute(vec3 x) { return mod(((x * 34.0) + 1.0) * x, 289.0); }\n' +
    '\n' +
    'float snoise(vec2 v) {\n' +
    '  const vec4 C = vec4(\n' +
    '    0.211324865405187,\n' +
    '    0.366025403784439,\n' +
    '   -0.577350269189626,\n' +
    '    0.024390243902439\n' +
    '  );\n' +
    '  vec2 i  = floor(v + dot(v, C.yy));\n' +
    '  vec2 x0 = v - i + dot(i, C.xx);\n' +
    '  vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);\n' +
    '  vec4 x12 = x0.xyxy + C.xxzz;\n' +
    '  x12.xy -= i1;\n' +
    '  i = mod(i, 289.0);\n' +
    '  vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0))\n' +
    '                          + i.x + vec3(0.0, i1.x, 1.0));\n' +
    '  vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy),\n' +
    '                          dot(x12.zw, x12.zw)), 0.0);\n' +
    '  m = m * m;\n' +
    '  m = m * m;\n' +
    '  vec3 x_  = 2.0 * fract(p * C.www) - 1.0;\n' +
    '  vec3 h   = abs(x_) - 0.5;\n' +
    '  vec3 ox  = floor(x_ + 0.5);\n' +
    '  vec3 a0  = x_ - ox;\n' +
    '  m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);\n' +
    '  vec3 g;\n' +
    '  g.x  = a0.x * x0.x  + h.x * x0.y;\n' +
    '  g.yz = a0.yz * x12.xz + h.yz * x12.yw;\n' +
    '  return 130.0 * dot(m, g);\n' +
    '}\n' +
    '\n' +
    '// --- FBM (3 octaves) ---\n' +
    'float fbm(vec2 p) {\n' +
    '  float value = 0.0;\n' +
    '  float amp   = 0.5;\n' +
    '  float freq  = 1.0;\n' +
    '  for (int i = 0; i < 3; i++) {\n' +
    '    value += amp * snoise(p * freq);\n' +
    '    freq  *= 2.0;\n' +
    '    amp   *= 0.5;\n' +
    '  }\n' +
    '  return value;\n' +
    '}\n' +
    '\n' +
    'void main() {\n' +
    '  vec2 uv = gl_FragCoord.xy / uResolution;\n' +
    '  float aspect = uResolution.x / uResolution.y;\n' +
    '\n' +
    '  vec3 navy      = vec3(0.0392, 0.0549, 0.102);\n' +
    '  vec3 gold      = vec3(0.788,  0.659,  0.298);\n' +
    '  vec3 lightGold = vec3(0.910,  0.831,  0.545);\n' +
    '\n' +
    '  vec2 mouseOff = (uMouse - 0.5) * 0.1;\n' +
    '\n' +
    '  float t = uTime * 0.08;\n' +
    '  vec2 nCoord = vec2(\n' +
    '    uv.x * aspect * 0.8 + mouseOff.x,\n' +
    '    uv.y * 2.0 + t + mouseOff.y\n' +
    '  );\n' +
    '\n' +
    '  float n1 = fbm(nCoord * 1.0 + vec2(0.0, t * 0.5));\n' +
    '  float n2 = fbm(nCoord * 1.5 + vec2(3.7, t * 0.3));\n' +
    '  float n3 = snoise(nCoord * 0.5 + vec2(-1.3, t * 0.2));\n' +
    '\n' +
    '  float aurora = n1 * 0.5 + n2 * 0.3 + n3 * 0.2;\n' +
    '  aurora = aurora * 0.5 + 0.5;\n' +
    '  aurora = smoothstep(0.35, 0.75, aurora);\n' +
    '\n' +
    '  float vertFade = smoothstep(0.0, 0.35, uv.y) * smoothstep(1.0, 0.65, uv.y);\n' +
    '  vertFade *= smoothstep(0.0, 0.5, uv.y);\n' +
    '  float horizFade = smoothstep(0.0, 0.25, uv.x) * smoothstep(1.0, 0.75, uv.x);\n' +
    '  float vignette = vertFade * horizFade;\n' +
    '\n' +
    '  vec3 auroraColor = mix(gold, lightGold, smoothstep(0.3, 0.7, aurora));\n' +
    '  auroraColor = mix(navy, auroraColor, smoothstep(0.0, 0.4, aurora));\n' +
    '\n' +
    '  float intensity = aurora * vignette * uAmplitude * 0.35;\n' +
    '  vec3 color = mix(navy, auroraColor, intensity);\n' +
    '  float alpha = max(intensity * vignette, 0.0);\n' +
    '\n' +
    '  gl_FragColor = vec4(color, 1.0);\n' +
    '}\n';

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  function compileShader(gl, type, source) {
    var shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      var info = gl.getShaderInfoLog(shader);
      gl.deleteShader(shader);
      throw new Error('Shader compile error: ' + info);
    }
    return shader;
  }

  function createProgram(gl, vertSrc, fragSrc) {
    var vs = compileShader(gl, gl.VERTEX_SHADER, vertSrc);
    var fs = compileShader(gl, gl.FRAGMENT_SHADER, fragSrc);
    var prog = gl.createProgram();
    gl.attachShader(prog, vs);
    gl.attachShader(prog, fs);
    gl.bindAttribLocation(prog, 0, 'aPosition');
    gl.linkProgram(prog);
    if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) {
      var info = gl.getProgramInfoLog(prog);
      gl.deleteProgram(prog);
      throw new Error('Program link error: ' + info);
    }
    // Detach and delete shaders — they are baked into the program now
    gl.detachShader(prog, vs);
    gl.detachShader(prog, fs);
    gl.deleteShader(vs);
    gl.deleteShader(fs);
    return prog;
  }

  // ---------------------------------------------------------------------------
  // init(canvas) — the main entry point
  // ---------------------------------------------------------------------------

  function init(canvas) {
    if (!canvas || !(canvas instanceof HTMLCanvasElement)) {
      throw new Error('AmotiveAurora.init requires an HTMLCanvasElement');
    }

    // ---- Accessibility: prefers-reduced-motion ----
    var prefersReduced = window.matchMedia &&
      window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    // ---- WebGL context ----
    var isWebGL2 = true;
    var gl = canvas.getContext('webgl2', {
      alpha: true,
      antialias: false,
      depth: false,
      stencil: false,
      premultipliedAlpha: false,
      preserveDrawingBuffer: false
    });

    if (!gl) {
      isWebGL2 = false;
      gl = canvas.getContext('webgl', {
        alpha: true,
        antialias: false,
        depth: false,
        stencil: false,
        premultipliedAlpha: false,
        preserveDrawingBuffer: false
      }) || canvas.getContext('experimental-webgl', {
        alpha: true,
        antialias: false,
        depth: false,
        stencil: false,
        premultipliedAlpha: false,
        preserveDrawingBuffer: false
      });
    }

    if (!gl) {
      console.warn('AmotiveAurora: WebGL not supported');
      return null;
    }

    // ---- Compile shaders ----
    var vertSrc = isWebGL2 ? VERT_300 : VERT_100;
    var fragSrc = isWebGL2 ? FRAG_300 : FRAG_100;
    var program;

    try {
      program = createProgram(gl, vertSrc, fragSrc);
    } catch (e) {
      console.error('AmotiveAurora:', e.message);
      return null;
    }

    gl.useProgram(program);

    // ---- Uniforms ----
    var uTime       = gl.getUniformLocation(program, 'uTime');
    var uResolution = gl.getUniformLocation(program, 'uResolution');
    var uMouse      = gl.getUniformLocation(program, 'uMouse');
    var uAmplitude  = gl.getUniformLocation(program, 'uAmplitude');

    // ---- Full-screen triangle (covers clip space, more efficient than a quad) ----
    //   v0 (-1, -1)   v1 (3, -1)   v2 (-1, 3)
    //   This single triangle fully covers the [-1,1] clip region.
    var triVerts = new Float32Array([
      -1.0, -1.0,
       3.0, -1.0,
      -1.0,  3.0
    ]);

    var vbo = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
    gl.bufferData(gl.ARRAY_BUFFER, triVerts, gl.STATIC_DRAW);

    var aPosition = 0; // bound in createProgram
    gl.enableVertexAttribArray(aPosition);
    gl.vertexAttribPointer(aPosition, 2, gl.FLOAT, false, 0, 0);

    // For WebGL2, use a VAO to keep things clean
    var vao = null;
    if (isWebGL2) {
      vao = gl.createVertexArray();
      gl.bindVertexArray(vao);
      gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
      gl.enableVertexAttribArray(aPosition);
      gl.vertexAttribPointer(aPosition, 2, gl.FLOAT, false, 0, 0);
      gl.bindVertexArray(null);
    }

    // ---- State ----
    var mouseX = 0.5;
    var mouseY = 0.5;
    var isVisible = true;
    var destroyed = false;
    var rafId = 0;
    var startTime = performance.now();
    var resizeTimer = 0;
    var dpr = 1;
    var isMobile = window.innerWidth < 768;

    // ---- Sizing ----
    function resize() {
      isMobile = window.innerWidth < 768;
      dpr = Math.min(window.devicePixelRatio || 1, 2);
      // Half resolution on mobile for performance
      var scale = isMobile ? 0.5 : 1.0;
      var w = Math.round(canvas.clientWidth  * dpr * scale);
      var h = Math.round(canvas.clientHeight * dpr * scale);
      if (w < 1) w = 1;
      if (h < 1) h = 1;
      if (canvas.width !== w || canvas.height !== h) {
        canvas.width  = w;
        canvas.height = h;
      }
    }

    function onResize() {
      clearTimeout(resizeTimer);
      resizeTimer = setTimeout(resize, 150);
    }

    resize(); // initial size

    // ---- Render ----
    function render() {
      if (destroyed) return;
      if (!isVisible && !prefersReduced) {
        rafId = requestAnimationFrame(render);
        return;
      }

      var elapsed = prefersReduced ? 0.0 : (performance.now() - startTime) / 1000.0;

      gl.viewport(0, 0, canvas.width, canvas.height);

      gl.uniform1f(uTime, elapsed);
      gl.uniform2f(uResolution, canvas.width, canvas.height);
      gl.uniform2f(uMouse, mouseX, mouseY);
      gl.uniform1f(uAmplitude, 1.0);

      if (isWebGL2 && vao) {
        gl.bindVertexArray(vao);
      }

      gl.drawArrays(gl.TRIANGLES, 0, 3);

      if (isWebGL2 && vao) {
        gl.bindVertexArray(null);
      }

      // If reduced motion, render exactly one frame (static gradient), then stop
      if (prefersReduced) return;

      rafId = requestAnimationFrame(render);
    }

    // ---- Mouse tracking ----
    function onMouseMove(e) {
      mouseX = e.clientX / window.innerWidth;
      mouseY = 1.0 - (e.clientY / window.innerHeight); // flip Y for GL coords
    }

    // ---- Intersection Observer (pause when off-screen) ----
    var observer = null;
    if (typeof IntersectionObserver !== 'undefined') {
      observer = new IntersectionObserver(function (entries) {
        isVisible = entries[0].isIntersecting;
      }, { threshold: 0.0 });
      observer.observe(canvas);
    }

    // ---- Event listeners ----
    window.addEventListener('resize', onResize, false);
    window.addEventListener('mousemove', onMouseMove, false);

    // ---- Kick off ----
    rafId = requestAnimationFrame(render);

    // ---- Cleanup function ----
    function cleanup() {
      destroyed = true;
      cancelAnimationFrame(rafId);
      clearTimeout(resizeTimer);

      window.removeEventListener('resize', onResize, false);
      window.removeEventListener('mousemove', onMouseMove, false);

      if (observer) {
        observer.disconnect();
        observer = null;
      }

      // Tear down WebGL resources
      if (gl) {
        if (vao && isWebGL2) {
          gl.deleteVertexArray(vao);
        }
        if (vbo) gl.deleteBuffer(vbo);
        if (program) gl.deleteProgram(program);

        // Lose the context to free GPU memory
        var ext = gl.getExtension('WEBGL_lose_context');
        if (ext) ext.loseContext();
      }
    }

    return cleanup;
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  window.AmotiveAurora = { init: init };

})();
