<script lang="ts">
	import './styles.css';
	import type { PageProps } from './$types';
	import '$lib/components/word.svelte';
	import type { Word } from '$lib/components/word.svelte';
	import FlashcardsButton from '$lib/components/flashcards-button.svelte';
	import Morphology from '$lib/components/morphology.svelte';
	import Definition from '$lib/components/definition.svelte';
	import makeApi from '$lib/api';
	import { onMount } from 'svelte';
	import { page } from '$app/state';

	let urn = page.params.urn.split('/');
	let sp = page.url.searchParams;
	let api = makeApi(fetch);
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
		clearDependants?.();
		if (selection === null && defined) {
			highlightDependants(defined).then((clear) => (clearDependants = clear));
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

	type Complement = { type: string; head: number; descendants: number[] };
	async function highlightDependants(w: Word) {
		let complements: Complement[] = await api
			.get(`hl/${urn[0]}/${urn[1]}/${w.sentence}/${w.id}`)
			.json();
		let nodes: { el: Word; class: string | string[] }[] = [];
		for (let c of complements) {
			let el = tb!.querySelector(`[sentence="${w.sentence}"][id="${c.head}"]`) as Word;
			if (el) nodes.push({ el, class: ['head', c.type] });
			for (let d of c.descendants) {
				let el = tb!.querySelector(`[sentence="${w.sentence}"][id="${d}"]`) as Word;
				if (el) nodes.push({ el, class: ['dep', c.type] });
			}
		}
		for (let n of nodes) {
			n.el.classList.add(...n.class);
		}
		return () => {
			for (let n of nodes) {
				n.el.classList.remove(...n.class);
			}
		};
	}
</script>

<div class="relative flex h-screen flex-col">
	<nav
		class="font-sans-sc sticky top-0 z-50 flex items-baseline gap-x-4 border-b border-gray-300 px-12 py-1 text-sm"
	>
		<a href="/" class="text-gray-800">oxytone</a>
		<FlashcardsButton bind:selection />
	</nav>
	<article class="overflow-y-scroll scroll-smooth pt-4 pb-32 leading-relaxed has-[.sentence]:px-12">
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
