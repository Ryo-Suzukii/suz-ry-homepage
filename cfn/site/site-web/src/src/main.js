import { createPinia } from "pinia"
import { createApp } from "vue"

import App from "./App.vue"
import { auth } from "./plugins/auth/index.js"
import { router } from "./router/index.js"

const app = createApp(App)
app.use(createPinia())
app.use(auth)
app.use(router)
app.mount("#app")
