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
	<button onclick={() => (selection = null)} class="btn ghost danger ml-auto"> cancel </button>
	<button onclick={exportWordList} class="btn relative" popovertarget="flashcards-help">
		<span> {`${count} word${count === 1 ? '' : 's'} selected`}</span>
		{#if selection?.length < 1}
			<div
				class={[
					'absolute top-10 right-0 left-auto w-36 border-r-2 border-blue-700 bg-gray-100 px-2 py-1',
					'font-sans text-xs text-gray-600 italic'
				]}
			>
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
	<button onclick={() => (selection = [])} class="btn ml-auto"> flashcards </button>
{/if}
