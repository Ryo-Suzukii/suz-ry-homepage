import { auth } from "./plugin.js"

export function createAuthGuard() {
  return async () => {
    const search = location.search
    if ((search.includes("code=") || search.includes("error=")) && search.includes("state=")) {
      try {
        await auth.handleLoginCallback()
      } catch {
        await auth.logout()
        return "login"
      } finally {
        const url = location.href.replace(location.origin, "").replace(location.search, "")
        history.replaceState({}, document.title, url)
      }
    } else if (!(await auth.checkLogin())) {
      return "login"
    }
  }
}
