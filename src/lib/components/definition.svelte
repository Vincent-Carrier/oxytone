<script lang="ts">
	import './definition.css'
	import { basex } from '$lib/api'
	import { fade } from 'svelte/transition'

	type Props = { lemma: string }
	let { lemma }: Props = $props()
</script>

{#if lemma && /\p{L}+/u.test(lemma)}
	<div
		in:fade|global
		class="absolute right-2 bottom-8 z-30 max-h-40 min-h-40 w-72 overflow-y-scroll rounded border-1 border-r-4 border-b-3 border-gray-400 bg-white px-2 md:bottom-2 lg:max-h-[80%]">
		{#await basex.get(`define/lsj/${lemma}`).text()}
			<div class=" absolute inset-0 animate-pulse bg-gray-200 pt-12 text-center"></div>
		{:then definition}
			<div transition:fade|global>
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
	</div>
{/if}
