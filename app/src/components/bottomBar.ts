import { TokenSelectInit } from '@/components/token.js'
import { CustomElement, on, register, select } from '@/lib/baseElement.js'
import decodeFlags from '@/lib/flags.js'

@register()
export default class BottomBar extends CustomElement {
	static tag = 'bottom-bar'
	@select('#lemma') accessor $lemma: HTMLDivElement
	@select('#def') accessor $def: HTMLDivElement
	@select('#flags') accessor $flags: HTMLDivElement
	@select('#lsj') accessor $lsj: HTMLAnchorElement

	@on('tokenselect', { root: true, capture: true }) #handleTokenSelect(ev: TokenSelectInit) {
		const $w = ev.detail.word
		if (!$w.selected) {
			this.$lemma.innerText = ''
			return
		}
		this.$lemma.innerText = $w.lemma
		this.$def.innerText = $w.definition ?? ''
		this.$flags.innerHTML = decodeFlags($w.flags)
		this.$lsj.href = `https://lsj.gr/index.php?search=${$w.lemma}`
	}
}
