import { SvelteSet } from 'svelte/reactivity'

type GlobalState = {
  content?: HTMLElement | null
  selected?: WordElement | null
  selecting: boolean
  selection: SvelteSet<WordElement>
  analysis: boolean
  smoothBreathings: boolean
}

const global: GlobalState = $state({
  selecting: false,
  selection: new SvelteSet(),
  analysis: true,
  smoothBreathings: true
})

export default global
