import { $inVerticalView } from '@/lib/dom.js'
import { Span } from '@/lib/types.js'
import { some } from 'lodash-es'

export function* wordsInView() {
	let prevInView: boolean | undefined
	for (const $w of document.querySelectorAll<Span>('[data-id]')) {
		const inView = $inVerticalView($w)
		if (inView) yield $w
		if (prevInView && prevInView != inView) break
		prevInView = inView
	}
}

export function head($w: Span): Span | null | undefined {
	const $head = $w.dataset?.head,
		$sentence = $w.closest('.sentence')
	return $head ? $sentence?.querySelector(`[data-id="${$head}"]`) : null
}

export function* headUp($w: Span): Iterable<Span> {
	const $head = head($w)
	if (!$head) return
	yield $head
	yield* headUp($head)
}

export function* children($w: Span, opts?: { include?: string[]; exclude?: string[] }) {
	const $sentence = $w.closest('.sentence')!
	const $children = $sentence.querySelectorAll<Span>(`[data-head="${$w.dataset.id}"]`)
	for (const $child of $children) {
		if (opts?.exclude && isRole($child, ...opts.exclude)) continue
		if (opts?.include && !isRole($child, ...opts.include)) continue
		yield $child
	}
}

export function* dependents(
	$w: Span,
	opts?: { include?: string[]; exclude?: string[] }
): Iterable<Span> {
	for (const $child of children($w)) {
		if (opts?.exclude && isRole($child, ...opts.exclude)) continue
		if (opts?.include && !isRole($child, ...opts.include)) continue
		yield $child
		yield* dependents($child)
	}
}

export function verb($w: Span): Span | undefined {
	for (const $a of headUp($w)) {
		if (isVerb($w)) return $a
	}
}

export function* argument($verb: Span, ...roles: string[]): Iterable<Span> {
	for (const $w of children($verb)) {
		yield* constituent($w, roles)
	}
}

export function* constituent($w: Span, roles: string[]) {
	if (isRole($w, 'COORD')) yield* children($w, { include: roles })
	else if (isRole($w, ...roles)) yield $w
}

export function isRole($w: Span, ...roles: string[]): boolean {
	return some(roles, r => $w.dataset.role?.startsWith(r))
}

export function isVerb($w: Span): boolean {
	return isRole($w, 'PRED', 'ATR', 'ADV')
}
