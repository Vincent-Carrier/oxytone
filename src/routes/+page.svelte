<script lang="ts">
	import './styles.css';
	import type { PageProps } from './$types';
	import '$lib/components/word.svelte';

	let { data }: PageProps = $props();
</script>

<hgroup>
	<h1 class="font-sc mt-16 text-center text-6xl text-gray-900">oxytone</h1>
	<p class="font-sc text-center text-xl text-gray-800">the bleeding edge of ancient language</p>
</hgroup>
<div class="mx-auto max-w-4xl py-12 text-gray-800">
	{@html data.body}
</div>
