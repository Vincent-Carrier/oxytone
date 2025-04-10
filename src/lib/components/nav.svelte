<script lang="ts">
	import FlashcardsButton from './flashcards-button.svelte'
	import Toggle from './toggle.svelte'
	import g from '$/lib/global-state.svelte'

	type Props = { content?: Nullish<HTMLElement> }
	let { content }: Props = $props()
	let manualAnalysis = $derived(content?.dataset.analysis === 'manual')
	$inspect(manualAnalysis)
</script>

<nav
	class={[
		'sticky top-0 z-50 flex items-baseline gap-x-2 py-1 pr-4 pl-[var(--padded-margin-w)]',
		'font-sans-sc border-b border-gray-300 bg-gray-50 text-sm'
	]}>
	<a href="/" class="text-gray-800">oxytone</a>
	<div class="grow"></div>
	<FlashcardsButton />
	<Toggle get={() => g.analysis} set={val => (g.analysis = val)}>
		analysis
		{#snippet tooltip()}
			<div class="w-56">
				<p>If enabled, whenever a word is selected:</p>
				<ol>
					<li>Its <span class="underline">syntactical head</span> is underlined.</li>
					<li>The 「bounds of its dependencies」 are shown within brackets.</li>
					<li>
						If a verb, its <span class="rounded-xs bg-blue-50 outline outline-blue-300"
							>complements</span> will be highlighted.
					</li>
				</ol>
				{#if !manualAnalysis}
					<p class="mt-2 text-gray-500 italic">
						<strong class="text-gray-700">N.B.</strong>: This text was annotated automatically.
						Accuracy may vary.
					</p>
				{/if}
			</div>
		{/snippet}
	</Toggle>
	<Toggle key="verbs" set={val => content?.classList.toggle('verbs', val)}>
		verbs
		{#snippet tooltip()}
			<div class="w-60">
				<p>
					Each verb is shown in <strong>bold</strong>. Finite verbs are in a bolder weight than
					infinitives and participles.
				</p>
			</div>
		{/snippet}
	</Toggle>
	<Toggle key="colors" set={val => content?.classList.toggle('syntax', val)}>
		colors
		{#snippet tooltip()}
			<div class="w-48">
				<p>Each word is colored according to its case:</p>
				<div class="syntax font-sans-sc flex flex-wrap justify-center gap-x-4 font-bold lowercase">
					<div class="text-green-700">Nominative</div>
					<div class="text-cyan-700">Accusative</div>
					<div class="text-yellow-700">Dative</div>
					<div class="text-purple-700">Genitive</div>
					<div class="text-pink-700">Vocative</div>
				</div>
			</div>
		{/snippet}
	</Toggle>
</nav>
