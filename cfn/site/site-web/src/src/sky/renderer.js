// 星空の描画。恒星と天の川は WebGL、星座線・月・流れ星・ラベルは 2D canvas に描く。
import {
  apply3,
  colorFromBV,
  dirFromRaDec,
  equatorialToHorizontal,
  horizontalToCamera,
  localSiderealTime,
  mul3,
  solarSystem,
  transpose3,
} from "./astro.js"

// 遠くの稜線。方位ごとの高さ (rad)。背景と恒星の両方のシェーダーで同じ式を使う。
const RIDGE_GLSL = `
float ridge(float az) {
  return max(0.006, 0.026 + 0.017 * sin(az * 3.0 + 0.5) + 0.011 * sin(az * 7.0 + 2.1)
    + 0.006 * sin(az * 13.0 + 4.0) + 0.003 * sin(az * 29.0 + 1.0) + 0.0015 * sin(az * 61.0 + 3.0));
}`

const QUAD_VS = `
attribute vec2 aPos;
varying vec2 vPos;
void main() {
  vPos = aPos;
  gl_Position = vec4(aPos, 0.0, 1.0);
}`

// 天の川を赤道座標の正距円筒図として一度だけ焼き込む
const BAKE_FS = `
precision highp float;
varying vec2 vPos;
// 赤道座標 (J2000) → 銀河座標
const mat3 GAL = mat3(
  -0.0548755604, 0.4941094279, -0.8676661490,
  -0.8734370902, -0.4448296300, -0.1980763734,
  -0.4838350155, 0.7469822445, 0.4559837762);

float hash(vec3 p) {
  p = fract(p * 0.3183099 + 0.1);
  p *= 17.0;
  return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}
float noise(vec3 x) {
  vec3 i = floor(x);
  vec3 f = fract(x);
  f = f * f * (3.0 - 2.0 * f);
  return mix(
    mix(mix(hash(i), hash(i + vec3(1, 0, 0)), f.x), mix(hash(i + vec3(0, 1, 0)), hash(i + vec3(1, 1, 0)), f.x), f.y),
    mix(mix(hash(i + vec3(0, 0, 1)), hash(i + vec3(1, 0, 1)), f.x), mix(hash(i + vec3(0, 1, 1)), hash(i + vec3(1, 1, 1)), f.x), f.y),
    f.z);
}
float fbm(vec3 p) {
  float a = 0.5;
  float s = 0.0;
  for (int i = 0; i < 6; i++) {
    s += a * noise(p);
    p = p * 2.03 + vec3(1.7, 9.2, 3.1);
    a *= 0.5;
  }
  return s;
}
void main() {
  float ra = (vPos.x * 0.5 + 0.5) * 6.2831853;
  float dec = vPos.y * 1.5707963;
  vec3 e = vec3(cos(dec) * cos(ra), cos(dec) * sin(ra), sin(dec));
  vec3 g = GAL * e;
  float b = asin(clamp(g.z, -1.0, 1.0));
  float l = atan(g.y, g.x);
  // 銀河中心 (いて座方向) に近いほど明るく太い
  float center = exp(-pow(acos(clamp(g.x, -1.0, 1.0)) / 0.75, 2.0));
  float width = mix(0.085, 0.2, center);
  float band = exp(-pow(b / width, 2.0));
  float haze = exp(-pow(b / (width * 2.8), 2.0));
  float clouds = fbm(g * 3.4 + 2.0);
  float fine = fbm(g * 11.0 + 7.0);
  float light = band * (0.3 + 0.7 * center) * (0.1 + 2.7 * pow(clouds, 1.6) * (0.4 + 1.2 * fine));
  light += haze * (0.05 + 0.1 * center);
  // 暗黒星雲の帯
  float rift = exp(-pow((b - 0.025 * sin(l * 2.0 + 0.6) - 0.012) / (0.022 + 0.035 * center), 2.0));
  float dust = smoothstep(0.38, 0.62, fbm(g * 6.0 + 21.0));
  light *= 1.0 - 0.82 * rift * dust * (0.35 + 0.65 * smoothstep(0.0, 0.6, center + 0.25));
  vec3 tint = mix(vec3(0.64, 0.72, 0.96), vec3(1.0, 0.84, 0.64), clamp(center * 1.15, 0.0, 1.0));
  vec3 col = tint * light * 0.62;
  gl_FragColor = vec4(sqrt(clamp(col, 0.0, 1.0)), 1.0);
}`

const SKY_FS = `
precision highp float;
varying vec2 vPos;
uniform vec2 uProj;
uniform mat3 uCamToEq;
uniform mat3 uCamToHor;
uniform sampler2D uMilkyWay;
uniform float uMilkyWayGain;
${RIDGE_GLSL}
float dither(vec2 p) {
  return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453) - 0.5;
}
void main() {
  vec2 p = vPos * uProj;
  float r2 = dot(p, p);
  vec3 c = vec3(4.0 * p, 4.0 - r2) / (4.0 + r2);
  vec3 h = uCamToHor * c;
  vec3 e = uCamToEq * c;
  float alt = asin(clamp(h.z, -1.0, 1.0));
  float az = atan(h.x, h.y);

  float up = clamp(alt / 1.5707963, 0.0, 1.0);
  vec3 sky = mix(vec3(0.036, 0.058, 0.108), vec3(0.007, 0.011, 0.026), pow(up, 0.42));
  // 地平線ぎわの、遠い街あかり
  float dome = exp(-max(alt, 0.0) / 0.075) * (0.55 + 0.45 * sin(az + 2.0));
  sky += vec3(0.105, 0.066, 0.036) * dome;

  vec2 uv = vec2(atan(e.y, e.x) / 6.2831853, asin(clamp(e.z, -1.0, 1.0)) / 3.14159265 + 0.5);
  vec3 mw = texture2D(uMilkyWay, uv).rgb;
  sky += mw * mw * smoothstep(0.0, 0.4, alt) * uMilkyWayGain;

  float rd = ridge(az);
  float ground = smoothstep(rd + 0.0015, rd - 0.0015, alt);
  vec3 earth = vec3(0.004, 0.006, 0.010) + vec3(0.012, 0.014, 0.020) * exp(min(alt, 0.0) * 9.0) * 0.4;
  vec3 col = mix(sky, earth, ground);
  col += dither(gl_FragCoord.xy) / 255.0;
  gl_FragColor = vec4(col, 1.0);
}`

const STAR_VS = `
attribute vec3 aDir;
attribute vec4 aColor; // rgb + 等級
attribute float aSeed; // 負の値は瞬かない (惑星)
uniform mat3 uEqToCam;
uniform mat3 uEqToHor;
uniform vec2 uInvProj;
uniform float uDpr;
uniform float uTime;
uniform float uLimit;
uniform float uTwinkle;
varying vec3 vColor;
varying float vAlpha;
varying float vCore;
varying float vBright;
${RIDGE_GLSL}
void main() {
  vec3 c = uEqToCam * aDir;
  vec3 h = uEqToHor * aDir;
  float alt = asin(clamp(h.z, -1.0, 1.0));
  float az = atan(h.x, h.y);
  bool visible = alt > ridge(az) + 0.002 && c.z > -0.5;
  vec2 p = 2.0 * c.xy / (1.0 + c.z) * uInvProj;

  float mag = aColor.a;
  float flux = pow(10.0, -0.4 * mag);
  float size = 0.8 + 2.9 * pow(flux, 0.42);
  float alpha = clamp(5.0 * pow(flux, 0.55), 0.0, 1.0);
  // 目が暗さに慣れるにつれて暗い星まで見えてくる
  alpha *= smoothstep(uLimit, uLimit - 1.5, mag);
  // 大気のゆらぎ。低い空ほど強く瞬く
  float low = 1.0 - smoothstep(0.0, 0.8, alt);
  float wave = sin(uTime * (1.6 + aSeed * 4.0) + aSeed * 97.0) * sin(uTime * (0.7 + aSeed * 2.3) + aSeed * 31.0);
  alpha *= 1.0 + uTwinkle * step(0.0, aSeed) * (0.1 + 0.55 * low) * wave;
  alpha *= mix(0.3, 1.0, smoothstep(0.0, 0.32, alt));

  vBright = smoothstep(2.6, -1.0, mag);
  float spread = 1.0 + 3.2 * vBright;
  vCore = 0.55 / spread;
  vColor = aColor.rgb;
  vAlpha = alpha;
  gl_Position = vec4(visible ? p : vec2(4.0), 0.0, 1.0);
  gl_PointSize = size * 3.2 * spread * uDpr;
}`

const STAR_FS = `
precision mediump float;
varying vec3 vColor;
varying float vAlpha;
varying float vCore;
varying float vBright;
void main() {
  vec2 q = gl_PointCoord * 2.0 - 1.0;
  float d = length(q);
  float fall = max(0.0, 1.0 - d);
  float core = exp(-d * d / (vCore * vCore));
  float halo = vBright * 0.2 * fall * fall * fall;
  float spikes = vBright * 0.28 * (exp(-abs(q.x) * 46.0) + exp(-abs(q.y) * 46.0)) * fall * fall;
  float light = (core + halo + spikes) * vAlpha;
  gl_FragColor = vec4(mix(vColor, vec3(1.0), core * 0.55) * light, 1.0);
}`

function compile(gl, type, source) {
  const shader = gl.createShader(type)
  gl.shaderSource(shader, source)
  gl.compileShader(shader)
  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    throw new Error(gl.getShaderInfoLog(shader))
  }
  return shader
}

function program(gl, vs, fs, attribs) {
  const p = gl.createProgram()
  gl.attachShader(p, compile(gl, gl.VERTEX_SHADER, vs))
  gl.attachShader(p, compile(gl, gl.FRAGMENT_SHADER, fs))
  attribs.forEach((name, i) => gl.bindAttribLocation(p, i, name))
  gl.linkProgram(p)
  if (!gl.getProgramParameter(p, gl.LINK_STATUS)) {
    throw new Error(gl.getProgramInfoLog(p))
  }
  const uniforms = {}
  const count = gl.getProgramParameter(p, gl.ACTIVE_UNIFORMS)
  for (let i = 0; i < count; i++) {
    const name = gl.getActiveUniform(p, i).name
    uniforms[name] = gl.getUniformLocation(p, name)
  }
  return { p, uniforms }
}

const STRIDE = 8 // dir(3) + color(3) + mag(1) + seed(1)

function ridgeAt(az) {
  return Math.max(
    0.006,
    0.026 +
      0.017 * Math.sin(az * 3 + 0.5) +
      0.011 * Math.sin(az * 7 + 2.1) +
      0.006 * Math.sin(az * 13 + 4) +
      0.003 * Math.sin(az * 29 + 1) +
      0.0015 * Math.sin(az * 61 + 3),
  )
}

export function createSky(glCanvas, overlayCanvas, skydata) {
  const gl = glCanvas.getContext("webgl", { alpha: false, antialias: false, powerPreference: "high-performance" })
  if (!gl) throw new Error("WebGL is not available")
  const ctx = overlayCanvas.getContext("2d")

  const skyProg = program(gl, QUAD_VS, SKY_FS, ["aPos"])
  const starProg = program(gl, STAR_VS, STAR_FS, ["aDir", "aColor", "aSeed"])

  const quad = gl.createBuffer()
  gl.bindBuffer(gl.ARRAY_BUFFER, quad)
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 3, -1, -1, 3]), gl.STATIC_DRAW)

  // 天の川を焼き込む
  const milkyWay = gl.createTexture()
  {
    const bake = program(gl, QUAD_VS, BAKE_FS, ["aPos"])
    const w = 2048
    const h = 1024
    gl.bindTexture(gl.TEXTURE_2D, milkyWay)
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, w, h, 0, gl.RGBA, gl.UNSIGNED_BYTE, null)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
    const fb = gl.createFramebuffer()
    gl.bindFramebuffer(gl.FRAMEBUFFER, fb)
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, milkyWay, 0)
    gl.viewport(0, 0, w, h)
    gl.useProgram(bake.p)
    gl.bindBuffer(gl.ARRAY_BUFFER, quad)
    gl.enableVertexAttribArray(0)
    gl.vertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0)
    gl.drawArrays(gl.TRIANGLES, 0, 3)
    gl.bindFramebuffer(gl.FRAMEBUFFER, null)
    gl.deleteFramebuffer(fb)
    gl.deleteProgram(bake.p)
  }

  const starBuffer = gl.createBuffer()
  let starCount = 0
  const planetBuffer = gl.createBuffer()
  const planetData = new Float32Array(5 * STRIDE)

  // 名前のわかる明るい星と星座線
  const named = skydata.stars.map((s) => ({ ...s, dir: dirFromRaDec(s.ra, s.dec), kind: "star" }))
  const constellations = skydata.constellations.map((c) => ({
    name: c.ja,
    at: dirFromRaDec(c.p[0], c.p[1]),
    lines: c.l.map((seg) => {
      const pts = []
      for (let i = 0; i < seg.length; i += 2) pts.push(dirFromRaDec(seg[i], seg[i + 1]))
      return pts
    }),
  }))

  let width = 1
  let height = 1
  let dpr = 1
  let bodies = null
  let bodiesAt = 0
  let targets = []
  let view = null

  function resize() {
    dpr = Math.min(window.devicePixelRatio || 1, 2)
    width = glCanvas.clientWidth || window.innerWidth
    height = glCanvas.clientHeight || window.innerHeight
    for (const c of [glCanvas, overlayCanvas]) {
      c.width = Math.round(width * dpr)
      c.height = Math.round(height * dpr)
    }
  }

  function loadStars(arrayBuffer) {
    const raw = new DataView(arrayBuffer)
    starCount = arrayBuffer.byteLength / 8
    const data = new Float32Array(starCount * STRIDE)
    for (let i = 0; i < starCount; i++) {
      const ra = (raw.getUint16(i * 8, true) / 65536) * 360
      const dec = (raw.getInt16(i * 8 + 2, true) / 32767) * 90
      const mag = raw.getInt16(i * 8 + 4, true) / 1000
      const bv = raw.getUint16(i * 8 + 6, true) / 10000 - 1
      const d = dirFromRaDec(ra, dec)
      const c = colorFromBV(bv)
      data.set([d[0], d[1], d[2], c[0], c[1], c[2], mag, Math.random()], i * STRIDE)
    }
    gl.bindBuffer(gl.ARRAY_BUFFER, starBuffer)
    gl.bufferData(gl.ARRAY_BUFFER, data, gl.STATIC_DRAW)
  }

  function updateBodies(date) {
    if (bodies && Math.abs(date.getTime() - bodiesAt) < 60000) return
    bodies = solarSystem(date)
    bodiesAt = date.getTime()
    bodies.planets.forEach((p, i) => {
      planetData.set([p.dir[0], p.dir[1], p.dir[2], p.color[0], p.color[1], p.color[2], p.mag, -1], i * STRIDE)
    })
    gl.bindBuffer(gl.ARRAY_BUFFER, planetBuffer)
    gl.bufferData(gl.ARRAY_BUFFER, planetData, gl.DYNAMIC_DRAW)
  }

  function bindStarAttribs() {
    const bytes = STRIDE * 4
    gl.enableVertexAttribArray(0)
    gl.enableVertexAttribArray(1)
    gl.enableVertexAttribArray(2)
    gl.vertexAttribPointer(0, 3, gl.FLOAT, false, bytes, 0)
    gl.vertexAttribPointer(1, 4, gl.FLOAT, false, bytes, 12)
    gl.vertexAttribPointer(2, 1, gl.FLOAT, false, bytes, 28)
  }

  // 赤道座標の向き → 画面座標 (CSS px)。見えない向きは null。
  function project(dir) {
    const c = apply3(view.eqToCam, dir)
    if (c[2] < -0.3) return null
    const k = 2 / (1 + c[2])
    const x = (c[0] * k) / view.projX
    const y = (c[1] * k) / view.projY
    if (Math.abs(x) > 1.3 || Math.abs(y) > 1.3) return null
    const h = apply3(view.eqToHor, dir)
    return { x: (x * 0.5 + 0.5) * width, y: (0.5 - y * 0.5) * height, alt: Math.asin(h[2]), az: Math.atan2(h[0], h[1]) }
  }

  function aboveRidge(p) {
    return p && p.alt > ridgeAt(p.az) + 0.004
  }

  function drawOverlay(state) {
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
    ctx.clearRect(0, 0, width, height)
    targets = []

    if (state.lines > 0.01) {
      ctx.lineWidth = 1
      ctx.strokeStyle = `rgba(168, 197, 255, ${0.32 * state.lines})`
      ctx.beginPath()
      for (const c of constellations) {
        for (const seg of c.lines) {
          let pen = false
          for (const d of seg) {
            const p = project(d)
            if (!aboveRidge(p)) {
              pen = false
              continue
            }
            if (pen) ctx.lineTo(p.x, p.y)
            else ctx.moveTo(p.x, p.y)
            pen = true
          }
        }
      }
      ctx.stroke()
      ctx.font = '500 13px "Zen Kaku Gothic New", sans-serif'
      ctx.textAlign = "center"
      ctx.fillStyle = `rgba(168, 197, 255, ${0.7 * state.lines})`
      for (const c of constellations) {
        const p = project(c.at)
        if (aboveRidge(p)) ctx.fillText(c.name, p.x, p.y)
      }
    }

    for (const s of named) {
      const p = project(s.dir)
      if (aboveRidge(p)) targets.push({ ...p, item: s })
    }

    ctx.font = '500 12px "Zen Kaku Gothic New", sans-serif'
    ctx.textAlign = "left"
    ctx.fillStyle = `rgba(242, 240, 232, ${0.62 * state.adapt})`
    for (const planet of bodies.planets) {
      const p = project(planet.dir)
      if (!aboveRidge(p)) continue
      targets.push({ ...p, item: { ...planet, kind: "planet" } })
      ctx.fillText(planet.name, p.x + 10, p.y + 4)
    }

    const moon = project(bodies.moon.dir)
    if (aboveRidge(moon)) {
      targets.push({ ...moon, item: { ...bodies.moon, kind: "moon" } })
      drawMoon(moon, state)
    }

    if (state.meteor) drawMeteor(state.meteor)
  }

  function drawMoon(at, state) {
    const m = bodies.moon.dir
    const s = bodies.sun.dir
    const dot = m[0] * s[0] + m[1] * s[1] + m[2] * s[2]
    let t = [s[0] - m[0] * dot, s[1] - m[1] * dot, s[2] - m[2] * dot]
    const len = Math.hypot(t[0], t[1], t[2]) || 1
    t = t.map((v) => v / len)
    const near = project([m[0] + t[0] * 0.01, m[1] + t[1] * 0.01, m[2] + t[2] * 0.01])
    const angle = near ? Math.atan2(near.y - at.y, near.x - at.x) : 0
    // 実際の月の見かけの大きさ (視半径 約0.26°)。小さくなりすぎる画面では少し大きく描く。
    const radius = Math.max(7, ((0.0045 / view.projY) * height) / 2)
    const lit = bodies.moon.lit
    const fade = state.adapt * (0.35 + 0.65 * Math.min(1, at.alt / 0.3))

    const glow = ctx.createRadialGradient(at.x, at.y, radius, at.x, at.y, radius * (4 + 9 * lit))
    glow.addColorStop(0, `rgba(210, 222, 255, ${0.26 * lit * fade + 0.03})`)
    glow.addColorStop(1, "rgba(210, 222, 255, 0)")
    ctx.fillStyle = glow
    ctx.beginPath()
    ctx.arc(at.x, at.y, radius * (4 + 9 * lit), 0, Math.PI * 2)
    ctx.fill()

    ctx.save()
    ctx.translate(at.x, at.y)
    ctx.rotate(angle)
    ctx.fillStyle = `rgba(46, 54, 74, ${0.9 * fade})`
    ctx.beginPath()
    ctx.arc(0, 0, radius, 0, Math.PI * 2)
    ctx.fill()
    ctx.fillStyle = `rgba(244, 240, 226, ${fade})`
    ctx.beginPath()
    ctx.arc(0, 0, radius, -Math.PI / 2, Math.PI / 2)
    ctx.ellipse(0, 0, radius * Math.abs(1 - 2 * lit), radius, 0, Math.PI / 2, -Math.PI / 2, lit < 0.5)
    ctx.fill()
    ctx.restore()
  }

  function drawMeteor(meteor) {
    const t = meteor.t
    if (t <= 0 || t >= 1) return
    const head = Math.min(1, t * 1.6)
    const tail = Math.max(0, t * 1.6 - 0.6)
    const x0 = meteor.x + meteor.dx * tail
    const y0 = meteor.y + meteor.dy * tail
    const x1 = meteor.x + meteor.dx * head
    const y1 = meteor.y + meteor.dy * head
    const g = ctx.createLinearGradient(x0, y0, x1, y1)
    const a = Math.sin(Math.PI * t)
    g.addColorStop(0, "rgba(255, 255, 255, 0)")
    g.addColorStop(1, `rgba(255, 248, 232, ${0.9 * a})`)
    ctx.strokeStyle = g
    ctx.lineWidth = 1.4
    ctx.lineCap = "round"
    ctx.beginPath()
    ctx.moveTo(x0, y0)
    ctx.lineTo(x1, y1)
    ctx.stroke()
  }

  // state: { date, az, alt, tanHalf, adapt (0-1), lines (0-1), twinkle (0|1), time (秒), meteor }
  function render(state) {
    updateBodies(state.date)
    const lst = localSiderealTime(state.date)
    const eqToHor = equatorialToHorizontal(lst)
    const horToCam = horizontalToCamera(state.az, state.alt)
    const eqToCam = mul3(horToCam, eqToHor)
    const projY = 2 * state.tanHalf
    const projX = projY * (width / height)
    view = { eqToHor, eqToCam, projX, projY }

    gl.viewport(0, 0, glCanvas.width, glCanvas.height)
    gl.disable(gl.BLEND)
    gl.useProgram(skyProg.p)
    gl.bindBuffer(gl.ARRAY_BUFFER, quad)
    gl.enableVertexAttribArray(0)
    gl.disableVertexAttribArray(1)
    gl.disableVertexAttribArray(2)
    gl.vertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0)
    gl.uniform2f(skyProg.uniforms.uProj, projX, projY)
    // 行優先の配列をそのまま渡すと GL 側では転置 (= 逆回転) になる
    gl.uniformMatrix3fv(skyProg.uniforms.uCamToEq, false, eqToCam)
    gl.uniformMatrix3fv(skyProg.uniforms.uCamToHor, false, horToCam)
    gl.uniform1f(skyProg.uniforms.uMilkyWayGain, Math.min(1, Math.max(0, (state.adapt - 0.3) / 0.7)))
    gl.activeTexture(gl.TEXTURE0)
    gl.bindTexture(gl.TEXTURE_2D, milkyWay)
    gl.uniform1i(skyProg.uniforms.uMilkyWay, 0)
    gl.drawArrays(gl.TRIANGLES, 0, 3)

    gl.enable(gl.BLEND)
    gl.blendFunc(gl.ONE, gl.ONE)
    gl.useProgram(starProg.p)
    gl.uniformMatrix3fv(starProg.uniforms.uEqToCam, false, transpose3(eqToCam))
    gl.uniformMatrix3fv(starProg.uniforms.uEqToHor, false, transpose3(eqToHor))
    gl.uniform2f(starProg.uniforms.uInvProj, 1 / projX, 1 / projY)
    gl.uniform1f(starProg.uniforms.uDpr, dpr)
    gl.uniform1f(starProg.uniforms.uTime, state.time)
    gl.uniform1f(starProg.uniforms.uLimit, 1.2 + 8.3 * state.adapt)
    gl.uniform1f(starProg.uniforms.uTwinkle, state.twinkle)
    if (starCount) {
      gl.bindBuffer(gl.ARRAY_BUFFER, starBuffer)
      bindStarAttribs()
      gl.drawArrays(gl.POINTS, 0, starCount)
    }
    gl.bindBuffer(gl.ARRAY_BUFFER, planetBuffer)
    bindStarAttribs()
    gl.drawArrays(gl.POINTS, 0, 5)

    drawOverlay(state)
  }

  // 画面上の位置にいちばん近い、名前のわかる天体
  function pick(x, y, reach = 26) {
    let best = null
    let bestDist = reach
    for (const t of targets) {
      const d = Math.hypot(t.x - x, t.y - y)
      if (d < bestDist) {
        best = t
        bestDist = d
      }
    }
    return best
  }

  // いまの空で、明るい星と惑星がいちばん多く入る方位を選ぶ
  function bestAzimuth(date) {
    updateBodies(date)
    const eqToHor = equatorialToHorizontal(localSiderealTime(date))
    const lights = [
      ...named.map((s) => ({ dir: s.dir, mag: s.mag })),
      ...bodies.planets.map((p) => ({ dir: p.dir, mag: p.mag })),
    ]
    let best = Math.PI
    let bestScore = -1
    for (let deg = 0; deg < 360; deg += 10) {
      const az = (deg * Math.PI) / 180
      let score = 0
      for (const light of lights) {
        const h = apply3(eqToHor, light.dir)
        const alt = Math.asin(h[2])
        if (alt < 0.14 || alt > 1.05) continue
        let diff = Math.abs(Math.atan2(h[0], h[1]) - az)
        if (diff > Math.PI) diff = 2 * Math.PI - diff
        if (diff > 0.6) continue
        score += Math.min(10 ** (-0.4 * light.mag), 2.5) * (1 - diff / 1.2)
      }
      if (score > bestScore) {
        bestScore = score
        best = az
      }
    }
    return best
  }

  // 表示用: いま地平線より上にある惑星と月、太陽の高度
  function summary(date) {
    updateBodies(date)
    const eqToHor = equatorialToHorizontal(localSiderealTime(date))
    const altitude = (dir) => Math.asin(apply3(eqToHor, dir)[2])
    return {
      sunAlt: altitude(bodies.sun.dir),
      moonUp: altitude(bodies.moon.dir) > 0.03,
      moonLit: bodies.moon.lit,
      planets: bodies.planets.filter((p) => altitude(p.dir) > 0.05).map((p) => p.name),
    }
  }

  resize()
  return { resize, loadStars, render, pick, bestAzimuth, summary }
}
