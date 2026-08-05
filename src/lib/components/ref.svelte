<svelte:options
	customElement={{
		tag: 'ox-ref',
		shadow: 'none'
	}} />

<script lang="ts">
	let { children } = $props()
	let self = $host()

	// LSJ bakes sentence punctuation into the cross-reference text (ἄβαξι.,
	// ἀβροτάξομεν;), which would be looked up verbatim and miss. Strip it from
	// the query only — the displayed text stays as the dictionary wrote it.
	// Trailing hyphens are left alone: they mark a truncated stem (ἀβέρ-), which
	// is not a lemma either way.
	function lemmaOf(text: string | null) {
		return text?.replace(/[.,;:·?!’']+$/gu, '').trim() || undefined
	}

	function follow() {
		self.dispatchEvent(
			// textContent is nullable; normalize to undefined so consumers get one
			// "absent" value rather than two.
			new CustomEvent('lemma', {
				detail: { lemma: lemmaOf(self.textContent) },
				bubbles: true
			})
		)
	}

	// It looks and behaves like a link, so it has to be reachable and operable
	// without a mouse.
	self.setAttribute('role', 'link')
	self.setAttribute('tabindex', '0')
	self.onclick = follow
	self.onkeydown = (ev: KeyboardEvent) => {
		if (ev.key !== 'Enter' && ev.key !== ' ') return
		ev.preventDefault()
		follow()
	}
</script>

{@render children()}
