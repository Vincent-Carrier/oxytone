<script lang="ts">
	import { Button } from 'bits-ui'

	type Props = { danger?: boolean } & Button.RootProps
	let { children, class: klass, danger, ...attrs }: Props = $props()
</script>

<Button.Root
	class={[
		'relative flex w-max items-baseline gap-x-1 [&>svg]:self-center',
		'font-sans-sc cursor-pointer leading-tight text-blue-700 lowercase',
		// py matches px so the hover/active background sits evenly around the
		// content. Without it the box collapses to the exact height of its
		// contents, which is invisible next to a text label but obvious on mobile,
		// where the labels go sr-only and the button is just a flush-cropped icon.
		'rounded-sm px-1 py-1 hover:bg-blue-50 active:bg-blue-100',
		danger && 'text-red-700 hover:bg-red-50 active:bg-red-100',
		attrs.inert && 'text-gray-600',
		klass
	]}
	{...attrs}>
	{@render children?.()}
</Button.Root>
