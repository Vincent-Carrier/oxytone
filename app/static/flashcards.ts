import ky from 'ky'
import flagsToString from './flagsToString'
import { $, $$, $id } from './utils'

const $def = $id('def'),
	$flags = $id('flags'),
	$lemma = $id('lemma'),
	$export = $id<HTMLButtonElement>('export'),
	$selectedCount = $id('selected-count'),
	$treebank = $('article.treebank'),
	slug = $treebank.id

let selectedCount = 0

$$('[data-lemma]').forEach(el => {
	el.addEventListener('mouseenter', ev => {
		const el = ev.target as HTMLSpanElement
		const { dataset: d } = el
		if (el.classList.contains('punct')) return
		$def.innerHTML = d.def ?? ''
		$flags.innerHTML = flagsToString(d.flags)
		$lemma.innerHTML = d.lemma ?? ''
	})
	el.addEventListener('mousedown', ev => {
		const span = ev.target as HTMLSpanElement
		span.classList.toggle('selected')
		selectedCount = $$('.selected').length
		$selectedCount.innerText = selectedCount > 0 ? `${selectedCount} selected` : ''
		$export.disabled = selectedCount <= 0
	})
})

$export.onclick = async function exportFlashcards() {
	const words = $$<HTMLSpanElement>('.selected').map(el => ({
		lemma: el.dataset.lemma,
		definition: el.dataset.def ?? '',
	}))
	const title = $id('title')!.innerText
	const res = await ky.post('/flashcards', { json: { title, slug, words } })
	location.href = res.headers.get('Location')!
}
