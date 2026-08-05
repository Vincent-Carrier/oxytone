import type { PageLoad } from './$types'
import { basex } from '$lib/api'

// Awaited rather than streamed: the treebank *is* the page, so handing the
// browser a "Loading ..." shell only to fetch it in a second round-trip delays
// the text it came for. Server-rendering costs ~75ms of TTFB and pays it back
// by arriving readable.
export const load: PageLoad = async ({ params }) => {
	return {
		treebank: await basex.get(`read/${params.urn}`).text()
	}
}
