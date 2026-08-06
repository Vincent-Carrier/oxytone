<svelte:options
	customElement={{
		tag: 'ox-w',
		shadow: 'none',
		props: {
			id: { type: 'Number' },
			head: { type: 'Number' },
			sentence: { type: 'Number' },
			form: { reflect: false },
			lemma: {},
			relation: {},
			pos: {},
			person: {},
			tense: {},
			mood: {},
			voice: {},
			number: {},
			gender: {},
			case: {},
			degree: {}
		}
	}} />

<script lang="ts">
	import { maxBy, minBy } from 'lodash-es'
	import './word.css'
	import g from '$lib/global-state.svelte'
	import ClassMap from '$lib/class-map'

	const tb = document.getElementById('tb-content')!
	const q = <T extends HTMLElement = WordElement>(sel: string) => tb!.querySelector<T>(sel)
	const qq = <T extends HTMLElement = WordElement>(sel: string) => tb!.querySelectorAll<T>(sel)
	const { children } = $props()
	const self = $host<WordElement>()
	// Undo callbacks for the analysis markings this word painted onto others, run
	// when it stops being the selected word. The markings live on sibling elements,
	// so nothing else knows what to take back off.
	self.clear = []

	// Selects this word, or deselects it if it was already selected. Selection both
	// opens the definition panel and, in flashcard mode, adds the word to the deck.
	self.onclick = () => {
		// A drag across words ends with a click on whichever word the pointer was
		// released over. Without this guard every text selection would also select
		// that word, opening the definition aside and repainting the tree.
		let sel = getSelection()
		if (sel && !sel.isCollapsed) return

		let old = g.selected
		for (let clear of old?.clear ?? []) clear()
		if (old === self) {
			g.selected = null
			old.removeAttribute('defined')
			if (g.selecting) {
				self.removeAttribute('selected')
				g.selection.delete(self)
			}
		} else {
			old?.removeAttribute('defined')
			g.selected = self
			self.setAttribute('defined', '')
			if (g.analysis) {
				highlightComplements()
				highlightBounds()
				highlightHead()
			}
			if (g.selecting) {
				self.setAttribute('selected', '')
				g.selection.add(self)
			}
		}
	}

	// The words immediately depending on `root` in the treebank, optionally only
	// those whose relation starts with `rel` (relations carry suffixes, so
	// "OBJ" also matches "OBJ_CO").
	function* directDependencies({
		root = self,
		rel = undefined
	}: {
		root?: WordElement
		rel?: string
	}): Iterable<WordElement> {
		let words = qq(`[sentence="${root.sentence}"][head="${root.id}"]`)
		for (let w of words) {
			if (rel && w.relation?.startsWith(rel)) yield w
			else if (!rel) yield w
		}
	}

	// The whole dependency subtree under `root`, depth-first.
	function* dependencies(root: WordElement = self): Iterable<WordElement> {
		for (let d of directDependencies({ root })) {
			yield d
			yield* dependencies(d)
		}
	}

	// The first and last word of this word's subtree in reading order, which is
	// the span the bracket markers get drawn around. A leading punctuation mark
	// belongs to the previous clause, so the bracket starts after it.
	function subtreeBounds() {
		let deps = [...dependencies(), self]
		let start = minBy(deps, w => w.id)
		if (start?.pos === 'punct.') {
			start = deps.find(w => w.id === start!.id + 1)
		}
		return {
			start,
			end: maxBy(deps, w => w.id)!
		}
	}

	function highlightBounds() {
		let bounds = subtreeBounds()
		let cmap = new ClassMap([bounds.start, 'left-bound'], [bounds.end, 'right-bound'])
		cmap.addClasses()
		self.clear.push(() => cmap.removeClasses())
	}

	// This word's complements bearing `rel`, reaching through coordination so that
	// both halves of "he saw X and Y" count as objects.
	function* complement(rel: string): Iterable<WordElement> {
		yield* directDependencies({ rel })
		for (let coord of directDependencies({ rel: 'COORD' })) {
			yield* directDependencies({ rel, root: coord })
		}
	}

	function head(): WordElement | null {
		return q(`ox-w[id="${self.head}"]`)
	}

	// Underlines this word's syntactic head. Coordinators and auxiliaries are
	// skipped: they are structural nodes, not the word this one really depends on.
	function highlightHead() {
		let h = head()
		if (h && !(h.relation?.startsWith('COORD') || h.relation?.startsWith('Aux'))) {
			h.classList.add('head')
			self.clear.push(() => h.classList.remove('head'))
		}
	}

	// Tints a verb's objects, object complements and subject, each subtree in the
	// colour of its own case.
	function highlightComplements() {
		// Indexed by w.case, which is a free-form string from the treebank, so the
		// map is typed to accept any key rather than just the three listed.
		let cases: Record<string, string> = {
			'acc.': 'acc-obj',
			'dat.': 'dat-obj',
			'gen.': 'gen-obj'
		}
		for (let w of complement('OBJ')) highlightComplement(w, cases[w.case ?? 'acc.'])
		for (let w of complement('OCOMP')) highlightComplement(w, 'comp-obj')
		for (let w of complement('SBJ')) highlightComplement(w, 'sbj')
	}

	function highlightComplement(w: WordElement, klass: string) {
		let cmap = new ClassMap([w, klass, 'head'])
		for (let d of dependencies(w)) cmap.set(d, klass)
		cmap.addClasses()
		self.clear.push(() => cmap.removeClasses())
	}

	// Shows or hides this word's smooth breathing mark. The original spelling is
	// kept in `form` on the way out, since the mark cannot be recovered from the
	// stripped text — and `form` is what gets sent to the LLM either way.
	self.toggleSmoothBreathing = function (this: WordElement, val: boolean) {
		if (!val) {
			let stripped = this.textContent!.normalize('NFD')
				.replace(/^([αεηιυοω]{1,2})\u0313/u, '$1')
				.normalize('NFC')
			if (!this.form) this.form = this.textContent!
			this.textContent = stripped
		} else if (this.form) {
			this.textContent = this.form!
		}
	}
</script>

{children}
