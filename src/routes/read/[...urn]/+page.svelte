<script lang="ts">
	import './treebank.css'
	import type { PageProps } from './$types'
	import '$lib/components/word.svelte'
	import Morphology from '$lib/components/morphology.svelte'
	import Definition from '$lib/components/definition.svelte'
	import Nav from '$lib/components/nav.svelte'
	import AskPopover from '$lib/components/ask-popover.svelte'
	import Button from '$lib/components/button.svelte'
	import CloseIcon from '~icons/heroicons/x-mark-16-solid'
	import g from '$lib/global-state.svelte'
	import type { Attachment } from 'svelte/attachments'
	import { fly } from 'svelte/transition'
	import { MediaQuery } from 'svelte/reactivity'

	let { data }: PageProps = $props()
	let lemma = $derived(g.selected?.lemma)
	let popover = $state<AskPopover>()

	// Below lg the aside is a bottom sheet that flies up and back down; at lg it
	// is the static sidebar and must not move. `transition:` can't be applied
	// conditionally, so the distance is zeroed out on desktop instead — a fly of
	// 0 over 0ms is a no-op.
	let mobile = new MediaQuery('width < 64rem')
	let sheet = $derived(
		mobile.current
			? { y: '100%', duration: 250, opacity: 1 }
			: { y: 0, duration: 0, opacity: 1 }
	)

	// Tapping the selected word again clears it, so the sheet has a natural close.
	// The button gives it an explicit affordance, and a reachable one: on a phone
	// the word that opened the sheet may well be underneath it.
	function closeSheet() {
		for (let clear of g.selected?.clear ?? []) clear()
		g.selected?.removeAttribute('defined')
		g.selected = null
	}

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
		<!-- The morphology bar sits at the top of this column rather than in a
		full-width strip below: it describes the selected word, as does the
		definition beneath it, so the two read as one panel. It is pinned while the
		definition scrolls, since the lemma and parse are the fixed reference you
		read the entry against.

		Below lg this is a bottom sheet: near-full-width, anchored to the bottom
		edge, sliding up on selection and down on dismissal. It is fixed rather
		than absolute so it stays put while the text scrolls behind it, and takes
		half the viewport so there is always readable context above.

		That height is fixed rather than capped: a content-sized sheet resizes
		every time you select a different word, which reads as a flicker under the
		slide. Holding it constant means switching lemmas only swaps the contents.
		The definition area scrolls, so long entries still fit; short ones simply
		leave space. The sheet hangs below the viewport by its own bottom padding so
		its bottom border and rounded corners fall out of sight — it reads as
		attached to the bottom edge rather than as a card floating near it — while
		that padding still keeps the last line clear of the edge and of the iOS home
		indicator. At lg and up the same element is the static right-hand
		sidebar. -->
		<!-- Keyed on the selection alone, not on `lemma`. `lemma` is a $derived that
		the onlemma handler overwrites for cross-reference clicks, and an overwritten
		$derived keeps its value instead of following g.selected back to undefined —
		so including it here would hold the sheet open after a deselect and leave the
		exit transition never running. -->
		{#if g.selected}
			<aside
				transition:fly={sheet}
				class={[
					'sheet z-30 ml-auto flex flex-col overflow-hidden bg-gray-50',
					// --sheet-pad is both the interior bottom padding and the distance the
					// sheet hangs below the viewport, so the two can't drift apart. Sinking
					// it by exactly its own padding tucks the bottom border and its rounded
					// corners out of sight, leaving the sheet reading as attached to the
					// bottom edge while the padding still keeps the last line clear of it.
					'max-lg:[--sheet-pad:max(0.5rem,env(safe-area-inset-bottom))]',
					// Height grows by the same amount it sinks, so the part still on screen
					// stays a clean 50vh.
					'max-lg:elevated max-lg:fixed max-lg:inset-x-2 max-lg:h-[calc(50vh+var(--sheet-pad))]',
					'max-lg:bottom-[calc(var(--sheet-pad)*-1)] max-lg:pb-[var(--sheet-pad)]',
					'max-lg:rounded-t-lg',
					'lg:max-w-96 lg:min-w-40 lg:grow lg:basis-60 lg:border-l-1 lg:border-l-gray-300'
				]}>
				<div
					class="flex shrink-0 items-baseline gap-x-2 border-b-1 border-gray-300 bg-gray-100 px-2 py-1 text-xs lg:px-4">
					<Morphology word={g.selected} />
					<!-- Dismissal on mobile: the sheet may well be covering the word
					that opened it, so tapping that word again isn't reachable. -->
					<div class="grow"></div>
					<!-- Neutral rather than the Button default blue: this dismisses the
					sheet, it isn't one of the actions in it. Matches the popover's close. -->
					<Button
						onclick={closeSheet}
						class="shrink-0 text-gray-600 hover:bg-gray-100 active:bg-gray-200 lg:hidden"
						aria-label="close">
						<CloseIcon />
					</Button>
				</div>
				{#if lemma}
					<!-- min-h-0 lets this shrink below its content inside the flex column,
					so a long entry scrolls here instead of pushing the sheet taller. -->
					<div class="min-h-0 grow overflow-y-auto p-2 lg:p-4">
						<Definition {lemma} />
					</div>
				{/if}
			</aside>
		{/if}
	</div>
</div>
