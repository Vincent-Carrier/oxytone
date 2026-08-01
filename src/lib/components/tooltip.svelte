<script lang="ts">
	import { Tooltip } from 'bits-ui'
	import type { Snippet } from 'svelte'

	type TriggerProps = Record<string, unknown>

	type Props = {
		children?: Snippet
		tooltip: Snippet
		class?: string
		// Wrap interactive content (anything containing a button or link) in this
		// instead of `children`: the default trigger renders its own <button>, and
		// nesting one inside another is invalid HTML the browser silently repairs.
		child?: Snippet<[{ props: TriggerProps }]>
	}

	let { children, tooltip, class: klass, child }: Props = $props()
</script>

<Tooltip.Root delayDuration={100}>
	{#if child}
		<Tooltip.Trigger {child} />
	{:else}
		<Tooltip.Trigger>
			{@render children?.()}
		</Tooltip.Trigger>
	{/if}
	<Tooltip.Portal>
		<Tooltip.Content
			class={[
				'tooltip-content elevated absolute top-7 right-0 z-50 bg-white px-2 py-1 text-left font-sans text-xs hyphens-auto text-gray-800 normal-case',
				klass
			]}>
			{@render tooltip()}
		</Tooltip.Content>
	</Tooltip.Portal>
</Tooltip.Root>

<style>
	:global([data-bits-floating-content-wrapper] a) {
		text-decoration: underline 2px;
		color: var(--color-blue-700);
	}
	:global([data-bits-floating-content-wrapper] ol) {
		list-style: disc inside;
		text-indent: 0.75rem hanging;
	}
</style>
