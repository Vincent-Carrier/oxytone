import type { ChatMessage } from './providers'
import type { SelectionContext } from '$lib/selection'

// Only the surface Greek is sent. Morphology, lemmas and dependency relations
// are deliberately withheld even though the treebank carries them: supplying a
// parse biases the model toward it, and a wrong parse then produces a
// confidently wrong translation. Do not "enrich" this with treebank attributes.
// The output renders as plain text in a small popover, so any Markdown the model
// emits shows up as literal asterisks. The wrappers named below are ones models
// add by default; naming each one specifically works where "be concise" does not.
const SYSTEM = [
	'You are helping a reader of Ancient Greek.',
	'Answer concisely and in English.',
	'Write Greek in the original script, never transliterated.',
	'Where the Greek is genuinely ambiguous, say so briefly rather than inventing certainty.',
	'Do not repeat the passage back unless asked.',
	'Give only the answer itself, as plain prose.',
	'Never add a heading, label, or preamble such as "Translation:".',
	'Never wrap the answer in quotation marks.',
	'Never add a source citation naming the work, book, or line numbers.',
	'Never use Markdown formatting of any kind.'
].join(' ')

const MAX_CONTEXT = 4000

export function translatePrompt(ctx: SelectionContext): ChatMessage[] {
	return build(
		ctx,
		'Translate the text in <selection> into fluent English.' +
			' Use <context> only to disambiguate; do not translate it.'
	)
}

export function askPrompt(ctx: SelectionContext, question: string): ChatMessage[] {
	return build(ctx, question)
}

function build(ctx: SelectionContext, task: string): ChatMessage[] {
	return [
		{ role: 'system', content: SYSTEM },
		{ role: 'user', content: `${passage(ctx)}\n\n${task}` }
	]
}

// The Greek the task is about, as a <selection> and the surrounding <context>.
// Tags are safe delimiters here in a way that punctuation is not: Greek text can
// contain almost any punctuation mark, but never angle-bracketed tags.
function passage(ctx: SelectionContext): string {
	const selection = `<selection>\n${ctx.selectedText}\n</selection>`

	// When the reader selected a whole sentence the two are identical, and
	// repeating it invites the model to translate the passage twice.
	if (!ctx.contextText || ctx.contextText === ctx.selectedText) return selection

	return `<context>\n${truncate(ctx.contextText)}\n</context>\n\n${selection}`
}

// A long period plus its neighbours can grow unexpectedly large. Cuts on a word
// boundary, and only ever the context — the selection is never truncated.
function truncate(text: string): string {
	if (text.length <= MAX_CONTEXT) return text
	return text.slice(0, MAX_CONTEXT).replace(/\S+$/, '').trim() + ' …'
}
