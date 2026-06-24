<template>
  <div class="min-h-screen pt-24 pb-20 px-6" style="background: var(--bg);">
    <div class="max-w-5xl mx-auto">

      <!-- Header -->
      <div class="mb-12 reveal">
        <p class="font-mono text-xs mb-3" style="color: var(--green);">./games</p>
        <h1 class="font-display font-bold" style="font-size: clamp(2.5rem, 6vw, 4rem); line-height: 1.1; color: var(--text);">
          Games
        </h1>
        <p class="mt-4 text-sm leading-relaxed" style="color: var(--text-muted);">
          やってるゲーム・やったゲームたち。難しいゲームが好き。<br>
          エンジニアリングとゲームは似ている気がする——どちらも「システムを理解して攻略する」楽しさがある。
        </p>
      </div>

      <!-- Stats row -->
      <div class="grid grid-cols-3 gap-4 mb-12 reveal">
        <div class="glass rounded-xl p-4 text-center">
          <p class="font-display font-bold text-2xl gradient-text">{{ gamesData.length }}</p>
          <p class="text-xs mt-1" style="color: var(--text-muted);">Games listed</p>
        </div>
        <div class="glass rounded-xl p-4 text-center">
          <p class="font-display font-bold text-2xl" style="color: var(--amber);">{{ totalHours }}h</p>
          <p class="text-xs mt-1" style="color: var(--text-muted);">Total hours</p>
        </div>
        <div class="glass rounded-xl p-4 text-center">
          <p class="font-display font-bold text-2xl" style="color: var(--green);">{{ playing.length }}</p>
          <p class="text-xs mt-1" style="color: var(--text-muted);">Now playing</p>
        </div>
      </div>

      <!-- Filter tabs -->
      <div class="flex gap-2 mb-8 reveal">
        <button
          v-for="tab in ['all', 'playing', 'completed']"
          :key="tab"
          class="px-4 py-1.5 rounded-full text-xs font-mono transition-all duration-200"
          :style="activeTab === tab
            ? 'background: rgba(74,222,128,0.15); color: var(--green); border: 1px solid rgba(74,222,128,0.3);'
            : 'background: transparent; color: var(--text-muted); border: 1px solid var(--glass-border);'"
          @click="activeTab = tab"
        >
          {{ tab }}
        </button>
      </div>

      <!-- Game grid -->
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        <div
          v-for="(game, i) in filteredGames"
          :key="game.id"
          class="glass rounded-2xl p-5 group reveal game-card"
          :style="{ transitionDelay: `${i * 0.08}s` }"
        >
          <!-- Colored top accent -->
          <div class="h-1 rounded-full mb-4 -mx-5 -mt-5 px-0" :style="`background: ${game.color}; margin-top: -1.25rem; margin-left: -1.25rem; margin-right: -1.25rem; width: calc(100% + 2.5rem); height: 3px; border-radius: 1rem 1rem 0 0;`" />

          <div class="flex items-start justify-between mb-3 mt-2">
            <span class="text-3xl">{{ game.emoji }}</span>
            <span
              class="text-xs px-2 py-0.5 rounded-full font-mono"
              :style="game.status === 'playing'
                ? 'background: rgba(74,222,128,0.1); color: var(--green); border: 1px solid rgba(74,222,128,0.2);'
                : 'background: rgba(255,255,255,0.05); color: var(--text-muted); border: 1px solid var(--glass-border);'"
            >{{ game.status }}</span>
          </div>

          <h3 class="font-display font-bold text-lg mb-0.5" style="color: var(--text);">{{ game.title }}</h3>
          <p class="text-xs mb-3 font-mono" :style="`color: ${game.color};`">{{ game.genre }} · {{ game.platform }}</p>
          <p class="text-xs leading-relaxed mb-4" style="color: var(--text-muted);">{{ game.description }}</p>

          <div class="flex items-center justify-between">
            <!-- Stars -->
            <div class="flex gap-0.5">
              <span
                v-for="n in 5"
                :key="n"
                class="text-sm"
                :style="n <= game.rating ? `color: ${game.color};` : 'color: var(--text-dim);'"
              >★</span>
            </div>
            <span class="text-xs font-mono" style="color: var(--text-muted);">{{ game.hours }}h</span>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { gamesData } from '../data/games.js'

const activeTab = ref('all')

const playing = computed(() => gamesData.filter(g => g.status === 'playing'))
const totalHours = computed(() => gamesData.reduce((s, g) => s + g.hours, 0))

const filteredGames = computed(() => {
  if (activeTab.value === 'all') return gamesData
  return gamesData.filter(g => g.status === activeTab.value)
})

onMounted(() => {
  const observer = new IntersectionObserver(
    entries => entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible') }),
    { threshold: 0.1 }
  )
  document.querySelectorAll('.reveal').forEach(el => observer.observe(el))
})
</script>

<style scoped>
.game-card {
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}
.game-card:hover {
  transform: translateY(-4px);
}
</style>
