import { $, BaseElement, attr, on, register, select } from '@vincentcarrier/boreas'
import { postJSON } from '../fetch.js'
import Token, { type TokenSelectInit } from './token.js'

const $treebank = $('article.treebank'),
	title = $('#title')?.innerText,
	slug = $treebank.id

@register('button')
export default class FlashcardsButton extends BaseElement(HTMLButtonElement) {
	static tag = 'flashcards-btn'
	@attr(Boolean) accessor active: boolean
	@select('label') accessor #label: HTMLLabelElement
	count: number = 0

	#render() {
		if (this.active) this.#label.innerText = `${this.count} selected`
		else this.#label.innerText = 'Flashcards'
		this.disabled = this.active && this.count === 0
	}

	@on('tokenselect', { root: true, capture: true }) #handleTokenSelect(ev: TokenSelectInit) {
		this.count += ev.detail!.word.selected ? 1 : -1
		this.#render()
	}

	@on('pointerdown') async #handleClick() {
		if (this.active && this.count > 0) await this.#exportFlashcards()
		this.#clear()
		this.active = !this.active
		this.#render()
	}

	#clear() {
		Token.clearSelected()
		this.count = 0
	}

	async #exportFlashcards() {
		const words = Token.allSelected().map($w => ({
			lemma: $w.lemma,
			definition: $w.definition ?? '',
			ref: $w.canonicalRef()?.toString(),
			phrase: $w
				.containingPhrase()
				.sort((a, b) => a.n - b.n)
				.map(({ innerText }) =>
					innerText === $w.innerText ? `<b>${innerText}</b>` : innerText
				)
				.join(' ')
				.replace(' ,', ','),
		}))
		// TODO: error handling
		const res = await postJSON('/flashcards', { title, slug, words })
		location.href = res.headers.get('Location')!
	}
}
