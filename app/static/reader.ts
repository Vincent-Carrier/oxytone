import { $, $$on } from './_dom.ts'
import { argument, head, isVerb } from './_selectWords.ts'
import { Span } from './_types.ts'

import './flashcards.ts'
import './memorize.ts'

const $treebank = $('article.treebank')

document.addEventListener('selectionchange', () => {
	const selection = document.getSelection()
	if (!selection!.isCollapsed) $treebank.classList.add('selection')
	else $treebank.classList.remove('selection')
})

$$on('[data-id]', {
	pointerenter($w) {
		const $head = head($w)
		$head?.classList.add('head')
		if (isVerb($w)) {
			this.dobjOff = highlightArguments($w, 'dobj', 'OBJ')
			this.subjOff = highlightArguments($w, 'subj', 'SBJ')
		}
	},
	mouseleave($w) {
		const $head = head($w)
		$head?.classList.remove('head')
		this.subjOff?.()
		this.dobjOff?.()
	},
})

function highlightArguments($verb: Span, className: string, ...roles: string[]) {
	const $args = Array.from(argument($verb, className, ...roles))
	$args.forEach($a => $a.classList.add('hl', className))
	return () => $args.forEach($a => $a.classList.remove('hl', className))
}
