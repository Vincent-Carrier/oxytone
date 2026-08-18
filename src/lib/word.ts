// Reading a word out of the treebank markup.
//
// Words are plain `<ox-w>` elements carrying their analysis as attributes, not
// custom elements: a page of Herodotus holds 33,000 of them, and registering a
// component for each cost ~550ms of upgrade before the text could be read. So
// nothing turns those attributes into properties, and this is where they are
// read instead.

// The attributes that describe the word itself, as opposed to its place in the
// dependency tree. Order is the order they read in. `person` is kept out of the
// list because it is rendered differently — see Morphology.person.
const MORPH = ['gender', 'case', 'number', 'degree'] as const
const VERB_MORPH = ['mood', 'tense', 'voice'] as const

export type Morphology = {
	lemma: string
	pos: string
	// Set only on the words that inflect for it, and rendered with an ordinal
	// superscript ("1st p."), which is why it is separate from `noun`.
	person?: string
	noun: string[]
	verb: string[]
}

function attr(w: WordElement, name: string): string | undefined {
	return w.getAttribute(name) ?? undefined
}

export function lemma(w: WordElement): string {
	return attr(w, 'lemma') ?? ''
}

export function pos(w: WordElement): string | undefined {
	return attr(w, 'pos')
}

export function relation(w: WordElement): string | undefined {
	return attr(w, 'relation')
}

export function wordCase(w: WordElement): string | undefined {
	return attr(w, 'case')
}

// The treebank ids are integers and get compared as such — the bracket bounds
// take the lowest and highest id in a subtree — so they are parsed here rather
// than left as the strings getAttribute returns. Lexicographic order would put
// "100880710" after "1008807" and draw the bracket around the wrong span.
export function wordId(w: WordElement): number {
	return Number(w.getAttribute('id'))
}

export function headId(w: WordElement): number {
	return Number(w.getAttribute('head'))
}

export function sentenceId(w: WordElement): string | undefined {
	return attr(w, 'sentence')
}

// Everything the morphology panel shows, gathered in one pass so the component
// reads the DOM once per selected word rather than once per field.
export function morphology(w: WordElement): Morphology {
	return {
		lemma: lemma(w),
		pos: attr(w, 'pos') ?? '',
		person: attr(w, 'person'),
		noun: MORPH.map(k => attr(w, k)).filter((v): v is string => Boolean(v)),
		verb: VERB_MORPH.map(k => attr(w, k)).filter((v): v is string => Boolean(v))
	}
}

// The word as the corpus spells it, which is not always as the page displays it:
// with breathings off, `toggleSmoothBreathing` rewrites textContent and keeps the
// original here. `form` is what gets sent to the LLM and into a flashcard.
export function form(w: WordElement): string {
	return attr(w, 'form') ?? w.textContent ?? ''
}

// Shows or hides a word's smooth breathing. The original spelling is stashed in
// `form` on the way out, since the mark cannot be recovered from stripped text.
export function toggleSmoothBreathing(w: WordElement, show: boolean) {
	if (!show) {
		const stripped = w
			.textContent!.normalize('NFD')
			.replace(/^([αεηιυοω]{1,2})\u0313/u, '$1')
			.normalize('NFC')
		if (!w.hasAttribute('form')) w.setAttribute('form', w.textContent!)
		w.textContent = stripped
	} else {
		const original = w.getAttribute('form')
		if (original) w.textContent = original
	}
}
