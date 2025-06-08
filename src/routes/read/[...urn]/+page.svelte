<script lang="ts">
	import './treebank.css'
	import type { PageProps } from './$types'
	import '$lib/components/word.svelte'
	import Morphology from '$lib/components/morphology.svelte'
	import Definition from '$lib/components/definition.svelte'
	import { fade, slide } from 'svelte/transition'
	import Nav from '$/lib/components/nav.svelte'
	import g from '$/lib/global-state.svelte'
	import type { Attachment } from 'svelte/attachments'

	let { data }: PageProps = $props()
	let lemma = $derived(g.selected?.lemma)

	const onTbMount: Attachment = tb => {
		const q = (sel: string) => tb.querySelector<HTMLElement>(sel)
		let title = q('h1')?.textContent ?? 'Oxytone'
		document.title = title
		let content = q('#tb-content')
		g.content = content

		if (!g.content) return
		const qq = (sel: string) => g.content!.querySelectorAll<HTMLElement>(sel)
		let l = location
		if (l.hash) q(`a[href="${l.hash}`)?.scrollIntoView({ behavior: 'smooth' })
		g.analysis = g.content.dataset.analysis === 'manual'

		// allow hash anchors to be unselected and remove them from browser history
		for (let anchor of qq('a[href^="#"]')) {
			anchor.addEventListener('click', ev => {
				let a = ev.target as HTMLAnchorElement
				if (a.hash === l.hash) l.replace('#')
				else l.replace(a.hash)
				ev.preventDefault()
			})
		}

		return () => {}
	}
</script>

<div class="flex h-screen flex-col" onlemma={ev => (lemma = ev.detail.lemma)}>
	<Nav />
	<div class="flex overflow-y-auto">
		{#await data.treebank}
			<p
				transition:fade|global
				class="font-sc absolute inset-x-0 top-1/3 text-center text-2xl lowercase">
				Loading ...
			</p>
		{:then treebank}
			<article
				transition:fade|global
				id="treebank"
				class="flow-root h-full grow-1 overflow-y-auto scroll-smooth pt-4 pr-4 leading-relaxed"
				{@attach onTbMount}>
				{@html treebank}
			</article>
		{:catch}
			<p transition:fade|global class="font-sc mt-32 self-center text-2xl lowercase">
				Something went wrong
			</p>
		{/await}
		<aside
			class="ml-auto flow-root h-screen min-w-40 basis-96 overflow-y-auto border-l-1 border-l-gray-300 bg-gray-50 p-4 max-lg:hidden">
			{#if lemma}
				<Definition {lemma} />
			{/if}
		</aside>
	</div>
	{#if g.selected}
		<div
			transition:slide
			class="z-20 flex items-baseline gap-x-2 border-t-1 border-gray-300 bg-gray-100 py-1 pr-2 pl-[var(--padded-margin-w)] text-xs">
			<Morphology word={g.selected} />
		</div>
	{/if}
</div>
