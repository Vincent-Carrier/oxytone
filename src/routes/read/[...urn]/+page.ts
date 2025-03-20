import type { PageLoad } from './$types';
import { basex } from '$lib/api';

export const load: PageLoad = async ({ params }) => {
	const res = await basex.get(`read/${params.urn}`);
	return {
		treebank: await res.text()
	};
};
