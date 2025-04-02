<script lang="ts">
	import Tooltip from './tooltip.svelte';

	let help = $state(false);
	let verbs = $state(true);

	function onclick() {
		verbs = !verbs;
		document.getElementById('treebank')?.classList.toggle('verbs');
	}
</script>

<button
	{onclick}
	onmouseenter={() => (help = true)}
	onmouseleave={() => (help = false)}
	class="btn ghost relative flex items-center gap-x-1"
	>verbs
	<span
		class={[
			'mb-px',
			verbs ? 'i-[solar--check-square-bold-duotone]' : 'i-[solar--minus-square-line-duotone]'
		]}
	></span>
	{#if help}
		<Tooltip class="w-max">
			<p>Each verb is shown in bold</p>
		</Tooltip>
	{/if}
</button>
