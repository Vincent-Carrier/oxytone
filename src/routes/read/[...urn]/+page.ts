import type { PageLoad } from './$types';
import { basex } from '$lib/api';

export const load: PageLoad = async ({ params }) => {
	return {
		treebank: basex.get(`read/${params.urn}`).text()
	};
};
