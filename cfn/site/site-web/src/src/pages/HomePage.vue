<template>
  <div class="relative w-full h-screen overflow-hidden bg-black">
    <!-- 3D 宇宙背景 -->
    <div ref="spaceContainer" class="absolute inset-0" />
    
    <!-- メインコンテンツ -->
    <div class="relative z-10 flex flex-col items-center justify-center h-full text-white">
      <!-- ロゴ/タイトル -->
      <div class="text-center mb-8 animate-fade-in">
        <h1 class="text-6xl md:text-8xl font-bold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-blue-400 via-purple-500 to-pink-500">
          Ryo Suzuki
        </h1>
        <p class="text-xl md:text-2xl text-gray-300 mb-2">Full Stack Engineer</p>
        <p class="text-lg text-gray-400">宇宙をテーマにしたポートフォリオサイト</p>
      </div>

      <!-- ナビゲーションメニュー -->
      <nav class="grid grid-cols-2 md:grid-cols-3 gap-6 mt-12">
        <router-link
          v-for="item in navigationItems"
          :key="item.path"
          :to="item.path"
          class="group relative p-6 bg-gray-900/50 backdrop-blur-sm rounded-lg border border-gray-700/50 hover:border-blue-400/50 transition-all duration-300 hover:transform hover:scale-105"
        >
          <div class="text-center">
            <div class="text-3xl mb-3">{{ item.icon }}</div>
            <h3 class="text-lg font-semibold mb-2">{{ item.title }}</h3>
            <p class="text-sm text-gray-400">{{ item.description }}</p>
          </div>
          <div class="absolute inset-0 bg-gradient-to-r from-blue-500/10 to-purple-500/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300 rounded-lg" />
        </router-link>
      </nav>

      <!-- スクロールインジケーター -->
      <div class="absolute bottom-8 left-1/2 transform -translate-x-1/2 animate-bounce">
        <div class="flex flex-col items-center">
          <p class="text-sm text-gray-400 mb-2">Explore the universe</p>
          <div class="w-6 h-10 border-2 border-gray-400 rounded-full flex justify-center">
            <div class="w-1 h-3 bg-gray-400 rounded-full mt-2 animate-pulse" />
          </div>
        </div>
      </div>
    </div>

    <!-- パーティクル効果 -->
    <div class="absolute inset-0 pointer-events-none">
      <div
        v-for="n in 50"
        :key="n"
        class="absolute w-1 h-1 bg-white rounded-full animate-twinkle"
        :style="getRandomPosition()"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import * as THREE from 'three'

const spaceContainer = ref(null)
let scene, camera, renderer, stars, animationId

const navigationItems = [
  {
    path: '/about-site',
    title: 'このサイトについて',
    description: 'サイトの技術と特徴',
    icon: '🌟'
  },
  {
    path: '/about-me',
    title: '自分について',
    description: '経歴とプロフィール',
    icon: '👨‍🚀'
  },
  {
    path: '/portfolio',
    title: '成果物',
    description: 'プロジェクト一覧',
    icon: '🚀'
  },
  {
    path: '/skills',
    title: 'スキルセット',
    description: '技術スタック',
    icon: '⚡'
  },
  {
    path: '/profile',
    title: 'プロフィール',
    description: '3D宇宙体験',
    icon: '🌍'
  },
  {
    path: '/contact',
    title: 'Contact',
    description: 'お問い合わせ',
    icon: '📡'
  }
]

function getRandomPosition() {
  return {
    left: Math.random() * 100 + '%',
    top: Math.random() * 100 + '%',
    animationDelay: Math.random() * 2 + 's'
  }
}

function initThreeJS() {
  if (!spaceContainer.value) return

  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000)
  renderer = new THREE.WebGLRenderer({ alpha: true })
  
  renderer.setSize(window.innerWidth, window.innerHeight)
  renderer.setClearColor(0x000000, 0)
  spaceContainer.value.appendChild(renderer.domElement)

  // 星を作成
  const starGeometry = new THREE.BufferGeometry()
  const starCount = 1000
  const positions = new Float32Array(starCount * 3)

  for (let i = 0; i < starCount * 3; i++) {
    positions[i] = (Math.random() - 0.5) * 2000
  }

  starGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3))
  
  const starMaterial = new THREE.PointsMaterial({
    color: 0xffffff,
    size: 2,
    transparent: true,
    opacity: 0.8
  })

  stars = new THREE.Points(starGeometry, starMaterial)
  scene.add(stars)

  camera.position.z = 5

  animate()
}

function animate() {
  animationId = requestAnimationFrame(animate)
  
  if (stars) {
    stars.rotation.x += 0.0005
    stars.rotation.y += 0.0005
  }

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
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  if (animationId) {
    cancelAnimationFrame(animationId)
  }
  if (renderer && spaceContainer.value) {
    spaceContainer.value.removeChild(renderer.domElement)
  }
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
.animate-fade-in {
  animation: fadeIn 2s ease-in-out;
}

.animate-twinkle {
  animation: twinkle 2s infinite ease-in-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes twinkle {
  0%, 100% { opacity: 0.3; }
  50% { opacity: 1; }
}
</style>
