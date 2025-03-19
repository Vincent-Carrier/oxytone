<script lang="ts">
	import { getContext } from 'svelte';
	import './definition.css';
	import type { KyInstance } from 'ky';

	let basex = getContext<KyInstance>('basex');
	console.log(basex);
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
		class="-sm absolute right-2 bottom-8 max-h-32 w-72 overflow-y-scroll rounded border-1 border-r-4 border-b-3 border-gray-500 bg-gray-50 px-2 text-sm lg:bottom-2 lg:max-h-[80%]"
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
