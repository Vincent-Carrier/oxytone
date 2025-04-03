<script lang="ts">
	import Tooltip from './tooltip.svelte';

	let help = $state(false);
	let toggle = $state(true);

	let { tooltip, children } = $props();

	function onclick() {
		toggle = !toggle;
		document.getElementById('treebank')?.classList.toggle('syntax');
	}
</script>

<button
	{onclick}
	onmouseenter={() => (help = true)}
	onmouseleave={() => (help = false)}
	class="btn ghost relative flex items-center gap-x-1"
>
	{@render children()}
	<span
		class={[
			'mb-px',
			toggle ? 'i-[solar--check-square-bold-duotone]' : 'i-[solar--minus-square-line-duotone]'
		]}
	></span>
	{#if help}
		{@render tooltip()}
	{/if}
</button>
