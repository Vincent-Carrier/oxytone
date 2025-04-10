<script lang="ts">
	import { type Snippet } from 'svelte'
	import LocalStore from '$lib/local-storage.svelte'
	import Button from '$lib/components/button.svelte'
	import CheckmarkIcon from '~icons/heroicons/check-16-solid'
	import UncheckedIcon from '~icons/heroicons/minus-16-solid'

	type Props = {
		children: Snippet
		tooltip?: Snippet
		get?: () => boolean
		set?: (value: boolean) => void
		key?: string
		value?: boolean
	}
	let { children, tooltip, set, get, key, value = true }: Props = $props()

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

	if (key) $effect(() => set?.(toggle.value))
</script>

<Button
	{tooltip}
	onclick={() => (toggle.value = !toggle.value)}
	class={[!toggle.value && 'text-gray-600 hover:bg-gray-100']}>
	{#if toggle.value}
		<CheckmarkIcon class="mt-px" />
	{:else}
		<UncheckedIcon class="mt-px" />
	{/if}
	{@render children()}
</Button>
