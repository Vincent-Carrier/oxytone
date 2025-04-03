<script lang="ts">
	import './definition.css'
	import { basex } from '$lib/api'
	import { fade, slide } from 'svelte/transition'

	type Props = { lemma: string }
	let { lemma }: Props = $props()
</script>

{#if lemma && /\p{L}+/u.test(lemma)}
	{@const klass =
		'px-2 absolute right-2 bottom-8 z-30 w-72 rounded border-1 border-r-4 border-b-3 border-gray-400 bg-white md:bottom-2'}
	{#await basex.get(`define/lsj/${lemma}`).text()}
		<div transition:fade|global class={[klass, 'h-32 animate-pulse bg-gray-200']}>
			<div class="font-sans-sc mt-12 text-center text-gray-600 lowercase">Loading ...</div>
		</div>
	{:then definition}
		<div transition:slide|global class={[klass, 'max-h-32 overflow-y-scroll lg:max-h-[80%]']}>
			{@html definition}
			<a
				target="_blank"
				href={`https://lsj.gr/wiki/${lemma}`}
				class="mt-4 mb-2 block text-right text-blue-600">
				<span class="underline">lsj.gr/</span> 🡽
			</a>
		</div>
	{/await}
{/if}
