<svelte:options
	customElement={{
		tag: 'ox-ref',
		shadow: 'none'
	}} />

<script lang="ts">
	let { children } = $props()
	let self = $host()
	self.onclick = () => {
		self.dispatchEvent(
			new CustomEvent('lemma', { detail: { lemma: self.textContent }, bubbles: true })
		)
	}
</script>

{@render children()}
