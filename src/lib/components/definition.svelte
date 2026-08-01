<script lang="ts">
	import { browser } from '$app/environment'
	import { basex } from '$lib/api'
	import '$lib/components/ref.svelte'
	import ky from 'ky'
	import ExternalIcon from '~icons/heroicons/arrow-top-right-on-square-16-solid'
	import './definition.css'

	type Props = { lemma: string }
	let { lemma }: Props = $props()

	type Source = { source: string; html: string }

	// The endpoint returns one <section data-source> per dictionary; split them so
	// each can be followed by its own external link. DOMParser is browser-only, so
	// during SSR (and if the markup ever arrives without sections) fall back to
	// emitting the fragment as a single block.
	function parseSources(definition: string): Source[] {
		if (!definition.trim()) return []
		if (!browser) return [{ source: 'lsj', html: definition }]
		const doc = new DOMParser().parseFromString(definition, 'text/html')
		const sections = [...doc.querySelectorAll('section.source')]
		if (sections.length === 0) return [{ source: 'lsj', html: definition }]
		return sections.map(el => ({
			source: el.getAttribute('data-source') ?? 'lsj',
			html: el.outerHTML
		}))
	}
</script>

{#if lemma && /\p{L}+/u.test(lemma)}
	{#await basex.get(`define/lsj/${lemma}`, { fetch }).text() then definition}
		{@const sources = parseSources(definition)}
		<div>
			{#each sources as { source, html } (source)}
				<!-- Each source section renders with its own external link at the bottom,
				     rather than one shared row of links for the whole panel. -->
				{@html html}
				<div class="mb-2">
					{#if source === 'wiktionary'}
						{@render validatedLink('wiktionary.org', 'https://en.wiktionary.org/wiki/')}
					{:else}
						{@render validatedLink('lsj.gr', 'https://lsj.gr/wiki/')}
					{/if}
				</div>
			{/each}
		</div>
	{/await}
{/if}

{#snippet externalLink(text: string, baseUrl: string, disabled = false)}
	<a
		target="_blank"
		href={disabled ? undefined : `${baseUrl}${lemma}`}
		class={['source-link', disabled ? 'text-gray-600' : 'text-blue-600']}>
		<span class="underline">{text}</span>
		<ExternalIcon />
	</a>
{/snippet}

{#snippet validatedLink(text: string, baseUrl: string)}
	{@const searchParams = new URLSearchParams({ url: `${baseUrl}${lemma}` })}
	{#await ky.head(`/validate?${searchParams}`, { fetch, retry: 0 })}
		{@render externalLink(text, baseUrl)}
	{:then}
		{@render externalLink(text, baseUrl)}
	{:catch}
		{@render externalLink(text, baseUrl, true)}
	{/await}
{/snippet}
