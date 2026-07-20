import tailwindcss from '@tailwindcss/vite'
import { sveltekit } from '@sveltejs/kit/vite'
import { defineConfig } from 'vite'
import Icons from 'unplugin-icons/vite'

export default defineConfig({
	plugins: [sveltekit(), Icons({ compiler: 'svelte', scale: 1 }), tailwindcss()],
	// Bundle ky into the adapter-node server output so `build/` is fully
	// self-contained and can run with `node build` without node_modules present
	// (see deploy/oxytone.yml — the droplet gets no node_modules).
	ssr: {
		noExternal: ['ky']
	}
})
