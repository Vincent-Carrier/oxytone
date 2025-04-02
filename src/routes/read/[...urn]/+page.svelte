<script lang="ts">
	import './treebank.css';
	import type { PageProps } from './$types';
	import '$lib/components/word.svelte';
	import type { Word } from '$lib/components/word.svelte';
	import FlashcardsButton from '$lib/components/flashcards-button.svelte';
	import ColorsButton from '$lib/components/colors-button.svelte';
	import Morphology from '$lib/components/morphology.svelte';
	import Definition from '$lib/components/definition.svelte';
	import { onMount } from 'svelte';
	import { page } from '$app/state';
	import VerbsButton from '$/lib/components/verbs-button.svelte';

	let { data }: PageProps = $props();
	let tb: HTMLElement;
	let selection: Word[] | null = $state(null);
	let defined: Word | null = $state(null);

	function clearSelection() {
		for (let w of selection ?? []) {
			w.selected = false;
		}
		selection = null;
	}

	onMount(() => {
		document.title = document.querySelector('h1')?.textContent ?? 'Oxytone';

		let hash = page.url.hash;
		if (hash) document.querySelector(`a[href="${hash}`)?.scrollIntoView({ behavior: 'smooth' });

		// Don't add line / chapter anchors to history stack
		tb.querySelectorAll<HTMLAnchorElement>('a[href^="#"]').forEach((anchor) => {
			anchor.addEventListener('click', (ev) => {
				let a = ev.target as HTMLAnchorElement;
				if (a.hash === hash) location.replace('#');
				else location.replace(a.hash);
				ev.preventDefault();
			});
		});

		tb!.addEventListener('w-click', async (ev) => {
			let w = ev.target as Word;
			if (selection === null) {
				w.defined = !w.defined;
				if (defined && defined !== w) defined.defined = false;
				defined = w === defined ? null : w;
				defined?.highlightComplements();
			} else {
				defined = null;
				w.selected = !w.selected;
				if (w.selected) selection.push(w);
				else selection.splice(selection.indexOf(w));
			}
		});
	});
</script>

<div class="flex h-screen flex-col">
	<nav
		class="font-sans-sc sticky top-0 z-50 flex items-baseline gap-x-2 border-b border-gray-300 bg-gray-50 px-14 py-1 text-sm"
	>
		<a href="/" class="text-gray-800">oxytone</a>
		<div class="grow"></div>
		<FlashcardsButton bind:selection bind:defined />
		<VerbsButton />
		<ColorsButton />
	</nav>
	<div
		class="absolute top-0 bottom-0 left-0 -z-10 w-10 border-r-1 border-gray-200 bg-gray-50"
	></div>
	<article
		id="treebank"
		class="verbs syntax h-full scroll-pt-8 overflow-y-scroll scroll-smooth pt-4 pr-4 pb-12 leading-relaxed"
	>
		<div bind:this={tb} class="max-w-[60ch] font-serif">
			{@html data.treebank}
		</div>
	</article>
	{#if defined}
		<Morphology word={defined} />
	{/if}
</div>

{#if defined?.lemma}
	<Definition lemma={defined.lemma} />
{/if}
