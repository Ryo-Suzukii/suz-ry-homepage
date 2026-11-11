<script setup>
import { computed, onBeforeUnmount, onMounted, reactive, ref } from "vue"

import { createSky } from "../sky/renderer.js"
import skydata from "../sky/skydata.json"

const glCanvas = ref(null)
const overlay = ref(null)
const failed = ref(false)

const linesOn = ref(false)
const forwarding = ref(false)
const shifted = ref(false)
const tip = ref(null)
const info = reactive({ time: "", sunAlt: -1, moonUp: false, moonLit: 0, planets: [] })

const reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches
const FORWARD_RATE = 1500 // 早送り中は 1 秒で 25 分進む

let sky = null
let raf = 0
let last = 0
let clock = 0
let offsetMs = 0
let adapt = reduced ? 1 : 0
let starsReady = false
let lines = 0
let baseAz = Math.PI
let dragAz = 0
let dragAlt = 0
let parallax = { x: 0, y: 0, tx: 0, ty: 0 }
let drag = null
let meteor = null
let nextMeteor = 9
let infoAt = -1

const timeFormat = new Intl.DateTimeFormat("ja-JP", {
  timeZone: "Asia/Tokyo",
  month: "long",
  day: "numeric",
  hour: "2-digit",
  minute: "2-digit",
})

const note = computed(() => {
  const parts = []
  if (info.sunAlt > -0.1) parts.push("昼間なので、ほんとうは太陽の光に隠れています")
  if (info.planets.length) parts.push(`${info.planets.join("・")}が出ています`)
  if (info.moonUp) parts.push(`月は${Math.round(info.moonLit * 100)}%が光っています`)
  return parts.join("。")
})

function shownDate() {
  return new Date(Date.now() + offsetMs)
}

function camera() {
  const aspect = window.innerWidth / window.innerHeight
  const tanHalf = Math.max(Math.tan((17 * Math.PI) / 180), Math.tan((13 * Math.PI) / 180) / aspect)
  const scrollable = document.documentElement.scrollHeight - window.innerHeight
  const progress = scrollable > 0 ? Math.min(1, Math.max(0, window.scrollY / scrollable)) : 0
  const eased = progress * progress * (3 - 2 * progress)
  // ページの先頭では地平線が画面の下のほうに見え、読み進めるほど空を見上げていく
  const low = 2 * Math.atan(0.86 * tanHalf)
  const high = 1.12
  const alt = Math.min(1.45, Math.max(low - 0.12, low + (high - low) * eased + dragAlt + parallax.y))
  return { az: baseAz + dragAz + parallax.x, alt, tanHalf }
}

function frame(now) {
  raf = requestAnimationFrame(frame)
  const dt = Math.min(0.1, (now - last) / 1000 || 0)
  last = now
  clock += dt

  if (forwarding.value) offsetMs += dt * FORWARD_RATE * 1000
  if (starsReady && adapt < 1) adapt = Math.min(1, adapt + dt / 6.5)
  lines += ((linesOn.value ? 1 : 0) - lines) * Math.min(1, dt * 5)
  parallax.x += (parallax.tx - parallax.x) * Math.min(1, dt * 2.5)
  parallax.y += (parallax.ty - parallax.y) * Math.min(1, dt * 2.5)

  if (!reduced) {
    if (!meteor && clock > nextMeteor) {
      const angle = Math.PI * (0.15 + Math.random() * 0.7)
      const length = 140 + Math.random() * 200
      meteor = {
        x: window.innerWidth * (0.1 + Math.random() * 0.8),
        y: window.innerHeight * (0.05 + Math.random() * 0.4),
        dx: Math.cos(angle) * length,
        dy: Math.sin(angle) * length,
        start: clock,
        t: 0,
      }
    }
    if (meteor) {
      meteor.t = (clock - meteor.start) / 0.7
      if (meteor.t >= 1) {
        meteor = null
        nextMeteor = clock + 10 + Math.random() * 18
      }
    }
  }

  const date = shownDate()
  const ease = adapt * adapt * (3 - 2 * adapt)
  sky.render({ date, ...camera(), adapt: ease, lines, twinkle: reduced ? 0 : 1, time: clock, meteor })

  if (clock - infoAt > 0.25) {
    infoAt = clock
    info.time = timeFormat.format(date)
    Object.assign(info, sky.summary(date))
  }
}

function describe(item) {
  if (item.kind === "moon") {
    return { title: "月", body: `いま、${Math.round(item.lit * 100)}%が照らされています。` }
  }
  if (item.kind === "planet") {
    return { title: item.name, body: `${item.mag.toFixed(1)}等。惑星は恒星とちがって、ほとんど瞬きません。` }
  }
  const year = shownDate().getFullYear()
  const light =
    item.ly <= 150
      ? `いま見えているのは、${Math.round(year - item.ly)}年ごろに星を出た光です。`
      : `いま見えているのは、およそ${item.ly.toLocaleString("ja-JP")}年前に星を出た光です。`
  return { title: item.ja, sub: item.en, body: `地球から約${item.ly.toLocaleString("ja-JP")}光年。${light}` }
}

function showTip(x, y, reach) {
  const hit = sky?.pick(x, y, reach)
  if (!hit) {
    tip.value = null
    return
  }
  const flip = hit.x > window.innerWidth - 300
  tip.value = { ...describe(hit.item), x: hit.x, y: hit.y, flip }
}

function isText(target) {
  return Boolean(target.closest?.("a, button, p, h1, h2, h3, li, dt, dd"))
}

function onPointerDown(e) {
  if (!sky || isText(e.target) || e.button > 0) return
  drag = { x: e.clientX, y: e.clientY, moved: 0, touch: e.pointerType === "touch" }
}

function onPointerMove(e) {
  if (!sky) return
  if (drag) {
    const { tanHalf } = camera()
    const perPx = (4 * tanHalf) / window.innerHeight
    const dx = e.clientX - drag.x
    const dy = e.clientY - drag.y
    drag.moved += Math.abs(dx) + Math.abs(dy)
    dragAz -= dx * perPx
    if (!drag.touch) dragAlt = Math.min(0.9, Math.max(-0.1, dragAlt + dy * perPx))
    drag.x = e.clientX
    drag.y = e.clientY
    if (drag.moved > 4) {
      document.documentElement.classList.add("is-dragging")
      tip.value = null
    }
    return
  }
  if (e.pointerType === "mouse") {
    if (!reduced) {
      parallax.tx = (e.clientX / window.innerWidth - 0.5) * 0.05
      parallax.ty = -(e.clientY / window.innerHeight - 0.5) * 0.03
    }
    if (isText(e.target)) tip.value = null
    else showTip(e.clientX, e.clientY, 26)
  }
}

function onPointerUp(e) {
  if (drag && drag.moved <= 4 && drag.touch) showTip(e.clientX, e.clientY, 40)
  drag = null
  document.documentElement.classList.remove("is-dragging")
}

function toggleForward() {
  forwarding.value = !forwarding.value
  shifted.value = true
}

function backToNow() {
  forwarding.value = false
  shifted.value = false
  offsetMs = 0
}

function onResize() {
  sky?.resize()
}

onMounted(async () => {
  try {
    sky = createSky(glCanvas.value, overlay.value, skydata)
  } catch {
    failed.value = true
    return
  }
  baseAz = sky.bestAzimuth(new Date())
  window.addEventListener("resize", onResize)
  window.addEventListener("pointerdown", onPointerDown)
  window.addEventListener("pointermove", onPointerMove)
  window.addEventListener("pointerup", onPointerUp)
  window.addEventListener("pointercancel", onPointerUp)
  raf = requestAnimationFrame(frame)

  const response = await fetch(`${import.meta.env.BASE_URL}sky/stars.bin`)
  sky.loadStars(await response.arrayBuffer())
  starsReady = true
})

onBeforeUnmount(() => {
  cancelAnimationFrame(raf)
  window.removeEventListener("resize", onResize)
  window.removeEventListener("pointerdown", onPointerDown)
  window.removeEventListener("pointermove", onPointerMove)
  window.removeEventListener("pointerup", onPointerUp)
  window.removeEventListener("pointercancel", onPointerUp)
})
</script>

<template>
  <div class="sky" :class="{ 'sky--static': failed }" aria-hidden="true">
    <canvas ref="glCanvas" class="sky__layer"></canvas>
    <canvas ref="overlay" class="sky__layer"></canvas>
  </div>

  <div v-if="tip" class="tip" :class="{ 'tip--flip': tip.flip }" :style="{ left: `${tip.x}px`, top: `${tip.y}px` }" role="status">
    <p class="tip__title">
      {{ tip.title }}<span v-if="tip.sub" class="tip__sub">{{ tip.sub }}</span>
    </p>
    <p class="tip__body">{{ tip.body }}</p>
  </div>

  <div v-if="!failed" class="deck">
    <p class="deck__readout">
      <span class="deck__time">{{ info.time }}</span>
      <span>北緯35°・東経139°から見た{{ shifted ? "空" : "いまの空" }}</span>
      <span v-if="note" class="deck__note">{{ note }}</span>
    </p>
    <div class="deck__buttons">
      <button type="button" :aria-pressed="linesOn" @click="linesOn = !linesOn">星座線</button>
      <button type="button" :aria-pressed="forwarding" @click="toggleForward">
        {{ forwarding ? "時間を止める" : "時間を進める" }}
      </button>
      <button v-if="shifted" type="button" @click="backToNow">いまに戻る</button>
    </div>
  </div>
</template>

<style scoped>
.sky {
  position: fixed;
  inset: 0;
  z-index: 0;
  background: linear-gradient(#02040a, #070c18 70%, #101a2e);
}

.sky__layer {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  display: block;
}

.sky--static .sky__layer {
  display: none;
}

.tip {
  position: fixed;
  z-index: 30;
  width: max-content;
  max-width: min(17rem, 80vw);
  margin: 0.9rem 0 0 0.9rem;
  padding: 0.7rem 0.95rem 0.8rem;
  border-left: 2px solid var(--amber);
  background: rgba(4, 7, 14, 0.82);
  backdrop-filter: blur(6px);
  pointer-events: none;
}

.tip--flip {
  transform: translateX(calc(-100% - 1.8rem));
}

.tip__title {
  margin: 0;
  font-family: var(--mincho);
  font-size: 1.15rem;
  font-weight: 700;
}

.tip__sub {
  margin-left: 0.6em;
  font-family: var(--gothic);
  font-size: 0.8rem;
  font-weight: 400;
  color: var(--dusk);
}

.tip__body {
  margin: 0.25rem 0 0;
  font-size: 0.85rem;
  line-height: 1.7;
  color: var(--dusk);
}

.deck {
  position: fixed;
  z-index: 20;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 1rem 2rem;
  padding: 2.5rem clamp(1rem, 3vw, 2rem) 1.1rem;
  background: linear-gradient(transparent, rgba(2, 4, 9, 0.78));
  pointer-events: none;
}

.deck__readout {
  display: flex;
  flex-wrap: wrap;
  gap: 0.1rem 1.1rem;
  margin: 0;
  font-size: 0.82rem;
  line-height: 1.7;
  color: var(--dusk);
}

.deck__time {
  color: var(--star);
  font-variant-numeric: tabular-nums;
}

.deck__note {
  flex-basis: 100%;
}

.deck__buttons {
  display: flex;
  flex-shrink: 0;
  gap: 0.5rem;
  pointer-events: auto;
}

.deck button {
  padding: 0.5rem 0.95rem;
  border: 1px solid rgba(168, 197, 255, 0.35);
  border-radius: 999px;
  background: rgba(4, 7, 14, 0.55);
  color: var(--star);
  font: inherit;
  font-size: 0.82rem;
  cursor: pointer;
  transition:
    background 0.2s,
    border-color 0.2s;
}

.deck button:hover {
  border-color: var(--rigel);
}

.deck button[aria-pressed="true"] {
  border-color: var(--amber);
  background: rgba(255, 179, 124, 0.16);
}

@media (max-width: 640px) {
  .deck {
    flex-direction: column;
    align-items: stretch;
  }

  .deck__readout {
    font-size: 0.75rem;
  }

  .deck__note {
    display: none;
  }
}
</style>
