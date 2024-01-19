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

export function $get<T extends HTMLElement>(El: (new () => T) & { selector: string }): T {
	return $(El.selector)
}

export function $all<T extends HTMLElement>(El: (new () => T) & { selector: string }): T[] {
	return $$(El.selector)
}

export function $inVerticalView($el: HTMLElement): boolean {
	const bounds = $el.getBoundingClientRect()
	return bounds.top >= 0 && bounds.bottom <= window.innerHeight
}
