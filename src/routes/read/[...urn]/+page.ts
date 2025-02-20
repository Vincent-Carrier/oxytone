import type { PageLoad } from "./$types"
import api from '$lib/api'

export const load: PageLoad = async ({ fetch, params }) => {
  const res = await api(fetch).get(`read/${params.urn}`)
  return {
    treebank: await res.text()
  }
}
