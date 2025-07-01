<script lang="ts">
	import Button from '$/lib/components/button.svelte'
	import '$lib/components/word.svelte'
	import { onMount } from 'svelte'
	import type { PageProps } from './$types'
	import './styles.css'

	let { data }: PageProps = $props()

	let expanded = $state(false)

	function expandAll() {
		for (let details of document.querySelectorAll<HTMLDetailsElement>('details')) {
			details.open = !expanded
		}
		expanded = !expanded
	}
</script>

<svelte:head>
	<title>Oxytone</title>
</svelte:head>

<img
	class="mx-auto w-full max-w-4xl px-4 grayscale"
	srcset="/greek_heroes@0.5x.webp 1x, /greek_heroes.webp 2x"
	src="/greek_heroes.webp"
	alt="" />
<hgroup class="font-sc -mt-16 text-center">
	<h1
		class="relative mx-auto bg-linear-to-t from-white from-50% to-transparent text-6xl text-gray-900">
		oxy<span class="tracking-tighter">tone</span>
	</h1>
	<p class="text-xl text-gray-800">the bleeding edge of ancient language</p>
</hgroup>
<main class="mx-auto mt-4 mb-12 max-w-4xl px-8 text-gray-800">
	<div
		class="card pointer-events-auto mt-8 mb-24 bg-gray-50 p-4 pt-2 text-gray-800 md:ml-24 lg:mx-auto lg:max-w-[60ch]">
		<h2 class="font-sans-sc font-bold lowercase">About</h2>
		<p>
			Oxytone is a web application that aims to provide a comprehensive reading environment for
			reading Ancient Greek literature. It offers a wide range of features and tools to help users
			improve their language skills and gain a deeper understanding of Ancient Greek. Source code
			and more details can be found over on <a
				href="https://github.com/Vincent-Carrier/oxytone"
				target="_blank"
				class="text-blue-700 underline decoration-2">GitHub</a
			>.
		</p>
	</div>

	<div class="ml-24 flex items-baseline">
		<p class="text-right max-md:hidden">
			<strong>Pro Tip: </strong> Use Cmd-F / Ctrl-F to search through the corpus.
		</p>
		<Button class="pointer-events-auto mb-2 ml-auto" onclick={expandAll}>
			{expanded ? 'Collapse all' : 'Expand all'}
		</Button>
	</div>
	{@html data.body}
</main>
