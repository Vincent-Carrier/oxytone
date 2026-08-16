<script lang="ts">
	import DisplayMenu from './display-menu.svelte'
	import FlashcardsButton from './flashcards-button.svelte'
	import SettingsMenu from './settings-menu.svelte'
	import Tooltip from './tooltip.svelte'
	import Button from './button.svelte'
	import g from '$lib/global-state.svelte'
	import { page } from '$app/state'
	import TranslationIcon from '~icons/heroicons/language-16-solid'

	// Passed in rather than derived here so the link server-renders with the rest of
	// the nav, and so the translation route — which renders this same nav and has no
	// second translation to offer — simply leaves it off.
	let { translated = false }: { translated?: boolean } = $props()

	// The read and translation routes share the {author}/{work}/{page} tail, so
	// each links to the other by swapping the prefix — which keeps the reader on
	// the same passage rather than dropping them at the top of the work.
	let urn = $derived(page.url.pathname.replace(/^\/(read|translation)\//, ''))

	function toggleSmoothBreathings(val: boolean) {
		for (let w of g.content?.querySelectorAll<WordElement>('ox-w') ?? []) {
			// The treebank HTML is injected before the `ox-w` custom elements are
			// upgraded, so this can run against elements that don't yet have the
			// method. Throwing here aborts the whole effect flush.
			w.toggleSmoothBreathing?.(val)
		}
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
				Create a deck of flashcards from the words you select. Each card will have the lemma
				on the front side and a full LSJ definition on its back side. The deck can be
				imported into Anki or any other software compatible with the Anki format.
			</p>
		{/snippet}
	</Tooltip>
	<!-- Only where there is one to read: 128 of the 180 works that paginate have no
	translation, so offering the link everywhere would mostly lead to a dead end.
	Hidden on the translation route itself, which carries its own way back. -->
	{#if translated}
		<Button href={`/translation/${urn}`}>
			<TranslationIcon />
			<span class="max-sm:sr-only">translation</span>
		</Button>
	{/if}
	<DisplayMenu />
	<SettingsMenu />
</nav>
