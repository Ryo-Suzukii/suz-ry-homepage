import { defineStore } from "pinia"
import { ref } from "vue"

export const useStore = defineStore("app", () => {
  const loading = ref(false)

  return {
    loading,

    setLoading(value) {
      loading.value = value
    },
  }
})
