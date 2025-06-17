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
	self.clear = []

	self.onclick = () => {
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

	function* dependencies(root: WordElement = self): Iterable<WordElement> {
		for (let d of directDependencies({ root })) {
			yield d
			yield* dependencies(d)
		}
	}

	function getBounds() {
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
		let bounds = getBounds()
		let cmap = new ClassMap([bounds.start, 'left-bound'], [bounds.end, 'right-bound'])
		cmap.addClasses()
		self.clear.push(() => cmap.removeClasses())
	}

	function* complement(rel: string): Iterable<WordElement> {
		yield* directDependencies({ rel })
		for (let coord of directDependencies({ rel: 'COORD' })) {
			yield* directDependencies({ rel, root: coord })
		}
	}

	function head(): WordElement | null {
		return q(`ox-w[id="${self.head}"]`)
	}

	function highlightHead() {
		let h = head()
		if (h && !(h.relation?.startsWith('COORD') || h.relation?.startsWith('Aux'))) {
			h.classList.add('head')
			self.clear.push(() => h.classList.remove('head'))
		}
	}

	function highlightComplements() {
		let cases = { 'acc.': 'acc-obj', 'dat.': 'dat-obj', 'gen.': 'gen-obj' } as any
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

	// function* sentenceWords() {
	// 	yield* qq(`[sentence="${self.sentence}"]`)
	// }

	// function highlightHyperbatons() {
	// 	if (
	// 		!['verb', 'punct.'].includes(w.pos!) &&
	// 		!w.relation?.startsWith('COORD') &&
	// 		!w.relation?.startsWith('Aux')
	// 	) {
	// 		let dist = Math.abs(w.head - w.id)
	// 		if (dist > 2) {
	// 			if (dist < 5) w.classList.add('bg-gray-100')
	// 			else if (dist < 9) w.classList.add('bg-gray-200')
	// 		}
	// 	}
	// }
</script>

{children}
