import { maxBy, minBy } from 'lodash-es'
import ClassMap from '$lib/class-map'
import g from '$lib/global-state.svelte'
import { dependencies, directDependencies, treebankFor, type Treebank } from '$lib/treebank'
import { pos, relation, wordCase, wordId } from '$lib/word'

// Selecting a word: the definition panel, the flashcard deck, and the analysis
// markings painted onto the words around it.
//
// A module rather than the per-word component this used to live in. The markings
// were always applied to *other* elements, so nothing here needed a component
// per word — and paying for 33,000 of them cost half a second of upgrade on a
// long page before a word could be clicked at all.

// Undo callbacks for the markings the selected word painted onto others. They
// live on sibling elements, so nothing else knows what to take back off.
let clear: (() => void)[] = []

export function clearMarkings() {
	for (const undo of clear) undo()
	clear = []
}

// Selects a word, or deselects it if it was already selected. Selection both
// opens the definition panel and, in flashcard mode, adds the word to the deck.
export function selectWord(w: WordElement) {
	const old = g.selected
	clearMarkings()

	if (old === w) {
		g.selected = null
		old.removeAttribute('defined')
		if (g.selecting) {
			w.removeAttribute('selected')
			g.selection.delete(w)
		}
		return
	}

	old?.removeAttribute('defined')
	g.selected = w
	w.setAttribute('defined', '')

	if (g.analysis && g.body) {
		const tb = treebankFor(g.body)
		highlightComplements(tb, w)
		highlightBounds(tb, w)
		highlightHead(tb, w)
	}
	if (g.selecting) {
		w.setAttribute('selected', '')
		g.selection.add(w)
	}
}

// The first and last word of a subtree in reading order, which is the span the
// bracket markers get drawn around. A leading punctuation mark belongs to the
// previous clause, so the bracket starts after it.
function subtreeBounds(tb: Treebank, w: WordElement) {
	const deps = [...dependencies(tb, w), w]
	let start = minBy(deps, wordId)
	if (start && pos(start) === 'punct.') {
		start = deps.find(d => wordId(d) === wordId(start!) + 1)
	}
	return { start, end: maxBy(deps, wordId)! }
}

function highlightBounds(tb: Treebank, w: WordElement) {
	const bounds = subtreeBounds(tb, w)
	const cmap = new ClassMap([bounds.start, 'left-bound'], [bounds.end, 'right-bound'])
	cmap.addClasses()
	clear.push(() => cmap.removeClasses())
}

// A word's complements bearing `rel`, reaching through coordination so that both
// halves of "he saw X and Y" count as objects.
function complements(tb: Treebank, w: WordElement, rel: string): WordElement[] {
	const direct = directDependencies(tb, w, rel)
	const coordinated = directDependencies(tb, w, 'COORD').flatMap(c =>
		directDependencies(tb, c, rel)
	)
	return [...direct, ...coordinated]
}

// Underlines a word's syntactic head. Coordinators and auxiliaries are skipped:
// they are structural nodes, not the word this one really depends on.
function highlightHead(tb: Treebank, w: WordElement) {
	const h = tb.byId.get(Number(w.getAttribute('head')))
	if (!h) return
	const rel = relation(h)
	if (rel?.startsWith('COORD') || rel?.startsWith('Aux')) return
	h.classList.add('head')
	clear.push(() => h.classList.remove('head'))
}

// Tints a verb's objects, object complements and subject, each subtree in the
// colour of its own case.
function highlightComplements(tb: Treebank, w: WordElement) {
	// Indexed by the word's case, which is a free-form string from the treebank,
	// so the map is typed to accept any key rather than just the three listed.
	const cases: Record<string, string> = {
		'acc.': 'acc-obj',
		'dat.': 'dat-obj',
		'gen.': 'gen-obj'
	}
	for (const c of complements(tb, w, 'OBJ')) {
		highlightComplement(tb, c, cases[wordCase(c) ?? 'acc.'])
	}
	for (const c of complements(tb, w, 'OCOMP')) highlightComplement(tb, c, 'comp-obj')
	for (const c of complements(tb, w, 'SBJ')) highlightComplement(tb, c, 'sbj')
}

function highlightComplement(tb: Treebank, w: WordElement, klass: string) {
	const cmap = new ClassMap([w, klass, 'head'])
	for (const d of dependencies(tb, w)) cmap.set(d, klass)
	cmap.addClasses()
	clear.push(() => cmap.removeClasses())
}
