type Div = HTMLDivElement
type Constructor<T> = new (...args: any[]) => T

export function BaseElement<T extends Constructor<HTMLElement>>(superClass: T) {
	return class extends superClass implements ElementLifecycle {
		constructor(...args: any[]) {
			super()
			// TODO: Replace with decorator
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
	}
}
export class CustomElement extends BaseElement(HTMLElement) {}

export function register(name: string, base: string = undefined) {
	return (target, ctx: ClassDecoratorContext) => {
		ctx.addInitializer(function () {
			customElements.define(name, this as any, base && { extends: base })
		})
	}
}

export function attr(convert: (k: string) => any = k => k, key: string = undefined) {
	return function (val, ctx: ClassAccessorDecoratorContext) {
		return {
			get() {
				return convert(this.attributes[key ?? ctx.name]?.value)
			},
		}
	}
}

export function select(selector: string) {
	return function (val, ctx: ClassAccessorDecoratorContext) {
		return {
			get() {
				return this.$(selector)
			},
		}
	}
}

export function on(event: string) {
	return function (val, ctx: ClassMethodDecoratorContext) {
		return {}
	}
}

interface ElementLifecycle {
	connectedCallback?(): void
	disconnectedCallback?(): void
	adoptedCallback?(): void
	attributeChangedCallback?(name: string, oldValue: any, newValue: any): void
}
