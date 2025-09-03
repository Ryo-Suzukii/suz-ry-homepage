<script setup>
import { watch } from "vue"

import { useAuth } from "./plugins/auth/index.js"
import { useStore } from "./store/app.js"

const { isLoading } = useAuth()
const store = useStore()

watch(isLoading, (value) => store.setLoading(value))
</script>

<template>
  <router-view class="h-screen w-screen" />
</template>
