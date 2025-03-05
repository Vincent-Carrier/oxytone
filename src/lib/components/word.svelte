<svelte:options
	customElement={{
		tag: 'ox-w',
		shadow: 'none',
		extend,
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
	type WordProps = {
		id: number;
		head: number;
		sentence: number;
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
		children: string;
	};

	function extend(constructor: new () => HTMLElement) {
		return class extends constructor {
			selected = false;
			toggleSelected() {
				this.selected = !this.selected;
				this.classList.toggle('selected');
			}
		};
	}

	export type Word = InstanceType<ReturnType<typeof extend>> & WordProps;
</script>

<script lang="ts">
	import './word.css';
	let { children } = $props();
	let w = $host() as Word;
	w.onclick = () => {
		w.dispatchEvent(new CustomEvent('w-click', { bubbles: true }));
	};

	// if (
	// 	!['verb', 'punct.'].includes(w.pos!) &&
	// 	!w.relation?.startsWith('COORD') &&
	// 	!w.relation?.startsWith('Aux')
	// ) {
	// 	let dist = Math.abs(w.head - w.id);
	// 	if (dist > 2) {
	// 		if (dist < 5) w.classList.add('bg-gray-100');
	// 		else if (dist < 9) w.classList.add('bg-gray-200');
	// 	}
	// }
</script>

{children}
