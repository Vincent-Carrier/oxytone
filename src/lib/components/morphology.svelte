<script lang="ts">
	interface Props {
		word: WordElement
	}

	const { word: w }: Props = $props()
	let nounMorpho = $derived(
		[
			w.person?.replace(/st|nd|rd/, '<sup class="-top-0.5">$&</sup> p.'),
			w.gender,
			w.case,
			w.number,
			w.degree
		].filter(Boolean)
	)
	let verbMorpho = $derived([w.tense, w.mood, w.voice].filter(Boolean))
	let morpho = $derived([nounMorpho.join(' '), verbMorpho.join(' ')].filter(Boolean).join(', '))
</script>

<div class="font-bold">{w.lemma}</div>
<div class="morphology text-gray-700 italic">
	{w.pos}
	{#if morpho}
		<span class="px-1">—</span>
	{/if}
	{@html morpho}
</div>
