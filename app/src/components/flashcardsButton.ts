import { BaseElement, attr, on, register, select } from '@/lib/baseElement.js'
import { $, $id } from '@/lib/dom.js'
import { postJSON } from '@/lib/fetch.js'
import Token, { TokenSelectInit } from './token.js'

const $treebank = $('article.treebank'),
	title = $id('title').innerText,
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
		this.count += ev.detail.word.selected ? 1 : -1
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
