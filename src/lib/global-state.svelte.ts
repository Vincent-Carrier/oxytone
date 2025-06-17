import { browser } from '$app/environment'
import { SvelteSet } from 'svelte/reactivity'

const g = $state({
  content: null as HTMLElement | null,
  selected: null as WordElement | null,
  selecting: false,
  selection: new SvelteSet<WordElement>(),
  analysis: true,
  smoothBreathings: true,
  verbs: stored('verbs'),
  colors: stored('colors'),
  memMode: false,
})

export default g


function stored(key: string): boolean {
  if (!browser) return true
  let store = localStorage.getItem(key)
  return store ? JSON.parse(store) : true
}
