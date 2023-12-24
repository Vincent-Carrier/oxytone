import { some } from "lodash-es"
import tippy from "tippy.js"
import flagsToString from "./flagsToString"

function highlightGroup(role: string, className: string) {
	let hlGroup: HTMLSpanElement[] = []
	document.querySelectorAll("[data-head]").forEach(el => {
		el.addEventListener("mouseenter", ev => {
			const span = ev.target as HTMLSpanElement
			span.classList.add("hovered")
			if (some(["PRED", "ADV", "ATR"], role => span.dataset.role?.startsWith(role))) {
				hlGroup = [...deps(span, role)]
				hlGroup.forEach(el => el.classList.add("hl", className))
			}
		})
		el.addEventListener("mouseleave", ev => {
			const span = ev.target as HTMLSpanElement
			span.classList.remove("hovered")
			hlGroup.forEach(el => el.classList.remove("hl", className))
		})
	})
}

highlightGroup("SBJ", "subj")
highlightGroup("OBJ", "dobj")
// highlightGroup("OBJ", "iobj");

function* deps(word: HTMLSpanElement, role?: string): Iterable<HTMLSpanElement> {
	const ds: HTMLSpanElement[] = Array.from(
		word.closest(".sentence")!.querySelectorAll(`[data-head="${word.dataset.id}"]`)
	)
	for (let d of ds) {
		if (d.role == "COORD") {
			yield* deps(d, role)
		}
		if (role ? d.dataset.role?.startsWith(role) : true) {
			yield d
			yield* deps(d)
		}
	}
}

tippy("[data-lemma]", {
	trigger: "click",
	content: span => {
		const { dataset: d } = span
		return `<a class="lemma" style="color: white;" href="https://logeion.uchicago.edu/${
			d.lemma
		}" target="_blank">${d.lemma}</a>
				${d.def ? `<div class="def">${d.def}</div>` : ""}
    			${d.flags ? `<div class="flags">${flagsToString(d.flags)}</div>` : ""}`
	},
	allowHTML: true,
	interactive: true,
	appendTo: document.body,
})
