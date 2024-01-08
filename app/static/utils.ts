export function $id<E extends HTMLElement>(id: string): E {
	return document.getElementById(id) as E
}

export function $<E extends HTMLElement>(selector: string): E {
	return document.querySelector<E>(selector)!
}

export function $$<E extends HTMLElement>(selector: string): E[] {
	return Array.from(document.querySelectorAll<E>(selector))
}
