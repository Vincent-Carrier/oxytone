<script lang="ts">
	import './translation.css'
	import type { PageProps } from './$types'
	import Nav from '$lib/components/nav.svelte'
	import BackIcon from '~icons/heroicons/arrow-left-16-solid'
	import type { Attachment } from 'svelte/attachments'

	let { data }: PageProps = $props()

	// The same passage in Greek. The two routes take the same {author}/{work}/{page}
	// tail, so the link is the prefix swap and nothing else.
	let readHref = $derived(`/read/${data.urn}`)

	// The endpoint marks a work with no translation rather than 404ing, since that
	// is the ordinary case for 128 of the 180 works that paginate. Reachable by URL
	// even though the nav hides the link, so it needs saying rather than a blank page.
	let empty = $derived(data.translation.includes('data-empty'))

	// Footnotes arrive as markup from the endpoint, so they get one delegated
	// listener rather than a component each — Herodotus book 1 alone carries 67.
	//
	// The note text rides on the button's data-note and is written into a single
	// shared popover on demand. The native popover API handles light dismiss and
	// top-layer stacking; anchor positioning is still not in Firefox, so the
	// position is measured from the button's rect instead.
	const setUpNotes: Attachment<HTMLElement> = article => {
		const pop = document.createElement('div')
		pop.popover = 'auto'
		pop.className = 'note-popover'
		article.append(pop)

		const onClick = (ev: MouseEvent) => {
			const btn = (ev.target as Element).closest<HTMLButtonElement>('button.note')
			if (!btn || !article.contains(btn)) return

			pop.textContent = btn.dataset.note ?? ''
			pop.showPopover()

			// Measured after showing, so the popover has its final size. Anchored on the
			// marker's own centre and clamped to the viewport, so a note near either
			// edge stays fully on screen without drifting away from what it annotates.
			const b = btn.getBoundingClientRect()
			const p = pop.getBoundingClientRect()
			const centre = b.left + b.width / 2 - p.width / 2
			const left = Math.min(Math.max(8, centre), innerWidth - p.width - 8)
			// Above by default, below when there is not room — the note should not
			// cover the line it belongs to.
			const above = b.top > p.height + 12
			pop.style.left = `${left}px`
			pop.style.top = `${above ? b.top - p.height - 8 : b.bottom + 8}px`
		}

		article.addEventListener('click', onClick)
		return () => {
			article.removeEventListener('click', onClick)
			pop.remove()
		}
	}
</script>

<svelte:head>
	<title>Translation</title>
</svelte:head>

<div class="flex h-screen flex-col print:h-auto">
	<!-- No reading tools: they all act on <ox-w> words this page does not have. -->
	<Nav tools={false} />
	<div class="flex overflow-y-auto">
		<!-- `.translation` is a direct child so its `& > hgroup` rule reaches the
		heading the endpoint emits; the endpoint returns <hgroup> and <main> as
		siblings for the same reason. -->
		<article
			class="translation flow-root h-full grow-1 overflow-y-auto scroll-smooth pt-4 pr-4"
			{@attach setUpNotes}>
			<p class="mb-4 ml-[var(--padded-margin-w)]">
				<!-- items-center, not items-baseline: an SVG icon has no text baseline of
				its own, so aligning on one leaves the arrow sitting low. -->
				<a
					href={readHref}
					class="font-sans-sc inline-flex items-center gap-x-1 text-blue-600">
					<BackIcon />
					back to the Greek
				</a>
			</p>
			{#if empty}
				<p class="ml-[var(--padded-margin-w)] text-gray-600">
					No English translation is available for this work.
				</p>
			{:else}
				{@html data.translation}
			{/if}
		</article>
	</div>
</div>
