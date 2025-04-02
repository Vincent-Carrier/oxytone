<script lang="ts">
	import './styles.css';
	import type { PageProps } from './$types';
	import '$lib/components/word.svelte';

	let { data }: PageProps = $props();

	let expanded = $state(false);

	function expandAll() {
		for (let details of document.querySelectorAll<HTMLDetailsElement>('details')) {
			details.open = !expanded;
		}
		expanded = !expanded;
	}
</script>

<svelte:head>
	<title>Oxytone</title>
</svelte:head>

<img
	class="mx-auto w-full max-w-4xl px-4 grayscale"
	srcset="/greek_heroes@0.5x.webp 1x, /greek_heroes.webp 2x"
	src="/greek_heroes.webp"
	alt=""
/>
<hgroup class="font-sc -mt-8 text-center">
	<h1 class="relative text-6xl text-gray-900">oxytone</h1>
	<p class="text-xl text-gray-800">the bleeding edge of ancient language</p>
</hgroup>
<div class="mx-auto mt-4 mb-12 max-w-4xl px-8 text-gray-800">
	<div class="card mb-12 p-4 pt-2 text-gray-800 sm:ml-24">
		<h2 class="font-sans-sc font-bold lowercase">About</h2>
		<p class="">
			Oxytone is a web application that aims to provide a comprehensive reading environment for the
			reading of Ancient Greek literature. It offers a wide range of features and tools to help
			users improve their language skills and gain a deeper understanding of the language.
		</p>
	</div>
	<button class="btn ghost pointer-events-auto mb-2 ml-auto block" onclick={expandAll}>
		{expanded ? 'Collapse all' : 'Expand all'}
	</button>
	{@html data.body}
</div>
