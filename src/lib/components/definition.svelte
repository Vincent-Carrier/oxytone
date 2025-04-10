<script lang="ts">
	import './definition.css'
	import { basex } from '$lib/api'
	import { fade } from 'svelte/transition'
	import ky from 'ky'
	import ExternalIcon from '~icons/solar/square-arrow-right-up-outline'

	type Props = { lemma: string }
	let { lemma }: Props = $props()
</script>

{#if lemma && /\p{L}+/u.test(lemma)}
	<div
		in:fade|global
		class="absolute right-2 bottom-8 z-30 max-h-40 min-h-40 w-72 overflow-y-scroll rounded border-1 border-r-4 border-b-3 border-gray-400 bg-white px-2 md:bottom-2 lg:max-h-[80%]">
		{#await basex.get(`define/lsj/${lemma}`, { fetch }).text()}
			<div class=" absolute inset-0 animate-pulse bg-gray-200 pt-12 text-center"></div>
		{:then definition}
			<div transition:fade|global>
				{@html definition}
				<div class="mt-4 mb-2">
					{@render validatedLink('lsj.gr', 'https://lsj.gr/wiki/')}
					{@render validatedLink('wiktionary.org', 'https://en.wiktionary.org/wiki/')}
				</div>
			</div>
		{/await}
	</div>
{/if}

{#snippet externalLink(text: string, baseUrl: string, disabled = false)}
	<a
		target="_blank"
		href={disabled ? undefined : `${baseUrl}${lemma}`}
		class={[
			'ml-auto flex w-fit items-center gap-x-1',
			disabled ? 'text-gray-600' : 'text-blue-600'
		]}>
		<span class="underline">{text}</span>
		<ExternalIcon class="mt-px" />
	</a>
{/snippet}

{#snippet validatedLink(text: string, baseUrl: string)}
	{@const searchParams = new URLSearchParams({ url: `${baseUrl}${lemma}` })}
	{#await ky.head(`/validate?${searchParams}`, { fetch, retry: 0 })}
		{@render externalLink(text, baseUrl)}
	{:then _}
		{@render externalLink(text, baseUrl)}
	{:catch _}
		{@render externalLink(text, baseUrl, true)}
	{/await}
{/snippet}
