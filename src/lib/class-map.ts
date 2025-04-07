type Entry = [HTMLElement | undefined | null, ...string[]]

export default class ClassMap {
	#map: Map<HTMLElement, string[]> = new Map()
	constructor(...entries: Entry[]) {
		for (let [el, ...classes] of entries) {
			if (el) this.#map.set(el, classes)
		}
	}

	set(el: HTMLElement, ...classes: string[]) {
		if (el) this.#map.set(el, classes)
	}

	addClasses() {
		for (let [el, classes] of this.#map) {
			el.classList.add(...classes)
		}
	}

	removeClasses() {
		for (let [el, classes] of this.#map) {
			el.classList.remove(...classes)
		}
	}
}
