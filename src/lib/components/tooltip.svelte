<script lang="ts">
	import { Tooltip } from 'bits-ui'
	import type { Snippet } from 'svelte'
	import { fade } from 'svelte/transition'

	type Props = {
		children: Snippet
		tooltip: Snippet
		class?: string
	}

	let { children, tooltip, class: klass }: Props = $props()
</script>

<Tooltip.Root delayDuration={100}>
	<Tooltip.Trigger>
		{@render children()}
	</Tooltip.Trigger>
	<Tooltip.Portal>
		<Tooltip.Content
			class={[
				'tooltip-content elevated absolute top-7 right-0 bg-white px-2 py-1 text-left font-sans text-xs hyphens-auto text-gray-800 normal-case',
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
