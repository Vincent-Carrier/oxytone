<script lang="ts">
	import '$/app.css'
	import '@fontsource-variable/alegreya'
	import '@fontsource/alegreya-sans'
	import '@fontsource/alegreya-sc'
	import '@fontsource/alegreya-sans-sc'
	import { Tooltip } from 'bits-ui'
	let { children } = $props()
</script>

<Tooltip.Provider>
	{@render children()}
</Tooltip.Provider>
