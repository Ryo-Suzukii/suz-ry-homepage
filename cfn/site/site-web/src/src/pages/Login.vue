<script setup>
import { useAuth } from "../plugins/auth/index.js"

const { login } = useAuth()
</script>

<template>
  <div class="bg-gray-300 flex items-center justify-center">
    <div class="h-128 w-96 p-16 bg-white shadow-md rounded-xl flex flex-col justify-center gap-y-16">
      <div class="flex-1 flex items-center justify-center">
        <img src="/vue.svg" alt="Logo" class="w-32 h-32" />
      </div>
      <div>
        <button
          class="w-full px-8 py-2 bg-blue-500 hover:bg-blue-700 rounded text-white text-xl cursor-pointer"
          @click="login()"
        >
          Login
        </button>
      </div>
    </div>
  </div>
</template>
