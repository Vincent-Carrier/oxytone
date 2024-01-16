import { Token } from '@/components/token.js'
import decodeFlags from '@/lib/flags.js'
import { BaseElement, register, select } from './baseElement.js'

@register('bottom-bar')
export class BottomBar extends BaseElement(HTMLElement) {
	static tagName = 'bottom-bar'
	@select('#lemma') accessor $lemma: HTMLDivElement
	@select('#def') accessor $def: HTMLDivElement
	@select('#flags') accessor $flags: HTMLDivElement

	set word(w: Token) {
		this.$lemma.innerText = w.lemma
		this.$def.innerText = w.definition ?? ''
		this.$flags.innerHTML = decodeFlags(w.flags)
	}
}
