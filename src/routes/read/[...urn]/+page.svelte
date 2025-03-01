<script lang="ts">
	import './styles.css';
	import type { PageProps } from './$types';
	import '$lib/components/word.svelte';
	import type { Word } from '$lib/components/word.svelte';
	import makeApi from '$lib/api';
	import { onMount } from 'svelte';
	import { page } from '$app/state';
	import Morphology from '$lib/components/morphology.svelte';
	import Definition from '$lib/components/definition.svelte';

	let urn = page.params.urn.split('/');
	let api = makeApi(fetch);
	let { data }: PageProps = $props();
	let tb: HTMLElement;
	let sel: Word[] | undefined = $state();
	let defined: Word | undefined = $state();
	let lemma: string | null | undefined = $state();
	let definition: string | undefined = $state();

	$effect(() => {
		if (lemma && defined?.pos !== 'punct.') {
			(async () => {
				definition = await api.get(`define/lsj/${lemma}`).text();
			})();
		}
	});

	$effect(() => {
		if (definition)
			document.querySelectorAll('#definition button.lemma-ref').forEach((el) => {
				let btn = el as HTMLButtonElement;
				btn.onclick = () => {
					lemma = btn.textContent;
				};
			});
	});

	function select(w: Word) {
		w.classList.toggle('selected');
		if (w.classList.contains('selected')) {
			defined = w;
			lemma = defined.lemma;
		} else {
			defined = undefined;
			lemma = undefined;
			definition = undefined;
		}
		if (sel) {
			if (defined) sel.push(defined);
			else sel.splice(sel.indexOf(w));
		} else {
			tb.querySelectorAll(`ox-w.selected:not([id="${w?.id}"])`).forEach((el) => {
				let e = el as Word;
				e.classList.remove('selected');
			});
		}
	}

	onMount(() => {
		let clearDependants: () => void;
		tb!.addEventListener('w-click', async (ev) => {
			let w = ev.target as Word;
			select(w);
			if (clearDependants) clearDependants();
			if (!sel && defined) {
				clearDependants = await highlightDependants(w);
			}
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

	function stripBreathings(s: string): string {
		return s;
		// .normalize('NFD')
		// .replaceAll(/>([αεηιυοωΑΕΗΙΥΟΩ]{1,2})\u{0313}/gu, '>$1')
		// .normalize('NFC');
	}

	function exportWordList() {
		const wordlist = sel!.map((e) => e.lemma).join('\n');
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
	<article class="mt-4 overflow-y-scroll scroll-smooth pb-32 leading-relaxed has-[.sentence]:px-12">
		<div bind:this={tb} class="max-w-md font-serif">
			{@html stripBreathings(data.treebank)}
		</div>
	</article>
	{#if defined}
		<Morphology word={defined} />
	{/if}
</div>

{#if lemma && definition}
	<Definition {lemma} {definition} />
{/if}
