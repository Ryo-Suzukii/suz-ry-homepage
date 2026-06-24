<script setup>
import NavBar from './components/NavBar.vue'
</script>

<template>
  <div style="background: var(--bg); min-height: 100vh;">
    <NavBar />
    <RouterView />
  </div>
</template>
