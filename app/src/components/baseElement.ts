import { Div } from '@/lib/types.js'

type Constructor<T> = new (...args: any[]) => T

export function BaseElement<T extends Constructor<HTMLElement>>(superClass: T) {
	return class extends superClass {
		connectedCallback() {
			for (const prop of Object.getOwnPropertyNames(Object.getPrototypeOf(this))) {
				if (prop.startsWith('$on')) this.addEventListener(prop.slice(3), this[prop])
			}
		}

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
}

export function register(name: string) {
	return (target, ctx: ClassDecoratorContext) => {
		ctx.addInitializer(function () {
			//@ts-ignore
			customElements.define(name, this)
		})
	}
}
