import { createRouter as baseCreateRouter, createWebHashHistory } from "vue-router"

import HomePage from "../pages/HomePage.vue"
import CareerPage from "../pages/CareerPage.vue"
import GamesPage from "../pages/GamesPage.vue"
import SetupPage from "../pages/SetupPage.vue"
import ProductsPage from "../pages/ProductsPage.vue"
import LabPage from "../pages/LabPage.vue"
import NotFound from "../pages/NotFound.vue"

function createRouter() {
  const routes = [
    { name: "home", path: "/", component: HomePage },
    { name: "career", path: "/career", component: CareerPage },
    { name: "games", path: "/games", component: GamesPage },
    { name: "setup", path: "/setup", component: SetupPage },
    { name: "products", path: "/products", component: ProductsPage },
    { name: "lab", path: "/lab", component: LabPage },
    { name: "not-found", path: "/:pathMatch(.*)*", component: NotFound },
  ]

  const router = baseCreateRouter({ routes, history: createWebHashHistory() })

  return router
}

export const router = createRouter()
