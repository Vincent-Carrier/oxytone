<script lang="ts">
	import { DropdownMenu } from 'bits-ui'
	import type { Snippet } from 'svelte'
	import Button from '$lib/components/button.svelte'
	import g, { analysisChosen } from '$lib/global-state.svelte'
	import DisplayIcon from '~icons/heroicons/adjustments-horizontal-16-solid'

	// These toggles persist across reloads; the write lives next to the state in
	// global-state.svelte.ts, since a value bound with `bind:checked` never
	// reaches an `onCheckedChange` callback here.
	//
	// `analysis` additionally records *that* it was chosen, so the read route
	// stops applying its per-text default. onSelect rather than an effect on the
	// value: only a real interaction should count, and the route assigns to
	// g.analysis itself.

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

			<DropdownMenu.CheckboxItem
				bind:checked={g.analysis}
				onSelect={() => (analysisChosen.current = true)}
				closeOnSelect={false}
				class={item}>
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

			<DropdownMenu.CheckboxItem bind:checked={g.verbs} closeOnSelect={false} class={item}>
				{#snippet children({ checked })}
					{@render row(
						'verbs',
						checked,
						'Shows each verb in bold; finite verbs bolder than infinitives and participles.'
					)}
				{/snippet}
			</DropdownMenu.CheckboxItem>

			<DropdownMenu.CheckboxItem bind:checked={g.colors} closeOnSelect={false} class={item}>
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
	<!-- One line, not wrapped: the five cases read as a single legend, and a
	second row makes the menu item look like it has grown a paragraph. The names
	are abbreviated to the forms a reader already knows from a grammar, which is
	what lets them fit. -->
	<div
		class="font-sans-sc flex justify-between gap-x-1 pt-1 text-xs font-bold whitespace-nowrap lowercase">
		<span class="text-nom-700">nom.</span>
		<span class="text-acc-700">acc.</span>
		<span class="text-dat-700">dat.</span>
		<span class="text-gen-700">gen.</span>
		<span class="text-voc-700">voc.</span>
	</div>
{/snippet}

<!-- Inlined rather than nested in a tooltip: a hover-triggered popover inside a
menu item fights the item's own highlight and portals a second layer over the
menu. The markings are easier to recognise shown than described, so each one is
rendered in the style it takes on the page. -->
{#snippet analysisDetail()}
	<!-- list-inside rather than the default outside marker: it keeps the bullets
	flush with the help text above instead of indenting the list as a block. -->
	<ul class="list-inside list-disc pt-1 text-xs text-gray-600 marker:text-gray-400">
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
