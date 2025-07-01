<script lang="ts">
	import { type Snippet } from 'svelte'
	import Button from '$lib/components/button.svelte'
	import CheckmarkIcon from '~icons/heroicons/check-16-solid'
	import UncheckedIcon from '~icons/heroicons/minus-16-solid'
	import g from '$lib/global-state.svelte'
	import type { Attachment } from 'svelte/attachments'
	import type { ClassValue } from 'svelte/elements'

	type Props = {
		children: Snippet
		class?: ClassValue
		key: keyof typeof g
		store?: boolean
	}
	let { children, class: klass, key, store }: Props = $props()

	// @ts-ignore
	let set = (val: boolean) => (g[key] = val)
	let get = () => g[key]

	const localStore: Attachment = () => {
		if (!store) return
		localStorage.setItem(key, JSON.stringify(get()))
	}
</script>

<Button
	onclick={() => set(!get())}
	class={[{ 'text-gray-600 hover:bg-gray-100': !get() }, klass]}
	{@attach localStore}>
	{#if get()}
		<CheckmarkIcon class="mt-px" />
	{:else}
		<UncheckedIcon class="mt-px" />
	{/if}
	{@render children()}
</Button>
