<template>
  <div class="min-h-screen bg-gradient-to-b from-black via-gray-900 to-black text-white">
    <!-- ヘッダー -->
    <div class="relative h-64 flex items-center justify-center">
      <div ref="headerScene" class="absolute inset-0" />
      <div class="relative z-10 text-center">
        <h1 class="text-5xl font-bold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-cyan-400 to-blue-400">
          このサイトについて
        </h1>
        <p class="text-xl text-gray-300">技術と宇宙への情熱を込めて</p>
      </div>
    </div>

    <!-- メインコンテンツ -->
    <div class="max-w-4xl mx-auto px-6 py-12">
      <!-- サイトコンセプト -->
      <section class="mb-16">
        <h2 class="text-3xl font-bold mb-6 text-cyan-400">🚀 サイトコンセプト</h2>
        <div class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-8 border border-gray-700">
          <p class="text-lg leading-relaxed mb-6">
            このポートフォリオサイトは、宇宙への憧れと最新技術への探究心を表現した作品です。
            無限に広がる宇宙のように、テクノロジーの可能性も無限大であることを表現しています。
          </p>
          <p class="text-gray-300 leading-relaxed">
            Three.jsを使用した3D表現により、従来の平面的なWebサイトを超えた没入感のあるユーザー体験を提供します。
            特にプロフィールページでは、冥王星から地球まで宇宙を旅するような体験ができます。
          </p>
        </div>
      </section>

      <!-- 技術スタック -->
      <section class="mb-16">
        <h2 class="text-3xl font-bold mb-6 text-purple-400">⚡ 使用技術</h2>
        <div class="grid md:grid-cols-2 gap-8">
          <div v-for="category in techStack" :key="category.title" class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700">
            <h3 class="text-xl font-semibold mb-4 flex items-center">
              <span class="mr-3">{{ category.icon }}</span>
              {{ category.title }}
            </h3>
            <ul class="space-y-3">
              <li v-for="tech in category.technologies" :key="tech.name" class="flex justify-between items-center">
                <span class="text-gray-300">{{ tech.name }}</span>
                <span class="text-sm text-gray-500">{{ tech.version }}</span>
              </li>
            </ul>
          </div>
        </div>
      </section>

      <!-- 特徴・機能 -->
      <section class="mb-16">
        <h2 class="text-3xl font-bold mb-6 text-green-400">✨ 特徴・機能</h2>
        <div class="grid md:grid-cols-3 gap-6">
          <div v-for="feature in features" :key="feature.title" class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700 hover:border-green-400/50 transition-colors">
            <div class="text-3xl mb-4">{{ feature.icon }}</div>
            <h3 class="text-xl font-semibold mb-3">{{ feature.title }}</h3>
            <p class="text-gray-300 text-sm">{{ feature.description }}</p>
          </div>
        </div>
      </section>

      <!-- パフォーマンス -->
      <section class="mb-16">
        <h2 class="text-3xl font-bold mb-6 text-yellow-400">📊 パフォーマンス</h2>
        <div class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-8 border border-gray-700">
          <div class="grid md:grid-cols-4 gap-8">
            <div v-for="metric in performanceMetrics" :key="metric.label" class="text-center">
              <div class="text-3xl font-bold text-yellow-400 mb-2">{{ metric.value }}</div>
              <div class="text-sm text-gray-400">{{ metric.label }}</div>
            </div>
          </div>
        </div>
      </section>

      <!-- 今後の予定 -->
      <section>
        <h2 class="text-3xl font-bold mb-6 text-pink-400">🔮 今後の予定</h2>
        <div class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-8 border border-gray-700">
          <ul class="space-y-4">
            <li v-for="plan in futurePlans" :key="plan" class="flex items-start">
              <span class="text-pink-400 mr-3">•</span>
              <span class="text-gray-300">{{ plan }}</span>
            </li>
          </ul>
        </div>
      </section>
    </div>

    <!-- フッターナビゲーション -->
    <div class="max-w-4xl mx-auto px-6 py-12">
      <div class="flex justify-between items-center">
        <router-link to="/" class="btn-back">
          ← ホームに戻る
        </router-link>
        <router-link to="/about-me" class="btn-next">
          自分について →
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import * as THREE from 'three'

const headerScene = ref(null)
let scene, camera, renderer, particles, animationId

const techStack = [
  {
    title: 'Frontend',
    icon: '🎨',
    technologies: [
      { name: 'Vue.js', version: 'v3.5' },
      { name: 'Three.js', version: 'v0.180' },
      { name: 'Tailwind CSS', version: 'v4.1' },
      { name: 'Vite', version: 'v6.3' }
    ]
  },
  {
    title: 'Development',
    icon: '🛠️',
    technologies: [
      { name: 'TypeScript', version: 'Latest' },
      { name: 'Vue Router', version: 'v4.5' },
      { name: 'Pinia', version: 'v3.0' },
      { name: 'PostCSS', version: 'v8.5' }
    ]
  }
]

const features = [
  {
    icon: '🌌',
    title: '3D宇宙体験',
    description: 'Three.jsによるリアルタイム3D宇宙シミュレーション'
  },
  {
    icon: '📱',
    title: 'レスポンシブ',
    description: 'あらゆるデバイスで最適化された表示'
  },
  {
    icon: '⚡',
    title: '高速パフォーマンス',
    description: 'Viteによる最適化とコード分割'
  },
  {
    icon: '🎯',
    title: 'インタラクティブ',
    description: '没入感のあるユーザーインターフェース'
  },
  {
    icon: '🌍',
    title: 'アクセシブル',
    description: 'WCAG準拠のアクセシビリティ対応'
  },
  {
    icon: '🔄',
    title: 'SPA構成',
    description: 'シームレスなページ遷移'
  }
]

const performanceMetrics = [
  { label: 'Performance', value: '95+' },
  { label: 'Accessibility', value: '100' },
  { label: 'Best Practices', value: '100' },
  { label: 'SEO', value: '90+' }
]

const futurePlans = [
  'WebGLエフェクトのさらなる最適化',
  'VRモードの実装検討',
  '音響効果の追加（Space Audio）',
  'ダークモード/ライトモードの切り替え',
  '多言語対応（日本語/英語）',
  'プログレッシブWebアプリ（PWA）化'
]

function initHeaderScene() {
  if (!headerScene.value) return

  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera(75, window.innerWidth / 200, 0.1, 1000)
  renderer = new THREE.WebGLRenderer({ alpha: true })
  
  renderer.setSize(window.innerWidth, 200)
  renderer.setClearColor(0x000000, 0)
  headerScene.value.appendChild(renderer.domElement)

  // パーティクル作成
  const particleGeometry = new THREE.BufferGeometry()
  const particleCount = 300
  const positions = new Float32Array(particleCount * 3)

  for (let i = 0; i < particleCount * 3; i += 3) {
    positions[i] = (Math.random() - 0.5) * 200
    positions[i + 1] = (Math.random() - 0.5) * 200
    positions[i + 2] = (Math.random() - 0.5) * 200
  }

  particleGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))
  
  const particleMaterial = new THREE.PointsMaterial({
    color: 0x00ffff,
    size: 3,
    transparent: true,
    opacity: 0.6
  })

  particles = new THREE.Points(particleGeometry, particleMaterial)
  scene.add(particles)

  camera.position.z = 50

  animate()
}

function animate() {
  animationId = requestAnimationFrame(animate)
  
  if (particles) {
    particles.rotation.x += 0.001
    particles.rotation.y += 0.002
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
</style>