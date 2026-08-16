<script lang="ts">
	import './translation.css'
	import type { PageProps } from './$types'
	import Nav from '$lib/components/nav.svelte'
	import BackIcon from '~icons/heroicons/arrow-left-16-solid'

	let { data }: PageProps = $props()

	// The same passage in Greek. The two routes take the same {author}/{work}/{page}
	// tail, so the link is the prefix swap and nothing else.
	let readHref = $derived(`/read/${data.urn}`)

	// The endpoint marks a work with no translation rather than 404ing, since that
	// is the ordinary case for 128 of the 180 works that paginate. Reachable by URL
	// even though the nav hides the link, so it needs saying rather than a blank page.
	let empty = $derived(data.translation.includes('data-empty'))
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
			class="translation flow-root h-full grow-1 overflow-y-auto scroll-smooth pt-4 pr-4">
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
