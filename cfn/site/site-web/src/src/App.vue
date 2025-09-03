<script setup>
import { watch } from "vue"

import { useAuth } from "./plugins/auth/index.js"
import { useStore } from "./store/app.js"

const { isLoading } = useAuth()
const store = useStore()

watch(isLoading, (value) => store.setLoading(value))
</script>

<template>
  <div class="app-container">
    <router-view class="h-screen w-screen" />
  </div>
</template>

<style>
.app-container {
  background-color: #000000;
  min-height: 100vh;
  width: 100vw;
}

html, body {
  background-color: #000000 !important;
  color: white;
}
</style>
