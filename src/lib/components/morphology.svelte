<script lang="ts">
	import type { Word } from './word.svelte'

	interface Props {
		word: Word
	}

	const { word }: Props = $props()
</script>

<div class="leading-none font-bold">
	{word?.lemma}
</div>
<div class="text-gray-700 italic">
	{#each ['pos', 'person', 'tense', 'mood', 'voice', 'number', 'gender', 'case', 'degree'] as morpho}
		{(word as any)?.[morpho]}{' '}
	{/each}
</div>
