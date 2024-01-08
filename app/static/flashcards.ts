import ky from 'ky'
import flagsToString from './flagsToString'
import { $, $$, $$on, $id } from './utils'

const $def = $id('def'),
	$flags = $id('flags'),
	$lemma = $id('lemma'),
	$export = $id<HTMLButtonElement>('export'),
	$selectedCount = $id('selected-count'),
	$treebank = $('article.treebank'),
	title = $id('title')!.innerText,
	slug = $treebank.id

let selectedCount = 0

$$on('[data-lemma]', {
	mouseenter(el) {
		const data = el.dataset
		if (el.classList.contains('punct')) return
		$def.innerHTML = data.def ?? ''
		$flags.innerHTML = flagsToString(data.flags)
		$lemma.innerHTML = data.lemma ?? ''
	},
	mousedown(el) {
		el.classList.toggle('selected')
		selectedCount = $$('.selected').length
		$selectedCount.innerText = selectedCount > 0 ? `${selectedCount} selected` : ''
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
