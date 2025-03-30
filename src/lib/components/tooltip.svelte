<script lang="ts">
	import { fade } from 'svelte/transition';

	let { children } = $props();
</script>

<div
	class="absolute top-7 right-0 w-56 rounded-sm border-1 border-r-4 border-b-3 border-blue-900 bg-blue-50 px-2 py-1 font-sans text-xs text-blue-900 italic"
	transition:fade|global
>
	{@render children()}
</div>
