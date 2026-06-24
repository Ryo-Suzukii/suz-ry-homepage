<template>
  <div class="min-h-screen flex items-center justify-center px-6" style="background: var(--bg);">
    <div class="text-center">
      <p class="font-mono text-xs mb-2" style="color: var(--text-muted);">
        <span style="color: var(--cyan);">ryo</span>
        <span style="color: var(--text-muted);">@suz-ry % </span>
        <span style="color: var(--text);">cd {{ route.path }}</span>
      </p>
      <p class="font-mono text-xs mb-8" style="color: var(--text-dim);">bash: cd: {{ route.path }}: No such file or directory</p>
      <h1 class="font-display font-bold gradient-text mb-4" style="font-size: clamp(5rem, 15vw, 10rem); line-height: 1;">404</h1>
      <p class="text-sm mb-8" style="color: var(--text-muted);">ページが見つかりません</p>
      <RouterLink
        to="/"
        class="font-mono text-xs px-6 py-3 rounded-xl transition-all duration-300 hover:text-white"
        style="background: rgba(255,255,255,0.06); color: var(--text-muted); border: 1px solid var(--glass-border);"
      >→ cd ~</RouterLink>
    </div>
  </div>
</template>

<script setup>
import { RouterLink, useRoute } from 'vue-router'
const route = useRoute()
</script>
