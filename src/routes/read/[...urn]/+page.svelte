<script lang="ts">
	import './treebank.css'
	import type { PageProps } from './$types'
	import '$lib/components/word.svelte'
	import Morphology from '$lib/components/morphology.svelte'
	import Definition from '$lib/components/definition.svelte'
	import Nav from '$lib/components/nav.svelte'
	import AskPopover from '$lib/components/ask-popover.svelte'
	import g from '$lib/global-state.svelte'
	import type { Attachment } from 'svelte/attachments'

	let { data }: PageProps = $props()
	let lemma = $derived(g.selected?.lemma)
	let popover = $state<AskPopover>()

	// `selectionchange` fires continuously while dragging, so act on the gestures
	// that end a selection instead.
	function onSelectionEnd(event: Event) {
		// The listener is on the document, so it also sees clicks inside the
		// popover itself — which would re-run show(), wiping the answer on every
		// button press and reopening the popover the moment it's dismissed.
		const target = event.target as Node | null
		if (target && !g.content?.contains(target)) return

		// Both events fire before the browser finalises the selection, so read it a
		// tick later. A timeout rather than requestAnimationFrame: rAF is throttled
		// to zero in background tabs, which would silently drop the popover.
		setTimeout(() => popover?.show())
	}

	const onTbMount: Attachment = tb => {
		const q = (sel: string) => tb.querySelector<HTMLElement>(sel)
		let title = q('h1')?.textContent ?? 'Oxytone'
		document.title = title
		let content = q('#tb-content')
		g.content = content

		if (!content) return
		let l = location
		// Matched on href rather than #id: the id is a line number ("1.30"), which
		// would need escaping to be a valid CSS identifier.
		if (l.hash) q(`a[href="${l.hash}"]`)?.scrollIntoView({ behavior: 'smooth' })
		g.autoAnnotated = content.dataset.analysis !== 'manual'
		g.analysis = !g.autoAnnotated

		// Allow hash anchors to be toggled off, without pushing every line number
		// onto the history stack.
		//
		// Delegated to the container and cleaned up on teardown. This attachment
		// re-runs whenever the state in the article's class expression changes,
		// and it also writes g.analysis below, so it re-entered on its own. When
		// it bound a listener per anchor with a no-op cleanup, every re-run added
		// another: the first set the hash, the second saw `a.hash === l.hash`
		// (l is live) and immediately cleared it, so clicking a line number left
		// a bare "#".
		const onAnchorClick = (ev: MouseEvent) => {
			let a = (ev.target as Element).closest<HTMLAnchorElement>('a[href^="#"]')
			if (!a || !content.contains(a)) return
			ev.preventDefault()
			l.replace(a.hash === l.hash ? '#' : a.hash)
		}
		content.addEventListener('click', onAnchorClick)

		return () => content.removeEventListener('click', onAnchorClick)
	}
</script>

<svelte:document onpointerup={onSelectionEnd} onkeyup={onSelectionEnd} />

<AskPopover bind:this={popover} />

<div class="flex h-screen flex-col print:h-auto" onlemma={ev => (lemma = ev.detail.lemma)}>
	<Nav />
	<div class="flex overflow-y-auto">
		<article
			id="treebank"
			class={[
				'flow-root h-full grow-1 overflow-y-auto scroll-smooth pt-4 pr-4 leading-relaxed',
				{
					verbs: g.verbs,
					syntax: g.colors,
					'mem-mode': g.memMode
				}
			]}
			{@attach onTbMount}>
			{@html data.treebank}
		</article>
		<aside
			class={[
				'max-lg:elevated right-2 bottom-8 z-30 ml-auto flow-root max-w-96 min-w-40 grow basis-60 overflow-y-auto border-l-1 border-l-gray-300 bg-gray-50 p-2 max-lg:absolute max-lg:max-h-40 lg:p-4',
				{ 'bg-white max-lg:hidden': !lemma }
			]}>
			{#if lemma}
				<Definition {lemma} />
			{/if}
		</aside>
	</div>
	{#if g.selected}
		<div
			class="z-20 flex items-baseline gap-x-2 border-t-1 border-gray-300 bg-gray-100 py-1 pr-2 pl-[var(--padded-margin-w)] text-xs">
			<Morphology word={g.selected} />
		</div>
	{/if}
</div>
