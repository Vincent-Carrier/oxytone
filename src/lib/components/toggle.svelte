<script lang="ts">
	import { onMount } from 'svelte';

	let help = $state(false);
	let toggle = $state(true);

	let { tooltip, children, key, onclick: onClick } = $props();

	onMount(() => {
		let val = localStorage.getItem(key);
		toggle = val !== 'false';
	});

	$effect(() => {
		localStorage.setItem(key, String(toggle));
		onClick();
	});
</script>

<button
	onclick={() => (toggle = !toggle)}
	onpointerenter={() => (help = true)}
	onpointerleave={() => (help = false)}
	class="btn ghost relative flex items-center gap-x-1"
>
	{@render children()}
	<span
		class={[
			'mb-px',
			toggle ? 'i-[solar--check-square-outline]' : 'i-[solar--minus-square-line-duotone]'
		]}
	></span>
	{#if help}
		{@render tooltip()}
	{/if}
</button>
