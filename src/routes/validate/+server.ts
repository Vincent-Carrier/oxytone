import ky from 'ky'
import type { RequestHandler } from './$types'

export const HEAD: RequestHandler = async ({ url }) => {
	const target = url.searchParams.get('url')!
	// Wikimedia rejects requests without a User-Agent with a 403, which would
	// otherwise mark every wiktionary.org link as dead.
	// https://foundation.wikimedia.org/wiki/Policy:User-Agent_policy
	return await ky.head(target, {
		retry: 0,
		headers: { 'user-agent': 'oxytone/1.0 (https://oxytone.xyz)' }
	})
}
