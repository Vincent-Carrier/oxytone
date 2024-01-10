import { Div } from '@/lib/types'

export class BaseElement extends HTMLElement {
	$<E extends HTMLElement = Div>(selector: string): E {
		return this.querySelector<E>(selector)!
	}

	$$<E extends HTMLElement = Div>(selector: string): E[] {
		return Array.from(this.querySelectorAll<E>(selector))
	}

	on(listeners: Record<string, (el: this) => void>) {
		for (const event in listeners) {
			this.addEventListener(event, ev => listeners[event](ev.target as this))
		}
	}
}
