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
          <div
            ref="terminalBody"
            class="p-5 md:p-6 overflow-y-auto"
            style="font-family: 'JetBrains Mono', monospace; min-height: 340px; max-height: 60vh;"
            @click="focusInput"
          >
            <!-- Command history -->
            <div v-for="(entry, i) in history" :key="i" class="mb-2">
              <!-- Command line -->
              <div class="text-sm flex items-start gap-1">
                <span class="shrink-0">
                  <span style="color: var(--cyan);">ryo</span>
                  <span style="color: var(--text-muted);">@suz-ry % </span>
                </span>
                <span style="color: var(--text);">{{ entry.cmd }}</span>
              </div>
              <!-- Output -->
              <div v-if="entry.output" class="mt-1 text-sm" v-html="entry.output" />
            </div>

            <!-- Current input line -->
            <div class="text-sm flex items-center gap-1" v-if="!booting">
              <span class="shrink-0">
                <span style="color: var(--cyan);">ryo</span>
                <span style="color: var(--text-muted);">@suz-ry % </span>
              </span>
              <span style="color: var(--text);">{{ currentInput }}</span>
              <span class="animate-blink" style="color: var(--cyan);">▊</span>
              <input
                ref="inputRef"
                v-model="currentInput"
                class="absolute opacity-0 w-0 h-0"
                autocomplete="off"
                spellcheck="false"
                @keydown.enter="runCommand"
                @keydown.up.prevent="historyUp"
                @keydown.down.prevent="historyDown"
                @keydown.tab.prevent="tabComplete"
              />
            </div>
          </div>
        </div>

        <p class="text-center text-xs mt-6" style="color: var(--text-dim);">
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
import { ref, nextTick, onMounted, onUnmounted } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import * as THREE from 'three'

const canvas = ref(null)
const terminalBody = ref(null)
const inputRef = ref(null)
const currentInput = ref('')
const booting = ref(true)
const history = ref([])
const cmdHistory = ref([])
const cmdHistoryIdx = ref(-1)
const router = useRouter()

// Command definitions
const COMMANDS = {
  whoami: () => `<span style="color: var(--cyan);">ryo</span> — Full Stack Engineer @ Tokyo`,
  pwd: () => `<span style="color: var(--violet-light);">/home/ryo/suz-ry</span>`,
  ls: () => `<span style="color: var(--cyan);">career</span>  <span style="color: var(--cyan);">products</span>  <span style="color: var(--cyan);">setup</span>  <span style="color: var(--cyan);">games</span>  <span style="color: var(--violet-light);">lab</span>  <span style="color: var(--text-muted);">about.txt</span>`,
  date: () => `<span style="color: var(--text-muted);">${new Date().toLocaleString('ja-JP', { timeZone: 'Asia/Tokyo' })} JST</span>`,
  'cat about.txt': () => `<span style="color: var(--text-muted);">Name:    </span><span style="color: var(--text);">Ryo Suzuki</span>\n<span style="color: var(--text-muted);">Role:    </span><span style="color: var(--text);">Full Stack Engineer</span>\n<span style="color: var(--text-muted);">Location:</span><span style="color: var(--text);"> Tokyo, Japan</span>\n<span style="color: var(--text-muted);">Stack:   </span><span style="color: var(--cyan);">Vue.js · Python · AWS</span>\n<span style="color: var(--text-muted);">Hobbies: </span><span style="color: var(--violet-light);">天体観測 · ゲーム · 旅行</span>`,
  sl: () => `<span style="color: var(--amber);">      ====        ________                ___________</span>\n<span style="color: var(--amber);">  _D _|  |_______/        \\__I_I_____===__|_________|</span>\n<span style="color: var(--amber);">   |(_)---  |   H\\________/ |   |        =|___ ___|</span>\n<span style="color: var(--amber);">   /     |  |   H  |  |     |   |         ||_| |_||</span>\n<span style="color: var(--amber);">  |      |  |   H  |__--------------------| [___] |</span>\n<span style="color: var(--amber);">  | ________|___H__/__|_____/[][]~\\_______|       |</span>\n<span style="color: var(--amber);">  |/ |   |-----------I_____I [][] []  D   |=======|__</span>\n<span style="color: var(--cyan);">__/ =| o |=-~~\\  /~~\\  /~~\\  /~~\\ ____Y___________|__</span>\n<span style="color: var(--cyan);">" | |   |  <span style="color: var(--green);">O</span> | |  <span style="color: var(--green);">O</span> | |  <span style="color: var(--green);">O</span> | |  <span style="color: var(--green);">O</span> |          ||</span>\n<span style="color: var(--cyan);">  \\_____/  \\_____/ \\_____/ \\_____/</span>`,
  uname: () => `<span style="color: var(--text);">Darwin suz-ry 25.0.0 Darwin Kernel Version 25.0.0 arm64</span>`,
  help: () => `<span style="color: var(--violet-light);">Available commands:</span>\n  <span style="color: var(--cyan);">whoami</span>       who is ryo?\n  <span style="color: var(--cyan);">ls</span>           list pages\n  <span style="color: var(--cyan);">cd &lt;page&gt;</span>    navigate to page\n  <span style="color: var(--cyan);">cat about.txt</span> read about file\n  <span style="color: var(--cyan);">date</span>         current time\n  <span style="color: var(--cyan);">pwd</span>          current path\n  <span style="color: var(--cyan);">uname</span>        system info\n  <span style="color: var(--cyan);">sl</span>           steam locomotive\n  <span style="color: var(--cyan);">clear</span>        clear terminal\n  <span style="color: var(--cyan);">help</span>         show this help`,
  clear: () => null,
}

const PAGE_MAP = {
  career: '/career',
  products: '/products',
  setup: '/setup',
  games: '/games',
  lab: '/lab',
  home: '/',
  '~': '/',
}

function parseCommand(input) {
  const trimmed = input.trim()
  if (!trimmed) return null

  // cd command
  const cdMatch = trimmed.match(/^cd\s+(.+)$/)
  if (cdMatch) {
    const target = cdMatch[1].trim()
    const route = PAGE_MAP[target]
    if (route) {
      return { output: `<span style="color: var(--green);">Navigating to /${target}...</span>`, navigate: route }
    }
    return { output: `<span style="color: #ef4444;">cd: ${target}: No such page</span>` }
  }

  if (COMMANDS[trimmed] !== undefined) {
    return { output: COMMANDS[trimmed]() }
  }

  return { output: `<span style="color: #ef4444;">command not found: ${trimmed}</span>` }
}

async function runCommand() {
  const cmd = currentInput.value.trim()
  if (!cmd) return

  cmdHistory.value.unshift(cmd)
  cmdHistoryIdx.value = -1

  if (cmd === 'clear') {
    history.value = []
    currentInput.value = ''
    return
  }

  const result = parseCommand(cmd)
  history.value.push({ cmd, output: result?.output || null })
  currentInput.value = ''

  await nextTick()
  scrollToBottom()

  if (result?.navigate) {
    setTimeout(() => router.push(result.navigate), 600)
  }
}

function historyUp() {
  if (cmdHistoryIdx.value < cmdHistory.value.length - 1) {
    cmdHistoryIdx.value++
    currentInput.value = cmdHistory.value[cmdHistoryIdx.value]
  }
}

function historyDown() {
  if (cmdHistoryIdx.value > 0) {
    cmdHistoryIdx.value--
    currentInput.value = cmdHistory.value[cmdHistoryIdx.value]
  } else {
    cmdHistoryIdx.value = -1
    currentInput.value = ''
  }
}

function tabComplete() {
  const input = currentInput.value
  const allCmds = [...Object.keys(COMMANDS), ...Object.keys(PAGE_MAP).map(k => `cd ${k}`)]
  const matches = allCmds.filter(c => c.startsWith(input) && c !== input)
  if (matches.length === 1) currentInput.value = matches[0]
}

function focusInput() {
  inputRef.value?.focus()
}

function scrollToBottom() {
  if (terminalBody.value) {
    terminalBody.value.scrollTop = terminalBody.value.scrollHeight
  }
}

// Boot sequence
const bootSequence = [
  { cmd: './ryo --introduce', delay: 400 },
]

const introOutput = `<div style="margin-bottom: 0.5rem;">
  <p style="font-size: 0.65rem; color: var(--text-muted); margin-bottom: 0.25rem; font-family: 'JetBrains Mono', monospace;">NAME</p>
  <p style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: clamp(2rem, 5vw, 3.2rem); line-height: 1.1; background: linear-gradient(135deg, #a78bfa, #22d3ee); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;">Ryo Suzuki</p>
</div>
<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.2rem 1rem; font-size: 0.75rem; margin-bottom: 0.5rem;">
  <div><span style="color: var(--text-muted);">ROLE     </span><span style="color: var(--text);">Full Stack Engineer</span></div>
  <div><span style="color: var(--text-muted);">LOC      </span><span style="color: var(--text);">Tokyo, Japan</span></div>
  <div><span style="color: var(--text-muted);">ORG      </span><span style="color: var(--amber);">BtoB SaaS (Maritime)</span></div>
  <div><span style="color: var(--text-muted);">STACK    </span><span style="color: var(--cyan);">AWS · Vue.js · Python</span></div>
</div>
<div style="font-size: 0.75rem; margin-bottom: 0.25rem;"><span style="color: var(--text-muted);">INTERESTS </span><span style="color: var(--violet-light);">天体観測 · LoL · Factorio · 旅行</span></div>
<div style="font-size: 0.75rem; margin-bottom: 0.75rem;"><span style="color: var(--text-muted);">LINKS     </span><a href="https://github.com/ryo-suzukii" target="_blank" style="color: var(--cyan);">github</a> · <a href="https://twitter.com/Hayaa_6211" target="_blank" style="color: var(--cyan);">twitter</a> · <a href="https://zenn.dev/ha" target="_blank" style="color: var(--cyan);">zenn</a></div>
<div style="font-size: 0.7rem; color: var(--text-dim);">Type <span style="color: var(--cyan);">help</span> for available commands, or <span style="color: var(--cyan);">ls</span> to explore</div>`

onMounted(async () => {
  booting.value = true
  await new Promise(r => setTimeout(r, 500))

  // Type the command character by character
  const cmd = bootSequence[0].cmd
  let typed = ''
  history.value.push({ cmd: '', output: null })

  for (let i = 0; i <= cmd.length; i++) {
    typed = cmd.slice(0, i)
    history.value[history.value.length - 1].cmd = typed
    await new Promise(r => setTimeout(r, 55 + Math.random() * 35))
  }

  await new Promise(r => setTimeout(r, 250))
  history.value[history.value.length - 1].output = introOutput

  await nextTick()
  scrollToBottom()
  booting.value = false
  await nextTick()
  inputRef.value?.focus()
})

// Three.js starfield
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

  let fc = 0
  function animate() {
    animId = requestAnimationFrame(animate)
    fc++
    stars.rotation.y += 0.00008
    stars.rotation.x += 0.00004
    if (fc % 2 === 0) renderer.render(scene, camera)
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
.bento-card {
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}
.bento-card:hover {
  transform: scale(1.02);
}
</style>
