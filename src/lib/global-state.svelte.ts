import { SvelteSet } from 'svelte/reactivity'
import type { WordElement } from './word'

type GlobalState = {
	selected: WordElement | null
	selecting: boolean
	selection: SvelteSet<WordElement>
	analysis: boolean
}

const global: GlobalState = $state({
	selected: null,
	selecting: false,
	selection: new SvelteSet(),
	analysis: true
})

export default global
