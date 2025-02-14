import type { PageLoad } from "./$types"

const DB_URL = 'http://localhost:8080'

export const load: PageLoad = async ({ params }) => {
  console.log(params.urn)
  const res = await fetch(`${DB_URL}/read/${params.urn}`)
  return {
    treebank: await res.text()
  }
}
