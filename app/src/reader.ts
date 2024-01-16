import '@/components/bottomBar.js'
import '@/components/token.js'
import { Token } from '@/components/token.js'
import { $, $$, $id } from '@/lib/dom.js'
import '@/memorize.js'

const $export = $id<HTMLButtonElement>('export'),
	$treebank = $('article.treebank'),
	title = $id('title')!.innerText,
	slug = $treebank.id

$export.onclick = async function exportFlashcards() {
	const words = $$<Token>('.selected').map($w => ({
		lemma: $w.lemma,
		definition: $w.definition ?? '',
	}))
	const res = await fetch('/flashcards', { body: JSON.stringify({ title, slug, words }) })
	location.href = res.headers.get('Location')!
}

addEventListener('selectionchange', () => {
	const selection = document.getSelection()
	if (!selection!.isCollapsed) $treebank.classList.add('selection')
	else $treebank.classList.remove('selection')
})
