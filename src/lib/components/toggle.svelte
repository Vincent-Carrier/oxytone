<script lang="ts">
	import { type Snippet } from 'svelte'
	import LocalStore from '$lib/local-storage.svelte'
	import Button from '$lib/components/button.svelte'
	import CheckmarkIcon from '~icons/heroicons/check-16-solid'
	import UncheckedIcon from '~icons/heroicons/minus-16-solid'

	type Props = {
		children: Snippet
		class?: string
		get?: () => boolean
		set?: (value: boolean) => void
		key?: string
		value?: boolean
	}
	let { children, class: klass, set, get, key, value = true }: Props = $props()

	// use localStorage to remember the value if a key is given
	let toggle = key
		? new LocalStore(key, value)
		: {
				get value() {
					return get!()
				},
				set value(v) {
					set!(v)
				}
			}
</script>

<Button
	onclick={() => (toggle.value = !toggle.value)}
	class={[{ 'text-gray-600 hover:bg-gray-100': !toggle.value }, klass]}
	{@attach () => key && set?.(toggle.value)}>
	{#if toggle.value}
		<CheckmarkIcon class="mt-px" />
	{:else}
		<UncheckedIcon class="mt-px" />
	{/if}
	{@render children()}
</Button>
