import { identity, kebabCase } from 'lodash-es';
export function BaseElement(superClass) {
    return class extends superClass {
        connectedCallback() {
            for (const prop of Object.getOwnPropertyNames(Object.getPrototypeOf(this))) {
                if (prop.startsWith('$on'))
                    this.addEventListener(prop.slice(3), this[prop]);
            }
        }
        $(selector) {
            return this.querySelector(selector);
        }
        $$(selector) {
            return Array.from(this.querySelectorAll(selector));
        }
    };
}
export function register(name) {
    return (target, ctx) => {
        ctx.addInitializer(function () {
            customElements.define(name, this);
        });
    };
}
export function attr(convert = identity) {
    return function (val, ctx) {
        const key = kebabCase(ctx.name);
        return {
            get() {
                return convert(this.attributes[key]?.value);
            },
        };
    };
}
//# sourceMappingURL=baseElement.js.map