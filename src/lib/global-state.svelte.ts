import { browser } from '$app/environment'
import { SvelteSet } from 'svelte/reactivity'

const g = $state({
	// The treebank's #tb-content element, published by the read route once the
	// server-rendered HTML is mounted.
	content: null as HTMLElement | null,
	// The word whose definition is showing. One at a time, unlike `selection`.
	selected: null as WordElement | null,
	// Whether flashcard mode is on, in which clicking words accumulates a deck.
	selecting: false,
	// The words gathered for the flashcard deck, only meaningful while `selecting`.
	selection: new SvelteSet<WordElement>(),
	analysis: stored('analysis'),
	// Whether the loaded text's treebank was machine-annotated (GLAUx marks each
	// sentence `auto` or `manual`). Distinct from `analysis`, which is the user's
	// toggle and only takes its *initial* value from this.
	autoAnnotated: false,
	smoothBreathings: stored('smoothBreathings'),
	verbs: stored('verbs'),
	colors: stored('colors'),
	memMode: false
})

// Whether the user has ever set `analysis` themselves. Until they do, each text
// picks the default from its own annotation quality (see the read route); once
// they have, that choice wins on every text.
export const analysisChosen = $state({ current: hasStored('analysis') })

// Persists the toggles that survive a reload. Kept next to the state rather than
// at the call site so that every mutation persists wherever it comes from: the
// display menu binds these with `bind:checked`, which writes straight into the
// state without going through any callback a menu could hang persistence off.
//
// $effect.root because a module has no component owner to attach an effect to.
// These live as long as the tab, so they are never torn down.
if (browser) {
	$effect.root(() => {
		$effect(() => localStorage.setItem('verbs', JSON.stringify(g.verbs)))
		$effect(() => localStorage.setItem('colors', JSON.stringify(g.colors)))
		$effect(() => localStorage.setItem('smoothBreathings', JSON.stringify(g.smoothBreathings)))
		// Only once the user has actually toggled it, so this stores their choice
		// and not the per-text default the read route assigns on every mount.
		$effect(() => {
			if (analysisChosen.current) localStorage.setItem('analysis', JSON.stringify(g.analysis))
		})
	})
}

export default g

// A persisted display toggle, defaulting to on — every one of them is a reading
// aid, so an unconfigured reader should see them all. Also the SSR value, so the
// server-rendered markup matches the common case.
function stored(key: string): boolean {
	if (!browser) return true
	const store = localStorage.getItem(key)
	return store ? JSON.parse(store) : true
}

function hasStored(key: string): boolean {
	return browser && localStorage.getItem(key) !== null
}
