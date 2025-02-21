import type { PageLoad } from './$types';
import api from '$lib/api';

export const load: PageLoad = async ({ fetch }) => {
	const res = await api(fetch).get('');
	return {
		body: await res.text()
	};
};
