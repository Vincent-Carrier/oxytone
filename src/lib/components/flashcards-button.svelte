<script lang="ts">
	import { SvelteURLSearchParams } from 'svelte/reactivity';
	import type { Word } from './word.svelte';
	import { page } from '$app/state';
	import Tooltip from './tooltip.svelte';

	interface Props {
		selection: Word[] | null;
	}

	let segments = page.url.pathname.split('/');
	let { selection = $bindable() }: Props = $props();
	let count = $derived(selection?.length);
	let searchParams = $derived(
		new SvelteURLSearchParams([
			['author', segments[2]],
			['work', segments[3]],
			...(selection || [])
				.map((w) => w.lemma!)
				.filter(Boolean)
				.map((w) => ['w', w])
		])
	);
</script>

<div class="relative">
	{#if selection}
		<button onclick={() => (selection = null)} class="btn ghost danger mr-2"> cancel </button>
		<button class="btn" inert={count == 0} popovertarget="flashcards-help">
			<a href={`http://localhost:8000/flashcards?${searchParams}`} download="greek-flashcards.apkg">
				{`export ${count} word${count === 1 ? '' : 's'}`}</a
			>
		</button>
	{:else}
		<button onclick={() => (selection = [])} class="btn ghost">flashcards</button>
	{/if}
	{#if selection?.length == 0}
		<Tooltip>
			<p>
				Select words to create a deck of <a
					href="https://apps.ankiweb.net/"
					class="text-blue-700 underline">Anki</a
				> flashcards. Each card will have the lemma on the front side and a full LSJ definition on its
				back side.
			</p>
		</Tooltip>
	{/if}
</div>
