<template>
  <div class="min-h-screen bg-gradient-to-b from-black via-gray-900 to-black text-white">
    <!-- ヘッダー -->
    <div class="relative h-64 flex items-center justify-center">
      <div ref="headerScene" class="absolute inset-0" />
      <div class="relative z-10 text-center">
        <h1 class="text-5xl font-bold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-purple-400 to-pink-400">
          成果物
        </h1>
        <p class="text-xl text-gray-300">技術への情熱を形にした作品たち</p>
      </div>
    </div>

    <!-- フィルター -->
    <div class="max-w-6xl mx-auto px-6 mb-12">
      <div class="flex flex-wrap justify-center gap-4">
        <button
          @click="selectedCategory = 'all'"
          :class="['filter-btn', selectedCategory === 'all' ? 'active' : '']"
        >
          All
        </button>
        <button
          v-for="category in categories"
          :key="category"
          @click="selectedCategory = category"
          :class="['filter-btn', selectedCategory === category ? 'active' : '']"
        >
          {{ category }}
        </button>
      </div>
    </div>

    <!-- ポートフォリオグリッド -->
    <div class="max-w-6xl mx-auto px-6 pb-16">
      <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
        <div
          v-for="item in filteredPortfolios"
          :key="item.id"
          class="portfolio-card group cursor-pointer"
          @click="navigateToDetail(item.id)"
        >
          <!-- 画像 -->
          <div class="relative overflow-hidden rounded-t-xl aspect-video bg-gray-800">
            <div class="absolute inset-0 bg-gradient-to-br from-purple-500/20 to-pink-500/20" />
            <div class="absolute inset-0 flex items-center justify-center">
              <div class="text-6xl opacity-50">{{ getProjectIcon(item.category) }}</div>
            </div>
            <!-- ホバー効果 -->
            <div class="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center justify-center">
              <div class="text-center">
                <div class="text-2xl mb-2">🚀</div>
                <p class="text-sm font-semibold">詳細を見る</p>
              </div>
            </div>
          </div>

          <!-- コンテンツ -->
          <div class="p-6 bg-gray-800/50 backdrop-blur-sm rounded-b-xl border border-gray-700 border-t-0 group-hover:border-purple-400/50 transition-colors">
            <div class="flex justify-between items-start mb-3">
              <h3 class="text-xl font-bold group-hover:text-purple-400 transition-colors">{{ item.title }}</h3>
              <span class="text-xs text-gray-400 bg-gray-700 px-2 py-1 rounded">{{ item.date }}</span>
            </div>
            
            <p class="text-gray-300 text-sm mb-4 line-clamp-2">{{ item.description }}</p>
            
            <!-- 技術タグ -->
            <div class="flex flex-wrap gap-2 mb-4">
              <span
                v-for="tech in item.technologies.slice(0, 3)"
                :key="tech"
                class="text-xs bg-purple-600/20 text-purple-300 px-2 py-1 rounded"
              >
                {{ tech }}
              </span>
              <span v-if="item.technologies.length > 3" class="text-xs text-gray-400">
                +{{ item.technologies.length - 3 }}
              </span>
            </div>

            <!-- アクション -->
            <div class="flex justify-between items-center">
              <div class="flex gap-3">
                <a
                  v-if="item.githubUrl"
                  :href="item.githubUrl"
                  target="_blank"
                  @click.stop
                  class="text-gray-400 hover:text-white transition-colors"
                >
                  <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385c.6.105.825-.255.825-.57c0-.285-.015-1.23-.015-2.235c-3.015.555-3.795-.735-4.035-1.41c-.135-.345-.72-1.41-1.23-1.695c-.42-.225-1.02-.78-.015-.795c.945-.015 1.62.87 1.845 1.23c1.08 1.815 2.805 1.305 3.495.99c.105-.78.42-1.305.765-1.605c-2.67-.3-5.46-1.335-5.46-5.925c0-1.305.465-2.385 1.23-3.225c-.12-.3-.54-1.53.12-3.18c0 0 1.005-.315 3.3 1.23c.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23c.66 1.65.24 2.88.12 3.18c.765.84 1.23 1.905 1.23 3.225c0 4.605-2.805 5.625-5.475 5.925c.435.375.81 1.095.81 2.22c0 1.605-.015 2.895-.015 3.3c0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z"/>
                  </svg>
                </a>
                <a
                  v-if="item.liveUrl"
                  :href="item.liveUrl"
                  target="_blank"
                  @click.stop
                  class="text-gray-400 hover:text-white transition-colors"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/>
                  </svg>
                </a>
              </div>
              <span class="text-xs text-gray-500">{{ item.category }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 空の状態 -->
      <div v-if="filteredPortfolios.length === 0" class="text-center py-16">
        <div class="text-6xl mb-4">🔍</div>
        <h3 class="text-xl font-semibold mb-2">該当する成果物が見つかりません</h3>
        <p class="text-gray-400">フィルターを変更してみてください</p>
      </div>
    </div>

    <!-- 統計情報 -->
    <div class="max-w-4xl mx-auto px-6 pb-16">
      <div class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-8 border border-gray-700">
        <h2 class="text-2xl font-bold mb-6 text-center text-purple-400">開発統計</h2>
        <div class="grid md:grid-cols-4 gap-8">
          <div v-for="stat in stats" :key="stat.label" class="text-center">
            <div class="text-3xl font-bold text-purple-400 mb-2">{{ stat.value }}</div>
            <div class="text-sm text-gray-400">{{ stat.label }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- フッターナビゲーション -->
    <div class="max-w-4xl mx-auto px-6 py-12">
      <div class="flex justify-between items-center">
        <router-link to="/about-me" class="btn-back">
          ← 自分について
        </router-link>
        <router-link to="/skills" class="btn-next">
          スキルセット →
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import * as THREE from 'three'
import { getAllPortfolios } from '../data/portfolio.js'

const router = useRouter()
const headerScene = ref(null)
const selectedCategory = ref('all')

let scene, camera, renderer, floatingObjects, animationId

const portfolios = getAllPortfolios()

const categories = computed(() => {
  const cats = [...new Set(portfolios.map(item => item.category))]
  return cats.sort()
})

const filteredPortfolios = computed(() => {
  if (selectedCategory.value === 'all') {
    return portfolios
  }
  return portfolios.filter(item => item.category === selectedCategory.value)
})

const stats = computed(() => [
  { label: 'Total Projects', value: portfolios.length },
  { label: 'Technologies', value: new Set(portfolios.flatMap(p => p.technologies)).size },
  { label: 'Categories', value: categories.value.length },
  { label: 'Years Active', value: '4+' }
])

function getProjectIcon(category) {
  const icons = {
    'Web Application': '🌐',
    'Full Stack Application': '⚡',
    'Data Visualization': '📊',
    'Mobile App': '📱',
    'Game': '🎮',
    'Desktop App': '💻'
  }
  return icons[category] || '💡'
}

function navigateToDetail(id) {
  router.push(`/portfolio/${id}`)
}

function initHeaderScene() {
  if (!headerScene.value) return

  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera(75, window.innerWidth / 200, 0.1, 1000)
  renderer = new THREE.WebGLRenderer({ alpha: true })
  
  renderer.setSize(window.innerWidth, 200)
  renderer.setClearColor(0x000000, 0)
  headerScene.value.appendChild(renderer.domElement)

  // 浮遊するオブジェクト
  const geometries = [
    new THREE.BoxGeometry(5, 5, 5),
    new THREE.SphereGeometry(3, 16, 16),
    new THREE.ConeGeometry(3, 6, 8)
  ]

  floatingObjects = []
  for (let i = 0; i < 15; i++) {
    const geometry = geometries[Math.floor(Math.random() * geometries.length)]
    const material = new THREE.MeshBasicMaterial({
      color: new THREE.Color().setHSL(Math.random() * 0.7 + 0.5, 0.7, 0.5),
      wireframe: true,
      transparent: true,
      opacity: 0.6
    })
    
    const mesh = new THREE.Mesh(geometry, material)
    mesh.position.set(
      (Math.random() - 0.5) * 200,
      (Math.random() - 0.5) * 100,
      (Math.random() - 0.5) * 100
    )
    mesh.rotation.set(
      Math.random() * Math.PI * 2,
      Math.random() * Math.PI * 2,
      Math.random() * Math.PI * 2
    )
    
    scene.add(mesh)
    floatingObjects.push(mesh)
  }

  camera.position.z = 50
  animate()
}

function animate() {
  animationId = requestAnimationFrame(animate)
  
  floatingObjects.forEach((obj, index) => {
    obj.rotation.x += 0.01 + index * 0.001
    obj.rotation.y += 0.01 + index * 0.001
    obj.position.y += Math.sin(Date.now() * 0.001 + index) * 0.1
  })

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
.portfolio-card {
  transform: scale(1);
  transition: all 0.3s;
  z-index: 1;
}

.portfolio-card:hover {
  transform: scale(1.05);
  z-index: 10;
}

.filter-btn {
  padding: 0.5rem 1rem;
  background-color: rgb(31 41 55);
  border: 1px solid rgb(75 85 99);
  border-radius: 0.5rem;
  transition: all 0.3s;
  font-size: 0.875rem;
}

.filter-btn:hover {
  background-color: rgb(55 65 81);
  border-color: rgb(107 114 128);
}

.filter-btn.active {
  background-color: rgb(147 51 234);
  border-color: rgb(168 85 247);
  color: white;
}

.btn-back, .btn-next {
  padding: 0.75rem 1.5rem;
  background-color: rgb(31 41 55);
  border: 1px solid rgb(75 85 99);
  border-radius: 0.5rem;
  transition: all 0.3s;
}

.btn-back:hover, .btn-next:hover {
  background-color: rgb(55 65 81);
  border-color: rgb(107 114 128);
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
