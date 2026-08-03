<script lang="ts">
	import { DropdownMenu } from 'bits-ui'
	import type { Snippet } from 'svelte'
	import Button from '$lib/components/button.svelte'
	import g from '$lib/global-state.svelte'
	import DisplayIcon from '~icons/heroicons/adjustments-horizontal-16-solid'

	// Only `verbs` and `colors` persist, matching the previous behaviour.
	function persist(key: string, value: boolean) {
		localStorage.setItem(key, JSON.stringify(value))
	}

	// Verse-only feature; greyed rather than hidden, since a menu has room and a
	// disabled row explains itself where a vanishing one does not.
	let hasLines = $derived(Boolean(g.content?.querySelector('.line')))

	const item = [
		'flex w-full cursor-pointer items-baseline gap-x-2 rounded-sm px-1 py-1 text-left',
		'data-highlighted:bg-blue-50 data-disabled:cursor-default data-disabled:text-gray-500'
	]
</script>

<DropdownMenu.Root>
	<DropdownMenu.Trigger>
		{#snippet child({ props })}
			<Button {...props}>
				<DisplayIcon />
				<span class="max-sm:sr-only">display</span>
			</Button>
		{/snippet}
	</DropdownMenu.Trigger>
	<DropdownMenu.Portal>
		<DropdownMenu.Content
			sideOffset={6}
			align="end"
			collisionPadding={8}
			class={['elevated z-50 w-72 bg-white p-1', 'font-sans text-sm text-gray-800']}>
			<DropdownMenu.CheckboxItem
				bind:checked={g.memMode}
				closeOnSelect={false}
				disabled={!hasLines}
				class={item}>
				{#snippet children({ checked })}
					{@render row(
						'memorize',
						checked,
						'Hides everything but the first letter of each line.'
					)}
				{/snippet}
			</DropdownMenu.CheckboxItem>

			<DropdownMenu.CheckboxItem bind:checked={g.analysis} closeOnSelect={false} class={item}>
				{#snippet children({ checked })}
					{@render row(
						'analysis',
						checked,
						"Marks the selected word's head, dependency bounds, and complements.",
						undefined,
						analysisDetail
					)}
				{/snippet}
			</DropdownMenu.CheckboxItem>

			<DropdownMenu.CheckboxItem
				bind:checked={g.verbs}
				onCheckedChange={v => persist('verbs', v)}
				closeOnSelect={false}
				class={item}>
				{#snippet children({ checked })}
					{@render row(
						'verbs',
						checked,
						'Shows each verb in bold; finite verbs bolder than infinitives and participles.'
					)}
				{/snippet}
			</DropdownMenu.CheckboxItem>

			<DropdownMenu.CheckboxItem
				bind:checked={g.colors}
				onCheckedChange={v => persist('colors', v)}
				closeOnSelect={false}
				class={item}>
				{#snippet children({ checked })}
					{@render row(
						'colors',
						checked,
						'Colours each word according to its case.',
						undefined,
						caseLegend
					)}
				{/snippet}
			</DropdownMenu.CheckboxItem>

			<DropdownMenu.CheckboxItem
				bind:checked={g.smoothBreathings}
				closeOnSelect={false}
				class={item}>
				{#snippet children({ checked })}
					{@render row(
						'breathings',
						checked,
						'Removes unnecessary smooth breathing marks.'
					)}
				{/snippet}
			</DropdownMenu.CheckboxItem>
		</DropdownMenu.Content>
	</DropdownMenu.Portal>
</DropdownMenu.Root>

{#snippet row(label: string, checked: boolean, help: string, extra?: Snippet, below?: Snippet)}
	<div class="flex w-full items-baseline gap-x-2">
		<span class="w-4 shrink-0 self-center text-blue-700">{checked ? '✓' : ''}</span>
		<div class="grow">
			<div class="font-sans-sc lowercase">{label}</div>
			<p class="text-xs text-gray-600">{help}</p>
			{@render below?.()}
		</div>
		{@render extra?.()}
	</div>
{/snippet}

<!-- Inline rather than behind a tooltip: this is the key to what the toggle
does, so it belongs next to it while you're deciding whether to turn it on. -->
{#snippet caseLegend()}
	<div class="font-sans-sc flex flex-wrap gap-x-2 pt-1 text-xs font-bold lowercase">
		<span class="text-nom-700">nominative</span>
		<span class="text-acc-700">accusative</span>
		<span class="text-dat-700">dative</span>
		<span class="text-gen-700">genitive</span>
		<span class="text-voc-700">vocative</span>
	</div>
{/snippet}

<!-- Inlined rather than nested in a tooltip: a hover-triggered popover inside a
menu item fights the item's own highlight and portals a second layer over the
menu. The markings are easier to recognise shown than described, so each one is
rendered in the style it takes on the page. -->
{#snippet analysisDetail()}
	<ul class="list-disc pt-1 pl-4 text-xs text-gray-600 marker:text-gray-400">
		<li>Its <span class="underline">syntactical head</span> is underlined.</li>
		<li>The 「bounds of its dependencies」 are bracketed.</li>
		<li>
			A verb's <span class="rounded-xs bg-blue-50 outline outline-blue-300">complements</span>
			are highlighted.
		</li>
	</ul>
	<!-- Only for machine-annotated texts: on a hand-annotated one the caveat is
	simply false, and it undersells the markings it sits beneath. -->
	{#if g.autoAnnotated}
		<p class="pt-1 text-xs text-gray-500 italic">
			<strong class="text-gray-700">N.B.</strong>: This text was annotated automatically.
			Accuracy may vary.
		</p>
	{/if}
{/snippet}
