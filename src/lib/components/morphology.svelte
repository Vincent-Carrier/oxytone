<script lang="ts">
	import type { Word } from './word.svelte';

	interface Props {
		word: Word;
	}

	const { word }: Props = $props();
</script>

<div class="min-h-16 border-t-1 border-gray-300 bg-gray-100 px-12 py-1">
	<div class="text-lg font-bold">
		{word?.lemma}
	</div>
	<div class="text-sm text-gray-700 italic">
		{#each ['pos', 'person', 'tense', 'mood', 'voice', 'number', 'gender', 'case', 'degree'] as morpho}
			{(word as any)?.[morpho]}{' '}
		{/each}
	</div>
</div>
