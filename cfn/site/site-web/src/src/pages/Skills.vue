<template>
  <div class="min-h-screen bg-gradient-to-b from-black via-gray-900 to-black text-white">
    <!-- ヘッダー -->
    <div class="relative h-64 flex items-center justify-center">
      <div ref="headerScene" class="absolute inset-0" />
      <div class="relative z-10 text-center">
        <h1 class="text-5xl font-bold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-yellow-400 to-orange-400">
          スキルセット
        </h1>
        <p class="text-xl text-gray-300">技術スタックと専門領域</p>
      </div>
    </div>

    <!-- メインコンテンツ -->
    <div class="max-w-6xl mx-auto px-6 py-12">
      <!-- スキルカテゴリー -->
      <div class="grid lg:grid-cols-2 gap-12 mb-16">
        <div v-for="category in skillCategories" :key="category.title" class="space-y-6">
          <div class="text-center">
            <div class="text-4xl mb-4">{{ category.icon }}</div>
            <h2 class="text-2xl font-bold text-yellow-400">{{ category.title }}</h2>
            <p class="text-gray-400 text-sm mt-2">{{ category.description }}</p>
          </div>
          
          <!-- スキル一覧 -->
          <div class="space-y-4">
            <div v-for="skill in category.skills" :key="skill.name" class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700">
              <div class="flex items-center justify-between mb-3">
                <div class="flex items-center gap-3">
                  <span class="text-2xl">{{ skill.icon }}</span>
                  <span class="font-semibold">{{ skill.name }}</span>
                </div>
                <div class="flex items-center gap-2">
                  <span class="text-sm text-gray-400">{{ skill.experience }}</span>
                  <span class="text-sm font-semibold">{{ skill.level }}%</span>
                </div>
              </div>
              
              <!-- プログレスバー -->
              <div class="w-full bg-gray-700 rounded-full h-3 mb-3">
                <div 
                  class="h-3 rounded-full transition-all duration-1000 ease-out"
                  :class="skill.color"
                  :style="{ width: skill.level + '%' }"
                />
              </div>
              
              <!-- 説明 -->
              <p class="text-gray-300 text-sm">{{ skill.description }}</p>
              
              <!-- 関連プロジェクト -->
              <div v-if="skill.projects" class="mt-3">
                <div class="text-xs text-gray-500 mb-2">関連プロジェクト:</div>
                <div class="flex flex-wrap gap-1">
                  <span 
                    v-for="project in skill.projects" 
                    :key="project"
                    class="text-xs bg-gray-700 text-gray-300 px-2 py-1 rounded"
                  >
                    {{ project }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 認定・資格 -->
      <section class="mb-16">
        <h2 class="text-3xl font-bold mb-8 text-center text-green-400">🏆 認定・資格</h2>
        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div v-for="cert in certifications" :key="cert.name" class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700 text-center">
            <div class="text-3xl mb-3">{{ cert.icon }}</div>
            <h3 class="text-lg font-semibold mb-2">{{ cert.name }}</h3>
            <p class="text-sm text-gray-400 mb-2">{{ cert.issuer }}</p>
            <div class="text-xs text-green-400">{{ cert.date }}</div>
          </div>
        </div>
      </section>

      <!-- 学習中の技術 -->
      <section class="mb-16">
        <h2 class="text-3xl font-bold mb-8 text-center text-purple-400">📚 現在学習中</h2>
        <div class="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          <div v-for="learning in currentLearning" :key="learning.name" class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700 text-center hover:border-purple-400/50 transition-colors">
            <div class="text-3xl mb-3">{{ learning.icon }}</div>
            <h3 class="text-lg font-semibold mb-2">{{ learning.name }}</h3>
            <div class="w-full bg-gray-700 rounded-full h-2 mb-3">
              <div 
                class="bg-gradient-to-r from-purple-500 to-pink-500 h-2 rounded-full transition-all duration-1000"
                :style="{ width: learning.progress + '%' }"
              />
            </div>
            <p class="text-xs text-gray-400">{{ learning.progress }}% 完了</p>
          </div>
        </div>
      </section>

      <!-- 開発ツール・環境 -->
      <section class="mb-16">
        <h2 class="text-3xl font-bold mb-8 text-center text-blue-400">🛠️ 開発ツール・環境</h2>
        <div class="grid md:grid-cols-3 gap-8">
          <div v-for="toolCategory in devTools" :key="toolCategory.category" class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700">
            <h3 class="text-xl font-semibold mb-4 text-blue-400">{{ toolCategory.category }}</h3>
            <div class="space-y-3">
              <div v-for="tool in toolCategory.tools" :key="tool" class="flex items-center gap-3 text-gray-300">
                <div class="w-2 h-2 bg-blue-400 rounded-full" />
                <span>{{ tool }}</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- ソフトスキル -->
      <section class="mb-16">
        <h2 class="text-3xl font-bold mb-8 text-center text-pink-400">💫 ソフトスキル</h2>
        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div v-for="softSkill in softSkills" :key="softSkill.name" class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700 hover:border-pink-400/50 transition-colors">
            <div class="flex items-center gap-3 mb-3">
              <span class="text-2xl">{{ softSkill.icon }}</span>
              <h3 class="text-lg font-semibold">{{ softSkill.name }}</h3>
            </div>
            <p class="text-gray-300 text-sm">{{ softSkill.description }}</p>
          </div>
        </div>
      </section>

      <!-- スキルマップ -->
      <section>
        <h2 class="text-3xl font-bold mb-8 text-center text-cyan-400">🗺️ 技術領域マップ</h2>
        <div class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-8 border border-gray-700">
          <div class="text-center mb-8">
            <p class="text-gray-300">私の専門領域と経験の広がりを視覚化</p>
          </div>
          <div class="grid md:grid-cols-3 gap-8">
            <div v-for="domain in skillDomains" :key="domain.name" class="text-center">
              <div class="relative mx-auto mb-4" :style="{ width: '120px', height: '120px' }">
                <svg class="transform -rotate-90 w-full h-full">
                  <circle
                    cx="60"
                    cy="60"
                    r="50"
                    stroke="currentColor"
                    stroke-width="8"
                    fill="transparent"
                    class="text-gray-700"
                  />
                  <circle
                    cx="60"
                    cy="60"
                    r="50"
                    stroke="currentColor"
                    stroke-width="8"
                    fill="transparent"
                    :stroke-dasharray="circumference"
                    :stroke-dashoffset="circumference - (domain.level / 100) * circumference"
                    :class="domain.color"
                    class="transition-all duration-1000 ease-out"
                  />
                </svg>
                <div class="absolute inset-0 flex items-center justify-center">
                  <span class="text-2xl font-bold">{{ domain.level }}%</span>
                </div>
              </div>
              <h3 class="text-lg font-semibold mb-2">{{ domain.name }}</h3>
              <p class="text-gray-400 text-sm">{{ domain.description }}</p>
            </div>
          </div>
        </div>
      </section>
    </div>

    <!-- フッターナビゲーション -->
    <div class="max-w-4xl mx-auto px-6 py-12">
      <div class="flex justify-between items-center">
        <router-link to="/portfolio" class="btn-back">
          ← 成果物
        </router-link>
        <router-link to="/profile" class="btn-next">
          プロフィール →
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import * as THREE from 'three'

const headerScene = ref(null)
let scene, camera, renderer, skillNodes, animationId

const circumference = computed(() => 2 * Math.PI * 50)

const skillCategories = [
  {
    title: 'フロントエンド',
    icon: '🎨',
    description: 'ユーザーインターフェース開発',
    skills: [
      {
        name: 'Vue.js / Nuxt.js',
        icon: '💚',
        level: 95,
        experience: '2年',
        color: 'bg-gradient-to-r from-green-400 to-green-600',
        description: 'コンポーネント設計からSSRまで幅広く対応。Composition APIを活用した現代的な開発スタイル。',
        projects: ['ポートフォリオサイト', 'ECサイト', 'ダッシュボード']
      },
    ]
  },
  {
    title: 'バックエンド',
    icon: '⚙️',
    description: 'サーバーサイド開発・API設計',
    skills: [
      {
        name: 'Python / FastAPI',
        icon: '🐍',
        level: 85,
        experience: '6年',
        color: 'bg-gradient-to-r from-yellow-400 to-yellow-600',
        description: 'データ分析APIや機械学習モデルのデプロイ。非同期処理による高性能API開発。',
        projects: ['データ分析API', 'AIサービス']
      },
      {
        name: 'PostgreSQL',
        icon: '🐘',
        level: 80,
        experience: '2年',
        color: 'bg-gradient-to-r from-blue-600 to-indigo-700',
        description: 'リレーショナルDB設計からNoSQLの活用まで。パフォーマンスチューニングも対応。',
        projects: ['ECサイト', 'ユーザー管理システム']
      }
    ]
  },
  {
    title: 'インフラ・DevOps',
    icon: '☁️',
    description: 'クラウド・CI/CD・運用',
    skills: [
      {
        name: 'AWS / GCP',
        icon: '☁️',
        level: 85,
        experience: '3年',
        color: 'bg-gradient-to-r from-orange-400 to-orange-600',
        description: 'スケーラブルなクラウドアーキテクチャの設計。コスト最適化と可用性の両立。',
        projects: ['Webアプリホスティング', 'データパイプライン']
      },
      {
        name: 'Docker / Kubernetes',
        icon: '🐳',
        level: 80,
        experience: '2年',
        color: 'bg-gradient-to-r from-cyan-400 to-cyan-600',
        description: 'コンテナ化によるポータビリティ向上。マイクロサービスのオーケストレーション。',
        projects: ['マイクロサービス基盤', 'CI/CDパイプライン']
      },
      {
        name: 'CI/CD',
        icon: '🔄',
        level: 85,
        experience: '3年',
        color: 'bg-gradient-to-r from-green-500 to-teal-600',
        description: 'GitHub ActionsやGitLab CIを活用した自動化。テスト・デプロイの効率化。',
        projects: ['全プロジェクトで導入']
      }
    ]
  },
  {
    title: 'デザイン・UX',
    icon: '🎯',
    description: 'UI/UXデザイン・ユーザビリティ',
    skills: [
      {
        name: 'UI/UX Design',
        icon: '🎨',
        level: 80,
        experience: '4年',
        color: 'bg-gradient-to-r from-pink-400 to-pink-600',
        description: 'ユーザー中心設計によるインターフェース設計。使いやすさと美しさの両立。',
        projects: ['全プロジェクトで設計から参加']
      },
    ]
  }
]

const certifications = [
  { name: 'AWS Cloud Practitioner', issuer: 'Amazon Web Services', date: '2023', icon: '☁️' },
]

const currentLearning = [
  { name: 'Rust', icon: '🦀', progress: 65 },
]

const devTools = [
  {
    category: 'エディタ・IDE',
    tools: ['VS Code']
  },
  {
    category: 'バージョン管理',
    tools: ['Git', 'GitHub']
  },
  {
    category: 'デザインツール',
    tools: ['Figma']
  },
  {
    category: 'プロジェクト管理',
    tools: ['Notion', 'Slack', 'backlog']
  },
  {
    category: 'その他',
    tools: ['Docker Desktop', 'Postman', 'TablePlus', 'SSH']
  }
]

const softSkills = [
  {
    name: 'チームワーク',
    icon: '👥',
    description: '多様なメンバーと協力し、チーム全体のパフォーマンスを向上させることができます。'
  },
  {
    name: '問題解決',
    icon: '🧩',
    description: '複雑な技術的課題を分析し、効率的で持続可能な解決策を見つけることが得意です。'
  },
  {
    name: 'コミュニケーション',
    icon: '💬',
    description: '技術的な内容を非技術者にもわかりやすく説明し、円滑な協業を実現します。'
  },
  {
    name: '学習意欲',
    icon: '📚',
    description: '新しい技術やツールを積極的に学び、常に最新のトレンドをキャッチアップします。'
  },
  {
    name: 'リーダーシップ',
    icon: '🌟',
    description: 'プロジェクトの方向性を示し、メンバーのモチベーションを高めることができます。'
  },
  {
    name: '創造性',
    icon: '💡',
    description: '従来の枠にとらわれず、革新的で実用的なソリューションを創出します。'
  }
]

const skillDomains = [
  {
    name: 'フロントエンド',
    level: 92,
    color: 'text-green-400',
    description: 'UI/UX、フレームワーク、3Dグラフィックス'
  },
  {
    name: 'バックエンド',
    level: 85,
    color: 'text-blue-400',
    description: 'API設計、データベース、サーバー構築'
  },
  {
    name: 'インフラ',
    level: 78,
    color: 'text-yellow-400',
    description: 'クラウド、CI/CD、コンテナ技術'
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

  skillNodes = []
  
  // スキルノードを作成
  for (let i = 0; i < 12; i++) {
    const geometry = new THREE.OctahedronGeometry(3, 0)
    const material = new THREE.MeshBasicMaterial({
      color: new THREE.Color().setHSL(Math.random(), 0.8, 0.6),
      wireframe: Math.random() > 0.5,
      transparent: true,
      opacity: 0.7
    })
    
    const node = new THREE.Mesh(geometry, material)
    node.position.set(
      (Math.random() - 0.5) * 150,
      (Math.random() - 0.5) * 80,
      (Math.random() - 0.5) * 80
    )
    
    scene.add(node)
    skillNodes.push(node)
  }

  // 接続線
  const lineGeometry = new THREE.BufferGeometry()
  const positions = []
  
  for (let i = 0; i < skillNodes.length; i++) {
    for (let j = i + 1; j < skillNodes.length; j++) {
      if (Math.random() > 0.7) {
        positions.push(
          skillNodes[i].position.x, skillNodes[i].position.y, skillNodes[i].position.z,
          skillNodes[j].position.x, skillNodes[j].position.y, skillNodes[j].position.z
        )
      }
    }
  }
  
  lineGeometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3))
  const lineMaterial = new THREE.LineBasicMaterial({ color: 0xffaa00, transparent: true, opacity: 0.3 })
  const lines = new THREE.LineSegments(lineGeometry, lineMaterial)
  scene.add(lines)

  camera.position.z = 100
  animate()
}

function animate() {
  animationId = requestAnimationFrame(animate)
  
  skillNodes.forEach((node, index) => {
    node.rotation.x += 0.005 + index * 0.001
    node.rotation.y += 0.01 + index * 0.002
    node.position.y += Math.sin(Date.now() * 0.002 + index) * 0.1
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
