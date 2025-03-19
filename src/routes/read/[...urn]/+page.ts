import type { PageLoad } from './$types';
import { makeBaseX } from '$lib/api';

export const load: PageLoad = async ({ fetch, params }) => {
	const res = await makeBaseX(fetch).get(`read/${params.urn}`);
	return {
		treebank: await res.text()
	};
};
