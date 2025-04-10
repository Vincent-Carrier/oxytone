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
		'card break absolute top-7 right-0 border-r-4 border-b-3 px-2 py-1 text-justify font-sans text-xs hyphens-auto text-gray-800 normal-case',
		klass
	]}
	transition:fly|global={{ y: 50 }}>
	{@render children()}
</div>
