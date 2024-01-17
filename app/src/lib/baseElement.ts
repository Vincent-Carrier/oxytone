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

const identity = (v: any) => v
type Parse = (k: string) => any

export function attr(parse: Parse = identity, key: string = undefined) {
	return function (val: any, ctx: ClassAccessorDecoratorContext) {
		const k = key ?? (ctx.name as string)
		return {
			get() {
				return parse(this.attributes[k]?.value)
			},
			set(val: any) {
				console.log(typeof val)
				if (val === true) this.setAttribute(k, '')
				else if (!val) this.removeAttribute(k)
				else this.setAttribute(k, val as string)
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
