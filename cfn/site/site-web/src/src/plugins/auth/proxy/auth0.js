import { Auth0Client } from "@auth0/auth0-spa-js"
import { ref } from "vue"

import { createCache } from "./cache.js"
import { call } from "./utils.js"

const uriBase = `${document.location.origin}${import.meta.env.BASE_URL ?? "/"}index.html`

export function createAuth0Proxy() {
  const isLoading = ref(false)
  const isAuthenticated = ref(false)
  const token = ref(null)
  const user = ref(null)
  const error = ref(null)

  const client = new Auth0Client({
    domain: import.meta.env.VITE_AUTH0_DOMAIN,
    clientId: import.meta.env.VITE_AUTH0_CLIENT_ID,
    authorizationParams: {
      audience: import.meta.env.VITE_AUTH0_IDENTIFIER,
      redirect_uri: uriBase,
    },
    useRefreshTokens: true,
    cache: createCache(import.meta.env.VITE_AUTH0_CLIENT_ID),
  })

  function reset() {
    token.value = null
    user.value = null
    error.value = null
  }

  return {
    isLoading,
    isAuthenticated,
    token,
    user,
    error,

    async login() {
      await call(() => client.loginWithRedirect(), { error })
    },

    async handleLoginCallback() {
      await call(
        async () => {
          await client.handleRedirectCallback()
          return true
        },
        { prop: isAuthenticated, isLoading, error },
      )
    },
    async getUser() {
      return await call(
        async () => {
          await client.getTokenSilently()
          return await client.getUser()
        },
        { prop: user, isLoading, error },
      )
    },

    async checkLogin() {
      return await call(
        () =>
          client
            .getTokenSilently()
            .then(() => true)
            .catch(() => false),
        { prop: isAuthenticated, isLoading },
      )
    },

    async logout() {
      await call(() => client.logout({ logoutParams: { returnTo: uriBase } }), { final: reset })
    },

    async getToken() {
      return await call(() => client.getTokenSilently(), { prop: token, isLoading, error })
    },
  }
}
