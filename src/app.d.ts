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

	// One `<ox-w>` in the treebank. A plain element: its analysis — lemma, part of
	// speech, case, its head and sentence in the dependency tree — lives in
	// attributes, and `$lib/word` is what reads them. It was a custom element with
	// all of that as typed properties, until a page of 33,000 of them made the
	// upgrade cost half a second before the text could be read.
	//
	// Aliased rather than declared, so that reaching for `w.lemma` is a type error
	// pointing at the accessors instead of silently reading undefined.
	type WordElement = HTMLElement
}

declare module 'svelte/elements' {
	export interface HTMLAttributes {
		// Dispatched by ref.svelte as a bubbling CustomEvent carrying the clicked
		// element's text.
		onlemma?: (event: CustomEvent<{ lemma: string | undefined }>) => void
	}
}

export {}
