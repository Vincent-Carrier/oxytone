<script lang="ts">
	import type { Snippet } from 'svelte'
	import type { HTMLButtonAttributes, HTMLAnchorAttributes } from 'svelte/elements'
	import Tooltip from './tooltip.svelte'

	type Props = {
		tooltip?: Snippet
		danger?: boolean
	} & HTMLButtonAttributes &
		HTMLAnchorAttributes
	let { children, tooltip, class: klass, danger, ...attrs }: Props = $props()
	let help = $state(false)

	let shared = {
		class: 'contents',
		...(tooltip
			? {
					onpointerover(ev: PointerEvent) {
						ev.pointerType === 'mouse' && (help = true)
					},
					onpointerleave() {
						help = false
					}
				}
			: {})
	}
</script>

{#if attrs.href}
	<a {...shared} {...attrs}>
		{@render content()}
	</a>
{:else}
	<button {...shared} {...attrs}>
		{@render content()}
	</button>
{/if}

{#snippet content()}
	<div
		class={[
			'relative flex w-fit items-center gap-x-1',
			'font-sans-sc cursor-pointer leading-tight text-blue-700 lowercase',
			'rounded-sm px-1 hover:bg-blue-50 active:bg-blue-100',
			danger && 'text-red-700 hover:bg-red-50 active:bg-red-100',
			attrs.inert && 'text-gray-600',
			klass
		]}>
		{@render children?.()}
		{#if help}
			<Tooltip>
				{@render tooltip?.()}
			</Tooltip>
		{/if}
	</div>
{/snippet}
