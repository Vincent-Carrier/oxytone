<script lang="ts">
	import { basex } from '$lib/api'
	import '$lib/components/ref.svelte'
	import ky from 'ky'
	import ExternalIcon from '~icons/heroicons/arrow-top-right-on-square-16-solid'
	import './definition.css'

	type Props = { lemma: string }
	let { lemma }: Props = $props()
</script>

{#if lemma && /\p{L}+/u.test(lemma)}
	{#await basex.get(`define/lsj/${lemma}`, { fetch }).text() then definition}
		<div class="">
			{@html definition}
			<div class="mt-4 mb-2">
				{@render validatedLink('lsj.gr', 'https://lsj.gr/wiki/')}
				{@render validatedLink('wiktionary.org', 'https://en.wiktionary.org/wiki/')}
			</div>
		</div>
	{/await}
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
