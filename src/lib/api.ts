import ky from 'ky'
import { browser } from '$app/environment'
import { PUBLIC_BASEX_URL } from '$env/static/public'

// Universal `load` functions run both in the browser and on the server, so this
// base URL has to work in both places.
//
// In the browser a relative prefix (the production `/basex/`) is correct: it
// resolves against the page origin and Caddy proxies it to BaseX, stripping the
// `/basex` prefix on the way.
//
// On the server there is no origin to resolve against — ky/undici reject a
// relative URL with `Failed to parse URL` — so SSR talks to BaseX directly on
// localhost. That bypasses Caddy, so the proxy-only `/basex/` prefix must be
// dropped rather than appended.
//
// An absolute PUBLIC_BASEX_URL (the dev default, http://localhost:8080/) is
// already valid in both contexts and is passed through untouched.
const SSR_BASEX_URL = 'http://localhost:8080/'

const prefixUrl =
	browser || /^https?:\/\//.test(PUBLIC_BASEX_URL) ? PUBLIC_BASEX_URL : SSR_BASEX_URL

export const basex = ky.create({ prefixUrl, fetch })
