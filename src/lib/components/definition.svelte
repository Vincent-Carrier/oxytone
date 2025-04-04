<script lang="ts">
	import './definition.css'
	import { basex } from '$lib/api'
	import { fade, fly, slide } from 'svelte/transition'

	type Props = { lemma: string }
	let { lemma }: Props = $props()
</script>

{#if lemma && /\p{L}+/u.test(lemma)}
	{@const klass =
		'px-2 absolute right-2 bottom-8 z-30 w-72 rounded border-1 border-r-4 border-b-3 border-gray-400 bg-white md:bottom-2'}
	{#await basex.get(`define/lsj/${lemma}`).text()}
		<div in:fade|global class={[klass, 'h-40 animate-pulse bg-gray-200']}>
			<div class="font-sans-sc mt-12 text-center text-gray-600 lowercase">Loading ...</div>
		</div>
	{:then definition}
		<div
			transition:fly|global={{ y: 600 }}
			class={[klass, 'max-h-40 overflow-y-scroll lg:max-h-[80%]']}>
			{@html definition}
			<a
				target="_blank"
				href={`https://lsj.gr/wiki/${lemma}`}
				class="mt-4 mb-2 ml-auto flex w-fit items-center gap-x-1 text-blue-600">
				<span class="underline">lsj.gr/</span>
				<span class="i-[solar--square-arrow-right-up-outline] mt-px inline-block"></span>
			</a>
		</div>
	{/await}
{/if}
