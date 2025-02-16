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
		$host().toggleAttribute('selected');
	};
</script>

{children}
