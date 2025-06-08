<script lang="ts">
	import FlashcardsButton from './flashcards-button.svelte'
	import Toggle from './toggle.svelte'
	import Tooltip from './tooltip.svelte'
	import g from '$/lib/global-state.svelte'

	function toggleSmoothBreathings(val: boolean) {
		if (!g.content) return
		for (let w of g.content.querySelectorAll<WordElement>('ox-w')) {
			w.toggleSmoothBreathing(val)
		}
	}
</script>

<nav
	class={[
		'sticky top-0 z-50 flex items-baseline gap-x-2 py-1 pr-4 pl-[var(--padded-margin-w)]',
		'font-sans-sc border-b border-gray-300 bg-gray-50 text-sm'
	]}>
	<a href="/" class="text-gray-800">oxytone</a>
	<div class="grow"></div>
	<Tooltip>
		<FlashcardsButton />
		{#snippet tooltip()}
			<p class="w-52">
				Create a deck of flashcards from the words you select. Each card will have the lemma on the
				front side and a full LSJ definition on its back side. The deck can be imported into Anki or
				any other software compatible with the Anki format.
			</p>
		{/snippet}
	</Tooltip>
	<Tooltip>
		<Toggle class="max-sm:hidden" get={() => g.analysis} set={val => (g.analysis = val)}
			>analysis</Toggle>
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
				{#if !g.analysis}
					<p class="mt-2 text-gray-500 italic">
						<strong class="text-gray-700">N.B.</strong>: This text was annotated automatically.
						Accuracy may vary.
					</p>
				{/if}
			</div>
		{/snippet}
	</Tooltip>
	<Tooltip>
		<Toggle key="verbs" set={val => g.content?.classList.toggle('verbs', val)}>verbs</Toggle>
		{#snippet tooltip()}
			<div class="w-60">
				<p>
					Each verb is shown in <strong>bold</strong>. Finite verbs are in a bolder weight than
					infinitives and participles.
				</p>
			</div>
		{/snippet}
	</Tooltip>
	<Tooltip>
		<Toggle key="colors" set={val => g.content?.classList.toggle('syntax', val)}>colors</Toggle>
		{#snippet tooltip()}
			<div class="w-48">
				<p>Each word is colored according to its case:</p>
				<div class="syntax font-sans-sc flex flex-wrap justify-center gap-x-4 font-bold lowercase">
					<div class="text-nom-700">Nominative</div>
					<div class="text-acc-700">Accusative</div>
					<div class="text-dat-700">Dative</div>
					<div class="text-gen-700">Genitive</div>
					<div class="text-voc-700">Vocative</div>
				</div>
			</div>
		{/snippet}
	</Tooltip>
	<Tooltip>
		<Toggle get={() => g.smoothBreathings} set={toggleSmoothBreathings}>breathings</Toggle>
		{#snippet tooltip()}
			<div class="w-60">
				<p>Remove unnecessary smooth breathing marks.</p>
				<p>
					<strong class="text-red-700"
						><span class="font-sans-sc">caution</span>: May trigger dizziness, altered vision, eye
						or muscle twitches, loss of awareness, disorientation, or convulsions. Discretion is
						advised.</strong>
				</p>
			</div>
		{/snippet}
	</Tooltip>
</nav>
