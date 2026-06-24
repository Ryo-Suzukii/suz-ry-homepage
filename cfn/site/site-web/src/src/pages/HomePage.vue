<template>
  <div class="min-h-screen" style="background: var(--bg);">
    <canvas ref="canvas" class="fixed inset-0 pointer-events-none" style="z-index: 0;" />

    <!-- Hero -->
    <section class="relative flex flex-col items-center justify-center min-h-screen px-6 pt-20" style="z-index: 1;">
      <div class="w-full max-w-3xl">
        <!-- Terminal window -->
        <div class="glass rounded-2xl overflow-hidden animate-fade-in" style="border-color: var(--glass-border);">
          <!-- Title bar -->
          <div class="flex items-center gap-2 px-4 py-3 border-b" style="border-color: var(--glass-border); background: rgba(255,255,255,0.02);">
            <span class="w-3 h-3 rounded-full" style="background: #ff5f57;"></span>
            <span class="w-3 h-3 rounded-full" style="background: #febc2e;"></span>
            <span class="w-3 h-3 rounded-full" style="background: #28c840;"></span>
            <span class="ml-3 text-xs" style="color: var(--text-muted); font-family: 'JetBrains Mono', monospace;">ryo@suz-ry — zsh</span>
          </div>

          <!-- Terminal body -->
          <div class="p-6 md:p-8" style="font-family: 'JetBrains Mono', monospace; min-height: 320px;">
            <div class="space-y-4">
              <div class="text-sm">
                <span style="color: var(--cyan);">ryo</span>
                <span style="color: var(--text-muted);">@</span>
                <span style="color: var(--violet-light);">suz-ry</span>
                <span style="color: var(--text-muted);"> % </span>
                <span style="color: var(--text);">{{ typedCommand }}</span>
                <span v-if="!commandDone" class="animate-blink" style="color: var(--cyan);">▊</span>
              </div>

              <Transition name="output">
                <div v-if="showOutput" class="space-y-4">
                  <div>
                    <p class="text-xs mb-1" style="color: var(--text-muted);">NAME</p>
                    <p class="font-display font-bold gradient-text leading-tight" style="font-size: clamp(2rem, 6vw, 3.5rem);">Ryo Suzuki</p>
                  </div>

                  <div class="grid grid-cols-1 sm:grid-cols-2 gap-1.5 text-xs">
                    <div><span style="color: var(--text-muted);">ROLE    </span><span style="color: var(--text);">Full Stack Engineer</span></div>
                    <div><span style="color: var(--text-muted);">LOC     </span><span style="color: var(--text);">Tokyo, Japan</span></div>
                    <div><span style="color: var(--text-muted);">ORG     </span><span style="color: var(--amber);">Weathernews Inc.</span></div>
                    <div><span style="color: var(--text-muted);">STACK   </span><span style="color: var(--cyan);">AWS · Vue.js · Python</span></div>
                  </div>

                  <div class="text-xs">
                    <span style="color: var(--text-muted);">INTERESTS </span>
                    <span style="color: var(--violet-light);">天体観測 · ゲーム · 旅行 · 技術書</span>
                  </div>

                  <div class="flex gap-3 pt-1 text-xs">
                    <a
                      v-for="link in socialLinks"
                      :key="link.label"
                      :href="link.url"
                      target="_blank"
                      rel="noopener noreferrer"
                      class="transition-colors duration-200 hover:text-white"
                      style="color: var(--text-muted);"
                    >{{ link.label }}</a>
                  </div>

                  <div>
                    <span style="color: var(--text-muted);">$ </span>
                    <span class="animate-blink" style="color: var(--cyan);">▊</span>
                  </div>
                </div>
              </Transition>
            </div>
          </div>
        </div>

        <p class="text-center text-xs mt-8 animate-fade-in delay-800" style="color: var(--text-dim);">
          scroll to explore ↓
        </p>
      </div>
    </section>

    <!-- Bento Grid Navigation -->
    <section class="relative px-6 pb-24 max-w-5xl mx-auto" style="z-index: 1;">
      <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
        <!-- Career - tall -->
        <RouterLink
          to="/career"
          class="glass rounded-2xl relative overflow-hidden group cursor-pointer block row-span-2 flex flex-col justify-between p-6 min-h-[240px] bento-card"
        >
          <div class="absolute inset-0 opacity-10" style="background: linear-gradient(135deg, var(--violet) 0%, transparent 60%);" />
          <div class="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300 rounded-2xl" style="box-shadow: inset 0 0 0 1px rgba(124,58,237,0.5);" />
          <div class="relative z-10 flex flex-col justify-between h-full">
            <span class="text-3xl block mb-3 transition-transform duration-300 group-hover:scale-110 inline-block">📍</span>
            <div>
              <h3 class="font-display font-bold text-xl mb-1" style="color: var(--text);">経歴</h3>
              <p class="text-xs" style="color: var(--text-muted);">エンジニアとしての軌跡</p>
              <p class="text-xs mt-2 font-mono" style="color: var(--violet-light);">2024 ~ Present</p>
            </div>
          </div>
        </RouterLink>

        <!-- Products -->
        <RouterLink to="/products" class="glass rounded-2xl relative overflow-hidden group cursor-pointer block p-5 bento-card">
          <div class="absolute inset-0 opacity-10" style="background: linear-gradient(135deg, var(--cyan) 0%, transparent 60%);" />
          <div class="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300 rounded-2xl" style="box-shadow: inset 0 0 0 1px rgba(34,211,238,0.5);" />
          <div class="relative z-10">
            <span class="text-3xl block mb-3 transition-transform duration-300 group-hover:scale-110 inline-block">🛠️</span>
            <h3 class="font-display font-bold text-lg mb-1" style="color: var(--text);">プロダクト</h3>
            <p class="text-xs" style="color: var(--text-muted);">作ったもの</p>
          </div>
        </RouterLink>

        <!-- Setup -->
        <RouterLink to="/setup" class="glass rounded-2xl relative overflow-hidden group cursor-pointer block p-5 bento-card">
          <div class="absolute inset-0 opacity-10" style="background: linear-gradient(135deg, var(--amber) 0%, transparent 60%);" />
          <div class="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300 rounded-2xl" style="box-shadow: inset 0 0 0 1px rgba(245,158,11,0.5);" />
          <div class="relative z-10">
            <span class="text-3xl block mb-3 transition-transform duration-300 group-hover:scale-110 inline-block">⚙️</span>
            <h3 class="font-display font-bold text-lg mb-1" style="color: var(--text);">機材・ツール</h3>
            <p class="text-xs" style="color: var(--text-muted);">こだわりの環境</p>
          </div>
        </RouterLink>

        <!-- Games -->
        <RouterLink to="/games" class="glass rounded-2xl relative overflow-hidden group cursor-pointer block p-5 bento-card">
          <div class="absolute inset-0 opacity-10" style="background: linear-gradient(135deg, var(--green) 0%, transparent 60%);" />
          <div class="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300 rounded-2xl" style="box-shadow: inset 0 0 0 1px rgba(74,222,128,0.5);" />
          <div class="relative z-10">
            <span class="text-3xl block mb-3 transition-transform duration-300 group-hover:scale-110 inline-block">🎮</span>
            <h3 class="font-display font-bold text-lg mb-1" style="color: var(--text);">Games</h3>
            <p class="text-xs" style="color: var(--text-muted);">やってるゲーム</p>
          </div>
        </RouterLink>

        <!-- Lab -->
        <RouterLink to="/lab" class="glass rounded-2xl relative overflow-hidden group cursor-pointer block p-5 col-span-2 md:col-span-1 bento-card">
          <div class="absolute inset-0 opacity-10" style="background: linear-gradient(135deg, var(--violet-light) 0%, var(--cyan) 100%);" />
          <div class="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300 rounded-2xl" style="box-shadow: inset 0 0 0 1px rgba(167,139,250,0.5);" />
          <div class="relative z-10">
            <span class="text-3xl block mb-3 transition-transform duration-300 group-hover:scale-110 inline-block">🧪</span>
            <h3 class="font-display font-bold text-lg mb-1 gradient-text">Lab</h3>
            <p class="text-xs" style="color: var(--text-muted);">実験場 · interactive</p>
          </div>
        </RouterLink>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { RouterLink } from 'vue-router'
import * as THREE from 'three'

const canvas = ref(null)
const typedCommand = ref('')
const commandDone = ref(false)
const showOutput = ref(false)

const command = './ryo --introduce'

const socialLinks = [
  { label: 'github', url: 'https://github.com/ryo-suzukii' },
  { label: 'twitter', url: 'https://twitter.com/Hayaa_6211' },
  { label: 'zenn', url: 'https://zenn.dev/ha' },
  { label: 'qiita', url: 'https://qiita.com/Hayaa6211' },
]

onMounted(async () => {
  await new Promise(r => setTimeout(r, 600))
  for (let i = 0; i <= command.length; i++) {
    typedCommand.value = command.slice(0, i)
    await new Promise(r => setTimeout(r, 55 + Math.random() * 45))
  }
  commandDone.value = true
  await new Promise(r => setTimeout(r, 300))
  showOutput.value = true
})

let renderer, scene, camera, stars, animId

onMounted(() => {
  const el = canvas.value
  renderer = new THREE.WebGLRenderer({ canvas: el, alpha: true, antialias: false })
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.5))
  renderer.setSize(window.innerWidth, window.innerHeight)

  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 1000)
  camera.position.z = 1

  const count = 1200
  const geo = new THREE.BufferGeometry()
  const pos = new Float32Array(count * 3)
  const col = new Float32Array(count * 3)
  for (let i = 0; i < count; i++) {
    pos[i * 3] = (Math.random() - 0.5) * 200
    pos[i * 3 + 1] = (Math.random() - 0.5) * 200
    pos[i * 3 + 2] = (Math.random() - 0.5) * 200
    const r = Math.random()
    if (r < 0.1) { col[i * 3] = 0.48; col[i * 3 + 1] = 0.23; col[i * 3 + 2] = 0.93 }
    else if (r < 0.2) { col[i * 3] = 0.13; col[i * 3 + 1] = 0.83; col[i * 3 + 2] = 0.93 }
    else { col[i * 3] = 1; col[i * 3 + 1] = 1; col[i * 3 + 2] = 1 }
  }
  geo.setAttribute('position', new THREE.BufferAttribute(pos, 3))
  geo.setAttribute('color', new THREE.BufferAttribute(col, 3))
  const mat = new THREE.PointsMaterial({ vertexColors: true, size: 0.12, transparent: true, opacity: 0.7 })
  stars = new THREE.Points(geo, mat)
  scene.add(stars)

  let frameCount = 0
  function animate() {
    animId = requestAnimationFrame(animate)
    frameCount++
    stars.rotation.y += 0.00008
    stars.rotation.x += 0.00004
    if (frameCount % 2 === 0) renderer.render(scene, camera)
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
.output-enter-active {
  transition: opacity 0.5s ease, transform 0.5s ease;
}
.output-enter-from {
  opacity: 0;
  transform: translateY(12px);
}

.bento-card {
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}
.bento-card:hover {
  transform: scale(1.02);
}
</style>
