import Cookie from "js-cookie"

export function createCache(clientId) {
  return {
    get(key) {
      return key in localStorage ? JSON.parse(localStorage.getItem(key)) : null
    },
    set(key, value) {
      localStorage.setItem(key, JSON.stringify(value))
    },
    remove(key) {
      if (key.startsWith(`localstorage:${clientId}:`)) {
        localStorage.removeItem(key.replace(`localstorage:${clientId}:`, ""))
      } else if (key.startsWith(`cookie:${clientId}:`)) {
        Cookie.remove(key.replace(`cookie:${clientId}:`, ""))
      }
    },
    allKeys() {
      return [...Object.keys(localStorage).map((el) => `localstorage:${clientId}:${el}`), ...Object.keys(Cookie.get()).map((el) => `cookie:${clientId}:${el}`)]
    },
  }
}
