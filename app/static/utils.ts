export function $id<E extends HTMLElement = HTMLDivElement>(id: string): E {
	return document.getElementById(id) as E
}

export function $<E extends HTMLElement = HTMLDivElement>(
	selector: string,
	root: ParentNode = document
): E {
	return root.querySelector<E>(selector)!
}

export function $$<E extends HTMLElement = HTMLDivElement>(
	selector: string,
	root: ParentNode = document
): E[] {
	return Array.from(root.querySelectorAll<E>(selector))
}

export function $$on<E extends HTMLElement = HTMLDivElement>(
	selector: string,
	listeners: Record<string, (el: E) => void>,
	root: ParentNode = document
) {
	root.querySelectorAll(selector).forEach(el => {
		for (const event in listeners) {
			el.addEventListener(event, ev => listeners[event](ev.target as E))
		}
	})
}
