<script lang="ts">
	import { onMount } from 'svelte';

	interface Props {}

	let {}: Props = $props();

	let help = $state(false);
	let colors = $state(true);
	let tb: HTMLElement | null;

	function onclick() {
		colors = !colors;
		tb?.classList.toggle('syntax');
	}

	function onmouseenter() {
		help = true;
	}
	function onmouseleave() {
		help = false;
	}

	onMount(() => {
		tb = document?.getElementById('treebank');
	});
</script>

<button {onclick} {onmouseenter} {onmouseleave} class="btn relative flex items-baseline gap-x-1"
	>colors
	<div
		class={[
			'h-2 w-2 rounded-full border-1 border-blue-700 bg-blue-600',
			colors || 'bg-transparent'
		]}
	></div>
	{#if help}
		<div class="tooltip info">
			<p class="">Each word is colored according to its case:</p>
			<div class="syntax flex flex-wrap justify-center gap-x-4 font-bold">
				<div class="text-emerald-700">Nominative</div>
				<div class="text-sky-700">Accusative</div>
				<div class="text-yellow-700">Dative</div>
				<div class="text-purple-700">Genitive</div>
				<div class="text-pink-700">Vocative</div>
			</div>
		</div>
	{/if}
</button>
