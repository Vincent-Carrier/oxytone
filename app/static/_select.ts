import { $$, $inVerticalView } from './_dom'

export function* wordsInView() {
	let prevInView: boolean | undefined
	for (const $w of document.querySelectorAll<HTMLSpanElement>('[data-id]')) {
		const inView = $inVerticalView($w)
		if (inView) yield $w
		if (prevInView && prevInView != inView) break
		prevInView = inView
	}
}

export function* deps(word: HTMLSpanElement, role?: string) {
	const $deps = $$(`[data-head="${word.dataset.id}"]`, word.closest('.sentence')!)
	for (let $dep of $deps) {
		if ($dep.role == 'COORD') {
			yield* deps($dep, role)
		}
		if (role ? $dep.dataset.role?.startsWith(role) : true) {
			yield $dep
			yield* deps($dep)
		}
	}
}
