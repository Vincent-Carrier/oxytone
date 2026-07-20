import prettier from 'eslint-config-prettier'
import js from '@eslint/js'
import { includeIgnoreFile } from '@eslint/compat'
import svelte from 'eslint-plugin-svelte'
import globals from 'globals'
import { fileURLToPath } from 'node:url'
import ts from 'typescript-eslint'
const gitignorePath = fileURLToPath(new URL('./.gitignore', import.meta.url))

export default ts.config(
	includeIgnoreFile(gitignorePath),
	js.configs.recommended,
	...ts.configs.recommended,
	...svelte.configs['flat/recommended'],
	prettier,
	...svelte.configs['flat/prettier'],
	{
		languageOptions: {
			globals: {
				...globals.browser,
				...globals.node
			}
		}
	},
	{
		// Rune files (*.svelte.ts/js) are matched by the plugin too, and they hold
		// plain TypeScript — they need the TS parser just as .svelte scripts do.
		files: ['**/*.svelte', '**/*.svelte.ts', '**/*.svelte.js'],

		languageOptions: {
			parserOptions: {
				parser: ts.parser
			}
		}
	},
	{
		rules: {
			// Treebank and definition HTML come from our own BaseX/XSLT pipeline,
			// not from user input.
			'svelte/no-at-html-tags': 'off',
			// The app is served from the domain root with no configured `base`, so
			// plain internal hrefs resolve correctly; the other flagged links are
			// external (LSJ, Logeion), which this rule does not apply to.
			'svelte/no-navigation-without-resolve': 'off'
		}
	},
	{
		// TypeScript resolves globals (e.g. the WordElement type in app.d.ts) via
		// the type checker, which no-undef cannot see — it only knows runtime
		// globals and reports every type as undefined. Disabling it here is the
		// approach typescript-eslint recommends for typed files.
		files: ['**/*.ts', '**/*.svelte', '**/*.svelte.ts'],
		rules: {
			'no-undef': 'off'
		}
	}
)
