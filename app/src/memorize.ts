import { wordsInView } from '@/_selectWords.js'
import { $id } from '@/lib/dom.js'

function toggleWord(show: boolean, $el: HTMLSpanElement) {
	const first = $el.innerText[0],
		rest = $el.innerText.slice(1)
	if (show) $el.innerHTML = $el.innerText
	else $el.innerHTML = `<span>${first}</span><span style="color: transparent">${rest}</span>`
}

let visible = true,
	$words: HTMLElement[] = []
$id('memorize').onclick = function (ev) {
	visible = !visible
	if ($words.length) {
		$words.forEach($w => toggleWord(true, $w))
		$words = []
	} else {
		$words = Array.from(wordsInView())
		$words.forEach($w => toggleWord(false, $w))
	}
}
