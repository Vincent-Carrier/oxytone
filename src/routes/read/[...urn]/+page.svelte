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

	let sp = page.url.searchParams;
	let { data }: PageProps = $props();
	let tb: HTMLElement;
	let selection: Word[] | null = $state(null);
	let defined: Word | null = $state(null);
	let lemma: string | null = $state(null);
	let clearDependants: null | (() => void) = $state(null);

	$effect(() => {
		if (selection === null) {
			defined = null;
			lemma = null;
		}
	});

	function select(w: Word) {
		defined?.clearComplements();
		w.toggleSelected();
		if (w.selected) {
			defined = w;
			lemma = defined.lemma ?? null;
		} else {
			defined = null;
			lemma = null;
		}
		if (selection) {
			if (defined) selection.push(defined);
			else selection.splice(selection.indexOf(w));
		} else {
			let selection = tb.querySelectorAll(`ox-w.selected:not([id="${w?.id}"])`);
			for (let el of selection) {
				(el as Word).toggleSelected();
			}
		}
		if (selection === null && defined) {
			defined.highlightComplements();
		}
	}

	onMount(() => {
		document.title = document.querySelector('h1')?.textContent ?? 'Oxytone';

		if (sp.has('word')) {
			defined = tb.querySelector(
				`[sentence="${sp.get('sentence')}"][id="${sp.get('word')}"]`
			) as Word;
			lemma = defined.lemma ?? null;
			defined?.scrollIntoView({ behavior: 'smooth', block: 'center' });
		}
		tb!.addEventListener('w-click', async (ev) => {
			let w = ev.target as Word;
			select(w);
		});
	});
</script>

<div class="relative flex h-screen flex-col">
	<nav
		class="font-sans-sc sticky top-0 z-50 flex items-baseline gap-x-2 border-b border-gray-300 px-12 py-1 text-sm"
	>
		<a href="/" class="text-gray-800">oxytone</a>
		<div class="grow"></div>
		<FlashcardsButton bind:selection />
		<VerbsButton />
		<ColorsButton />
	</nav>
	<article
		id="treebank"
		class="verbs syntax scroll-pt-8 overflow-y-scroll scroll-smooth pt-4 pb-32 leading-relaxed has-[.sentence]:px-12"
	>
		<div bind:this={tb} class="max-w-md font-serif">
			{@html data.treebank}
		</div>
	</article>
	{#if defined}
		<Morphology word={defined} />
	{/if}
</div>

{#if lemma}
	<Definition {lemma} />
{/if}
