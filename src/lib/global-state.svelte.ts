import { browser } from '$app/environment'
import { SvelteSet } from 'svelte/reactivity'

const g = $state({
	content: null as HTMLElement | null,
	selected: null as WordElement | null,
	selecting: false,
	selection: new SvelteSet<WordElement>(),
	analysis: true,
	// Whether the loaded text's treebank was machine-annotated (GLAUx marks each
	// sentence `auto` or `manual`). Distinct from `analysis`, which is the user's
	// toggle and only takes its *initial* value from this.
	autoAnnotated: false,
	smoothBreathings: true,
	verbs: stored('verbs'),
	colors: stored('colors'),
	memMode: false
})

export default g

function stored(key: string): boolean {
	if (!browser) return true
	const store = localStorage.getItem(key)
	return store ? JSON.parse(store) : true
}
