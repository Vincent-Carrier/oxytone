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
        on(listeners) {
            for (const event in listeners) {
                this.addEventListener(event, ev => listeners[event](ev.target));
            }
        }
    };
}
export function register(name) {
    return (target, ctx) => {
        ctx.addInitializer(function () {
            //@ts-ignore
            customElements.define(name, this);
        });
    };
}
//# sourceMappingURL=baseElement.js.map