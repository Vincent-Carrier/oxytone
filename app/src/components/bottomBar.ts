import Token from '@/components/token.js'
import { CustomElement, register, select } from '@/lib/baseElement.js'
import decodeFlags from '@/lib/flags.js'

@register('bottom-bar')
export default class BottomBar extends CustomElement {
	@select('#lemma') accessor $lemma: HTMLDivElement
	@select('#def') accessor $def: HTMLDivElement
	@select('#flags') accessor $flags: HTMLDivElement
	@select('#lsj') accessor $lsj: HTMLAnchorElement

	set word($w: Token | null) {
		if ($w === null) {
			this.$lemma.innerText = ''
			return
		}
		this.$lemma.innerText = $w.lemma
		this.$def.innerText = $w.definition ?? ''
		this.$flags.innerHTML = decodeFlags($w.flags)
		this.$lsj.href = `https://lsj.gr/index.php?search=${$w.lemma}`
	}
}
