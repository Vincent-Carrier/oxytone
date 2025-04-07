<svelte:options
	customElement={{
		tag: 'ox-w',
		shadow: 'none',
		props: {
			id: { type: 'Number' },
			head: { type: 'Number' },
			sentence: { type: 'Number' },
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
	import type { WordElement } from '../word'

	const tb = document.getElementById('treebank')!
	const analysis = document.getElementById('body')!.getAttribute('analysis') as 'auto' | 'manual'
	const qq = <T extends HTMLElement = WordElement>(sel: string) => tb!.querySelectorAll<T>(sel)
	const self = $host<WordElement>()
	const { children } = $props()

	self.onclick = () => {
		let old = g.selected
		old?.clearBounds?.()
		old?.clearComplements?.()
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
			if (analysis === 'manual') {
				highlightComplements()
				highlightBounds()
			}
			if (g.selecting) {
				self.setAttribute('selected', '')
				g.selection.add(self)
			}
		}
	}

	function* sentenceWords() {
		yield* qq(`[sentence="${self.sentence}"]`)
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
		return {
			start: minBy(deps, w => w.id)!,
			end: maxBy(deps, w => w.id)!
		}
	}

	function highlightBounds() {
		let bounds = getBounds()
		let cmap = new ClassMap([bounds.start, 'left-bound'], [bounds.end, 'right-bound'])
		cmap.addClasses()
		self.clearBounds = () => {
			cmap.removeClasses()
		}
	}

	function* complement(rel: string): Iterable<WordElement> {
		yield* directDependencies({ rel })
		for (let coord of directDependencies({ rel: 'COORD' })) {
			yield* directDependencies({ rel, root: coord })
		}
	}

	function highlightComplements() {
		let cmap = new ClassMap()
		for (let w of complement('OBJ')) {
			cmap.set(
				w,
				// @ts-ignore
				{ 'acc.': 'acc-obj', 'dat.': 'dat-obj', 'gen.': 'gen-obj' }[w.case ?? 'acc.']
			)
		}
		for (let w of complement('SBJ')) cmap.set(w, 'sbj')
		cmap.addClasses()
		self.clearComplements = () => {
			cmap.removeClasses()
		}
	}

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
