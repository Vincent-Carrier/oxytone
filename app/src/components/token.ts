import { BaseElement, register } from '@/components/baseElement.js'
import { $$, $id, $inVerticalView } from '@/lib/dom.js'
import decodeFlags from '@/lib/flags.js'
import { some } from 'lodash-es'

const $export = $id<HTMLButtonElement>('export'),
	$selectedCount = $id('selected-count')

let selectedCount = 0,
	timeout

@register('w-token')
export class Token extends BaseElement(HTMLElement) {
	// @attr(number) tokenId: number
	headId: number
	lemma: string
	flags: string
	def?: string
	grammarRole?: string
	case?: string

	$onmousedown() {
		this.classList.toggle('selected')
		selectedCount = $$('.selected').length
		$selectedCount.innerText = selectedCount > 0 ? `(${selectedCount})` : ''
		$export.disabled = selectedCount <= 0
	}

	$onmouseenter() {
		if (this.classList.contains('punct')) return
		// $bottomBar.word = this.attributes
	}

	$pointerenter() {
		timeout = setTimeout(() => {
			const $head = this.head()
			$head?.classList.add('head')
			if (this.isVerb()) {
				this.subjOff = highlight(this.argument('SBJ'), 'subj')
				this.dobjOff = highlight(this.argument('OBJ'), 'dobj')
			}
			this.dependentsOff = highlight(this.dependents(), 'hl')
		}, 100)
	}

	$pointerleave() {
		clearTimeout(timeout)
		const $head = this.head
		$head?.classList.remove('head')
		this.subjOff?.()
		this.dobjOff?.()
		this.dependentsOff?.()
	}

	*wordsInView() {
		let prevInView: boolean | undefined
		for (const $w of document.querySelectorAll<this>('w-token')) {
			const inView = $inVerticalView($w)
			if (inView) yield $w
			if (prevInView && prevInView != inView) break
			prevInView = inView
		}
	}

	get head(): Token | null {
		const $sentence = this.closest('.sentence'),
			$head = $sentence?.querySelector<Token>(`[w-id="${this.headId}"]`)
		return $head ?? null
	}

	*headUp(): Iterable<Token> {
		const $head = this.head
		if (!$head) return
		yield $head
		yield* $head.headUp()
	}

	*directDependents(opts?: { include?: string[]; exclude?: string[] }) {
		const $sentence = this.closest('.sentence')!
		const $children = $sentence.querySelectorAll<Token>(`[head="${this.tokenId}"]`)
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
		return some(roles, r => this.role?.startsWith(r))
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
