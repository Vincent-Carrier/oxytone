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

	// Below lg the aside is a bottom sheet that slides up when it appears and back
	// down when it goes; at lg it is the static sidebar and must not animate at
	// all. `transition:` can't be applied conditionally, so the desktop branch
	// passes `duration: 0`.
	//
	// It must also pass `opacity: 1` there. fly's opacity parameter is where the
	// fade *starts*, and with fill: forwards it holds the element at that value
	// for the whole (zero-length) animation — so `opacity: 0` at `duration: 0`
	// pins the desktop sidebar at invisible forever rather than being a no-op.
	//
	// matchMedia is read here, inside a function, rather than through Svelte's
	// MediaQuery: that is a lazily-subscribed ReactiveValue, so the first read
	// returns its fallback, and the first read is exactly when the transition
	// params are evaluated. It reported false on a phone-width viewport and every
	// slide was built with duration 0 — created, pinned at the start offset, and
	// never run. A function is re-evaluated per transition, so it cannot go stale.
	function sheetParams() {
		return matchMedia('(width < 64rem)').matches
			? { y: '100%', duration: 250, opacity: 0 }
			: { y: 0, duration: 0, opacity: 1 }
	}

	// The sheet is fixed, so it covers the lower half of the text rather than
	// displacing it — selecting a word down there hides the very word you tapped.
	// Scroll the article by exactly the overlap so it clears the sheet's top edge.
	//
	// Reads the sheet's own rect rather than assuming 50vh: it is the element that
	// defines the obstruction, and this stays right if its height ever changes.
	// Runs after a tick so the sheet is in the DOM on the selection that opens it.
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
		// Machine-annotated texts default to analysis off, since the markings are
		// less trustworthy there — but only until the user states a preference.
		// After that their choice holds across texts, rather than being reset by
		// whichever one they happen to open next.
		if (!analysisChosen.current) g.analysis = !g.autoAnnotated

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

				The {#key} is outside the {#if}, not inside it, and the transitioning
				element is the key block's direct child. With the nesting the other way
				round the fade silently never fires — a Svelte bug where a transition
				inside a {#key} that wraps another block is skipped
				(sveltejs/svelte#11935). |global because the enclosing {#if g.selected}
				already owns the mount, so a local intro would not run here either.

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
