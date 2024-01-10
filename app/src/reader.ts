import { argument, dependents, head, isVerb } from '@/_selectWords.ts'
import { Span } from '@/lib/types.ts'

import '@/components/bottomBar.ts'
import { BottomBar } from '@/components/bottomBar.ts'
import { $, $$, $id, $on } from '@/lib/dom.ts'
import '@/memorize.ts'
import ky from 'ky'

const $export = $id<HTMLButtonElement>('export'),
	$selectedCount = $id('selected-count'),
	$treebank = $('article.treebank'),
	$bottomBar = $<BottomBar>('bottom-bar'),
	title = $id('title')!.innerText,
	slug = $treebank.id

let selectedCount = 0,
	timeout

$on('[data-lemma]', {
	mouseenter($el) {
		if ($el.classList.contains('punct')) return
		$bottomBar.word = $el.dataset
	},
	mousedown($el) {
		$el.classList.toggle('selected')
		selectedCount = $$('.selected').length
		$selectedCount.innerText = selectedCount > 0 ? `(${selectedCount})` : ''
		$export.disabled = selectedCount <= 0
	},
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

$export.onclick = async function exportFlashcards() {
	const words = $$('.selected').map($el => ({
		lemma: $el.dataset.lemma,
		definition: $el.dataset.def ?? '',
	}))
	const res = await ky.post('/flashcards', { json: { title, slug, words } })
	location.href = res.headers.get('Location')!
}

addEventListener('selectionchange', () => {
	const selection = document.getSelection()
	if (!selection!.isCollapsed) $treebank.classList.add('selection')
	else $treebank.classList.remove('selection')
})

function highlight(words: Iterable<Span>, className: string) {
	const $words = Array.from(words)
	$words.forEach($w => $w.classList.add(className))
	return () => $words.forEach($w => $w.classList.remove(className))
}
