import type { PageLoad } from './$types'
import { basex } from '$lib/api'

// Awaited for the same reason as the treebank on the read route: the translation
// is the page, so a loading shell would only delay the text it came for.
export const load: PageLoad = async ({ params, url }) => {
	// Which edition to read, forwarded from the link the reader followed. A work
	// can have up to five translations of it, and the endpoint falls back to the
	// oldest when this is absent — so dropping it here would quietly serve the
	// same edition whichever one was picked.
	const ed = url.searchParams.get('ed')

	return {
		translation: await basex
			.get(`translate/${params.urn}`, { searchParams: ed ? { ed } : {} })
			.text(),
		urn: params.urn
	}
}
