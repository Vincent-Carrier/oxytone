<script lang="ts">
	import './styles.css';
	import type { PageProps } from './$types';
	import '$lib/components/word.svelte';
	import type { Word } from '$lib/components/word.svelte';
	import makeApi from '$lib/api';
	import { onMount } from 'svelte';

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

	type Dep = { type: string; head: number; descendants: number[] };
	async function highlightDependants(w: Word) {
		let id = w.id;
		let sentence = w.sentence;
		let complements: Dep[] = await api.get(`hl/tlg0012/tlg001/${sentence}/${id}`).json();
		let nodes: { el: Word; class: string | string[] }[] = [];
		for (let c of complements) {
			let el = tb!.querySelector(`[sentence="${sentence}"][id="${c.head}"]`) as Word;
			if (el) nodes.push({ el, class: ['head', c.type] });
			for (let d of c.descendants) {
				let el = tb!.querySelector(`[sentence="${sentence}"][id="${d}"]`) as Word;
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
		return s
			.normalize('NFD')
			.replaceAll(/>([αεηιυοωΑΕΗΙΥΟΩ]{1,2})\u{0313}/gu, '>$1')
			.normalize('NFC');
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
		<div class="min-h-16 border-t-1 border-gray-300 bg-gray-100 px-12 py-1">
			<div class="text-lg font-bold">
				{defined?.lemma}
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
		id="definition"
		class="absolute right-2 bottom-8 max-h-32 w-72 overflow-y-scroll border-1 border-gray-300 bg-gray-50 px-2 text-sm md:max-h-[80%]"
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
