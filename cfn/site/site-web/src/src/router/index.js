import { createRouter as baseCreateRouter, createWebHashHistory } from "vue-router"

import Home from "../pages/Home.vue"
import Login from "../pages/Login.vue"
import NotFound from "../pages/NotFound.vue"
import { createAuthGuard } from "../plugins/auth/index.js"

function createRouter() {
  const routes = [
    { name: "login", path: "/login", component: Login },
    { name: "home", path: "/", component: Home },
    { name: "not-found", path: "/:pathMatch(.*)*", component: NotFound },
  ]
  const ignoreRoutes = ["login", "not-found"]

  const guard = createAuthGuard()
  const router = baseCreateRouter({ routes, history: createWebHashHistory() })
  router.beforeEach((to) => {
    if (ignoreRoutes.includes(to.name)) {
      return
    }
    return guard()
  })

  return router
}

export const router = createRouter()
