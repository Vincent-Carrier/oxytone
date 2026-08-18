import adapter from '@sveltejs/adapter-node'
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte'

/** @type {import('@sveltejs/kit').Config} */
const config = {
	// Consult https://svelte.dev/docs/kit/integrations
	// for more information about preprocessors
	preprocess: vitePreprocess(),

	// Required for the <svelte:options customElement> declaration in ref.svelte
	// (ox-ref) to take effect; without it the compiler warns
	// options_missing_custom_element and the element is never registered.
	//
	// Words are deliberately not custom elements: a dictionary entry holds a
	// handful of cross-references, but a page of Herodotus holds 33,000 words, and
	// upgrading that many cost half a second before the text could be read.
	compilerOptions: {
		customElement: true
	},

	kit: {
		adapter: adapter(),
		alias: {
			$: 'src'
		},
		inlineStyleThreshold: 2048
	}
}

export default config
