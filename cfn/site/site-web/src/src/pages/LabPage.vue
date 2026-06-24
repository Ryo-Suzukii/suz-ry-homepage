<template>
  <div class="min-h-screen relative overflow-hidden" style="background: var(--bg);">
    <!-- Full screen canvas -->
    <canvas ref="canvas" class="fixed inset-0" style="z-index: 0;" />

    <!-- Scan line effect -->
    <div class="fixed inset-0 pointer-events-none" style="z-index: 1; background: repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(0,0,0,0.03) 2px, rgba(0,0,0,0.03) 4px);" />

    <!-- Content -->
    <div class="relative pt-28 pb-20 px-6" style="z-index: 2;">
      <div class="max-w-4xl mx-auto">

        <!-- System boot sequence -->
        <div class="mb-20">
          <div class="glass rounded-2xl p-6 font-mono text-xs" style="max-width: 600px;">
            <p style="color: var(--text-dim);">System v2.0.1 — Ryo Suzuki's Lab</p>
            <p class="mt-1" style="color: var(--text-muted);">Initializing creative environment<span class="animate-blink" style="color: var(--cyan);">...</span></p>
            <div class="mt-3 space-y-1">
              <p v-for="(line, i) in bootLines" :key="i" :class="line.class" style="transition: opacity 0.3s;">{{ line.text }}</p>
            </div>
          </div>
        </div>

        <!-- Hero identity block -->
        <div class="mb-24">
          <div class="overflow-hidden mb-2">
            <h1
              ref="titleRef"
              class="font-display font-bold"
              style="font-size: clamp(3rem, 10vw, 8rem); line-height: 0.9; color: var(--text); transform: translateY(100%); transition: transform 1s cubic-bezier(0.16, 1, 0.3, 1);"
            >
              Full Stack
            </h1>
          </div>
          <div class="overflow-hidden mb-2">
            <h1
              ref="title2Ref"
              class="font-display font-bold gradient-text"
              style="font-size: clamp(3rem, 10vw, 8rem); line-height: 0.9; transform: translateY(100%); transition: transform 1s cubic-bezier(0.16, 1, 0.3, 1) 0.1s;"
            >
              Engineer
            </h1>
          </div>
          <div class="overflow-hidden">
            <p
              ref="subtitleRef"
              class="font-mono text-sm mt-4"
              style="color: var(--text-muted); transform: translateY(100%); transition: transform 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.3s;"
            >
              Based in Tokyo · Building for the web
            </p>
          </div>
        </div>

        <!-- Interactive skill nodes -->
        <div class="mb-24">
          <p class="font-mono text-xs mb-8" style="color: var(--text-dim);">// hover to explore</p>
          <div class="flex flex-wrap gap-3">
            <div
              v-for="node in skillNodes"
              :key="node.label"
              class="skill-node px-4 py-2 rounded-full font-mono text-sm cursor-default relative overflow-hidden"
              :class="{ 'active': hoveredNode === node.label }"
              :style="`border: 1px solid ${node.color}33; color: ${node.color}; background: ${node.color}0a;`"
              @mouseenter="hoveredNode = node.label"
              @mouseleave="hoveredNode = null"
            >
              {{ node.label }}
              <div
                class="absolute inset-0 transition-opacity duration-300"
                :style="`background: ${node.color}; opacity: ${hoveredNode === node.label ? 0.08 : 0};`"
              />
            </div>
          </div>

          <!-- Tooltip -->
          <Transition name="tooltip">
            <div
              v-if="hoveredNode"
              class="glass rounded-xl p-4 mt-4 font-mono text-xs"
              style="max-width: 300px;"
            >
              <p style="color: var(--cyan);">{{ currentNode?.label }}</p>
              <p class="mt-1" style="color: var(--text-muted);">{{ currentNode?.desc }}</p>
              <div class="h-1 rounded-full mt-3 overflow-hidden" style="background: rgba(255,255,255,0.06);">
                <div
                  class="h-full rounded-full"
                  :style="`width: ${currentNode?.level}%; background: ${currentNode?.color};`"
                />
              </div>
            </div>
          </Transition>
        </div>

        <!-- Philosophy -->
        <div class="mb-24">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div
              v-for="(item, i) in philosophy"
              :key="i"
              class="glass rounded-2xl p-6 group reveal"
              :style="{ transitionDelay: `${i * 0.1}s` }"
            >
              <p class="font-mono text-xs mb-3" :style="`color: ${item.color};`">{{ String(i + 1).padStart(2, '0') }}</p>
              <h3 class="font-display font-bold text-xl mb-2" style="color: var(--text);">{{ item.title }}</h3>
              <p class="text-sm leading-relaxed" style="color: var(--text-muted);">{{ item.body }}</p>
            </div>
          </div>
        </div>

        <!-- Ambient quote -->
        <div class="text-center mb-20 reveal">
          <blockquote class="font-display font-bold text-2xl md:text-4xl" style="color: var(--text); line-height: 1.3;">
            "コードは詩だ。<br>
            <span class="gradient-text">リズムと構造と意味がある。</span>"
          </blockquote>
        </div>

        <!-- Contact -->
        <div class="glass rounded-2xl p-8 reveal">
          <div class="flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
            <div>
              <h2 class="font-display font-bold text-2xl mb-2" style="color: var(--text);">Let's connect</h2>
              <p class="text-sm" style="color: var(--text-muted);">新しいチャレンジは常に歓迎。</p>
            </div>
            <div class="flex flex-col gap-2 font-mono text-xs">
              <a href="https://github.com/ryo-suzukii" target="_blank" rel="noopener noreferrer" class="flex items-center gap-2 transition-colors hover:text-white" style="color: var(--text-muted);">
                <span style="color: var(--violet-light);">github</span> → ryo-suzukii
              </a>
              <a href="https://twitter.com/Hayaa_6211" target="_blank" rel="noopener noreferrer" class="flex items-center gap-2 transition-colors hover:text-white" style="color: var(--text-muted);">
                <span style="color: var(--cyan);">twitter</span> → @Hayaa_6211
              </a>
              <a href="mailto:astronautryosuzuki@gmail.com" class="flex items-center gap-2 transition-colors hover:text-white" style="color: var(--text-muted);">
                <span style="color: var(--amber);">mail</span> → astronautryosuzuki@gmail.com
              </a>
            </div>
          </div>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import * as THREE from 'three'

const canvas = ref(null)
const titleRef = ref(null)
const title2Ref = ref(null)
const subtitleRef = ref(null)
const hoveredNode = ref(null)

const bootLines = ref([])

const allBootLines = [
  { text: '[OK] Vue 3 runtime loaded', class: 'text-green-400' },
  { text: '[OK] Three.js scene initialized', class: 'text-green-400' },
  { text: '[OK] AWS connection established', class: 'text-green-400' },
  { text: '[WARN] Work-life balance: 72%', class: 'text-amber-400' },
  { text: '[INFO] Coffee level: optimal', class: '' },
  { text: '[READY] System online ▊', class: 'text-cyan-400' },
]

const skillNodes = [
  { label: 'Python', color: '#f59e0b', desc: 'FastAPI / Lambda / Scripts', level: 85 },
  { label: 'Vue.js', color: '#4ade80', desc: 'Composition API / Nuxt / Three.js', level: 80 },
  { label: 'AWS', color: '#22d3ee', desc: 'Lambda / DynamoDB / CloudFront / SAM', level: 85 },
  { label: 'Docker', color: '#60a5fa', desc: 'Compose / Kubernetes basics', level: 75 },
  { label: 'TypeScript', color: '#a78bfa', desc: 'Typing / Generics / Utility types', level: 70 },
  { label: 'PostgreSQL', color: '#fb923c', desc: 'Query optimization / RDS', level: 75 },
  { label: 'FastAPI', color: '#f59e0b', desc: 'REST / OpenAPI / Async', level: 85 },
  { label: 'Three.js', color: '#22d3ee', desc: 'WebGL / Shaders / Particles', level: 65 },
  { label: 'CI/CD', color: '#4ade80', desc: 'GitHub Actions / CodePipeline', level: 85 },
  { label: 'Rust', color: '#fb7185', desc: '学習中...', level: 30 },
]

const currentNode = computed(() => skillNodes.find(n => n.label === hoveredNode.value))

const philosophy = [
  {
    title: 'シンプルに考える',
    body: '複雑な問題は必ずシンプルな構造に分解できる。まず全体像を把握して、一つずつ解決していく。',
    color: 'var(--violet-light)',
  },
  {
    title: '動くものを作る',
    body: '完璧なコードより、まず動くもの。ユーザーに届けてから改善する。イテレーションが質を作る。',
    color: 'var(--cyan)',
  },
  {
    title: '好奇心を燃料に',
    body: 'Factorioで自動化を極めるのも、天体望遠鏡で土星の輪を見るのも、エンジニアリングと同じ知的興奮だ。',
    color: 'var(--amber)',
  },
  {
    title: 'チームで勝つ',
    body: '一人で作れるものには限界がある。良いチームと良いコミュニケーションが、良いプロダクトを作る。',
    color: 'var(--green)',
  },
]

// Boot sequence animation
onMounted(async () => {
  for (let i = 0; i < allBootLines.length; i++) {
    await new Promise(r => setTimeout(r, 200 + i * 120))
    bootLines.value.push(allBootLines[i])
  }
})

// Title entrance
onMounted(async () => {
  await new Promise(r => setTimeout(r, 800))
  if (titleRef.value) titleRef.value.style.transform = 'translateY(0)'
  if (title2Ref.value) title2Ref.value.style.transform = 'translateY(0)'
  if (subtitleRef.value) subtitleRef.value.style.transform = 'translateY(0)'
})

// Scroll reveal
onMounted(() => {
  const observer = new IntersectionObserver(
    entries => entries.forEach(e => { if (e.isIntersecting) { e.target.classList.add('visible'); observer.unobserve(e.target) } }),
    { threshold: 0.05, rootMargin: '0px 0px -20px 0px' }
  )
  requestAnimationFrame(() => document.querySelectorAll('.reveal').forEach(el => observer.observe(el)))
})

// Three.js — flowing particle field
let renderer, scene, camera, animId
let particleMesh, lineMesh

onMounted(() => {
  const el = canvas.value
  renderer = new THREE.WebGLRenderer({ canvas: el, alpha: true, antialias: false })
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.5))
  renderer.setSize(window.innerWidth, window.innerHeight)

  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 0.1, 1000)
  camera.position.z = 80

  // Particles
  const count = 800
  const positions = new Float32Array(count * 3)
  const colors = new Float32Array(count * 3)
  const velocities = []

  for (let i = 0; i < count; i++) {
    positions[i * 3] = (Math.random() - 0.5) * 160
    positions[i * 3 + 1] = (Math.random() - 0.5) * 160
    positions[i * 3 + 2] = (Math.random() - 0.5) * 80
    velocities.push({
      x: (Math.random() - 0.5) * 0.02,
      y: (Math.random() - 0.5) * 0.02,
    })
    const palette = [[0.48, 0.23, 0.93], [0.13, 0.83, 0.93], [0.96, 0.62, 0.04]]
    const c = palette[Math.floor(Math.random() * palette.length)]
    colors[i * 3] = c[0]; colors[i * 3 + 1] = c[1]; colors[i * 3 + 2] = c[2]
  }

  const geo = new THREE.BufferGeometry()
  geo.setAttribute('position', new THREE.BufferAttribute(positions, 3))
  geo.setAttribute('color', new THREE.BufferAttribute(colors, 3))
  const mat = new THREE.PointsMaterial({ vertexColors: true, size: 0.4, transparent: true, opacity: 0.8 })
  particleMesh = new THREE.Points(geo, mat)
  scene.add(particleMesh)

  let mouse = { x: 0, y: 0 }
  window.addEventListener('mousemove', e => {
    mouse.x = (e.clientX / window.innerWidth - 0.5) * 0.3
    mouse.y = -(e.clientY / window.innerHeight - 0.5) * 0.3
  })

  let frame = 0
  function animate() {
    animId = requestAnimationFrame(animate)
    frame++

    const pos = particleMesh.geometry.attributes.position.array
    for (let i = 0; i < count; i++) {
      pos[i * 3] += velocities[i].x
      pos[i * 3 + 1] += velocities[i].y
      if (Math.abs(pos[i * 3]) > 80) velocities[i].x *= -1
      if (Math.abs(pos[i * 3 + 1]) > 80) velocities[i].y *= -1
    }
    particleMesh.geometry.attributes.position.needsUpdate = true

    camera.position.x += (mouse.x * 10 - camera.position.x) * 0.02
    camera.position.y += (mouse.y * 10 - camera.position.y) * 0.02
    camera.lookAt(scene.position)

    if (frame % 2 === 0) renderer.render(scene, camera)
  }
  animate()

  window.addEventListener('resize', onResize)
})

function onResize() {
  if (!camera || !renderer) return
  camera.aspect = window.innerWidth / window.innerHeight
  camera.updateProjectionMatrix()
  renderer.setSize(window.innerWidth, window.innerHeight)
}

onUnmounted(() => {
  cancelAnimationFrame(animId)
  renderer?.dispose()
  window.removeEventListener('resize', onResize)
})
</script>

<style scoped>
.skill-node {
  transition: all 0.2s ease;
  position: relative;
}
.skill-node:hover {
  transform: scale(1.05);
}

.tooltip-enter-active,
.tooltip-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}
.tooltip-enter-from,
.tooltip-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}
</style>
