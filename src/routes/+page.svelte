<script lang="ts">
	import Button from '$/lib/components/button.svelte'
	import type { PageProps } from './$types'
	import './styles.css'

	let { data }: PageProps = $props()

	let expanded = $state(false)

	const link = 'text-blue-700 underline decoration-2'
	const ccbysa = 'https://creativecommons.org/licenses/by-sa/4.0/'
	const ccbyncsa = 'https://creativecommons.org/licenses/by-nc-sa/4.0/'

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
	srcset="/greek_heroes@0.5x.webp 864w, /greek_heroes.webp 1728w"
	sizes="(min-width: 896px) 864px, 100vw"
	src="/greek_heroes@0.5x.webp"
	width="864"
	height="434"
	fetchpriority="high"
	decoding="async"
	alt="" />
<hgroup class="font-sc -mt-16 text-center">
	<h1
		class="relative mx-auto bg-linear-to-t from-white from-50% to-transparent text-6xl text-gray-900">
		oxy<span class="tracking-tighter">tone</span>
	</h1>
</hgroup>
<main class="mx-auto mt-4 mb-12 max-w-4xl px-8 text-gray-800">
	<div
		class="card pointer-events-auto mt-8 mb-24 bg-gray-50 p-4 pt-2 text-gray-800 md:ml-24 lg:mx-auto lg:max-w-[60ch]">
		<h2 class="font-sans-sc font-bold lowercase">About</h2>
		<p>
			Oxytone is a web application that aims to provide a comprehensive reading environment
			for reading Ancient Greek literature. It offers a wide range of features and tools to
			help users improve their language skills and gain a deeper understanding of Ancient
			Greek. Source code and more details can be found over on <a
				href="https://github.com/Vincent-Carrier/oxytone"
				target="_blank"
				class={link}>GitHub</a
			>. The project is currently
			<a
				href="https://github.com/sponsors/Vincent-Carrier"
				target="_blank"
				class="text-blue-700 underline decoration-2">looking for sponsors</a
			>.
		</p>

		<h2 class="font-sans-sc mt-4 font-bold lowercase">Sources</h2>
		<p>
			Oxytone is built entirely on freely licensed scholarship, and is grateful for it. Each
			dataset below is used under its own terms; follow a link for the full license.
		</p>
		<dl class="mt-2 space-y-2">
			<div>
				<dt class="font-bold">
					<a href="https://github.com/alekkeersmaekers/glaux" target="_blank" class={link}
						>GLAUx</a>
				</dt>
				<dd>
					The treebank corpus, by Alek Keersmaekers and others &mdash; see
					<a
						href="https://aclanthology.org/2021.lchange-1.6/"
						target="_blank"
						class={link}>Keersmaekers (2021)</a
					>. It compiles several treebanks whose licenses differ, most under
					<a href={ccbysa} target="_blank" class={link}>CC BY-SA</a>, some under
					<a href={ccbyncsa} target="_blank" class={link}>CC BY-NC-SA</a>; the corpus
					metadata records the license of each source text.
				</dd>
			</div>
			<div>
				<dt class="font-bold">
					<a
						href="https://github.com/gcelano/LSJ_GreekUnicode"
						target="_blank"
						class={link}>LSJ</a>
				</dt>
				<dd>
					Liddell &amp; Scott&rsquo;s <i>Greek&ndash;English Lexicon</i> in Giuseppe
					Celano&rsquo;s Unicode edition, under
					<a href={ccbyncsa} target="_blank" class={link}>CC BY-NC-SA</a>.
				</dd>
			</div>
			<div>
				<dt class="font-bold">
					<a href="https://www.perseus.tufts.edu/" target="_blank" class={link}
						>Perseus Digital Library</a>
				</dt>
				<dd>
					The Greek texts and English translations, under
					<a href={ccbysa} target="_blank" class={link}>CC BY-SA 4.0</a>.
				</dd>
			</div>
			<div>
				<dt class="font-bold">
					<a
						href="https://kaikki.org/dictionary/Ancient%20Greek/"
						target="_blank"
						class={link}>Wiktionary</a>
				</dt>
				<dd>
					Short definitions, extracted by
					<a href="https://kaikki.org/" target="_blank" class={link}>Kaikki.org</a> from
					English Wiktionary, under
					<a href={ccbysa} target="_blank" class={link}>CC BY-SA 4.0</a>.
				</dd>
			</div>
		</dl>
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
