<script lang="ts">
	import './definition.css';
	import { basex } from '$lib/api';
	import { fade, slide } from 'svelte/transition';

	interface Props {
		lemma: string;
	}

	let { lemma }: Props = $props();
	let definition: string | null = $state(null);

	$effect(() => {
		if (/\p{L}+/u.test(lemma)) {
			(async () => {
				definition = await basex.get(`define/lsj/${lemma}`).text();
			})();
		}
	});
</script>

{#if definition}
	<div
		transition:slide|global
		class="-sm absolute right-2 bottom-8 z-30 max-h-32 w-72 overflow-y-scroll rounded border-1 border-r-4 border-b-3 border-gray-400 bg-white px-2 text-sm md:bottom-2 lg:max-h-[80%]"
	>
		{@html definition}
		<a
			target="_blank"
			href={`https://lsj.gr/wiki/${lemma}`}
			class="mt-4 mb-2 block text-right text-blue-600"
		>
			<span class="underline">lsj.gr/</span> 🡽
		</a>
	</div>
{/if}
