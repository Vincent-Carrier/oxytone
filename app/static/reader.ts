import some from 'lodash-es/some'
import './flashcards'

function highlightGroup(role: string, className: string) {
	let hlGroup: HTMLSpanElement[] = []
	document.querySelectorAll('[data-head]').forEach(el => {
		el.addEventListener('pointerenter', ev => {
			const $span = ev.target as HTMLSpanElement
			const { dataset: d } = $span
			const $head = $span.closest('.sentence')?.querySelector(`[data-head="${d.id}"]`)
			$head?.classList.add('head')
			$span.classList.add('hovered')
			if (some(['PRED', 'ADV', 'ATR'], role => d.role?.startsWith(role))) {
				hlGroup = [...deps($span, role)]
				hlGroup.forEach(el => el.classList.add('hl', className))
			}
		})
		el.addEventListener('mouseleave', ev => {
			const $span = ev.target as HTMLSpanElement
			const { dataset: d } = $span
			$span.classList.remove('hovered')
			const $head = $span.closest('.sentence')?.querySelector(`[data-head="${d.id}"]`)
			$head?.classList.remove('head')
			hlGroup.forEach(el => el.classList.remove('hl', className))
		})
	})
}

highlightGroup('SBJ', 'subj')
highlightGroup('OBJ', 'dobj')
// highlightGroup("OBJ", "iobj");

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

const $treebank = document.querySelector('article.treebank')!
document.addEventListener('selectionchange', () => {
	const selection = document.getSelection()
	if (!selection!.isCollapsed) $treebank.classList.add('selection')
	else $treebank.classList.remove('selection')
})
