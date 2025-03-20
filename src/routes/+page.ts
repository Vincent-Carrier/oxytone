import type { PageLoad } from './$types';
import { basex } from '$lib/api';

export const load: PageLoad = async () => {
	const res = await basex.get('/');
	return {
		body: await res.text()
	};
};
