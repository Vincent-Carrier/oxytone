type Div = HTMLDivElement

export function $id<E extends HTMLElement = Div>(id: string): E {
	return document.getElementById(id) as E
}

export function $<E extends HTMLElement = Div>(selector: string, root: ParentNode = document): E {
	return root.querySelector<E>(selector)!
}

export function $$<E extends HTMLElement = Div>(
	selector: string,
	root: ParentNode = document
): E[] {
	return Array.from(root.querySelectorAll<E>(selector))
}

export function $on<E extends HTMLElement = Div>(
	els: string | E | E[],
	listeners: Record<string, (el: E) => void>,
	root: ParentNode = document
) {
	let $els: E[]
	if (els instanceof HTMLElement) $els = [els]
	else if (typeof els === 'string') $els = $$(els, root)
	else $els = els
	$els.forEach(el => {
		for (const event in listeners) {
			el.addEventListener(event, ev => listeners[event](ev.target as E))
		}
	})
}

export function $inVerticalView($el: HTMLElement): boolean {
	const bounds = $el.getBoundingClientRect()
	return bounds.top >= 0 && bounds.bottom <= window.innerHeight
}
