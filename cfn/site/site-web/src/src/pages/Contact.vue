<template>
  <div class="min-h-screen bg-gradient-to-b from-black via-gray-900 to-black text-white">
    <!-- ヘッダー -->
    <div class="relative h-64 flex items-center justify-center">
      <div ref="headerScene" class="absolute inset-0" />
      <div class="relative z-10 text-center">
        <h1 class="text-5xl font-bold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-purple-400 to-pink-400">
          Contact
        </h1>
        <p class="text-xl text-gray-300">お気軽にお問い合わせください</p>
      </div>
    </div>

    <!-- メインコンテンツ -->
    <div class="max-w-4xl mx-auto px-6 py-12">
      <div class="grid lg:grid-cols-2 gap-12">
        <!-- 連絡先情報 -->
        <div class="space-y-8">
          <div>
            <h2 class="text-3xl font-bold mb-6 text-purple-400">📡 連絡方法</h2>
            <p class="text-gray-300 mb-8">
              新しいプロジェクトの相談、技術的な質問、コラボレーションの提案など、
              どのような内容でもお気軽にご連絡ください。
            </p>
          </div>

          <!-- 連絡先カード -->
          <div class="space-y-4">
            <div v-for="contact in contactMethods" :key="contact.type" class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700 hover:border-purple-400/50 transition-colors">
              <div class="flex items-center gap-4">
                <div class="text-3xl">{{ contact.icon }}</div>
                <div>
                  <h3 class="text-lg font-semibold mb-1">{{ contact.type }}</h3>
                  <div class="text-gray-300">{{ contact.value }}</div>
                  <div class="text-sm text-gray-400 mt-1">{{ contact.description }}</div>
                </div>
              </div>
            </div>
          </div>

          <!-- ソーシャルリンク -->
          <div>
            <h3 class="text-xl font-semibold mb-4 text-cyan-400">🌐 Social Links</h3>
            <div class="flex flex-wrap gap-4">
              <a
                v-for="social in socialLinks"
                :key="social.name"
                :href="social.url"
                target="_blank"
                class="flex items-center gap-3 px-4 py-3 bg-gray-800 hover:bg-gray-700 rounded-lg transition-colors border border-gray-600 hover:border-gray-500"
              >
                <span class="text-xl">{{ social.icon }}</span>
                <span>{{ social.name }}</span>
              </a>
            </div>
          </div>

          <!-- 対応可能業務 -->
          <div>
            <h3 class="text-xl font-semibold mb-4 text-green-400">💼 対応可能業務</h3>
            <div class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-6 border border-gray-700">
              <div class="grid md:grid-cols-2 gap-4">
                <div v-for="service in services" :key="service" class="flex items-center gap-3">
                  <div class="w-2 h-2 bg-green-400 rounded-full" />
                  <span class="text-gray-300">{{ service }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- お問い合わせフォーム -->
        <div class="bg-gray-800/50 backdrop-blur-sm rounded-xl p-8 border border-gray-700">
          <h2 class="text-2xl font-bold mb-6 text-center text-pink-400">📨 お問い合わせフォーム</h2>
          
          <form @submit.prevent="submitForm" class="space-y-6">
            <div>
              <label for="name" class="block text-sm font-medium mb-2">お名前 *</label>
              <input
                id="name"
                v-model="form.name"
                type="text"
                required
                class="w-full px-4 py-3 bg-gray-700 border border-gray-600 rounded-lg focus:outline-none focus:border-purple-400 transition-colors"
                placeholder="山田太郎"
              >
            </div>

            <div>
              <label for="email" class="block text-sm font-medium mb-2">メールアドレス *</label>
              <input
                id="email"
                v-model="form.email"
                type="email"
                required
                class="w-full px-4 py-3 bg-gray-700 border border-gray-600 rounded-lg focus:outline-none focus:border-purple-400 transition-colors"
                placeholder="example@email.com"
              >
            </div>

            <div>
              <label for="subject" class="block text-sm font-medium mb-2">件名 *</label>
              <select
                id="subject"
                v-model="form.subject"
                required
                class="w-full px-4 py-3 bg-gray-700 border border-gray-600 rounded-lg focus:outline-none focus:border-purple-400 transition-colors"
              >
                <option value="">選択してください</option>
                <option value="project">プロジェクトの相談</option>
                <option value="collaboration">コラボレーション</option>
                <option value="technical">技術的な質問</option>
                <option value="recruitment">採用について</option>
                <option value="other">その他</option>
              </select>
            </div>

            <div>
              <label for="message" class="block text-sm font-medium mb-2">メッセージ *</label>
              <textarea
                id="message"
                v-model="form.message"
                required
                rows="6"
                class="w-full px-4 py-3 bg-gray-700 border border-gray-600 rounded-lg focus:outline-none focus:border-purple-400 transition-colors resize-none"
                placeholder="お問い合わせ内容をできるだけ詳しくお聞かせください..."
              />
            </div>

            <div>
              <label class="flex items-start gap-3">
                <input
                  v-model="form.privacy"
                  type="checkbox"
                  required
                  class="mt-1 w-4 h-4 text-purple-600 bg-gray-700 border-gray-600 rounded focus:ring-purple-400 focus:ring-2"
                >
                <span class="text-sm text-gray-300">
                  プライバシーポリシーに同意します。お預かりした個人情報は、お問い合わせの対応にのみ使用いたします。
                </span>
              </label>
            </div>

            <button
              type="submit"
              :disabled="isSubmitting"
              :class="[
                'w-full px-6 py-4 rounded-lg font-semibold transition-colors',
                isSubmitting
                  ? 'bg-gray-600 cursor-not-allowed'
                  : 'bg-purple-600 hover:bg-purple-700'
              ]"
            >
              {{ isSubmitting ? '送信中...' : '送信する 🚀' }}
            </button>
          </form>

          <!-- 送信完了メッセージ -->
          <div v-if="isSubmitted" class="mt-6 p-4 bg-green-600/20 border border-green-400/30 rounded-lg">
            <div class="flex items-center gap-3">
              <span class="text-2xl">✅</span>
              <div>
                <div class="font-semibold text-green-400">送信完了</div>
                <div class="text-sm text-gray-300">お問い合わせありがとうございます。24時間以内にご返信いたします。</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- FAQ -->
      <section class="mt-16">
        <h2 class="text-3xl font-bold mb-8 text-center text-yellow-400">❓ よくある質問</h2>
        <div class="space-y-4">
          <div v-for="faq in faqs" :key="faq.question" class="bg-gray-800/50 backdrop-blur-sm rounded-xl border border-gray-700">
            <button
              @click="faq.open = !faq.open"
              class="w-full px-6 py-4 text-left flex justify-between items-center hover:bg-gray-700/50 transition-colors"
            >
              <span class="font-semibold">{{ faq.question }}</span>
              <span class="text-2xl transform transition-transform" :class="{ 'rotate-45': faq.open }">+</span>
            </button>
            <div v-show="faq.open" class="px-6 pb-4">
              <p class="text-gray-300">{{ faq.answer }}</p>
            </div>
          </div>
        </div>
      </section>
    </div>

    <!-- フッターナビゲーション -->
    <div class="max-w-4xl mx-auto px-6 py-12">
      <div class="flex justify-between items-center">
        <router-link to="/profile" class="btn-back">
          ← プロフィール
        </router-link>
        <router-link to="/" class="btn-next">
          ホームに戻る
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import * as THREE from 'three'

const headerScene = ref(null)
const isSubmitting = ref(false)
const isSubmitted = ref(false)

let scene, camera, renderer, satellites, animationId

const form = reactive({
  name: '',
  email: '',
  subject: '',
  message: '',
  privacy: false
})

const contactMethods = [
  {
    type: 'Email',
    icon: '📧',
    value: 'astronautryosuzuki@gmail.com',
    description: '24時間以内に返信します'
  },
  {
    type: 'Location',
    icon: '📍',
    value: 'Tokyo, Japan',
    description: 'リモートワーク・対面どちらも対応可'
  }
]

const socialLinks = [
  { name: 'GitHub', icon: '🐙', url: 'https://github.com/ryo-suzukii' },
  { name: 'Twitter', icon: '🐦', url: 'https://twitter.com/Hayaa_6211' },
  { name: 'Qiita', icon: '📝', url: 'https://qiita.com/Hayaa6211' },
  { name: 'zenn', icon: '📘', url: 'https://zenn.dev/ha' },
]

const services = [
  'Webアプリケーション開発',
  'フロントエンド開発',
  'バックエンドAPI開発',
  'UI/UXデザイン',
  '技術コンサルティング',
  'コードレビュー',
  '技術記事執筆',
  'メンタリング'
]

const faqs = ref([
  {
    question: 'プロジェクトの期間はどのくらいかかりますか？',
    answer: 'プロジェクトの規模や要件によって異なりますが、小規模なWebサイトは2-4週間、中規模なWebアプリケーションは2-3ヶ月程度が目安です。詳細はお問い合わせ時にご相談させていただきます。',
    open: false
  },
  {
    question: '料金体系はどうなっていますか？',
    answer: '時間単価制またはプロジェクト固定制からお選びいただけます。内容を詳しくお聞きした上で、最適な料金プランをご提案いたします。見積もりは無料です。',
    open: false
  },
  {
    question: 'リモートワークは可能ですか？',
    answer: 'はい、完全リモートでの対応が可能です。必要に応じてオンライン会議やチャットツールを活用し、スムーズなコミュニケーションを心がけています。',
    open: false
  },
  {
    question: '技術的な質問や相談はできますか？',
    answer: '技術的なご質問や開発に関するご相談も承っております。Discord やメールでお気軽にお声がけください。',
    open: false
  }
])

async function submitForm() {
  isSubmitting.value = true
  
  try {
    // フォーム送信のシミュレーション
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    // 実際の実装では、ここでAPIにデータを送信
    console.log('Form submitted:', form)
    
    isSubmitted.value = true
    
    // フォームをリセット
    Object.keys(form).forEach(key => {
      if (key === 'privacy') {
        form[key] = false
      } else {
        form[key] = ''
      }
    })
    
  } catch (error) {
    console.error('Form submission error:', error)
    alert('送信エラーが発生しました。しばらく経ってから再度お試しください。')
  } finally {
    isSubmitting.value = false
  }
}

function initHeaderScene() {
  if (!headerScene.value) return

  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera(75, window.innerWidth / 200, 0.1, 1000)
  renderer = new THREE.WebGLRenderer({ alpha: true })
  
  renderer.setSize(window.innerWidth, 200)
  renderer.setClearColor(0x000000, 0)
  headerScene.value.appendChild(renderer.domElement)

  // 通信衛星
  satellites = []
  for (let i = 0; i < 8; i++) {
    const geometry = new THREE.BoxGeometry(4, 2, 6)
    const material = new THREE.MeshBasicMaterial({
      color: new THREE.Color().setHSL(0.8, 0.8, 0.6),
      wireframe: true,
      transparent: true,
      opacity: 0.7
    })
    
    const satellite = new THREE.Mesh(geometry, material)
    satellite.position.set(
      (Math.random() - 0.5) * 200,
      (Math.random() - 0.5) * 100,
      (Math.random() - 0.5) * 100
    )
    
    scene.add(satellite)
    satellites.push(satellite)
  }

  // 信号線
  const signalGeometry = new THREE.BufferGeometry()
  const positions = []
  
  for (let i = 0; i < satellites.length - 1; i++) {
    positions.push(
      satellites[i].position.x, satellites[i].position.y, satellites[i].position.z,
      satellites[i + 1].position.x, satellites[i + 1].position.y, satellites[i + 1].position.z
    )
  }
  
  signalGeometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3))
  const signalMaterial = new THREE.LineBasicMaterial({ 
    color: 0xff6b9d, 
    transparent: true, 
    opacity: 0.4 
  })
  const signals = new THREE.LineSegments(signalGeometry, signalMaterial)
  scene.add(signals)

  camera.position.z = 100
  animate()
}

function animate() {
  animationId = requestAnimationFrame(animate)
  
  satellites.forEach((satellite, index) => {
    satellite.rotation.x += 0.01 + index * 0.002
    satellite.rotation.y += 0.01 + index * 0.003
    satellite.position.x += Math.sin(Date.now() * 0.001 + index) * 0.1
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
