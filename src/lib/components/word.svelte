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
			clearComplements = () => {};

			get selected() {
				return this.classList.contains('selected');
			}
			set selected(val: boolean) {
				if (val) {
					this.defined = false;
					this.classList.add('selected');
				} else {
					this.classList.remove('selected');
				}
			}

			get defined() {
				return this.classList.contains('defined');
			}
			set defined(val: boolean) {
				if (val) {
					this.selected = false;
					this.classList.add('defined');
				} else {
					this.clearComplements();
					this.classList.remove('defined');
				}
			}

			*sentenceWords(this: Word) {
				yield* document.querySelectorAll(`#treebank [sentence="${this.sentence}"]`);
			}

			*directDependencies(this: Word, rel: string | undefined = undefined): Iterable<Word> {
				let words = document.querySelectorAll<Word>(
					`#treebank [sentence="${this.sentence}"][head="${this.id}"]`
				);
				for (let w of words) {
					if (rel && w.relation?.startsWith(rel)) yield w;
					else if (!rel) yield w;
				}
			}

			*dependencies(this: Word): Iterable<Word> {
				for (let d of this.directDependencies()) {
					yield d;
					yield* d.dependencies();
				}
			}

			*complement(this: Word, rel: string): Iterable<Word> {
				yield* this.directDependencies(rel);
				for (let coord of this.directDependencies('COORD')) {
					yield* coord.directDependencies(rel);
				}
			}

			highlightComplements(this: Word) {
				let complements: { w: Word; class: string }[] = [];
				for (let w of this.complement('OBJ')) {
					complements.push({
						w,
						// @ts-ignore
						class: { 'acc.': 'acc-obj', 'dat.': 'dat-obj', 'gen.': 'gen-obj' }[w.case ?? 'acc.']
					});
				}
				for (let w of this.complement('SBJ')) complements.push({ w, class: 'sbj' });
				for (let c of complements) c.w.classList.add(c.class);
				this.clearComplements = () => {
					for (let c of complements) c.w.classList.remove(c.class);
				};
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

	function highlightHyperbatons() {
		if (
			!['verb', 'punct.'].includes(w.pos!) &&
			!w.relation?.startsWith('COORD') &&
			!w.relation?.startsWith('Aux')
		) {
			let dist = Math.abs(w.head - w.id);
			if (dist > 2) {
				if (dist < 5) w.classList.add('bg-gray-100');
				else if (dist < 9) w.classList.add('bg-gray-200');
			}
		}
	}
</script>

{children}
