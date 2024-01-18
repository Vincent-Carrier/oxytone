import { BaseElement, attr, register, select } from '@/lib/baseElement.js'
import { $, $$, $id } from '@/lib/dom.js'
import { postJSON } from '@/lib/fetch.js'
import Token from './token.js'

const $treebank = $('article.treebank'),
	title = $id('title').innerText,
	slug = $treebank.id

@register('flashcards-btn', 'button')
export default class FlashcardsButton extends BaseElement(HTMLButtonElement) {
	@attr(Boolean) accessor active: boolean
	@select('label') accessor label: HTMLLabelElement
	count: number = 0

	constructor() {
		super()
		addEventListener(
			'tokenselect',
			(ev: CustomEvent) => {
				console.log('ev:', ev)
				this.count += ev.detail.selected ? 1 : -1
				this.render()
			},
			{ capture: true }
		)
	}

	render() {
		if (this.active) this.label.innerText = `${this.count} selected`
		else this.label.innerText = 'Flashcards'
		this.disabled = this.active && this.count === 0
	}

	async $onclick() {
		// if (this.active && this.count > 0) {
		// 	this.exportFlashcards()
		// 	this.count = 0
		// }
		this.clear()
		this.active = !this.active
		this.render()
	}

	clear() {
		Token.clearSelected()
		this.count = 0
	}

	async exportFlashcards() {
		const words = $$<Token>('[selected]').map($w => ({
			lemma: $w.lemma,
			definition: $w.definition ?? '',
		}))
		// TODO: error handling
		const res = await postJSON('/flashcards', { title, slug, words })
		location.href = res.headers.get('Location')!
	}
}