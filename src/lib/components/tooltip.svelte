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
		'absolute top-7 right-0 rounded-sm border-1 border-r-4 border-b-3 border-blue-900 bg-blue-50 px-2 py-1 font-sans text-xs text-blue-900 normal-case italic',
		klass
	]}
	transition:fly|global={{ x: 300 }}
>
	{@render children()}
</div>
