<template>
  <div class="min-h-screen pt-28 pb-20 px-6" style="background: var(--bg);">
    <div class="max-w-5xl mx-auto">

      <!-- Header -->
      <div class="mb-12 reveal">
        <p class="font-mono text-xs mb-3" style="color: var(--amber);">./setup</p>
        <h1 class="font-display font-bold" style="font-size: clamp(2.5rem, 6vw, 4rem); line-height: 1.1; color: var(--text);">
          機材・ツール
        </h1>
        <p class="mt-4 text-sm leading-relaxed" style="color: var(--text-muted);">
          生産性は環境で決まる。こだわり抜いた開発環境と愛用ツールの紹介。
        </p>
      </div>

      <!-- Hardware section -->
      <div class="mb-16">
        <div class="flex items-center gap-3 mb-6 reveal">
          <div class="h-px flex-1" style="background: var(--glass-border);" />
          <span class="text-xs font-mono px-3 py-1 rounded-full" style="color: var(--amber); background: rgba(245,158,11,0.1); border: 1px solid rgba(245,158,11,0.2);">Hardware</span>
          <div class="h-px flex-1" style="background: var(--glass-border);" />
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            v-for="(item, i) in setupData.hardware"
            :key="item.id"
            class="glass rounded-2xl p-5 group setup-card reveal"
            :style="{ transitionDelay: `${i * 0.08}s` }"
          >
            <div class="flex items-start justify-between mb-3">
              <span class="text-3xl transition-transform duration-300 group-hover:scale-110 inline-block">{{ item.emoji }}</span>
              <span
                class="text-xs px-2 py-0.5 rounded font-mono"
                style="background: rgba(245,158,11,0.08); color: var(--amber); border: 1px solid rgba(245,158,11,0.15);"
              >{{ item.category }}</span>
            </div>
            <h3 class="font-display font-bold text-lg leading-tight mb-0.5" style="color: var(--text);">{{ item.name }}</h3>
            <p class="text-xs font-mono mb-3" style="color: var(--text-muted);">{{ item.spec }}</p>
            <p class="text-xs leading-relaxed" style="color: var(--text-muted);">{{ item.description }}</p>
          </div>
        </div>
      </div>

      <!-- Software section -->
      <div>
        <div class="flex items-center gap-3 mb-6 reveal">
          <div class="h-px flex-1" style="background: var(--glass-border);" />
          <span class="text-xs font-mono px-3 py-1 rounded-full" style="color: var(--cyan); background: rgba(34,211,238,0.1); border: 1px solid rgba(34,211,238,0.2);">Software</span>
          <div class="h-px flex-1" style="background: var(--glass-border);" />
        </div>

        <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
          <div
            v-for="(item, i) in setupData.software"
            :key="item.id"
            class="glass rounded-xl p-4 group setup-card reveal text-center"
            :style="{ transitionDelay: `${i * 0.06}s` }"
          >
            <span class="text-2xl transition-transform duration-300 group-hover:scale-125 inline-block mb-2">{{ item.emoji }}</span>
            <h3 class="font-semibold text-sm mb-0.5" style="color: var(--text);">{{ item.name }}</h3>
            <p class="text-xs font-mono" :style="`color: ${item.color};`">{{ item.category }}</p>
            <p class="text-xs mt-2 leading-relaxed" style="color: var(--text-muted); display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">{{ item.description }}</p>
          </div>
        </div>
      </div>

      <!-- Dotfiles note -->
      <div class="mt-16 glass rounded-2xl p-6 reveal flex items-center gap-4">
        <span class="text-3xl">📦</span>
        <div>
          <h3 class="font-display font-bold text-lg mb-1" style="color: var(--text);">Dotfiles</h3>
          <p class="text-sm" style="color: var(--text-muted);">設定ファイル群はGitHubで管理中。シェルはzsh + Starship。</p>
        </div>
        <a
          href="https://github.com/ryo-suzukii"
          target="_blank"
          rel="noopener noreferrer"
          class="ml-auto text-xs font-mono px-4 py-2 rounded-lg transition-colors duration-200"
          style="background: rgba(255,255,255,0.06); color: var(--text-muted); border: 1px solid var(--glass-border);"
        >→ GitHub</a>
      </div>

    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { setupData } from '../data/setup.js'

onMounted(() => {
  const observer = new IntersectionObserver(
    entries => entries.forEach(e => { if (e.isIntersecting) { e.target.classList.add('visible'); observer.unobserve(e.target) } }),
    { threshold: 0.05, rootMargin: '0px 0px -20px 0px' }
  )
  requestAnimationFrame(() => document.querySelectorAll('.reveal').forEach(el => observer.observe(el)))
})
</script>

<style scoped>
.setup-card {
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}
.setup-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
}
</style>
