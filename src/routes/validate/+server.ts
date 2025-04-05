import ky from 'ky'
import type { RequestHandler } from './$types'

export const HEAD: RequestHandler = async ({ url }) => {
	const target = url.searchParams.get('url')!
	return await ky.head(target)
}
