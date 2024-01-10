import { Base } from '@/components/baseElement.ts'
import { $inVerticalView } from '@/lib/dom.ts'
import decodeFlags from '@/lib/flags.ts'
import { some } from 'lodash-es'

export class Token extends Base(HTMLElement) {
	tokenId: number
	headId: number
	lemma: string
	flags: string
	def?: string
	grammarRole?: string
	case?: string;

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

	get isVerb(): boolean {
		return this.isRole('PRED', 'ATR', 'ADV')
	}
	get morphology(): string {
		return decodeFlags(this.flags)
	}
}
customElements.define('w-token', Token)
