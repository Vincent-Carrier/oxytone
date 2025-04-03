import { browser } from '$app/environment'

export function q<T extends HTMLElement>(selector: string) {
	if (browser) return document.querySelector<T>(selector)
}

export function qq<T extends HTMLElement>(selector: string) {
	if (browser) return document.querySelectorAll<T>(selector)
}
