import { BottomBar } from '@/components/bottomBar.ts'
import { $, $$, $id, $on } from '@/lib/dom.ts'
import ky from 'ky'

const $export = $id<HTMLButtonElement>('export'),
	$selectedCount = $id('selected-count'),
	$treebank = $('article.treebank'),
	$bottomBar = $<BottomBar>('bottom-bar'),
	title = $id('title')!.innerText,
	slug = $treebank.id

let selectedCount = 0

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
})

$export.onclick = async function exportFlashcards() {
	const words = $$('.selected').map($el => ({
		lemma: $el.dataset.lemma,
		definition: $el.dataset.def ?? '',
	}))
	const res = await ky.post('/flashcards', { json: { title, slug, words } })
	location.href = res.headers.get('Location')!
}
