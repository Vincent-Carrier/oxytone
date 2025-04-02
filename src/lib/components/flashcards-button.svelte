<script lang="ts">
	import { SvelteURLSearchParams } from 'svelte/reactivity';
	import type { Word } from './word.svelte';
	import { page } from '$app/state';
	import Tooltip from './tooltip.svelte';
	import { PUBLIC_FASTAPI_URL } from '$env/static/public';

	interface Props {
		selection: Word[] | null;
		defined: Word | null;
	}

	let segments = page.url.pathname.split('/');
	let { selection = $bindable(), defined = $bindable() }: Props = $props();
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

	function select() {
		defined = null;
		selection = [];
	}

	function cancel() {
		for (let w of selection!) {
			w.classList.remove('selected');
		}
		selection = null;
	}
</script>

{#if selection?.length}
	<div
		class="fixed top-10 right-2 max-h-96 w-32 overflow-y-scroll rounded-md border-1 border-r-3 border-b-3 border-gray-300 max-sm:hidden"
	>
		<div class="sticky top-0 border-b-1 border-gray-300 bg-gray-50 px-4 lowercase">Selection</div>
		<ul style="list-style: '– ' inside;" class="px-4 py-2 font-serif text-gray-800">
			{#each selection as w}
				<li>{w.lemma}</li>
			{/each}
		</ul>
	</div>
{/if}
<div class="relative max-sm:hidden">
	{#if selection}
		<button onclick={cancel} class="btn ghost danger mr-2">cancel</button>
		<button class="btn" inert={count == 0} popovertarget="flashcards-help">
			<a href={`${PUBLIC_FASTAPI_URL}/flashcards?${searchParams}`} download="greek-flashcards.apkg">
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
