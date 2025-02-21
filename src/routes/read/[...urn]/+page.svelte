<script lang="ts">
	import './styles.css';
	import type { PageProps } from './$types';
	import '$lib/components/word.svelte';
	import api from '$lib/api';
	import { onMount } from 'svelte';

	let { data }: PageProps = $props();
	let tb: HTMLElement;
	let sel: HTMLElement[] | undefined = $state([]);
	let defined: HTMLElement | undefined = $state();
	let lemma: string | null | undefined = $derived(defined?.getAttribute('lemma'));
	let definition: string | undefined = $state();

	$effect(() => {
		if (lemma) {
			api(fetch)
				.get(`define/lsj/${lemma}`)
				.then((res) => res.text().then((body) => (definition = body)));
		}
	});

	onMount(() => {
		tb.addEventListener('w-click', (ev) => {
			let w = ev.target as HTMLElement;
			w.toggleAttribute('selected');
			defined = w.hasAttribute('selected') ? w : undefined;
			definition = undefined;
			if (sel) {
				if (defined) sel.push(defined);
				else sel.splice(sel.indexOf(w));
			} else {
				tb.querySelectorAll('ox-w[selected]').forEach((e) => {
					if (!defined?.isSameNode(e)) e.removeAttribute('selected');
				});
			}
		});
	});

	function exportWordList() {
		const wordlist = sel!.map((e) => e.getAttribute('lemma')).join('\n');
		navigator.clipboard.writeText(wordlist);
	}
</script>

<div class="relative flex h-screen flex-col">
	<nav
		class="font-sans-sc sticky top-0 flex items-baseline gap-x-4 border-b border-gray-300 px-12 py-2"
	>
		<a href="/" class="text-gray-800">oxytone</a>
		<button
			onclick={exportWordList}
			class="ml-auto cursor-pointer border-1 border-blue-700 px-2 text-sm text-blue-700"
			>.apkg</button
		>
	</nav>
	<article
		class="overflow-y-scroll scroll-smooth pt-4 pb-32 text-xl leading-relaxed has-[.sentence]:px-12"
	>
		<div bind:this={tb} class="max-w-prose">
			{@html data.treebank
				.normalize('NFD')
				.replaceAll(/>([αεηιυοω]{1,2})\u{0313}/gu, '>$1') // strip smooth breathings
				.normalize('NFC')}
		</div>
	</article>
	{#if defined}
		<div class="min-h-16 border-t-1 border-gray-300 bg-gray-100 px-12 py-1">
			<div class="text-lg font-bold">
				{defined?.getAttribute('lemma')}
			</div>
			<div class="text-sm text-gray-700 italic">
				{#each ['pos', 'person', 'tense', 'mood', 'voice', 'number', 'gender', 'case', 'degree'] as morpho}
					{defined?.getAttribute(morpho)}{' '}
				{/each}
			</div>
		</div>
	{/if}
</div>

{#if lemma && definition}
	<div
		class="absolute right-8 bottom-8 max-h-32 w-80 overflow-y-scroll border-1 border-gray-300 bg-gray-50 px-2 text-sm"
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
