<script lang="ts">
	import { onMount } from 'svelte';

	interface Props {}

	let {}: Props = $props();

	let help = $state(false);
	let verbs = $state(true);
	let tb: HTMLElement | null;

	function onclick() {
		verbs = !verbs;
		tb?.classList.toggle('verbs');
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
	>verbs
	<div
		class={['h-2 w-2 rounded-full border-1 border-blue-700 bg-blue-600', verbs || 'bg-transparent']}
	></div>
	{#if help}
		<div class="tooltip info w-max">
			<p class="">Each verb is shown in bold</p>
		</div>
	{/if}
</button>
