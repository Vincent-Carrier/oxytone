type Div = HTMLDivElement
type Dict<V> = Record<string, V>

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

type Selectable<E extends HTMLElement> = string | E | E[]
function $select<E extends HTMLElement = Div>(sl: Selectable<E>, root: ParentNode = document): E[] {
	if (sl instanceof HTMLElement) return [sl]
	else if (typeof sl === 'string') return $$(sl, root)
	else return sl
}

export function $on<E extends HTMLElement = Div>(
	selectable: Selectable<E>,
	listeners: Dict<(ev: UIEvent, $target: E) => void>,
	root: ParentNode = document
) {
	for (const $el of $select(selectable, root)) {
		for (const event in listeners) {
			$el.addEventListener(event, ev => listeners[event](ev as UIEvent, ev.target as E))
		}
	}
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
