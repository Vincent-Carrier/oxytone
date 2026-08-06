import ky from 'ky'
import { browser } from '$app/environment'
import { PUBLIC_BASEX_URL } from '$env/static/public'

// Universal `load` functions run in both the browser and the server, so this base
// URL has to work in both places.
//
// In the browser the production `/basex/` prefix resolves against the page origin,
// where Caddy proxies it to BaseX and strips the prefix. On the server there is no
// origin to resolve a relative URL against (ky/undici reject it outright), so SSR
// goes straight to BaseX on localhost — bypassing Caddy, and with it the
// proxy-only prefix.
//
// An absolute PUBLIC_BASEX_URL (the dev default) is valid in both and passes
// through untouched.
const SSR_BASEX_URL = 'http://localhost:8080/'

const prefixUrl =
	browser || /^https?:\/\//.test(PUBLIC_BASEX_URL) ? PUBLIC_BASEX_URL : SSR_BASEX_URL

export const basex = ky.create({ prefixUrl, fetch })
