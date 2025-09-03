import { createRouter as baseCreateRouter, createWebHashHistory } from "vue-router"

import HomePage from "../pages/HomePage.vue"
import AboutMe from "../pages/AboutMe.vue"
import AboutSite from "../pages/AboutSite.vue"
import Portfolio from "../pages/Portfolio.vue"
import PortfolioDetail from "../pages/PortfolioDetail.vue"
import Skills from "../pages/Skills.vue"
import Profile from "../pages/Profile.vue"
import Contact from "../pages/Contact.vue"
import NotFound from "../pages/NotFound.vue"

function createRouter() {
  const routes = [
    { name: "home", path: "/", component: HomePage },
    { name: "about-site", path: "/about-site", component: AboutSite },
    { name: "about-me", path: "/about-me", component: AboutMe },
    { name: "portfolio", path: "/portfolio", component: Portfolio },
    { name: "portfolio-detail", path: "/portfolio/:id", component: PortfolioDetail },
    { name: "skills", path: "/skills", component: Skills },
    { name: "profile", path: "/profile", component: Profile },
    { name: "contact", path: "/contact", component: Contact },
    { name: "not-found", path: "/:pathMatch(.*)*", component: NotFound },
  ]

  const router = baseCreateRouter({ routes, history: createWebHashHistory() })
  router.beforeEach((to) => {
    return
  })

  return router
}

export const router = createRouter()
