<script lang="ts">
	// import { getContext } from 'svelte';
	import type { Word } from './word.svelte';
	import type { KyInstance } from 'ky';

	interface Props {
		selection: Word[] | null;
	}

	let { selection = $bindable() }: Props = $props();
	let count = $derived(selection?.length);
	// let python = getContext<KyInstance>('python');
	function exportWordList() {
		let lemmas = selection?.map((w) => w.lemma).filter(Boolean);
		console.log(lemmas);
		// python.post('/flashcards', { json: lemmas });
	}
</script>

{#if selection}
	<button onclick={() => (selection = null)} class="btn ghost danger"> cancel </button>
	<button onclick={exportWordList} class="btn relative" popovertarget="flashcards-help">
		<span> {`export ${count} word${count === 1 ? '' : 's'}`}</span>
		{#if selection?.length < 1}
			<div class="tooltip info w-40">
				<p>
					Select words to create a deck of <a
						href="https://apps.ankiweb.net/"
						class="text-blue-700 underline">Anki flashcards</a
					>. Each card will contain the lemma and its full LSJ definition.
				</p>
			</div>
		{/if}
	</button>
{:else}
	<button onclick={() => (selection = [])} class="btn ghost">flashcards</button>
{/if}
