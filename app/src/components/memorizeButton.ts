import Token from '@/components/token.js'
import { BaseElement, register } from '@/lib/baseElement.js'

@register('memorize-btn', 'button')
export default class MemorizeButton extends BaseElement(HTMLButtonElement) {
	$words: Token[] = []

	$onclick() {
		if (this.$words.length) {
			this.$words.forEach($w => toggleWord(true, $w))
			this.$words = []
		} else {
			this.$words = Array.from(Token.inView())
			this.$words.forEach($w => toggleWord(false, $w))
		}
	}
}

function toggleWord(show: boolean, $el: HTMLSpanElement) {
	const first = $el.innerText[0],
		rest = $el.innerText.slice(1)
	if (show) $el.innerHTML = $el.innerText
	else $el.innerHTML = `<span>${first}</span><span style="color: transparent">${rest}</span>`
}
