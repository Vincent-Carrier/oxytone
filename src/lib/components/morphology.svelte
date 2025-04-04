<script lang="ts">
	import { slide } from 'svelte/transition'
	import type { Word } from './word.svelte'

	interface Props {
		word: Word
	}

	const { word }: Props = $props()
</script>

<div
	transition:slide
	class="flex items-baseline gap-x-2 border-t-1 border-gray-300 bg-gray-100 py-1 pr-2 pl-[var(--padded-margin-w)] text-xs">
	<div class="leading-none font-bold">
		{word?.lemma}
	</div>
	<div class="text-gray-700 italic">
		{#each ['pos', 'person', 'tense', 'mood', 'voice', 'number', 'gender', 'case', 'degree'] as morpho}
			{(word as any)?.[morpho]}{' '}
		{/each}
	</div>
</div>
