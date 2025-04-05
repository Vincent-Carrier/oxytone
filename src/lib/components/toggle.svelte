<script lang="ts">
	import { type Snippet } from 'svelte'
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
	onpointerover={ev => ev.pointerType === 'mouse' && (help = true)}
	onpointerleave={() => (help = false)}
	class={[
		'btn ghost relative flex items-center gap-x-1',
		!toggle.value && 'text-gray-600 hover:bg-gray-100'
	]}>
	{@render children()}
	<span
		class={[
			'mt-px',
			toggle.value ? 'i-[solar--check-square-outline]' : 'i-[solar--minus-square-line-duotone]'
		]}></span>
	{#if help}
		{@render tooltip()}
	{/if}
</button>
