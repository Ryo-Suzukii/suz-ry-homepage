<template>
  <div class="min-h-screen pt-24 pb-20 px-6" style="background: var(--bg);">
    <div class="max-w-3xl mx-auto">

      <!-- Header -->
      <div class="mb-16 reveal" ref="header">
        <p class="font-mono text-xs mb-3" style="color: var(--cyan);">./career</p>
        <h1 class="font-display font-bold gradient-text" style="font-size: clamp(2.5rem, 6vw, 4rem); line-height: 1.1;">
          経歴
        </h1>
        <p class="mt-4 text-sm leading-relaxed" style="color: var(--text-muted);">
          ゼロから始めて、フルスタックエンジニアになるまでの軌跡。
        </p>
      </div>

      <!-- Timeline -->
      <div class="relative">
        <!-- Line -->
        <div
          class="absolute left-4 top-0 bottom-0 w-px"
          style="background: linear-gradient(to bottom, var(--violet), var(--cyan), transparent);"
        />

        <div class="space-y-12 pl-12">
          <div
            v-for="(item, i) in careerData"
            :key="item.id"
            class="reveal relative"
            :style="{ transitionDelay: `${i * 0.15}s` }"
          >
            <!-- Dot -->
            <div
              class="absolute -left-12 top-1 w-3 h-3 rounded-full border-2 animate-pulse-glow"
              :style="{
                background: dotColors[item.type],
                borderColor: dotColors[item.type],
                left: '-2.75rem',
              }"
            />

            <div class="glass rounded-2xl p-6 group hover:scale-[1.01] transition-transform duration-300">
              <!-- Period badge -->
              <div class="flex flex-wrap items-start justify-between gap-3 mb-4">
                <span
                  class="font-mono text-xs px-3 py-1 rounded-full"
                  :style="{
                    background: `${dotColors[item.type]}20`,
                    color: dotColors[item.type],
                    border: `1px solid ${dotColors[item.type]}44`,
                  }"
                >{{ item.period }}</span>
                <span class="text-2xl">{{ item.icon }}</span>
              </div>

              <h3 class="font-display font-bold text-xl mb-1" style="color: var(--text);">{{ item.role }}</h3>
              <p class="text-xs mb-3 font-mono" style="color: var(--text-muted);">{{ item.company }}</p>
              <p class="text-sm leading-relaxed mb-4" style="color: var(--text-muted);">{{ item.description }}</p>

              <div class="flex flex-wrap gap-2">
                <span
                  v-for="tag in item.tags"
                  :key="tag"
                  class="text-xs px-2 py-0.5 rounded font-mono"
                  style="background: rgba(255,255,255,0.05); color: var(--text-muted); border: 1px solid var(--glass-border);"
                >{{ tag }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Skills summary -->
      <div class="mt-20 reveal">
        <h2 class="font-display font-bold text-2xl mb-8" style="color: var(--text);">技術スタック</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div
            v-for="skill in skills"
            :key="skill.name"
            class="glass rounded-xl p-5"
          >
            <div class="flex items-center justify-between mb-3">
              <div>
                <p class="font-semibold text-sm" style="color: var(--text);">{{ skill.name }}</p>
                <p class="text-xs font-mono mt-0.5" style="color: var(--text-muted);">{{ skill.years }}年</p>
              </div>
              <span class="text-xl">{{ skill.emoji }}</span>
            </div>
            <div class="h-1.5 rounded-full overflow-hidden" style="background: rgba(255,255,255,0.06);">
              <div
                class="h-full rounded-full transition-all duration-1000 skill-bar"
                :style="{
                  width: barsVisible ? `${skill.level}%` : '0%',
                  background: `linear-gradient(90deg, var(--violet), var(--cyan))`,
                }"
              />
            </div>
            <div class="flex justify-between mt-1">
              <span class="text-xs" style="color: var(--text-dim);">{{ skill.category }}</span>
              <span class="text-xs font-mono" style="color: var(--text-muted);">{{ skill.level }}%</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Certifications -->
      <div class="mt-16 reveal">
        <h2 class="font-display font-bold text-2xl mb-6" style="color: var(--text);">資格・認定</h2>
        <div class="glass rounded-2xl p-6 flex items-center gap-4">
          <span class="text-3xl">☁️</span>
          <div>
            <p class="font-semibold" style="color: var(--text);">AWS Certified Cloud Practitioner</p>
            <p class="text-xs font-mono mt-1" style="color: var(--text-muted);">Amazon Web Services</p>
          </div>
          <div class="ml-auto">
            <span class="text-xs px-3 py-1 rounded-full font-mono" style="background: rgba(34,211,238,0.1); color: var(--cyan); border: 1px solid rgba(34,211,238,0.2);">
              Certified
            </span>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { careerData } from '../data/career.js'

const barsVisible = ref(false)

const dotColors = {
  hobby: '#a78bfa',
  education: '#22d3ee',
  work: '#4ade80',
}

const skills = [
  { name: 'Python / FastAPI', category: 'Backend', level: 85, years: 6, emoji: '🐍' },
  { name: 'AWS / Cloud', category: 'Infrastructure', level: 85, years: 3, emoji: '☁️' },
  { name: 'Vue.js / Nuxt', category: 'Frontend', level: 80, years: 2, emoji: '💚' },
  { name: 'Docker / K8s', category: 'DevOps', level: 75, years: 2, emoji: '🐳' },
  { name: 'PostgreSQL', category: 'Database', level: 75, years: 2, emoji: '🗄️' },
  { name: 'CI/CD', category: 'DevOps', level: 85, years: 3, emoji: '🔄' },
]

onMounted(() => {
  const observer = new IntersectionObserver(
    entries => {
      entries.forEach(e => {
        if (e.isIntersecting) e.target.classList.add('visible')
      })
    },
    { threshold: 0.1, rootMargin: '0px 0px -40px 0px' }
  )
  document.querySelectorAll('.reveal').forEach(el => observer.observe(el))

  const barObserver = new IntersectionObserver(
    entries => {
      if (entries[0].isIntersecting) {
        barsVisible.value = true
        barObserver.disconnect()
      }
    },
    { threshold: 0.3 }
  )
  const skillSection = document.querySelector('.skill-bar')?.closest('.glass')
  if (skillSection) barObserver.observe(skillSection)

  // Fallback: show bars after 1s
  setTimeout(() => { barsVisible.value = true }, 1200)
})
</script>

<style scoped>
.skill-bar {
  transition: width 1.2s cubic-bezier(0.4, 0, 0.2, 1);
}
</style>
