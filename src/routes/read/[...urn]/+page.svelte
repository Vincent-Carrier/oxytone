<script lang="ts">
	import './treebank.css'
	import type { PageProps } from './$types'
	import '$lib/components/word.svelte'
	import Morphology from '$lib/components/morphology.svelte'
	import Definition from '$lib/components/definition.svelte'
	import { fade, slide } from 'svelte/transition'
	import Nav from '$/lib/components/nav.svelte'
	import g from '$/lib/global-state.svelte'
	let { data }: PageProps = $props()
	let container: HTMLElement | null = $state(null)
	let tb: HTMLElement | null = $state(null)

	const q = (sel: string) => tb!.querySelector(sel)
	const qq = (sel: string) => tb!.querySelectorAll<HTMLElement>(sel)

	$inspect(g)

	$effect(() => {
		if (tb === null) return

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
	})
</script>

<div class="flex h-screen flex-col overflow-x-hidden">
	<Nav {container} />
	<div
		class="absolute top-0 bottom-0 left-0 -z-10 w-[var(--margin-w)] border-r-1 border-gray-200 bg-gray-50">
	</div>
	<div id="tb-container" bind:this={container} class="contents">
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
				<div class="max-w-[60ch] font-serif">
					{@html treebank}
				</div>
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
			class="fixed inset-x-0 bottom-0 flex items-baseline gap-x-2 border-t-1 border-gray-300 bg-gray-100 py-1 pr-2 pl-[var(--padded-margin-w)] text-xs">
			<Morphology word={g.selected} />
		</div>
	{/if}
	{#if g.selected?.lemma}
		<Definition lemma={g.selected.lemma} />
	{/if}
</div>
