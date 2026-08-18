<script lang="ts">
	import DisplayMenu from './display-menu.svelte'
	import FlashcardsButton from './flashcards-button.svelte'
	import SettingsMenu from './settings-menu.svelte'
	import Tooltip from './tooltip.svelte'
	import g from '$lib/global-state.svelte'
	import { treebankFor } from '$lib/treebank'
	import { toggleSmoothBreathing } from '$lib/word'

	// `tools` turns off the reading aids, for a page that has no treebank to apply
	// them to: flashcards builds a deck out of selected <ox-w> words, and the
	// display menu toggles verb marking, syntax colouring and breathings on them.
	// On the translation route there are no such words, so every one of those
	// controls is inert. Settings stays — it holds the LLM API key, which is the
	// app's, not the text's.
	let { tools = true }: { tools?: boolean } = $props()

	function toggleSmoothBreathings(val: boolean) {
		// From the index, so a long text is not re-queried on every toggle. The
		// effect also runs before the treebank is mounted, hence the guard.
		if (!g.body) return
		for (let w of treebankFor(g.body).words) toggleSmoothBreathing(w, val)
	}

	$effect(() => toggleSmoothBreathings(g.smoothBreathings))
</script>

<nav
	class={[
		'sticky top-0 z-50 flex items-baseline gap-x-2 py-1 pr-4 pl-[var(--padded-margin-w)] print:hidden',
		// On mobile the button labels go sr-only, which breaks both axes of the
		// desktop layout: baseline alignment centres the icons on a text baseline
		// that is no longer there (leaving them riding high in the bar), and gap-x-2
		// between bare icons reads as half the edge padding, bunching them together.
		// Centre them and match the gap to the padding so the spacing is even.
		'max-sm:items-center max-sm:gap-x-4',
		'font-sans-sc border-b border-gray-300 bg-gray-50 text-sm'
	]}>
	<a href="/" class="text-gray-800">oxytone</a>
	<div class="grow"></div>
	{#if tools}
		<Tooltip>
			<!-- FlashcardsButton renders buttons of its own, so the tooltip anchors to a
			wrapping element rather than its default <button>. -->
			{#snippet child({ props })}
				<div {...props}>
					<FlashcardsButton />
				</div>
			{/snippet}
			{#snippet tooltip()}
				<p class="w-64">
					Create a deck of flashcards from the words you select. Each card will have the
					lemma on the front side and a full LSJ definition on its back side. The deck can
					be imported into Anki or any other software compatible with the Anki format.
				</p>
			{/snippet}
		</Tooltip>
	{/if}
	{#if tools}
		<DisplayMenu />
	{/if}
	<SettingsMenu />
</nav>
