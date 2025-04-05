<script>
	import FlashcardsButton from './flashcards-button.svelte'
	import Toggle from './toggle.svelte'
	import Tooltip from './tooltip.svelte'

	let { selection = $bindable(), defined = $bindable(), container } = $props()
</script>

<nav
	class="font-sans-sc sticky top-0 z-50 flex items-baseline gap-x-2 border-b border-gray-300 bg-gray-50 py-1 pr-4 pl-[var(--padded-margin-w)] text-sm">
	<a href="/" class="text-gray-800">oxytone</a>
	<div class="grow"></div>
	<FlashcardsButton bind:selection bind:defined />
	<Toggle key="verbs" set={val => container?.classList.toggle('verbs', val)}>
		verbs
		{#snippet tooltip()}
			<Tooltip class="w-56 text-balance">
				<p>Each verb is shown in <strong>bold</strong></p>
				{@render disclaimer()}
			</Tooltip>
		{/snippet}
	</Toggle>
	<Toggle key="colors" set={val => container?.classList.toggle('syntax', val)}>
		colors
		{#snippet tooltip()}
			<Tooltip class="w-56 text-balance">
				<p>Each word is colored according to its case:</p>
				<div class="syntax font-sans-sc flex flex-wrap justify-center gap-x-4 font-bold lowercase">
					<div class="text-emerald-700">Nominative</div>
					<div class="text-sky-700">Accusative</div>
					<div class="text-yellow-700">Dative</div>
					<div class="text-purple-700">Genitive</div>
					<div class="text-pink-700">Vocative</div>
				</div>
				{@render disclaimer()}
			</Tooltip>
		{/snippet}
	</Toggle>
</nav>

{#snippet disclaimer()}
	<p class="mt-2 text-gray-600 italic">
		<strong>N.B.</strong>: Much of the corpus has been automated automatically and may not be 100%
		accurate.
	</p>
{/snippet}
