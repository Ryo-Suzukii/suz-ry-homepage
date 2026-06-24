<template>
  <div class="min-h-screen pt-24 pb-20 px-6" style="background: var(--bg);">
    <div class="max-w-4xl mx-auto">

      <!-- Header -->
      <div class="mb-12 reveal">
        <p class="font-mono text-xs mb-3" style="color: var(--cyan);">./products</p>
        <h1 class="font-display font-bold" style="font-size: clamp(2.5rem, 6vw, 4rem); line-height: 1.1; color: var(--text);">
          プロダクト
        </h1>
        <p class="mt-4 text-sm leading-relaxed" style="color: var(--text-muted);">
          作ったもの。仕事でも、個人でも、好奇心が向いた方向へ。
        </p>
      </div>

      <!-- Products list -->
      <div class="space-y-5">
        <div
          v-for="(product, i) in productsData"
          :key="product.id"
          class="glass rounded-2xl p-6 group product-card reveal"
          :style="{ transitionDelay: `${i * 0.12}s` }"
        >
          <div class="flex flex-wrap items-start gap-4">
            <!-- Icon -->
            <div
              class="w-14 h-14 rounded-xl flex items-center justify-center text-2xl shrink-0 transition-transform duration-300 group-hover:scale-110"
              :style="`background: ${product.color}20; border: 1px solid ${product.color}33;`"
            >{{ product.emoji }}</div>

            <div class="flex-1 min-w-0">
              <!-- Title row -->
              <div class="flex flex-wrap items-center gap-2 mb-1">
                <h3 class="font-display font-bold text-xl" style="color: var(--text);">{{ product.name }}</h3>
                <span
                  class="text-xs px-2 py-0.5 rounded-full font-mono"
                  :style="product.status === 'live'
                    ? 'background: rgba(74,222,128,0.1); color: var(--green); border: 1px solid rgba(74,222,128,0.2);'
                    : 'background: rgba(245,158,11,0.1); color: var(--amber); border: 1px solid rgba(245,158,11,0.2);'"
                >{{ product.status === 'live' ? '● live' : '◌ WIP' }}</span>
              </div>

              <p class="text-xs font-mono mb-3" :style="`color: ${product.color};`">{{ product.tagline }}</p>
              <p class="text-sm leading-relaxed mb-4" style="color: var(--text-muted);">{{ product.description }}</p>

              <!-- Tags -->
              <div class="flex flex-wrap gap-2 mb-4">
                <span
                  v-for="tag in product.tags"
                  :key="tag"
                  class="text-xs px-2 py-0.5 rounded font-mono"
                  style="background: rgba(255,255,255,0.05); color: var(--text-muted); border: 1px solid var(--glass-border);"
                >{{ tag }}</span>
              </div>

              <!-- Links -->
              <div class="flex gap-3">
                <a
                  v-if="product.github"
                  :href="product.github"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="text-xs px-3 py-1.5 rounded-lg transition-colors duration-200 font-mono"
                  style="background: rgba(255,255,255,0.06); color: var(--text-muted); border: 1px solid var(--glass-border);"
                >GitHub →</a>
                <a
                  v-if="product.url"
                  :href="product.url"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="text-xs px-3 py-1.5 rounded-lg transition-colors duration-200 font-mono"
                  :style="`background: ${product.color}15; color: ${product.color}; border: 1px solid ${product.color}33;`"
                >Live →</a>
                <span v-if="!product.github && !product.url" class="text-xs font-mono" style="color: var(--text-dim);">private repo</span>
              </div>
            </div>

            <!-- Year -->
            <span class="text-xs font-mono shrink-0" style="color: var(--text-dim);">{{ product.year }}</span>
          </div>
        </div>
      </div>

      <!-- Contact CTA -->
      <div class="mt-16 glass rounded-2xl p-8 text-center reveal">
        <h2 class="font-display font-bold text-2xl mb-3 gradient-text">何か一緒に作りませんか？</h2>
        <p class="text-sm mb-6" style="color: var(--text-muted);">フルスタックで相談に乗ります。お気軽に。</p>
        <a
          href="mailto:astronautryosuzuki@gmail.com"
          class="inline-flex items-center gap-2 px-6 py-3 rounded-xl font-mono text-sm transition-all duration-300"
          style="background: linear-gradient(135deg, var(--violet), var(--cyan)); color: white;"
        >
          📬 連絡する
        </a>
      </div>

    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { productsData } from '../data/products.js'

onMounted(() => {
  const observer = new IntersectionObserver(
    entries => entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible') }),
    { threshold: 0.1 }
  )
  document.querySelectorAll('.reveal').forEach(el => observer.observe(el))
})
</script>

<style scoped>
.product-card {
  transition: transform 0.3s ease;
}
.product-card:hover {
  transform: translateY(-2px);
}
</style>
