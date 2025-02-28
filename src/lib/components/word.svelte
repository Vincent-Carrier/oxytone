<svelte:options
	customElement={{
		tag: 'ox-w',
		shadow: 'none',
		props: {
			id: { type: 'Number' },
			head: { type: 'Number' },
			sentence: { type: 'Number' },
			lemma: {},
			relation: {},
			pos: {},
			person: {},
			tense: {},
			mood: {},
			voice: {},
			number: {},
			gender: {},
			case: {},
			degree: {}
		}
	}}
/>

<script module lang="ts">
	export type Word = {
		selected?: boolean;
		id?: number;
		head?: number;
		sentence?: number;
		lemma?: string;
		relation?: string;
		pos?: string;
		person?: string;
		tense?: string;
		mood?: string;
		voice?: string;
		number?: string;
		gender?: string;
		case?: string;
		degree?: string;
		children?: string;
	} & HTMLElement;
</script>

<script lang="ts">
	let { children } = $props();
	$host().onclick = () => {
		$host().dispatchEvent(new CustomEvent('w-click', { bubbles: true }));
	};
</script>

{children}
