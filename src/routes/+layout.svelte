<script lang="ts">
	import '$/app.css'
	import '@fontsource-variable/alegreya'
	// Only the upright weight axis, and only ever the Greek subset in practice:
	// each @font-face carries a unicode-range, so the browser fetches a file solely
	// when a glyph on the page falls in its range. Noto is the fallback for the
	// archaic letters Alegreya lacks (see --font-serif in app.css), which live in
	// the Greek block, so the Latin and Cyrillic subsets are never requested.
	import '@fontsource-variable/noto-serif/wght.css'
	import '@fontsource/alegreya-sans'
	import '@fontsource/alegreya-sc'
	import '@fontsource/alegreya-sans-sc'
	import { Tooltip } from 'bits-ui'
	let { children } = $props()
</script>

<Tooltip.Provider>
	{@render children()}
</Tooltip.Provider>
