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

<hgroup class="font-sc mt-16 text-center">
	<h1 class="text-6xl text-gray-900">oxytone</h1>
	<p class="text-xl text-gray-800">the bleeding edge of ancient language</p>
</hgroup>
<div class="mx-auto max-w-4xl px-4 py-12 text-gray-800">
	<button class="btn ml-auto block" onclick={expandAll}>
		{expanded ? 'Collapse all' : 'Expand all'}
	</button>
	{@html data.body}
</div>
