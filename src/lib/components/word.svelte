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
		$host().classList.toggle('selected');
	};
</script>

{children}
