<script lang="ts">
	import { onMount, type Snippet } from 'svelte'
	import LocalStore from '$lib/local-storage.svelte'

	type Props = {
		children: Snippet
		tooltip: Snippet
		key: string
		set: (value: boolean) => any
	}
	let { tooltip, children, key, set }: Props = $props()

	let toggle = new LocalStore(key, true)
	let help = $state(false)

	$effect(() => {
		set(toggle.value)
	})
</script>

<button
	onclick={() => (toggle.value = !toggle.value)}
	onpointerenter={() => (help = true)}
	onpointerleave={() => (help = false)}
	class="btn ghost relative flex items-center gap-x-1">
	{@render children()}
	<span
		class={[
			'mb-px',
			toggle.value ? 'i-[solar--check-square-outline]' : 'i-[solar--minus-square-line-duotone]'
		]}></span>
	{#if help}
		{@render tooltip()}
	{/if}
</button>
