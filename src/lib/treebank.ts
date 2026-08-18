import { headId, sentenceId, wordId } from '$lib/word'

// An index of the words on a page, built once when the treebank mounts.
//
// The dependency walks used to query the document: `directDependencies` ran
// `querySelectorAll('[sentence=…][head=…]')`, which is 3.7ms against the 33,000
// words of a Herodotus book, and `dependencies` recursed — re-scanning the whole
// page at every level of the subtree. Clicking one word cost 47ms. Built once,
// the same walks are hash lookups.
export type Treebank = {
	// Every word in reading order.
	words: WordElement[]
	byId: Map<number, WordElement>
	// The words depending on each head id, in reading order.
	childrenOf: Map<number, WordElement[]>
	bySentence: Map<string, WordElement[]>
}

// The index for a given body element, built on first use and reused after.
//
// Deliberately not held in reactive state and not built inside the treebank
// attachment: that attachment re-runs whenever the article's class changes
// (`g.verbs`, `g.colors`, `g.memMode`), so writing state from it that the click
// path then reads is a cycle — one that re-rendered `{@html data.treebank}` and
// tore the words out of the DOM mid-click.
//
// Keyed by the element itself through a WeakMap, so a new page gets a new index
// and the old one is collectable with the DOM it described.
const cache = new WeakMap<HTMLElement, Treebank>()

export function treebankFor(body: HTMLElement): Treebank {
	let tb = cache.get(body)
	if (!tb) {
		tb = indexTreebank(body)
		cache.set(body, tb)
	}
	return tb
}

export function indexTreebank(body: HTMLElement): Treebank {
	const words = [...body.querySelectorAll<WordElement>('span.w')]
	const byId = new Map<number, WordElement>()
	const childrenOf = new Map<number, WordElement[]>()
	const bySentence = new Map<string, WordElement[]>()

	for (const w of words) {
		byId.set(wordId(w), w)

		const head = headId(w)
		// A sentence root points at 0, or at a head outside the page; either way it
		// is nobody's dependency and only wastes a bucket.
		if (head) {
			const siblings = childrenOf.get(head)
			if (siblings) siblings.push(w)
			else childrenOf.set(head, [w])
		}

		const sentence = sentenceId(w)
		if (sentence) {
			const group = bySentence.get(sentence)
			if (group) group.push(w)
			else bySentence.set(sentence, [w])
		}
	}

	return { words, byId, childrenOf, bySentence }
}

// The words immediately depending on `root`, optionally only those whose relation
// starts with `rel` — relations carry suffixes, so "OBJ" also matches "OBJ_CO".
export function directDependencies(tb: Treebank, root: WordElement, rel?: string): WordElement[] {
	const children = tb.childrenOf.get(wordId(root)) ?? []
	if (!rel) return children
	return children.filter(w => w.getAttribute('relation')?.startsWith(rel))
}

// The whole dependency subtree under `root`, depth-first.
//
// Guarded against cycles: the ids come from the corpus, and a malformed sentence
// that makes a word its own ancestor would otherwise recurse until the stack
// gives out. The guard is per-walk, so a word legitimately reachable twice is
// still only visited once — which is what the callers want anyway.
export function dependencies(tb: Treebank, root: WordElement): WordElement[] {
	const out: WordElement[] = []
	const seen = new Set<WordElement>([root])
	const walk = (node: WordElement) => {
		for (const child of directDependencies(tb, node)) {
			if (seen.has(child)) continue
			seen.add(child)
			out.push(child)
			walk(child)
		}
	}
	walk(root)
	return out
}
