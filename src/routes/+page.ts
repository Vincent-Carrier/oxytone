import type { PageLoad } from './$types';
import { makeBaseX } from '$lib/api';

export const load: PageLoad = async ({ fetch }) => {
	const res = await makeBaseX(fetch).get('/');
	return {
		body: await res.text()
	};
};
