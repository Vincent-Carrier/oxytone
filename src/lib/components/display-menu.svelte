<script lang="ts">
	import { DropdownMenu } from 'bits-ui'
	import type { Snippet } from 'svelte'
	import Button from '$lib/components/button.svelte'
	import Tooltip from '$lib/components/tooltip.svelte'
	import g from '$lib/global-state.svelte'
	import DisplayIcon from '~icons/heroicons/adjustments-horizontal-16-solid'
	import HelpIcon from '~icons/heroicons/question-mark-circle-16-solid'

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
						analysisHelp
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
					{@render row('colors', checked, 'Colours each word according to its case.')}
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

{#snippet row(label: string, checked: boolean, help: string, extra?: Snippet)}
	<div class="flex w-full items-baseline gap-x-2">
		<span class="w-4 shrink-0 self-center text-blue-700">{checked ? '✓' : ''}</span>
		<div class="grow">
			<div class="font-sans-sc lowercase">{label}</div>
			<p class="text-xs text-gray-600">{help}</p>
		</div>
		{@render extra?.()}
	</div>
{/snippet}

<!-- The one help text too long for an inline row, kept as a tooltip. -->
{#snippet analysisHelp()}
	<Tooltip class="w-56">
		<HelpIcon class="shrink-0 self-center text-gray-500" />
		{#snippet tooltip()}
			<div>
				<p>If enabled, whenever a word is selected:</p>
				<ol>
					<li>Its <span class="underline">syntactical head</span> is underlined.</li>
					<li>The 「bounds of its dependencies」 are shown within brackets.</li>
					<li>
						If a verb, its <span class="rounded-xs bg-blue-50 outline outline-blue-300"
							>complements</span> will be highlighted.
					</li>
				</ol>
				{#if !g.analysis}
					<p class="mt-2 text-gray-500 italic">
						<strong class="text-gray-700">N.B.</strong>: This text was annotated
						automatically. Accuracy may vary.
					</p>
				{/if}
			</div>
		{/snippet}
	</Tooltip>
{/snippet}
