import { $, $$ } from '@/lib/dom.js'

type Div = HTMLDivElement
type Constructor<T> = new (...args: any[]) => T

export function BaseElement<T extends Constructor<HTMLElement>>(Sup: T) {
	return class Sub extends Sup {
		$<E extends HTMLElement = Div>(selector: string): E {
			return $<E>(selector, this)
		}

		$$<E extends HTMLElement = Div>(selector: string): E[] {
			return $$<E>(selector, this)
		}
	}
}
export class CustomElement extends BaseElement(HTMLElement) {}

export function register(base: string = undefined) {
	return (target: any, ctx: ClassDecoratorContext) => {
		ctx.addInitializer(function (this: any) {
			customElements.define(this.tag, this as any, base && { extends: base })
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
				const val = this.attributes[k]?.value
				if (parse === Boolean && val === '') return true
				else return parse(val)
			},
			set(val: any) {
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
		ctx.addInitializer(function (this: HTMLElement) {
			this.addEventListener(event, val)
		})
	}
}

interface ElementLifecycle {
	connectedCallback?(): void
	disconnectedCallback?(): void
	adoptedCallback?(): void
	attributeChangedCallback?(name: string, oldValue: any, newValue: any): void
}
