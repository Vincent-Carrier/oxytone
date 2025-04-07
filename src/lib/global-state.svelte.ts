import { SvelteSet } from 'svelte/reactivity'
import type { WordElement } from './word'

type GlobalState = {
	selected: WordElement | null
	selecting: boolean
	selection: SvelteSet<WordElement>
}

const global: GlobalState = $state({
	selected: null,
	selecting: false,
	selection: new SvelteSet()
})

export default global
