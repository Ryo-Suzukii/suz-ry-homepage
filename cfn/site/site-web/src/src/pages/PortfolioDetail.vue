<template>
  <div v-if="portfolio" class="min-h-screen bg-gradient-to-b from-black via-gray-900 to-black text-white">
    <!-- ヘッダー -->
    <div class="relative h-80 overflow-hidden">
      <div ref="headerScene" class="absolute inset-0" />
      <div class="absolute inset-0 bg-black/50" />
      <div class="relative z-10 max-w-4xl mx-auto px-6 h-full flex items-end pb-12">
        <div>
          <div class="flex items-center gap-4 mb-4">
            <router-link to="/portfolio" class="text-gray-400 hover:text-white transition-colors">
              ← 一覧に戻る
            </router-link>
            <span class="text-gray-500">|</span>
            <span class="text-sm text-gray-400 bg-gray-800 px-3 py-1 rounded">{{ portfolio.category }}</span>
            <span class="text-sm text-gray-400">{{ portfolio.date }}</span>
          </div>
          <h1 class="text-4xl md:text-6xl font-bold mb-4">{{ portfolio.title }}</h1>
          <p class="text-xl text-gray-300 max-w-2xl">{{ portfolio.description }}</p>
        </div>
      </div>
    </div>

    <!-- メインコンテンツ -->
    <div class="max-w-4xl mx-auto px-6 py-16">
      <!-- 概要 -->
      <section class="mb-16">
        <div class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-8 border border-gray-700">
          <h2 class="text-3xl font-bold mb-6 text-cyan-400">📋 概要</h2>
          <p class="text-lg leading-relaxed text-gray-300">{{ portfolio.details.overview }}</p>
        </div>
      </section>

      <!-- 技術スタック -->
      <section class="mb-16">
        <h2 class="text-3xl font-bold mb-8 text-purple-400">⚡ 技術スタック</h2>
        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            v-for="tech in portfolio.technologies"
            :key="tech"
            class="bg-gray-800/50 backdrop-blur-sm rounded-lg p-4 border border-gray-700 hover:border-purple-400/50 transition-colors text-center"
          >
            <div class="text-2xl mb-2">{{ getTechIcon(tech) }}</div>
            <div class="font-semibold">{{ tech }}</div>
          </div>
        </div>
      </section>

      <!-- 主要機能 -->
      <section class="mb-16">
        <h2 class="text-3xl font-bold mb-8 text-green-400">✨ 主要機能</h2>
        <div class="grid md:grid-cols-2 gap-6">
          <div
            v-for="(feature, index) in portfolio.details.features"
            :key="index"
            class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700 flex items-start gap-4"
          >
            <div class="w-8 h-8 bg-green-500 rounded-full flex items-center justify-center text-black font-bold text-sm shrink-0 mt-1">
              {{ index + 1 }}
            </div>
            <div>
              <p class="text-gray-300">{{ feature }}</p>
            </div>
          </div>
        </div>
      </section>

      <!-- 技術的課題 -->
      <section class="mb-16">
        <h2 class="text-3xl font-bold mb-8 text-yellow-400">🎯 技術的課題と解決策</h2>
        <div class="space-y-6">
          <div
            v-for="(challenge, index) in portfolio.details.challenges"
            :key="index"
            class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700"
          >
            <div class="flex items-start gap-4">
              <div class="w-8 h-8 bg-yellow-500 rounded-full flex items-center justify-center text-black font-bold text-sm shrink-0 mt-1">
                !
              </div>
              <div>
                <h3 class="text-lg font-semibold mb-2">課題 {{ index + 1 }}</h3>
                <p class="text-gray-300">{{ challenge }}</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- 技術的詳細 -->
      <section v-if="portfolio.details.technicalDetails" class="mb-16">
        <h2 class="text-3xl font-bold mb-8 text-pink-400">🔧 技術的詳細</h2>
        <div class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-8 border border-gray-700">
          <div class="grid md:grid-cols-3 gap-8">
            <div v-if="portfolio.details.technicalDetails.architecture">
              <h3 class="text-lg font-semibold mb-3 text-pink-400">アーキテクチャ</h3>
              <p class="text-gray-300 text-sm">{{ portfolio.details.technicalDetails.architecture }}</p>
            </div>
            <div v-if="portfolio.details.technicalDetails.performance">
              <h3 class="text-lg font-semibold mb-3 text-pink-400">パフォーマンス</h3>
              <p class="text-gray-300 text-sm">{{ portfolio.details.technicalDetails.performance }}</p>
            </div>
            <div v-if="portfolio.details.technicalDetails.deployment">
              <h3 class="text-lg font-semibold mb-3 text-pink-400">デプロイメント</h3>
              <p class="text-gray-300 text-sm">{{ portfolio.details.technicalDetails.deployment }}</p>
            </div>
          </div>
        </div>
      </section>

      <!-- アクション -->
      <section class="mb-16">
        <div class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-8 border border-gray-700 text-center">
          <h2 class="text-2xl font-bold mb-6">プロジェクトを確認</h2>
          <div class="flex justify-center gap-6">
            <a
              v-if="portfolio.githubUrl"
              :href="portfolio.githubUrl"
              target="_blank"
              class="inline-flex items-center gap-3 px-6 py-3 bg-gray-700 hover:bg-gray-600 rounded-lg transition-colors"
            >
              <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385c.6.105.825-.255.825-.57c0-.285-.015-1.23-.015-2.235c-3.015.555-3.795-.735-4.035-1.41c-.135-.345-.72-1.41-1.23-1.695c-.42-.225-1.02-.78-.015-.795c.945-.015 1.62.87 1.845 1.23c1.08 1.815 2.805 1.305 3.495.99c.105-.78.42-1.305.765-1.605c-2.67-.3-5.46-1.335-5.46-5.925c0-1.305.465-2.385 1.23-3.225c-.12-.3-.54-1.53.12-3.18c0 0 1.005-.315 3.3 1.23c.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23c.66 1.65.24 2.88.12 3.18c.765.84 1.23 1.905 1.23 3.225c0 4.605-2.805 5.625-5.475 5.925c.435.375.81 1.095.81 2.22c0 1.605-.015 2.895-.015 3.3c0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z"/>
              </svg>
              GitHub で見る
            </a>
            <a
              v-if="portfolio.liveUrl"
              :href="portfolio.liveUrl"
              target="_blank"
              class="inline-flex items-center gap-3 px-6 py-3 bg-purple-600 hover:bg-purple-700 rounded-lg transition-colors"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
              </svg>
              ライブデモ
            </a>
          </div>
        </div>
      </section>

      <!-- 他のプロジェクト -->
      <section>
        <h2 class="text-3xl font-bold mb-8 text-blue-400">🚀 他のプロジェクト</h2>
        <div class="grid md:grid-cols-2 gap-8">
          <router-link
            v-for="otherProject in otherProjects"
            :key="otherProject.id"
            :to="`/portfolio/${otherProject.id}`"
            class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700 hover:border-blue-400/50 transition-colors group"
          >
            <h3 class="text-xl font-semibold mb-2 group-hover:text-blue-400 transition-colors">{{ otherProject.title }}</h3>
            <p class="text-gray-300 text-sm mb-4 line-clamp-2">{{ otherProject.description }}</p>
            <div class="flex flex-wrap gap-2">
              <span
                v-for="tech in otherProject.technologies.slice(0, 3)"
                :key="tech"
                class="text-xs bg-blue-600/20 text-blue-300 px-2 py-1 rounded"
              >
                {{ tech }}
              </span>
            </div>
          </router-link>
        </div>
      </section>
    </div>
  </div>

  <!-- プロジェクトが見つからない場合 -->
  <div v-else class="min-h-screen bg-black text-white flex items-center justify-center">
    <div class="text-center">
      <div class="text-6xl mb-4">🔍</div>
      <h1 class="text-3xl font-bold mb-4">プロジェクトが見つかりません</h1>
      <p class="text-gray-400 mb-8">指定されたプロジェクトは存在しないか、削除された可能性があります。</p>
      <router-link to="/portfolio" class="px-6 py-3 bg-purple-600 hover:bg-purple-700 rounded-lg transition-colors">
        一覧に戻る
      </router-link>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import * as THREE from 'three'
import { getPortfolioById, getAllPortfolios } from '../data/portfolio.js'

const route = useRoute()
const headerScene = ref(null)

let scene, camera, renderer, mesh, animationId

const portfolio = computed(() => getPortfolioById(route.params.id))
const otherProjects = computed(() => {
  const all = getAllPortfolios()
  return all.filter(p => p.id !== route.params.id).slice(0, 2)
})

function getTechIcon(tech) {
  const icons = {
    'Vue.js': '💚',
    'React': '⚛️',
    'Three.js': '🎮',
    'Node.js': '🟢',
    'Python': '🐍',
    'TypeScript': '💙',
    'JavaScript': '💛',
    'WebGL': '🎨',
    'MongoDB': '🍃',
    'PostgreSQL': '🐘',
    'AWS': '☁️',
    'Docker': '🐳',
    'Kubernetes': '⚙️',
    'FastAPI': '⚡',
    'Express': '🚀',
    'WebSocket': '🔌',
    'OpenAI API': '🤖',
    'D3.js': '📊',
    'Web3.js': '⛓️',
    'Tailwind CSS': '🎨'
  }
  return icons[tech] || '🔧'
}

function initHeaderScene() {
  if (!headerScene.value) return

  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera(75, window.innerWidth / 320, 0.1, 1000)
  renderer = new THREE.WebGLRenderer({ alpha: true })
  
  renderer.setSize(window.innerWidth, 320)
  renderer.setClearColor(0x000000, 0)
  headerScene.value.appendChild(renderer.domElement)

  // 回転する3Dオブジェクト
  const geometry = new THREE.IcosahedronGeometry(20, 1)
  const material = new THREE.MeshBasicMaterial({
    color: 0x6366f1,
    wireframe: true,
    transparent: true,
    opacity: 0.6
  })
  
  mesh = new THREE.Mesh(geometry, material)
  scene.add(mesh)

  // パーティクル
  const particleGeometry = new THREE.BufferGeometry()
  const particleCount = 100
  const positions = new Float32Array(particleCount * 3)

  for (let i = 0; i < particleCount * 3; i++) {
    positions[i] = (Math.random() - 0.5) * 400
  }

  particleGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))
  
  const particleMaterial = new THREE.PointsMaterial({
    color: 0x8b5cf6,
    size: 2,
    transparent: true,
    opacity: 0.4
  })

  const particles = new THREE.Points(particleGeometry, particleMaterial)
  scene.add(particles)

  camera.position.z = 100
  animate()
}

function animate() {
  animationId = requestAnimationFrame(animate)
  
  if (mesh) {
    mesh.rotation.x += 0.005
    mesh.rotation.y += 0.01
  }

  renderer.render(scene, camera)
}

onMounted(() => {
  initHeaderScene()
})

onUnmounted(() => {
  if (animationId) {
    cancelAnimationFrame(animationId)
  }
  if (renderer && headerScene.value) {
    headerScene.value.removeChild(renderer.domElement)
  }
})
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>