<script lang="ts">
	import type { PageProps } from './$types';
	import '$lib/components/word.svelte';
	import api from '$lib/api';
	import { onMount } from 'svelte';

	let { data }: PageProps = $props();
	let tb: HTMLElement;
	let selected: HTMLElement[] | undefined = $state([]);
	let defined: HTMLElement | undefined = $state();
	let lemma: string | null | undefined = $derived(defined?.getAttribute('lemma'));
	let definition: string | undefined = $state();

	$effect(() => {
		if (lemma) {
			api.get(`define/lsj/${lemma}`).then((res) => res.text().then((body) => (definition = body)));
		}
	});

	onMount(() => {
		tb.addEventListener('w-click', (ev) => {
			let w = ev.target as HTMLElement;
			w.toggleAttribute('selected');
			defined = w.hasAttribute('selected') ? w : undefined;
			definition = undefined;
			if (!selected) {
				tb.querySelectorAll('ox-w[selected]').forEach((e) => {
					if (!defined?.isSameNode(e)) e.removeAttribute('selected');
				});
			}
		});
	});
</script>

<div class="flex h-screen flex-col">
	<article class="overflow-y-scroll pt-4 pb-32 text-xl leading-relaxed">
		<div bind:this={tb}>
			{@html data.treebank
				.normalize('NFD')
				.replaceAll(/>([αεηιυοω]{1,2})\u{0313}/gu, '>$1') // strip smooth breathings
				.normalize('NFC')}
		</div>
	</article>
	{#if defined}
		<div class="min-h-16 border-t-1 border-gray-300 bg-gray-100 px-16 py-1">
			<div class="mx-auto max-w-xl">
				<div class="text-lg font-bold">
					{defined?.getAttribute('lemma')}
				</div>
				<div class="text-sm text-gray-700 italic">
					{#each ['pos', 'person', 'number', 'tense', 'mood', 'voice', 'gender', 'case', 'degree'] as morpho}
						{@const m = defined?.getAttribute(morpho)}
						{m}{#if morpho === 'case' && m}.{/if}{' '}
					{/each}
				</div>
			</div>
		</div>
	{/if}
</div>

{#if lemma && definition}
	<div
		class="absolute right-8 bottom-8 h-32 w-80 overflow-y-scroll border-1 border-gray-300 bg-gray-50 px-2 text-sm"
	>
		{@html definition}

		<a
			target="_blank"
			href={`https://lsj.gr/wiki/${lemma}`}
			class="mt-4 block text-right text-blue-600"
		>
			<span class="underline">lsj.gr/</span> 🡽
		</a>
	</div>
{/if}
