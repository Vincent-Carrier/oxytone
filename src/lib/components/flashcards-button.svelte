<script lang="ts">
	import type { Word } from './word.svelte';

	interface Props {
		selection: Word[] | null;
	}

	let { selection = $bindable() }: Props = $props();
	let count = $derived(selection?.length);

	function exportWordList() {
		const wordlist = selection!.map((e) => e.lemma).join('\n');
		navigator.clipboard.writeText(wordlist);
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
					>
				</p>
			</div>
		{/if}
	</button>
{:else}
	<button onclick={() => (selection = [])} class="btn ghost">flashcards</button>
{/if}
