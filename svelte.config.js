import adapter from '@sveltejs/adapter-node'
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte'

/** @type {import('@sveltejs/kit').Config} */
const config = {
	// Consult https://svelte.dev/docs/kit/integrations
	// for more information about preprocessors
	preprocess: vitePreprocess(),

	// Required for the <svelte:options customElement> declarations in word.svelte
	// (ox-w) and ref.svelte (ox-ref) to take effect; without it the compiler warns
	// options_missing_custom_element and the elements are never registered.
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
