<svelte:options
	customElement={{
		tag: 'ox-w',
		shadow: 'none',
		props: {
			case: {}
		}
	}}
/>

<script lang="ts">
	let { children } = $props();
	$host().onclick = () => {
		$host().dispatchEvent(new CustomEvent('w-click', { bubbles: true }));
	};
</script>

{children}
