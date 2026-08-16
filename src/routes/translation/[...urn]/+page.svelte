<script lang="ts">
	import '../../read/[...urn]/treebank.css'
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
	<Nav />
	<div class="flex overflow-y-auto">
		<article
			id="treebank"
			class="translation flow-root h-full grow-1 overflow-y-auto scroll-smooth pt-4 pr-4 leading-relaxed">
			<div class="treebank prose">
				<p class="mb-4 ml-[var(--padded-margin-w)]">
					<a
						href={readHref}
						class="font-sans-sc inline-flex items-baseline gap-x-1 text-blue-600">
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
			</div>
		</article>
	</div>
</div>

<style>
	/* treebank.css sets `.body p { display: inline }`, which is right for running
	   Greek broken up by section numbers but runs the English together into one
	   block. Here each passage is its own paragraph. */
	.translation :global(.body p) {
		display: block;
		margin-bottom: 0.75rem;
	}

	/* Reads as English rather than as the justified Greek column. */
	.translation :global(.body) {
		text-align: left;
	}
</style>
