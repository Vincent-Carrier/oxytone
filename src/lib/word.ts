interface Props {
	id: number
	head: number
	sentence: number
	lemma?: string
	relation?: string
	pos?: string
	person?: string
	tense?: string
	mood?: string
	voice?: string
	number?: string
	gender?: string
	case?: string
	degree?: string
	children: string
	clear: (() => void)[]
}
export type WordElement = HTMLElement & Props
