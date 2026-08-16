<script lang="ts">
	import '$/app.css'
	import '@fontsource-variable/alegreya'
	// Cardo supplies the archaic letters no Alegreya family has a glyph for — see
	// the font stacks in app.css. Declared by hand rather than imported: Fontsource's
	// per-subset stylesheets carry no unicode-range, so importing them downloads
	// 25 KB on every page for glyphs almost none of them contain. Narrowing it to
	// the Greek block means the browser fetches Cardo only for a page that actually
	// shows one, which in practice is a handful of LSJ entries.
	import '@fontsource/alegreya-sans'
	import '@fontsource/alegreya-sc'
	import '@fontsource/alegreya-sans-sc'
	import { Tooltip } from 'bits-ui'
	let { children } = $props()
</script>

<Tooltip.Provider>
	{@render children()}
</Tooltip.Provider>
