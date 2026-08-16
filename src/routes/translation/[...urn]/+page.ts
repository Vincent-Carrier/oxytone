import type { PageLoad } from './$types'
import { basex } from '$lib/api'

// Awaited for the same reason as the treebank on the read route: the translation
// is the page, so a loading shell would only delay the text it came for.
export const load: PageLoad = async ({ params }) => {
	return {
		translation: await basex.get(`translate/${params.urn}`).text(),
		urn: params.urn
	}
}
