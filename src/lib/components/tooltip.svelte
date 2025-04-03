<script lang="ts">
	import { fly } from 'svelte/transition';

	type Props = {
		children: any;
		class?: string;
	};

	let { children, class: klass }: Props = $props();
</script>

<div
	class={[
		'card absolute top-7 right-0 border-r-4 border-b-3 px-2 py-1 font-sans text-xs text-gray-800 normal-case',
		klass
	]}
	transition:fly|global={{ x: 300 }}
>
	{@render children()}
</div>
