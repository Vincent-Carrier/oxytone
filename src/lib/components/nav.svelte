<script lang="ts">
	import DisplayMenu from './display-menu.svelte'
	import FlashcardsButton from './flashcards-button.svelte'
	import SettingsMenu from './settings-menu.svelte'
	import Tooltip from './tooltip.svelte'
	import g from '$lib/global-state.svelte'

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
	<DisplayMenu />
	<SettingsMenu />
</nav>
