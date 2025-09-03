<template>
  <div class="relative w-full bg-black text-white" style="min-height: 800vh;">
    <!-- 3D宇宙シーン -->
    <div ref="spaceContainer" class="fixed inset-0 z-0" />
    
    <!-- スクロールコンテンツ -->
    <div class="relative z-10">
      <!-- セクション1: 冥王星 -->
      <section class="h-screen flex items-center justify-center" data-planet="pluto">
        <div class="text-center animate-fade-in">
          <div class="text-8xl mb-8">🪐</div>
          <h1 class="text-6xl font-bold mb-6 text-transparent bg-clip-text bg-gradient-to-r from-purple-400 to-blue-400">
            Profile Journey
          </h1>
          <p class="text-xl text-gray-300 mb-8">冥王星からの旅を始めましょう</p>
          <div class="text-sm text-gray-500">スクロールして宇宙を旅してください</div>
        </div>
      </section>

      <!-- セクション2: 海王星 -->
      <section class="h-screen flex items-center justify-center" data-planet="neptune">
        <div class="max-w-2xl text-center">
          <div class="text-6xl mb-6">🔵</div>
          <h2 class="text-4xl font-bold mb-6 text-cyan-400">海王星 - 探究心</h2>
          <div class="bg-black/50 backdrop-blur-sm rounded-xl p-8 border border-cyan-400/30">
            <p class="text-lg leading-relaxed mb-4">
              最も遠い惑星のように、常に新しい知識の境界を求めています。
            </p>
            <p class="text-gray-300">
              未知の技術領域への探求心と、深い理解を追求する姿勢が私の原動力です。
            </p>
          </div>
        </div>
      </section>

      <!-- セクション3: 天王星 -->
      <section class="h-screen flex items-center justify-center" data-planet="uranus">
        <div class="max-w-2xl text-center">
          <div class="text-6xl mb-6">🌀</div>
          <h2 class="text-4xl font-bold mb-6 text-blue-400">天王星 - 革新性</h2>
          <div class="bg-black/50 backdrop-blur-sm rounded-xl p-8 border border-blue-400/30">
            <p class="text-lg leading-relaxed mb-4">
              独特な自転軸を持つ天王星のように、従来とは異なる視点でアプローチします。
            </p>
            <p class="text-gray-300">
              既存の枠組みにとらわれない革新的なソリューションを生み出すことを重視しています。
            </p>
          </div>
        </div>
      </section>

      <!-- セクション4: 土星 -->
      <section class="h-screen flex items-center justify-center" data-planet="saturn">
        <div class="max-w-2xl text-center">
          <div class="text-6xl mb-6">🪐</div>
          <h2 class="text-4xl font-bold mb-6 text-yellow-400">土星 - 体系化</h2>
          <div class="bg-black/50 backdrop-blur-sm rounded-xl p-8 border border-yellow-400/30">
            <p class="text-lg leading-relaxed mb-4">
              美しいリングシステムのように、整理された知識体系を構築します。
            </p>
            <p class="text-gray-300">
              複雑なプロジェクトも体系的にアプローチし、保守性の高いシステムを設計します。
            </p>
          </div>
        </div>
      </section>

      <!-- セクション5: 木星 -->
      <section class="h-screen flex items-center justify-center" data-planet="jupiter">
        <div class="max-w-2xl text-center">
          <div class="text-6xl mb-6">🟤</div>
          <h2 class="text-4xl font-bold mb-6 text-orange-400">木星 - リーダーシップ</h2>
          <div class="bg-black/50 backdrop-blur-sm rounded-xl p-8 border border-orange-400/30">
            <p class="text-lg leading-relaxed mb-4">
              太陽系最大の惑星として、チームを牽引する力を持っています。
            </p>
            <p class="text-gray-300">
              大きな視野でプロジェクト全体を俯瞰し、メンバーを適切な方向へ導きます。
            </p>
          </div>
        </div>
      </section>

      <!-- セクション6: 火星 -->
      <section class="h-screen flex items-center justify-center" data-planet="mars">
        <div class="max-w-2xl text-center">
          <div class="text-6xl mb-6">🔴</div>
          <h2 class="text-4xl font-bold mb-6 text-red-400">火星 - 情熱</h2>
          <div class="bg-black/50 backdrop-blur-sm rounded-xl p-8 border border-red-400/30">
            <p class="text-lg leading-relaxed mb-4">
              赤い惑星の情熱で、困難な課題にも果敢に挑戦します。
            </p>
            <p class="text-gray-300">
              テクノロジーへの情熱を原動力に、常に品質の高いソフトウェアを追求します。
            </p>
          </div>
        </div>
      </section>

      <!-- セクション7: 地球 -->
      <section class="h-screen flex items-center justify-center" data-planet="earth">
        <div class="max-w-4xl text-center">
          <div class="text-8xl mb-8">🌍</div>
          <h2 class="text-5xl font-bold mb-8 text-green-400">地球 - ホーム</h2>
          <div class="bg-black/50 backdrop-blur-sm rounded-xl p-8 border border-green-400/30">
            <p class="text-2xl leading-relaxed mb-8">
              長い旅を経て、最終的にたどり着くのは「人」のためのテクノロジー。
            </p>
            
            <!-- 個人情報カード -->
            <div class="grid md:grid-cols-3 gap-8 mb-8">
              <div class="bg-gray-800/50 rounded-lg p-6">
                <h3 class="text-lg font-semibold mb-3 text-green-400">基本情報</h3>
                <div class="space-y-2 text-left">
                  <div class="flex justify-between">
                    <span class="text-gray-400">名前:</span>
                    <span>Full Stack Engineer</span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-gray-400">専門:</span>
                    <span>Web Development</span>
                  </div>
                  <div class="flex justify-between">
                    <span class="text-gray-400">経験:</span>
                    <span>4+ Years</span>
                  </div>
                </div>
              </div>
              
              <div class="bg-gray-800/50 rounded-lg p-6">
                <h3 class="text-lg font-semibold mb-3 text-green-400">興味・関心</h3>
                <div class="space-y-2 text-sm">
                  <div class="bg-gray-700 rounded px-2 py-1">🌌 宇宙・天体物理学</div>
                  <div class="bg-gray-700 rounded px-2 py-1">🤖 人工知能・機械学習</div>
                  <div class="bg-gray-700 rounded px-2 py-1">🎮 ゲーム開発</div>
                  <div class="bg-gray-700 rounded px-2 py-1">🎵 音楽・DTM</div>
                </div>
              </div>
              
              <div class="bg-gray-800/50 rounded-lg p-6">
                <h3 class="text-lg font-semibold mb-3 text-green-400">目標・ビジョン</h3>
                <div class="space-y-2 text-sm text-left">
                  <div>• より良いUXの追求</div>
                  <div>• 技術の社会実装</div>
                  <div>• 持続可能な開発</div>
                  <div>• 知識の共有・教育</div>
                </div>
              </div>
            </div>

            <div class="text-gray-300">
              宇宙の広さに比べれば小さな存在ですが、<br>
              テクノロジーで人々の生活をより豊かにすることが私の使命です。
            </div>
          </div>
        </div>
      </section>

      <!-- 最終セクション: Contact -->
      <section class="h-screen flex items-center justify-center" data-planet="contact">
        <div class="text-center">
          <div class="text-6xl mb-8">📡</div>
          <h2 class="text-4xl font-bold mb-8 text-purple-400">Contact</h2>
          <p class="text-xl text-gray-300 mb-8">宇宙の旅はここで終わりですが、<br>新たなプロジェクトの始まりかもしれません</p>
          <div class="flex justify-center gap-8">
            <router-link to="/contact" class="px-8 py-4 bg-purple-600 hover:bg-purple-700 rounded-lg transition-colors text-lg font-semibold">
              お問い合わせ
            </router-link>
            <router-link to="/" class="px-8 py-4 bg-gray-700 hover:bg-gray-600 rounded-lg transition-colors text-lg font-semibold">
              ホームに戻る
            </router-link>
          </div>
        </div>
      </section>
    </div>

    <!-- スクロールプログレス -->
    <div class="fixed top-4 right-4 z-20">
      <div class="w-16 h-16 relative">
        <svg class="transform -rotate-90 w-full h-full">
          <circle
            cx="32"
            cy="32"
            r="28"
            stroke="currentColor"
            stroke-width="4"
            fill="transparent"
            class="text-gray-700"
          />
          <circle
            cx="32"
            cy="32"
            r="28"
            stroke="currentColor"
            stroke-width="4"
            fill="transparent"
            class="text-purple-400 transition-all duration-300"
            :stroke-dasharray="circumference"
            :stroke-dashoffset="circumference - (scrollProgress / 100) * circumference"
          />
        </svg>
        <div class="absolute inset-0 flex items-center justify-center text-xs font-bold">
          {{ Math.round(scrollProgress) }}%
        </div>
      </div>
    </div>

    <!-- 現在の惑星表示 -->
    <div class="fixed bottom-4 left-4 z-20 bg-black/50 backdrop-blur-sm rounded-lg px-4 py-2">
      <div class="flex items-center gap-3">
        <span class="text-2xl">{{ currentPlanetIcon }}</span>
        <span class="text-sm">{{ currentPlanetName }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import * as THREE from 'three'

const spaceContainer = ref(null)
const scrollProgress = ref(0)
const currentSection = ref(0)

let scene, camera, renderer, planets = [], stars, animationId
let isScrolling = false

const circumference = computed(() => 2 * Math.PI * 28)

const planetData = [
  { name: '冥王星', icon: '🪐', color: 0x8B4CBE, distance: 1000 },
  { name: '海王星', icon: '🔵', color: 0x0077BE, distance: 800 },
  { name: '天王星', icon: '🌀', color: 0x4FD0E4, distance: 600 },
  { name: '土星', icon: '🪐', color: 0xFFD700, distance: 400 },
  { name: '木星', icon: '🟤', color: 0xD8CA9D, distance: 200 },
  { name: '火星', icon: '🔴', color: 0xFF6B35, distance: 100 },
  { name: '地球', icon: '🌍', color: 0x6B93D6, distance: 0 },
  { name: 'Contact', icon: '📡', color: 0x9333EA, distance: -100 }
]

const currentPlanetIcon = computed(() => planetData[currentSection.value]?.icon || '🌌')
const currentPlanetName = computed(() => planetData[currentSection.value]?.name || 'Deep Space')

function initThreeJS() {
  if (!spaceContainer.value) return

  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 2000)
  renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true })
  
  renderer.setSize(window.innerWidth, window.innerHeight)
  renderer.setClearColor(0x000000, 1)
  spaceContainer.value.appendChild(renderer.domElement)

  // 星空背景
  createStarField()
  
  // 惑星を作成
  createPlanets()

  camera.position.set(0, 0, 1000)
  camera.lookAt(0, 0, 0)

  animate()
}

function createStarField() {
  const starGeometry = new THREE.BufferGeometry()
  const starCount = 2000
  const positions = new Float32Array(starCount * 3)
  const colors = new Float32Array(starCount * 3)

  for (let i = 0; i < starCount; i++) {
    positions[i * 3] = (Math.random() - 0.5) * 4000
    positions[i * 3 + 1] = (Math.random() - 0.5) * 4000
    positions[i * 3 + 2] = (Math.random() - 0.5) * 4000

    const color = new THREE.Color()
    color.setHSL(Math.random() * 0.2 + 0.5, 0.55, Math.random() * 0.25 + 0.55)
    colors[i * 3] = color.r
    colors[i * 3 + 1] = color.g
    colors[i * 3 + 2] = color.b
  }

  starGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))
  starGeometry.setAttribute('color', new THREE.BufferAttribute(colors, 3))
  
  const starMaterial = new THREE.PointsMaterial({
    size: 2,
    vertexColors: true,
    transparent: true,
    opacity: 0.8
  })

  stars = new THREE.Points(starGeometry, starMaterial)
  scene.add(stars)
}

function createPlanets() {
  planetData.forEach((planetInfo, index) => {
    const geometry = new THREE.SphereGeometry(20 + index * 5, 32, 32)
    const material = new THREE.MeshBasicMaterial({
      color: planetInfo.color,
      transparent: true,
      opacity: 0.8
    })

    const planet = new THREE.Mesh(geometry, material)
    planet.position.z = planetInfo.distance
    planet.position.x = (Math.random() - 0.5) * 200
    planet.position.y = (Math.random() - 0.5) * 200

    // 惑星のリング（土星用）
    if (index === 3) {
      const ringGeometry = new THREE.RingGeometry(30, 45, 32)
      const ringMaterial = new THREE.MeshBasicMaterial({
        color: 0xFFD700,
        transparent: true,
        opacity: 0.6,
        side: THREE.DoubleSide
      })
      const ring = new THREE.Mesh(ringGeometry, ringMaterial)
      ring.rotation.x = Math.PI / 2
      planet.add(ring)
    }

    scene.add(planet)
    planets.push(planet)
  })
}

function handleScroll() {
  if (isScrolling) return
  isScrolling = true

  const scrollTop = window.pageYOffset
  const docHeight = document.documentElement.scrollHeight - window.innerHeight
  const scrollPercent = scrollTop / docHeight
  
  scrollProgress.value = scrollPercent * 100
  currentSection.value = Math.floor(scrollPercent * planetData.length)
  
  // カメラ位置を更新
  const targetZ = 1000 - (scrollPercent * 1100)
  camera.position.z = THREE.MathUtils.lerp(camera.position.z, targetZ, 0.1)

  // 惑星の回転
  planets.forEach((planet, index) => {
    planet.rotation.y += 0.01 + index * 0.002
    planet.rotation.x += 0.005
    
    // スクロールに応じて透明度を調整
    const distance = Math.abs(camera.position.z - planet.position.z)
    const opacity = Math.max(0.1, Math.min(1, 500 / distance))
    planet.material.opacity = opacity
  })

  setTimeout(() => {
    isScrolling = false
  }, 16)
}

function animate() {
  animationId = requestAnimationFrame(animate)
  
  if (stars) {
    stars.rotation.y += 0.0002
  }

  planets.forEach((planet, index) => {
    planet.rotation.y += 0.001 + index * 0.0005
    
    // 浮遊効果
    planet.position.y += Math.sin(Date.now() * 0.001 + index) * 0.1
  })

  renderer.render(scene, camera)
}

function handleResize() {
  if (camera && renderer) {
    camera.aspect = window.innerWidth / window.innerHeight
    camera.updateProjectionMatrix()
    renderer.setSize(window.innerWidth, window.innerHeight)
  }
}

onMounted(() => {
  initThreeJS()
  window.addEventListener('scroll', handleScroll, { passive: true })
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  if (animationId) {
    cancelAnimationFrame(animationId)
  }
  if (renderer && spaceContainer.value) {
    spaceContainer.value.removeChild(renderer.domElement)
  }
  window.removeEventListener('scroll', handleScroll)
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
.animate-fade-in {
  animation: fadeIn 2s ease-in-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}

/* スムーススクロールを有効にする */
html {
  scroll-behavior: smooth;
}

/* 各セクションの間隔を調整 */
section {
  scroll-snap-align: start;
}
</style>