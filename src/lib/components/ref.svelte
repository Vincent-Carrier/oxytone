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
			// textContent is nullable; normalize to undefined so consumers get one
			// "absent" value rather than two.
			new CustomEvent('lemma', {
				detail: { lemma: self.textContent ?? undefined },
				bubbles: true
			})
		)
	}
</script>

{@render children()}
