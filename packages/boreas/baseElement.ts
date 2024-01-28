import { $, $$ } from '@/dom.js'

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

		static get selector(): string {
			//@ts-ignore
			return `[is="${this.tag}"]`
		}

		static get() {
			return $(this.selector)
		}

		static all() {
			return document.querySelectorAll(this.selector)
		}
	}
}

export class CustomElement extends BaseElement(HTMLElement) {
	static get selector(): string {
		//@ts-ignore
		return this.tag
	}
}

export function register(base?: string) {
	return (target: any, ctx: ClassDecoratorContext) => {
		ctx.addInitializer(function (this: any) {
			customElements.define(this.tag, this as any, base && { extends: base })
		})
	}
}

const identity = (v: any) => v
type Parse = (k: string) => any

export function attr(parse: Parse = identity, key?: string) {
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

export function select(selector: string): any {
	return function (val, ctx: DecoratorContext) {
		if (ctx.kind === 'accessor')
			return {
				get() {
					return this.$(selector)
				},
			}
		else if (ctx.kind === 'field')
			return function () {
				return this.$(selector)
			}
		else throw Error(`${ctx.kind} not supported`)
	}
}

export function on(event: string, options?: AddEventListenerOptions & { root?: true }) {
	return function (val, ctx: ClassMethodDecoratorContext) {
		ctx.addInitializer(function (this: HTMLElement) {
			if (options?.root) addEventListener(event, val.bind(this), options)
			else this.addEventListener(event, val, options)
		})
	}
}

interface ElementLifecycle {
	connectedCallback?(): void
	disconnectedCallback?(): void
	adoptedCallback?(): void
	attributeChangedCallback?(name: string, oldValue: any, newValue: any): void
}
