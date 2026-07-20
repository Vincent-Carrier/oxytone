import 'unplugin-icons/types/svelte'
// Imported for its side effect: it makes 'svelte/elements' a module so the
// `declare module` augmentation below merges instead of replacing.
import 'svelte/elements'

// See https://svelte.dev/docs/kit/types#app.d.ts
// for information about these interfaces
declare global {
	namespace App {
		// interface Error {}
		// interface Locals {}
		// interface PageData {}
		// interface PageState {}
		// interface Platform {}
	}
	type Nullish<T> = T | null | undefined

	type WordElement = HTMLElement & {
		id: number
		head: number
		sentence: number
		form?: string
		lemma?: string
		relation?: string
		pos?: string
		person?: string
		tense?: string
		mood?: string
		voice?: string
		number?: string
		gender?: string
		case?: string
		degree?: string
		children: string
		clear: (() => void)[]
		toggleSmoothBreathing: (boolean) => void
	}
}

declare module 'svelte/elements' {
	export interface HTMLAttributes {
		// Dispatched by ref.svelte as a bubbling CustomEvent carrying the clicked
		// element's text.
		onlemma?: (event: CustomEvent<{ lemma: string | undefined }>) => void
	}
}

export {}
