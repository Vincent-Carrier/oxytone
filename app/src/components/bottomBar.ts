import { Token } from '@/components/token.js'
import decodeFlags from '@/lib/flags.js'
import { Div } from '@/lib/types.js'
import { BaseElement, register } from './baseElement.js'

@register('bottom-bar')
export class BottomBar extends BaseElement(HTMLElement) {
	static tagName = 'bottom-bar'
	$lemma: Div
	$def: Div
	$flags: Div

	set word(w: Token) {
		this.$lemma.innerText = w.lemma
		this.$def.innerText = w.def
		this.$flags.innerHTML = decodeFlags(w.flags)
	}

	connectedCallback() {
		this.$lemma = this.$('#lemma')
		this.$def = this.$('#def')
		this.$flags = this.$('#flags')
	}
}
