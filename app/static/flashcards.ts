import ky from 'ky'
import flagsToString from './flagsToString'

const $def = document.getElementById('def')!
const $flags = document.getElementById('flags')!
const $lemma = document.getElementById('lemma')!

const $selectedCount = document.getElementById('selected-count')!

let selectedCount = 0

document.querySelectorAll('[data-lemma]').forEach(el => {
	el.addEventListener('mouseenter', ev => {
		const { dataset: d } = ev.target as HTMLSpanElement
		const flags = flagsToString(d.flags)
		if (flags == 'punct.') return
		$def.innerHTML = d.def ?? ''
		$flags.innerHTML = flags
		$lemma.innerHTML = d.lemma ?? ''
	})
	el.addEventListener('mouseleave', ev => {
		const span = ev.target as HTMLSpanElement
	})

	el.addEventListener('mousedown', ev => {
		const span = ev.target as HTMLSpanElement
		span.classList.toggle('selected')
		selectedCount = document.querySelectorAll('.selected').length
		$selectedCount.innerText = selectedCount > 0 ? `${selectedCount} selected` : ''
	})
})

function $$<E extends Element>(selector: string) {
	return Array.from(document.querySelectorAll<E>(selector))
}

async function exportFlashcards() {
	const words = $$<HTMLSpanElement>('.selected').map(el => ({
		lemma: el.dataset.lemma,
		definition: el.dataset.def,
	}))
	const res = await ky.post('/flashcards', { json: { words } })
}
document.getElementById('export')!.onclick = exportFlashcards
