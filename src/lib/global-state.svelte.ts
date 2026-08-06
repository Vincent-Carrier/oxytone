import { browser } from '$app/environment'
import { SvelteSet } from 'svelte/reactivity'

const g = $state({
	content: null as HTMLElement | null,
	selected: null as WordElement | null,
	selecting: false,
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
// they have, that choice wins on every text. Without this the per-text default
// would overwrite the stored preference on every navigation.
export const analysisChosen = $state({ current: hasStored('analysis') })

// Persist the toggles that survive a reload. Done here rather than at the call
// site: the display menu binds these with `bind:checked`, and a bound value is
// written straight into the state, so an `onCheckedChange` callback alongside
// the binding never fires and the write was silently lost. Keeping it next to
// the state means every future mutation persists, wherever it comes from.
//
// $effect.root because this is a module, not a component — there is no owner to
// attach an effect to. It lives as long as the tab does, so it is never torn
// down and needs no cleanup.
if (browser) {
	$effect.root(() => {
		$effect(() => localStorage.setItem('verbs', JSON.stringify(g.verbs)))
		$effect(() => localStorage.setItem('colors', JSON.stringify(g.colors)))
		$effect(() => localStorage.setItem('smoothBreathings', JSON.stringify(g.smoothBreathings)))
		// Only once the user has actually toggled it. Writing unconditionally would
		// persist the per-text default that the read route assigns on every mount,
		// which is exactly the value this is meant to override.
		$effect(() => {
			if (analysisChosen.current) localStorage.setItem('analysis', JSON.stringify(g.analysis))
		})
	})
}

export default g

function stored(key: string): boolean {
	if (!browser) return true
	const store = localStorage.getItem(key)
	return store ? JSON.parse(store) : true
}

function hasStored(key: string): boolean {
	return browser && localStorage.getItem(key) !== null
}
