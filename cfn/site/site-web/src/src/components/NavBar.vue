<template>
  <nav
    :class="['fixed top-0 left-0 right-0 z-50 transition-all duration-300', scrolled ? 'glass' : '']"
  >
    <div class="max-w-6xl mx-auto px-6 py-4 flex items-center justify-between">
      <!-- Logo -->
      <RouterLink to="/" class="flex items-center gap-1 group" style="font-family: 'JetBrains Mono', monospace;">
        <span class="text-sm" style="color: var(--text-muted);">~/</span>
        <span class="font-semibold text-sm" style="color: var(--text);">suz-ry</span>
        <span class="animate-blink text-sm" style="color: var(--cyan);">_</span>
      </RouterLink>

      <!-- Desktop nav -->
      <div class="hidden md:flex items-center gap-1" style="font-family: 'JetBrains Mono', monospace;">
        <RouterLink
          v-for="item in navItems"
          :key="item.path"
          :to="item.path"
          class="px-3 py-1.5 rounded-md text-xs transition-all duration-200"
          :style="isActive(item.path)
            ? 'color: var(--cyan); background: rgba(34,211,238,0.08);'
            : 'color: var(--text-muted);'"
        >{{ item.label }}</RouterLink>
      </div>

      <!-- Mobile burger -->
      <button
        class="md:hidden p-2 rounded-lg transition-colors"
        style="color: var(--text-muted);"
        @click="menuOpen = !menuOpen"
        aria-label="Toggle menu"
      >
        <svg v-if="!menuOpen" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="3" y1="6" x2="21" y2="6"/>
          <line x1="3" y1="12" x2="21" y2="12"/>
          <line x1="3" y1="18" x2="21" y2="18"/>
        </svg>
        <svg v-else width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="18" y1="6" x2="6" y2="18"/>
          <line x1="6" y1="6" x2="18" y2="18"/>
        </svg>
      </button>
    </div>

    <!-- Mobile menu -->
    <Transition name="menu">
      <div
        v-if="menuOpen"
        class="md:hidden glass border-t"
        style="border-color: var(--glass-border); font-family: 'JetBrains Mono', monospace;"
      >
        <div class="max-w-6xl mx-auto px-6 py-4 flex flex-col gap-1">
          <RouterLink
            v-for="item in navItems"
            :key="item.path"
            :to="item.path"
            class="py-2 px-3 rounded-lg text-sm transition-colors"
            :style="isActive(item.path) ? 'color: var(--cyan);' : 'color: var(--text-muted);'"
            @click="menuOpen = false"
          >{{ item.label }}</RouterLink>
        </div>
      </div>
    </Transition>
  </nav>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { RouterLink, useRoute } from 'vue-router'

const route = useRoute()
const scrolled = ref(false)
const menuOpen = ref(false)

const navItems = [
  { path: '/', label: './home' },
  { path: '/career', label: './career' },
  { path: '/products', label: './products' },
  { path: '/setup', label: './setup' },
  { path: '/games', label: './games' },
  { path: '/lab', label: './lab' },
]

function isActive(path) {
  return route.path === path
}

function onScroll() {
  scrolled.value = window.scrollY > 20
}

onMounted(() => window.addEventListener('scroll', onScroll, { passive: true }))
onUnmounted(() => window.removeEventListener('scroll', onScroll))
</script>

<style scoped>
.menu-enter-active,
.menu-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}
.menu-enter-from,
.menu-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}
</style>
