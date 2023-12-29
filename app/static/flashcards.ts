import ky from 'ky'
import flagsToString from './flagsToString'

const $def = document.getElementById('def')!
const $flags = document.getElementById('flags')!
const $lemma = document.getElementById('lemma')!

const $export = document.getElementById('export')! as HTMLButtonElement
const $selectedCount = document.getElementById('selected-count')!

let selectedCount = 0

document.querySelectorAll('[data-lemma]').forEach(el => {
	el.addEventListener('mouseenter', ev => {
		const el = ev.target as HTMLSpanElement
		const { dataset: d } = el
		if (el.classList.contains('punct')) return
		$def.innerHTML = d.def ?? ''
		$flags.innerHTML = flagsToString(d.flags)
		$lemma.innerHTML = d.lemma ?? ''
	})
	el.addEventListener('mouseleave', ev => {
		const span = ev.target as HTMLSpanElement
		// TODO
	})

	el.addEventListener('mousedown', ev => {
		const span = ev.target as HTMLSpanElement
		span.classList.toggle('selected')
		selectedCount = document.querySelectorAll('.selected').length
		$selectedCount.innerText = selectedCount > 0 ? `${selectedCount} selected` : ''
		$export.disabled = selectedCount <= 0
	})
})

function $$<E extends Element>(selector: string) {
	return Array.from(document.querySelectorAll<E>(selector))
}

$export.onclick = async function exportFlashcards() {
	const words = $$<HTMLSpanElement>('.selected').map(el => ({
		lemma: el.dataset.lemma,
		definition: el.dataset.def ?? '',
	}))
	const title = document.getElementById('title')!.innerText
	const res: any = await ky.post('/flashcards', { json: { title, words } }).json()
	window.location.href = `/flashcards/${res.filename}`
}
