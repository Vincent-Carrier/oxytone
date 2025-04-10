<script lang="ts">
	import { fly } from 'svelte/transition'

	type Props = {
		children: any
		class?: string
	}

	let { children, class: klass }: Props = $props()
</script>

<div
	class={[
		'elevated absolute top-7 right-0 px-2 py-1 text-left font-sans text-xs hyphens-auto text-gray-800 normal-case',
		klass
	]}
	transition:fly|global={{ y: 50 }}>
	{@render children()}
</div>

<style>
	div :global(a) {
		text-decoration: underline;
		text-decoration-thickness: 2px;
		color: var(--color-blue-700);
	}
	div :global(ol) {
		list-style: disc inside;
		text-indent: 0.75rem hanging;
	}
</style>
