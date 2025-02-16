<script lang="ts">
	import type { PageProps } from './$types';
	import '$lib/components/word.svelte';
	import { onMount } from 'svelte';

	let { data }: PageProps = $props();
	let tb: HTMLElement;
	let selected: HTMLElement[] | undefined = $state();
	let defined: HTMLElement | undefined = $state();

	onMount(() => {
		const mo = new MutationObserver((mutations) => {
			for (let m of mutations) {
				let w = m.target as HTMLElement;
				if (w.hasAttribute('selected')) {
					defined = w;
					selected?.push(w);
				} else {
					defined = undefined;
					let i = selected?.findIndex((e) => Object.is(e, w));
					selected?.splice(i!);
				}
			}
		});
		mo.observe(tb, { subtree: true, attributeFilter: ['selected'] });
	});

	$inspect(selected, defined);
</script>

<div class="flex h-screen flex-col">
	<article bind:this={tb} class="overflow-y-scroll py-12 text-xl leading-relaxed">
		<div class="mx-auto max-w-xl">
			{@html data.treebank}
		</div>
	</article>
	{#if defined}
		<div class="min-h-12 border-t-1 border-gray-300 bg-gray-100">
			<div class="mx-auto max-w-xl">
				<div class="text-lg">
					{defined?.getAttribute('lemma')}
				</div>
				<div class="text-sm text-gray-700 italic">
					{defined?.getAttribute('pos')}
					{defined?.getAttribute('person')}
					{defined?.getAttribute('number')}
					{defined?.getAttribute('tense')}
					{defined?.getAttribute('mood')}
					{defined?.getAttribute('voice')}
					{defined?.getAttribute('gender')}
					{defined?.getAttribute('case')}
					{defined?.getAttribute('degree')}
				</div>
			</div>
		</div>
	{/if}
</div>
