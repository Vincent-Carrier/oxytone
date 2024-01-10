import decodeFlags from '@/lib/flags.ts'
import { Div } from '@/lib/types.ts'
import { Base } from './baseElement.ts'

export class BottomBar extends Base(HTMLElement) {
	$lemma: Div
	$def: Div
	$flags: Div

	set word(w) {
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
customElements.define('bottom-bar', BottomBar)
