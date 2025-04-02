<script lang="ts">
	import Tooltip from './tooltip.svelte';

	let help = $state(false);
	let colors = $state(true);

	function onclick() {
		colors = !colors;
		document.getElementById('treebank-container')?.classList.toggle('syntax');
	}
</script>

<button
	{onclick}
	onmouseenter={() => (help = true)}
	onmouseleave={() => (help = false)}
	class="btn ghost relative flex items-center gap-x-1"
>
	colors
	<span
		class={[
			'mb-px',
			colors ? 'i-[solar--check-square-bold-duotone]' : 'i-[solar--minus-square-line-duotone]'
		]}
	></span>
	{#if help}
		<Tooltip class="w-56">
			<p>Each word is colored according to its case:</p>
			<div class="syntax font-sans-sc flex flex-wrap justify-center gap-x-4 font-bold lowercase">
				<div class="text-emerald-700">Nominative</div>
				<div class="text-sky-700">Accusative</div>
				<div class="text-yellow-700">Dative</div>
				<div class="text-purple-700">Genitive</div>
				<div class="text-pink-700">Vocative</div>
			</div>
		</Tooltip>
	{/if}
</button>
