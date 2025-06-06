<script lang="ts">
	import './treebank.css'
	import type { PageProps } from './$types'
	import '$lib/components/word.svelte'
	import Morphology from '$lib/components/morphology.svelte'
	import Definition from '$lib/components/definition.svelte'
	import { fade, slide } from 'svelte/transition'
	import Nav from '$/lib/components/nav.svelte'
	import g from '$/lib/global-state.svelte'

	let tb: Nullish<HTMLElement> = $state()
	const q = (sel: string) => tb?.querySelector<HTMLElement>(sel)
	const qq = (sel: string) => content!.querySelectorAll<HTMLElement>(sel)
	let content: Nullish<HTMLElement> = $derived(q('#tb-content'))
	let title = $derived(q('h1')?.textContent ?? 'Oxytone')
	let { data }: PageProps = $props()
	let lemma = $derived(g.selected?.lemma)

	$effect(() => {
		g.analysis = content?.dataset.analysis === 'manual'
	})

	$effect(() => {
		if (!tb) return

		let l = location
		if (l.hash) q(`a[href="${l.hash}`)?.scrollIntoView({ behavior: 'smooth' })

		// allow hash anchors to be unselected and remove them from browser history
		for (let anchor of qq('a[href^="#"]')) {
			anchor.addEventListener('click', ev => {
				let a = ev.target as HTMLAnchorElement
				if (a.hash === l.hash) l.replace('#')
				else l.replace(a.hash)
				ev.preventDefault()
			})
		}
	})
</script>

<svelte:head>
	<title>{title}</title>
</svelte:head>

<div class="flex h-screen flex-col overflow-x-hidden" onlemma={ev => (lemma = ev.detail.lemma)}>
	<Nav {content} />
	<div class="contents">
		{#await data.treebank}
			<p
				transition:fade|global
				class="font-sc absolute inset-x-0 top-1/3 text-center text-2xl lowercase">
				Loading ...
			</p>
		{:then treebank}
			<article
				transition:fade|global
				bind:this={tb}
				id="treebank"
				class="h-full scroll-pt-8 overflow-y-scroll scroll-smooth pt-4 pr-4 pb-12 leading-relaxed">
				{@html treebank}
			</article>
		{:catch}
			<p transition:fade|global class="font-sc mt-32 self-center text-2xl lowercase">
				Something went wrong
			</p>
		{/await}
	</div>
	{#if g.selected}
		<div
			transition:slide
			class="fixed inset-x-0 bottom-0 z-20 flex items-baseline gap-x-2 border-t-1 border-gray-300 bg-gray-100 py-1 pr-2 pl-[var(--padded-margin-w)] text-xs">
			<Morphology word={g.selected} />
		</div>
	{/if}
	{#if lemma}
		<Definition {lemma} />
	{/if}
</div>
