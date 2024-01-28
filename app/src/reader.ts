import '@ungap/custom-elements/es.js'

import '@/components/bottomBar.js'
import '@/components/flashcardsButton.js'
import '@/components/memorizeButton.js'
import '@/components/token.js'
import { $ } from '@/lib/dom.js'

const $treebank = $('article.treebank')

addEventListener('selectionchange', () => {
	const selection = document.getSelection()
	if (!selection!.isCollapsed) $treebank.classList.add('selection')
	else $treebank.classList.remove('selection')
})
