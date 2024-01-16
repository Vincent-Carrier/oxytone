import { BaseElement, register } from '@/lib/baseElement.js'
import { $, $$, $id } from '@/lib/dom.js'
import { postJSON } from '@/lib/fetch.js'
import Token from './token.js'

const $treebank = $('article.treebank'),
	title = $id('title').innerText,
	slug = $treebank.id

@register('flashcards-btn', 'button')
export default class FlashcardsButton extends BaseElement(HTMLButtonElement) {
	async $onclick() {
		const words = $$<Token>('.selected').map($w => ({
			lemma: $w.lemma,
			definition: $w.definition ?? '',
		}))
		// TODO: error handling
		const res = await postJSON('/flashcards', { title, slug, words })
		location.href = res.headers.get('Location')!
	}
}
