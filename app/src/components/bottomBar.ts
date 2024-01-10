import { Div } from '@/lib/types'
import { BaseElement } from './baseElement'

export class BottomBar extends BaseElement {
	$lemma: Div
	$def: Div
	$flags: Div

	set word(w) {
		this.$lemma.innerText = w.lemma
		this.$def.innerText = w.def
	}

	connectedCallback() {
		this.$lemma = this.$('#lemma')
		this.$def = this.$('#def')
		this.$flags = this.$('#flags')
	}
}
customElements.define('bottom-bar', BottomBar)
