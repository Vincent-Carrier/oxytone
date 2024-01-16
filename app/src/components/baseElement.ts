import { Div } from '@/lib/types.js'
import { identity, kebabCase } from 'lodash-es'

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
	}
}

export function register(name: string) {
	return (target, ctx: ClassDecoratorContext) => {
		ctx.addInitializer(function () {
			customElements.define(name, this as any)
		})
	}
}

export function attr(convert: (k: string) => any = identity) {
	return function (val, ctx: ClassAccessorDecoratorContext) {
		const key = kebabCase(ctx.name as string)
		return {
			get() {
				return convert(this.attributes[key]?.value)
			},
		}
	}
}
