<script lang="ts">
	import { page } from '$app/state'
	import { PUBLIC_FASTAPI_URL } from '$env/static/public'
	import Button from '$lib/components/button.svelte'
	import Tooltip from '$lib/components/tooltip.svelte'
	import g from '$lib/global-state.svelte'
	import { SvelteURLSearchParams } from 'svelte/reactivity'
	import { fly } from 'svelte/transition'
	import StudentIcon from '~icons/heroicons/academic-cap-16-solid'
	import DownloadIcon from '~icons/heroicons/arrow-down-16-solid'
	import CancelIcon from '~icons/heroicons/x-mark-16-solid'

	let segments = page.url.pathname.split('/')
	let count = $derived(g.selection?.size)
	let searchParams = $derived(
		new SvelteURLSearchParams([
			['author', segments[2]],
			['work', segments[3]],
			...Array.from(g.selection ?? [])
				.map(w => w.lemma!)
				.filter(Boolean)
				.map(w => ['w', w])
		])
	)

	function clearSelection() {
		g.selecting = false
		g.selection?.clear()
	}
</script>

{#if g.selection?.size}
	<div
		transition:fly={{ x: 300 }}
		class="fixed top-10 right-2 max-h-5/6 w-40 overflow-y-scroll rounded-md border-1 border-r-3 border-b-3 border-gray-300 max-lg:hidden">
		<div class="sticky top-0 border-b-1 border-gray-300 bg-gray-50 px-4 lowercase">Selection</div>
		<ul class="list-dash px-4 py-2 font-sans text-gray-800">
			{#each g.selection as w}
				<li>{w.lemma}</li>
			{/each}
		</ul>
	</div>
{/if}
<div class="contents max-md:hidden">
	{#if g.selecting}
		<Button onclick={clearSelection} danger>
			<CancelIcon />
			cancel
		</Button>
		<Button
			inert={count == 0}
			href={`${PUBLIC_FASTAPI_URL}/flashcards?${searchParams}`}
			download="greek-flashcards.apkg"
			onclick={clearSelection}>
			<DownloadIcon />
			{`export ${count} word${count === 1 ? '' : 's'}`}
		</Button>
	{:else}
		<Button onclick={() => (g.selecting = true)}>
			<StudentIcon />
			flashcards
		</Button>
	{/if}
</div>
{#if g.selecting && g.selection?.size == 0}
	<Tooltip class="fixed top-auto right-4 bottom-4 w-56">
		<p>
			Select words to create a deck of <a
				href="https://apps.ankiweb.net/"
				class="text-blue-700 underline">Anki</a> flashcards. Each card will have the lemma on the front
			side and a full LSJ definition on its back side.
		</p>
	</Tooltip>
{/if}
