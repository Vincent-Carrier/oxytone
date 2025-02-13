<script lang="ts">
	import type { PageProps } from './$types';
	import '$lib/components/word.svelte';

	let { data }: PageProps = $props();
</script>

<article class="mx-auto my-12 max-w-xl text-xl leading-relaxed">
	{@html data.treebank}
</article>
