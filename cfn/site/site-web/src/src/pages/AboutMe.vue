<template>
  <div class="min-h-screen bg-gradient-to-b from-black via-gray-900 to-black text-white">
    <!-- ヘッダー -->
    <div class="relative h-64 flex items-center justify-center">
      <div ref="headerScene" class="absolute inset-0" />
      <div class="relative z-10 text-center">
        <h1 class="text-5xl font-bold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-green-400 to-blue-400">
          自分について
        </h1>
        <p class="text-xl text-gray-300">Full Stack Engineer としての歩み</p>
      </div>
    </div>

    <!-- メインコンテンツ -->
    <div class="max-w-4xl mx-auto px-6 py-12">
      <!-- プロフィール概要 -->
      <section class="mb-16">
        <div class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-8 border border-gray-700">
          <div class="flex flex-col md:flex-row items-start gap-8">
            <div class="w-48 h-48 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-6xl shrink-0">
              👨‍💻
            </div>
            <div class="flex-1">
              <h2 class="text-3xl font-bold mb-4 text-green-400">エンジニアとしての信念</h2>
              <p class="text-lg leading-relaxed mb-4">
                テクノロジーを通じて人々の生活をより豊かにすることをミッションとしています。
                常に新しい技術を学び続け、課題解決に最適なソリューションを提供することを心がけています。
              </p>
              <p class="text-gray-300 leading-relaxed">
                フロントエンドからバックエンド、インフラまで幅広い領域で経験を積み、
                ユーザー体験を最優先に考えた開発を行っています。
              </p>
            </div>
          </div>
        </div>
      </section>

      <!-- 経歴 -->
      <section class="mb-16">
        <h2 class="text-3xl font-bold mb-8 text-blue-400">🚀 経歴・経験</h2>
        <div class="space-y-8">
          <div v-for="experience in experiences" :key="experience.period" class="relative">
            <div class="flex items-start gap-6">
              <div class="w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center text-2xl shrink-0">
                {{ experience.icon }}
              </div>
              <div class="flex-1 bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700">
                <div class="flex justify-between items-start mb-3">
                  <h3 class="text-xl font-semibold">{{ experience.title }}</h3>
                  <span class="text-sm text-gray-400 bg-gray-700 px-3 py-1 rounded-full">{{ experience.period }}</span>
                </div>
                <p class="text-gray-300 mb-4">{{ experience.description }}</p>
                <div class="flex flex-wrap gap-2">
                  <span v-for="tech in experience.technologies" :key="tech" class="text-xs bg-blue-600/20 text-blue-300 px-2 py-1 rounded">
                    {{ tech }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- スキル -->
      <section class="mb-16">
        <h2 class="text-3xl font-bold mb-8 text-purple-400">⚡ 主要スキル</h2>
        <div class="grid md:grid-cols-2 gap-8">
          <div v-for="skillCategory in skillCategories" :key="skillCategory.title" class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700">
            <h3 class="text-xl font-semibold mb-4 flex items-center">
              <span class="mr-3">{{ skillCategory.icon }}</span>
              {{ skillCategory.title }}
            </h3>
            <div class="space-y-4">
              <div v-for="skill in skillCategory.skills" :key="skill.name" class="space-y-2">
                <div class="flex justify-between">
                  <span class="text-gray-300">{{ skill.name }}</span>
                  <span class="text-sm text-gray-400">{{ skill.level }}%</span>
                </div>
                <div class="w-full bg-gray-700 rounded-full h-2">
                  <div 
                    class="bg-gradient-to-r from-blue-500 to-purple-500 h-2 rounded-full transition-all duration-1000"
                    :style="{ width: skill.level + '%' }"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- 趣味・興味 -->
      <section class="mb-16">
        <h2 class="text-3xl font-bold mb-8 text-yellow-400">🌟 趣味・興味</h2>
        <div class="grid md:grid-cols-3 gap-6">
          <div v-for="hobby in hobbies" :key="hobby.title" class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700 hover:border-yellow-400/50 transition-colors">
            <div class="text-3xl mb-4">{{ hobby.icon }}</div>
            <h3 class="text-xl font-semibold mb-3">{{ hobby.title }}</h3>
            <p class="text-gray-300 text-sm">{{ hobby.description }}</p>
          </div>
        </div>
      </section>

      <!-- 価値観 -->
      <section>
        <h2 class="text-3xl font-bold mb-8 text-pink-400">💫 大切にしている価値観</h2>
        <div class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-8 border border-gray-700">
          <div class="grid md:grid-cols-2 gap-8">
            <div v-for="value in values" :key="value.title" class="space-y-3">
              <h3 class="text-xl font-semibold flex items-center">
                <span class="mr-3">{{ value.icon }}</span>
                {{ value.title }}
              </h3>
              <p class="text-gray-300 leading-relaxed">{{ value.description }}</p>
            </div>
          </div>
        </div>
      </section>
    </div>

    <!-- フッターナビゲーション -->
    <div class="max-w-4xl mx-auto px-6 py-12">
      <div class="flex justify-between items-center">
        <router-link to="/about-site" class="btn-back">
          ← サイトについて
        </router-link>
        <router-link to="/portfolio" class="btn-next">
          成果物へ →
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import * as THREE from 'three'

const headerScene = ref(null)
let scene, camera, renderer, constellation, animationId

const experiences = [
  {
    period: '- 2020',
    title: 'Hobby Engineer',
    description: 'フリー動画編集ソフト使用中にJavaScriptの存在を知り、独学でプログラミングを学び始める。Webサイト制作や簡単なツール開発を趣味で行う。',
    technologies: ['HTML', 'CSS', 'JavaScript', 'AviUtl'],
    icon: '📚'
  },
  {
    period: '2020 - 2024',
    title: 'University Student',
    description: 'Computer Scienceを専攻し、AI、データベース、ネットワーク、セキュリティなど幅広く学習。学内プロジェクトでチームリーダーを務め、卒業研究では雲量予測モデルを開発。',
    technologies: ['Python', 'TensorFlow', 'PostgreSQL', 'Git', 'Linux'],
    icon: '🎓'
  },
  {
    period: '2024 - Present',
    title: 'Full Stack Engineer',
    description: '新卒でプライム上場IT企業に入社。主にLLMを活用した社内業務効率化アプリケーション、SaaSアプリケーションの設計・開発・運用を担当。AWSを用いたインフラ構築から課題解決まで幅広く経験。',
    technologies: ['Python', 'FastAPI', 'Vue.js', 'AWS', 'Docker', 'Kubernetes', 'CI/CD', 'LangChain', "LangGraph"],
    icon: '💼'
  }
]

const skillCategories = [
  {
    title: 'Frontend',
    icon: '🎨',
    skills: [
      { name: 'Vue.js', level: 60 },
    ]
  },
  {
    title: 'Backend',
    icon: '⚙️',
    skills: [
      { name: 'Python/FastAPI', level: 85 },
      { name: 'PostgreSQL/MongoDB', level: 70 },
      { name: 'Redis/Elasticsearch', level: 75 }
    ]
  },
  {
    title: 'Infrastructure',
    icon: '☁️',
    skills: [
      { name: 'AWS/GCP', level: 85 },
      { name: 'Docker/Kubernetes', level: 70 },
      { name: 'CI/CD', level: 85 },
    ]
  }
]

const hobbies = [
  {
    icon: '🌌',
    title: '宇宙・天体観測',
    description: '宇宙の神秘に魅力を感じ、天体観測や宇宙関連の学習を趣味としています。'
  },
  {
    icon: '📖',
    title: '技術書読書',
    description: '最新の技術トレンドをキャッチアップするため、技術書を読むことが日課です。'
  },
  {
    icon: '✈️',
    title: '旅行',
    description: '異文化体験や新しい発見を求めて、国内外を旅行することが好きです。'
  }
]

const values = [
  {
    icon: '🔄',
    title: '継続的な学習',
    description: '技術の進歩は日進月歩。常に新しいことを学び続け、自己成長を怠らないことを大切にしています。'
  },
  {
    icon: '👥',
    title: 'チームワーク',
    description: '一人でできることには限界があります。チームメンバーと協力し、互いの強みを活かすことを重視しています。'
  },
  {
    icon: '🎯',
    title: 'ユーザーファースト',
    description: '技術のための技術ではなく、ユーザーにとって本当に価値のあるものを作ることを最優先に考えています。'
  },
  {
    icon: '🌱',
    title: '品質への拘り',
    description: 'コードの可読性、保守性、パフォーマンスすべてにおいて妥協せず、高品質なソフトウェアの開発を心がけています。'
  }
]

function initHeaderScene() {
  if (!headerScene.value) return

  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera(75, window.innerWidth / 200, 0.1, 1000)
  renderer = new THREE.WebGLRenderer({ alpha: true })
  
  renderer.setSize(window.innerWidth, 200)
  renderer.setClearColor(0x000000, 0)
  headerScene.value.appendChild(renderer.domElement)

  // 星座を作成
  const points = []
  for (let i = 0; i < 20; i++) {
    points.push(new THREE.Vector3(
      (Math.random() - 0.5) * 100,
      (Math.random() - 0.5) * 100,
      (Math.random() - 0.5) * 100
    ))
  }

  const geometry = new THREE.BufferGeometry().setFromPoints(points)
  const material = new THREE.LineBasicMaterial({ color: 0x00ff88 })
  constellation = new THREE.Line(geometry, material)
  scene.add(constellation)

  camera.position.z = 50
  animate()
}

function animate() {
  animationId = requestAnimationFrame(animate)
  
  if (constellation) {
    constellation.rotation.x += 0.005
    constellation.rotation.y += 0.01
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
