<script lang="ts">
	import { morphology } from '$lib/word'

	interface Props {
		word: WordElement
	}

	const { word }: Props = $props()
	// Read from the element's attributes in one pass: words are plain elements,
	// not components, so there are no properties to reach for.
	let m = $derived(morphology(word))
	// "1" -> "1<sup>st</sup> p." Only person takes the ordinal, so it is rendered
	// apart from the rest and put back at the front.
	let person = $derived(m.person?.replace(/st|nd|rd/, '<sup class="-top-0.5">$&</sup> p.'))
	let nounMorpho = $derived([person, ...m.noun].filter(Boolean))
	let morpho = $derived([nounMorpho.join(' '), m.verb.join(' ')].filter(Boolean).join(', '))
</script>

<div class="font-bold">{m.lemma}</div>
<div class="morphology text-gray-700 italic">
	{m.pos}
	{#if morpho}
		<span class="px-1">—</span>
	{/if}
	{@html morpho}
</div>
