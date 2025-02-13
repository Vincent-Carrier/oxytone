import type { PageLoad } from "./$types"

export const load: PageLoad = async ({ params }) => {
  const res = await fetch('http://localhost:8080/read/tlg0003/tlg001/perseus-grc1')
  return {
    treebank: await res.text()
  }
}
