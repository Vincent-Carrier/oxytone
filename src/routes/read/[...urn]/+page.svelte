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
	import g, { analysisChosen } from '$lib/global-state.svelte'
	import type { Attachment } from 'svelte/attachments'
	import { fade, fly } from 'svelte/transition'

	let { data }: PageProps = $props()
	let lemma = $derived(g.selected?.lemma)
	let popover = $state<AskPopover>()

	// `fly` parameters for the aside: below lg it is a bottom sheet that slides in
	// and out, at lg the static sidebar, which must not animate. `transition:`
	// can't be applied conditionally, so desktop gets `duration: 0` instead.
	//
	// `opacity: 1` matters on that branch. fly's opacity is where the fade
	// *starts*, and `fill: forwards` holds the element there for the whole
	// zero-length animation — `opacity: 0` would pin the sidebar invisible.
	//
	// A function, and plain matchMedia rather than Svelte's MediaQuery: transition
	// params are evaluated once per transition, and a lazily-subscribed
	// ReactiveValue returns its fallback on that first read.
	function sheetParams() {
		return matchMedia('(width < 64rem)').matches
			? { y: '100%', duration: 250, opacity: 0 }
			: { y: 0, duration: 0, opacity: 1 }
	}

	// Keeps the tapped word visible on mobile. The sheet is fixed, so it covers the
	// lower half of the text rather than displacing it, and a word down there is
	// hidden by the very panel describing it. Scrolling the article by the overlap
	// brings it back above the sheet's top edge.
	//
	// Measures the sheet instead of assuming 50vh, and waits a tick so the sheet is
	// in the DOM on the selection that opens it.
	$effect(() => {
		let word = g.selected
		if (!word || !matchMedia('(width < 64rem)').matches) return

		setTimeout(() => {
			let article = document.getElementById('treebank')
			let aside = document.querySelector('aside')
			if (!article || !aside) return

			// The sheet slides up, so its rect is mid-animation here. `bottom` minus
			// the height is where it comes to rest, which is what to clear.
			let sheetTop = innerHeight - aside.getBoundingClientRect().height
			let overlap = word.getBoundingClientRect().bottom - sheetTop
			// A little past the edge, so the word doesn't sit flush against it. The
			// article carries `scroll-smooth`, so this animates without asking.
			if (overlap > 0) article.scrollTop += overlap + 16
		})
	})

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

	// Wires up the server-rendered treebank once it is in the DOM: publishes its
	// content element to the global state, takes the document title from its
	// heading, honours an incoming hash, and picks the default analysis setting.
	//
	// Re-runs whenever the state in the article's class expression changes, and it
	// writes `g.analysis` itself, so it must stay idempotent and clean up after
	// itself — hence the single delegated listener below rather than one per anchor.
	const setUpTreebank: Attachment = tb => {
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
		// Machine-annotated texts default to analysis off, since the markings are
		// less trustworthy there — but only until the user states a preference.
		// After that their choice holds across texts, rather than being reset by
		// whichever one they happen to open next.
		if (!analysisChosen.current) g.analysis = !g.autoAnnotated

		// Lets a hash anchor be toggled back off, without pushing every line number
		// onto the history stack.
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
			{@attach setUpTreebank}>
			{@html data.treebank}
		</article>
		<!-- The word's morphology and its definition describe the same thing, so they
		read as one panel: the morphology bar sits at the top of this column rather
		than in a strip of its own, and stays pinned while the definition scrolls —
		the lemma and parse are the fixed reference you read the entry against.

		At lg and up this element is the static right-hand sidebar. Below lg it is a
		bottom sheet, fixed rather than absolute so the text scrolls behind it, and
		half the viewport tall so there is always readable context above.

		Its height is fixed rather than capped, so that switching lemmas only swaps
		the contents; a content-sized sheet would resize on every selection, which
		reads as a flicker under the slide. Long entries scroll in the definition
		area, short ones leave space. It hangs below the viewport by its own bottom
		padding, tucking the bottom border and rounded corners out of sight so it
		reads as attached to the edge rather than floating near it, while that
		padding keeps the last line clear of the iOS home indicator. -->
		<!-- Keyed on the selection alone, not on `lemma`. The onlemma handler
		overwrites `lemma` for cross-reference clicks, and an overwritten $derived
		keeps its value rather than following g.selected back to undefined — so
		including it here would hold the sheet open after a deselect. -->
		{#if g.selected}
			<!-- The slide belongs to this {#if}: the panel appearing and disappearing
			is what it animates. The lemma-change fade lives on the {#key} inside, so
			the two never compete for one element's transition. -->
			<aside
				transition:fly={sheetParams()}
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
				<!-- Keyed so picking another word while the panel is already open fades
				the entry in rather than swapping it instantly.

				The {#key} must stay outside the {#if}, with the transitioning element as
				its direct child: nested the other way round the fade silently never
				fires (sveltejs/svelte#11935 — a transition inside a {#key} wrapping
				another block is skipped). |global because the enclosing {#if g.selected}
				owns the mount, so a local intro would not run here either.

				min-h-0 lets this shrink below its content inside the flex column, so a
				long entry scrolls here instead of pushing the sheet taller. -->
				{#key lemma}
					<div
						in:fade|global={{ duration: 200 }}
						class="min-h-0 grow overflow-y-auto p-2 lg:p-4">
						{#if lemma}
							<Definition {lemma} />
						{/if}
					</div>
				{/key}
			</aside>
		{/if}
	</div>
</div>
