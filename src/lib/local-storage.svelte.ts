import { browser } from '$app/environment'

export default class LocalStore<T> {
	value = $state<T>() as T

	constructor(
		public key: string,
		value: T
	) {
		this.value = value

		if (browser) {
			let val = localStorage.getItem(key)
			if (val) this.value = JSON.parse(val)
		}

		$effect(() => {
			localStorage.setItem(this.key, JSON.stringify(this.value))
		})
	}
}
