import { argument, dependents, head, isVerb } from '@/_selectWords.ts'
import { $, $on } from '@/lib/dom.ts'
import { Span } from '@/lib/types.ts'

import '@/components/bottomBar.ts'
import '@/flashcards.ts'
import '@/memorize.ts'

const $treebank = $('article.treebank')

addEventListener('selectionchange', () => {
	const selection = document.getSelection()
	if (!selection!.isCollapsed) $treebank.classList.add('selection')
	else $treebank.classList.remove('selection')
})

let timeout
$on('[data-id]', {
	pointerenter($w) {
		timeout = setTimeout(() => {
			const $head = head($w)
			$head?.classList.add('head')
			if (isVerb($w)) {
				this.subjOff = highlight(argument($w, 'SBJ'), 'subj')
				this.dobjOff = highlight(argument($w, 'OBJ'), 'dobj')
			}
			this.dependentsOff = highlight(dependents($w), 'hl')
		}, 100)
	},
	pointerleave($w) {
		clearTimeout(timeout)
		const $head = head($w)
		$head?.classList.remove('head')
		this.subjOff?.()
		this.dobjOff?.()
		this.dependentsOff?.()
	},
})

function highlight(words: Iterable<Span>, className: string) {
	const $words = Array.from(words)
	$words.forEach($w => $w.classList.add(className))
	return () => $words.forEach($w => $w.classList.remove(className))
}
