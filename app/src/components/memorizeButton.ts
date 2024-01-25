import Token from '@/components/token.js'
import { BaseElement, attr, on, register, select } from '@/lib/baseElement.js'

const states = ['off', 'words', 'lines'] as const
type State = (typeof states)[number]
function* cycleState(): Iterator<State> {
	while (true) yield* states
}

@register('button')
export default class MemorizeButton extends BaseElement(HTMLButtonElement) {
	static tag = 'memorize-btn'
	@select('label') $label: HTMLLabelElement
	@attr(Boolean) accessor active = false
	$words: Token[] = []
	#machine: Iterator<State> = cycleState()
	#state: State = this.#machine.next().value

	@on('pointerdown') #handleClick() {
		this.#state = this.#machine.next().value
		switch (this.#state) {
			case 'words':
				this.active = true
				this.$label.innerText = 'Words'
				this.$words = Array.from(Token.inView())
				for (const $w of this.$words) toggleWord(false, $w)
				break
			case 'lines':
				this.$label.innerText = 'Lines'
				this.$words
					.filter($w => $w.matches(':not(.ln + w-token)'))
					.forEach($w => {
						$w.classList.add('transparent')
					})
				break
			case 'off':
				this.active = false
				this.$label.innerText = 'Memorize'
				for (const $w of this.$words) {
					toggleWord(true, $w)
					$w.classList.remove('transparent')
				}
				this.$words = []
				break
		}
	}
}

function toggleWord(show: boolean, $el: HTMLSpanElement) {
	const first = $el.innerText[0],
		rest = $el.innerText.slice(1)
	if (show) $el.innerHTML = $el.innerText
	else $el.innerHTML = `<span>${first}</span><span class="transparent">${rest}</span>`
}
