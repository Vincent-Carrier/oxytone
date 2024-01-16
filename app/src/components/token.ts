import { BaseElement, attr, register } from '@/components/baseElement.js'
import { BottomBar } from '@/components/bottomBar.js'
import { $, $$, $id, $inVerticalView } from '@/lib/dom.js'
import decodeFlags from '@/lib/flags.js'

const $export = $id<HTMLButtonElement>('export'),
	$selectedCount = $id('selected-count'),
	$bottomBar = $<BottomBar>('bottom-bar')

let selectedCount = 0,
	timeout

@register('w-token')
export class Token extends BaseElement(HTMLElement) {
	@attr(Number) accessor n: number
	@attr(Number) accessor head: number
	@attr() accessor definition: string
	@attr() accessor lemma: string
	@attr() accessor flags: string
	@attr() accessor role: string
	@attr() accessor case: string
	off: { [k: string]: () => void } = {}

	$onmousedown() {
		this.classList.toggle('selected')
		selectedCount = $$('.selected').length
		$selectedCount.innerText = selectedCount > 0 ? `(${selectedCount})` : ''
		$export.disabled = selectedCount <= 0
	}

	$onmouseenter() {
		if (this.classList.contains('punct')) return
		$bottomBar.word = this
	}

	$pointerenter() {
		timeout = setTimeout(() => {
			this.$head?.classList.add('head')
			if (this.isVerb) {
				this.off.subj = highlight(this.argument('SBJ'), 'subj')
				this.off.dobj = highlight(this.argument('OBJ'), 'dobj')
			}
			this.off.dependents = highlight(this.dependents(), 'hl')
		}, 100)
	}

	$pointerleave() {
		clearTimeout(timeout)
		this.$head?.classList.remove('head')
		this.off.subj?.()
		this.off.dobj?.()
		this.off.dependents?.()
	}

	static *inView() {
		let prevInView: boolean | undefined
		for (const $w of document.querySelectorAll<Token>('w-token')) {
			const inView = $inVerticalView($w)
			if (inView) yield $w
			if (prevInView && prevInView != inView) break
			prevInView = inView
		}
	}

	get $head(): Token | null {
		const $sentence = this.closest('.sentence'),
			$head = $sentence?.querySelector<Token>(`[n="${this.head}"]`)
		return $head ?? null
	}

	*headUp(): Iterable<Token> {
		const $head = this.$head
		if (!$head) return
		yield $head
		yield* $head.headUp()
	}

	*directDependents(opts?: { include?: string[]; exclude?: string[] }) {
		const $sentence = this.closest('.sentence')!
		const $children = $sentence.querySelectorAll<Token>(`[head="${this.n}"]`)
		for (const $child of Array.from($children)) {
			if (opts?.exclude && $child.isRole(...opts.exclude)) continue
			if (opts?.include && !$child.isRole(...opts.include)) continue
			yield $child
		}
	}

	*dependents(opts?: { include?: string[]; exclude?: string[] }): Iterable<Token> {
		for (const $child of this.directDependents()) {
			if (opts?.exclude && $child.isRole(...opts.exclude)) continue
			if (opts?.include && !$child.isRole(...opts.include)) continue
			yield $child
			yield* $child.dependents()
		}
	}

	verb(): Token | undefined {
		for (const $a of this.headUp()) {
			if (this.isVerb) return $a
		}
	}

	*argument(...roles: string[]): Iterable<Token> {
		for (const $w of this.directDependents()) {
			yield* $w.constituent(...roles)
		}
	}

	*constituent(...roles: string[]) {
		if (this.isRole('COORD')) yield* this.directDependents({ include: roles })
		else if (this.isRole(...roles)) yield this
	}

	isRole(...roles: string[]): boolean {
		for (const role of roles) {
			if (this.role.startsWith(role)) return true
		}
		return false
	}

	toggleMemorize(show: boolean) {
		const first = this.innerText[0],
			rest = this.innerText.slice(1)
		if (show) this.innerHTML = this.innerText
		else this.innerHTML = `<span>${first}</span><span style="color: transparent">${rest}</span>`
	}

	get isVerb(): boolean {
		return this.isRole('PRED', 'ATR', 'ADV')
	}

	get morphology(): string {
		return decodeFlags(this.flags)
	}
}

function highlight(words: Iterable<Token>, className: string) {
	const $words = Array.from(words)
	$words.forEach($w => $w.classList.add(className))
	return () => $words.forEach($w => $w.classList.remove(className))
}
