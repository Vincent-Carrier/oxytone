import g from '$lib/global-state.svelte'

export type SelectionContext = {
	selectedText: string
	contextText: string
	wordCount: number
	rect: DOMRect
}

// Reads the current text selection and expands it to whole sentences, so a
// partial selection still gives the model a grammatically complete passage.
// Returns null whenever there is nothing usable to act on.
export function readSelection(): SelectionContext | null {
	const sel = getSelection()
	if (!sel || sel.isCollapsed || sel.rangeCount === 0) return null

	const range = sel.getRangeAt(0)

	// Ignore selections in the nav, the definition aside, or anywhere else
	// outside the text itself.
	if (!g.content?.contains(range.commonAncestorContainer)) return null

	const selectedText = normalize(sel.toString())
	if (!selectedText) return null

	const words = coveredWords(range)
	if (words.length === 0) {
		// A selection landing entirely in the whitespace between words still has
		// text worth acting on, just no sentence to expand to.
		return { selectedText, contextText: '', wordCount: 0, rect: range.getBoundingClientRect() }
	}

	return {
		selectedText: normalize(words.map(text).join(' ')) || selectedText,
		contextText: normalize(sentenceWords(words).map(text).join(' ')),
		wordCount: words.length,
		rect: range.getBoundingClientRect()
	}
}

function coveredWords(range: Range): WordElement[] {
	// Scope to the common ancestor before querying: a page holds thousands of
	// `ox-w` elements and this runs on every completed selection. The ancestor is
	// often a text node when the selection sits inside a single word.
	const node = range.commonAncestorContainer
	const scope = node.nodeType === Node.ELEMENT_NODE ? (node as Element) : node.parentElement
	if (!scope) return []

	return [...scope.querySelectorAll<WordElement>('ox-w')].filter(w => range.intersectsNode(w))
}

// Expands a set of words to every word sharing their sentence. Re-queries from
// the whole page rather than the original scope, which frequently holds only
// part of the sentence.
function sentenceWords(words: WordElement[]): WordElement[] {
	const ids = [...new Set(words.map(w => w.getAttribute('sentence')))]
		// The attribute, not the `.sentence` property, which the custom element
		// declares as a Number. Values are machine-generated, but they are being
		// interpolated into a selector, so verify their shape first.
		.filter((id): id is string => Boolean(id) && /^\d+$/.test(id!))

	if (ids.length === 0) return words

	const selector = ids.map(id => `ox-w[sentence="${id}"]`).join(',')
	const found = [...(g.content?.querySelectorAll<WordElement>(selector) ?? [])]
	return found.length > 0 ? found : words
}

// When the breathings toggle is off, `toggleSmoothBreathing` has rewritten
// textContent and kept the original in `form`. Sending stripped Greek to the
// model would quietly degrade exactly the readings this feature exists for.
function text(w: WordElement): string {
	return w.form ?? w.textContent ?? ''
}

function normalize(text: string): string {
	return text.replace(/\s+/g, ' ').trim().normalize('NFC')
}
