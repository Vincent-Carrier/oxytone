<script lang="ts">
	import './treebank.css'
	import type { PageProps } from './$types'
	import '$lib/components/word.svelte'
	import type { Word } from '$lib/components/word.svelte'
	import FlashcardsButton from '$lib/components/flashcards-button.svelte'
	import Morphology from '$lib/components/morphology.svelte'
	import Definition from '$lib/components/definition.svelte'
	import Tooltip from '$/lib/components/tooltip.svelte'
	import Toggle from '$/lib/components/toggle.svelte'

	let { data }: PageProps = $props()
	let container: HTMLElement | null = $state(null)
	let tb: HTMLElement | null = $state(null)
	let selection: Word[] | null = $state(null)
	let defined: Word | null = $state(null)

	$effect(() => {
		if (tb === null) return
		const q = (sel: string) => tb!.querySelector(sel)
		const qq = (sel: string) => tb!.querySelectorAll<HTMLElement>(sel)

		document.title = q('h1')?.textContent ?? 'Oxytone'

		let { hash } = location
		if (hash) q(`a[href="${hash}`)?.scrollIntoView({ behavior: 'smooth' })

		// allow hash anchors to be unselected and remove them from browser history
		for (let anchor of qq('a[href^="#"]')) {
			anchor.addEventListener('click', ev => {
				let a = ev.target as HTMLAnchorElement
				if (a.hash === location.hash) location.replace('#')
				else location.replace(a.hash)
				ev.preventDefault()
			})
		}

		tb.addEventListener('w-click', async ev => {
			let w = ev.target as Word
			if (selection === null) {
				w.defined = !w.defined
				if (defined && defined !== w) defined.defined = false
				defined = w === defined ? null : w
				defined?.highlightComplements()
			} else {
				defined = null
				w.selected = !w.selected
				if (w.selected) selection.push(w)
				else selection.splice(selection.indexOf(w))
			}
		})
	})

	$effect(() => {
		if (defined === null) {
			let old = tb?.querySelector<Word>('ox-w.defined')
			if (old) old.defined = false
		}
		if (selection === null) {
			for (let w of tb?.querySelectorAll<Word>('ox-w.selected') ?? []) {
				w.selected = false
			}
		}
	})
</script>

<div class="flex h-screen flex-col overflow-x-hidden">
	{@render nav()}
	<div
		class="absolute top-0 bottom-0 left-0 -z-10 w-[var(--margin-w)] border-r-1 border-gray-200 bg-gray-50">
	</div>
	<div id="tb-container" bind:this={container} class="contents">
		{#await data.treebank}
			<p class="font-sc mt-32 self-center text-2xl lowercase">Loading ...</p>
		{:then treebank}
			<article
				bind:this={tb}
				id="treebank"
				class="h-full scroll-pt-8 overflow-y-scroll scroll-smooth pt-4 pr-4 pb-12 leading-relaxed">
				<div class="max-w-[60ch] font-serif">
					{@html treebank}
				</div>
			</article>
		{:catch}
			<p class="font-sc mt-32 self-center text-2xl lowercase">Something went wrong</p>
		{/await}
	</div>
	{#if defined}
		<Morphology word={defined} />
	{/if}
	{#if defined?.lemma}
		<Definition lemma={defined.lemma} />
	{/if}
</div>

{#snippet nav()}
	<nav
		class="font-sans-sc sticky top-0 z-50 flex items-baseline gap-x-2 border-b border-gray-300 bg-gray-50 py-1 pr-4 pl-[var(--padded-margin-w)] text-sm">
		<a href="/" class="text-gray-800">oxytone</a>
		<div class="grow"></div>
		<FlashcardsButton bind:selection bind:defined />
		<Toggle key="verbs" set={val => container?.classList.toggle('verbs', val)}>
			verbs
			{#snippet tooltip()}
				<Tooltip class="w-max">
					<p>Each verb is shown in <strong>bold</strong></p>
				</Tooltip>
			{/snippet}
		</Toggle>
		<Toggle key="colors" set={val => container?.classList.toggle('syntax', val)}>
			colors
			{#snippet tooltip()}
				<Tooltip class="w-56">
					<p>Each word is colored according to its case:</p>
					<div
						class="syntax font-sans-sc flex flex-wrap justify-center gap-x-4 font-bold lowercase">
						<div class="text-emerald-700">Nominative</div>
						<div class="text-sky-700">Accusative</div>
						<div class="text-yellow-700">Dative</div>
						<div class="text-purple-700">Genitive</div>
						<div class="text-pink-700">Vocative</div>
					</div>
				</Tooltip>
			{/snippet}
		</Toggle>
	</nav>
{/snippet}
