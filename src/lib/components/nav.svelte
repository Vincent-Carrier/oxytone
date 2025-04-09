<script lang="ts">
	import FlashcardsButton from './flashcards-button.svelte'
	import Toggle from './toggle.svelte'
	import Tooltip from './tooltip.svelte'
	import g from '$/lib/global-state.svelte'

	type Props = { content?: HTMLElement }
	let { content }: Props = $props()
	let manualAnalysis = $derived(content?.dataset.analysis === 'manual')
	$inspect(manualAnalysis)
</script>

<nav
	class="font-sans-sc sticky top-0 z-50 flex items-baseline gap-x-2 border-b border-gray-300 bg-gray-50 py-1 pr-4 pl-[var(--padded-margin-w)] text-sm">
	<a href="/" class="text-gray-800">oxytone</a>
	<div class="grow"></div>
	<FlashcardsButton />
	<Toggle get={() => g.analysis} set={val => (g.analysis = val)}>
		analysis
		{#snippet tooltip()}
			<Tooltip class="w-52 text-balance">
				<p>
					When selected, each word underlines its <span class="underline">syntactical head</span> and
					the bounds of its dependencies are shown 「within brackets」. Furthermore, a verb's complements
					will be highlighted.
				</p>
				{#if !manualAnalysis}
					{@render disclaimer()}
				{/if}
			</Tooltip>
		{/snippet}
	</Toggle>
	<Toggle key="verbs" set={val => content?.classList.toggle('verbs', val)}>
		verbs
		{#snippet tooltip()}
			<Tooltip class="w-48 text-balance">
				<p>
					Each verb is shown in <strong>bold</strong>. Finite verbs are in a bolder weight than
					infinitives and participles.
				</p>
			</Tooltip>
		{/snippet}
	</Toggle>
	<Toggle key="colors" set={val => content?.classList.toggle('syntax', val)}>
		colors
		{#snippet tooltip()}
			<Tooltip class="w-56 text-balance">
				<p>Each word is colored according to its case:</p>
				<div class="syntax font-sans-sc flex flex-wrap justify-center gap-x-4 font-bold lowercase">
					<div class="text-green-700">Nominative</div>
					<div class="text-cyan-700">Accusative</div>
					<div class="text-yellow-700">Dative</div>
					<div class="text-purple-700">Genitive</div>
					<div class="text-pink-700">Vocative</div>
				</div>
			</Tooltip>
		{/snippet}
	</Toggle>
</nav>

{#snippet disclaimer()}
	<p class="mt-2 text-gray-500 italic">
		<strong class="text-gray-700">N.B.</strong>: This text was annotated automatically. Syntactical
		analysis may not be very accurate. Enable at your own risk.
	</p>
{/snippet}
