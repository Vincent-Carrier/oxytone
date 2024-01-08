import some from 'lodash-es/some'
import './flashcards'
import { $, $$on } from './utils'

const $treebank = $('article.treebank')
document.addEventListener('selectionchange', () => {
	const selection = document.getSelection()
	if (!selection!.isCollapsed) $treebank.classList.add('selection')
	else $treebank.classList.remove('selection')
})

function highlightGroup(role: string, className: string) {
	let hlGroup: HTMLSpanElement[] = []
	$$on('[data-head]', {
		pointerenter($el) {
			const data = $el.dataset,
				$head = $el.closest('.sentence')?.querySelector(`[data-head="${data.id}"]`)
			$head?.classList.add('head')
			$el.classList.add('hovered')
			if (some(['PRED', 'ADV', 'ATR'], role => data.role?.startsWith(role))) {
				hlGroup = [...deps($el, role)]
				hlGroup.forEach(el => el.classList.add('hl', className))
			}
		},
		mouseleave($el) {
			const data = $el.dataset,
				$head = $el.closest('.sentence')?.querySelector(`[data-head="${data.id}"]`)
			$el.classList.remove('hovered')
			$head?.classList.remove('head')
			hlGroup.forEach(el => el.classList.remove('hl', className))
		},
	})
}

highlightGroup('SBJ', 'subj')
highlightGroup('OBJ', 'dobj')

function* deps(word: HTMLSpanElement, role?: string): Iterable<HTMLSpanElement> {
	const ds: HTMLSpanElement[] = Array.from(
		word.closest('.sentence')!.querySelectorAll(`[data-head="${word.dataset.id}"]`)
	)
	for (let d of ds) {
		if (d.role == 'COORD') {
			yield* deps(d, role)
		}
		if (role ? d.dataset.role?.startsWith(role) : true) {
			yield d
			yield* deps(d)
		}
	}
}
