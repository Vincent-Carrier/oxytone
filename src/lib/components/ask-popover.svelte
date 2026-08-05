<script lang="ts">
	import { Popover } from 'bits-ui'
	import { page } from '$app/state'
	import Button from '$lib/components/button.svelte'
	import g from '$lib/global-state.svelte'
	import { readSelection, type SelectionContext } from '$lib/selection'
	import { describeError } from '$lib/llm/errors'
	import { askPrompt, translatePrompt } from '$lib/llm/prompt'
	import type { ChatMessage } from '$lib/llm/providers'
	import settings, { configured } from '$lib/llm/settings.svelte'
	import { streamChat } from '$lib/llm/stream'
	import TranslateIcon from '~icons/heroicons/language-16-solid'
	import SendIcon from '~icons/heroicons/paper-airplane-16-solid'
	import StopIcon from '~icons/heroicons/stop-16-solid'
	import WarningIcon from '~icons/heroicons/exclamation-triangle-16-solid'
	import CloseIcon from '~icons/heroicons/x-mark-16-solid'
	import DragIcon from '~icons/heroicons/bars-2-16-solid'

	let open = $state(false)
	let ctx = $state<SelectionContext | null>(null)
	let rect = $state<DOMRect | null>(null)
	let output = $state('')
	let error = $state('')
	let status = $state<'idle' | 'streaming' | 'done' | 'error'>('idle')
	let question = $state('')
	let history = $state<ChatMessage[]>([])
	let controller: AbortController | null = null

	// Once dragged, the popover stops being anchor-positioned and becomes a fixed
	// panel at `moved`. Keeping floating-ui in charge doesn't work: it re-runs
	// flip/shift whenever the content resizes — which is exactly what happens as a
	// response streams in — and would snap a dragged panel back over the text.
	let moved = $state<{ x: number; y: number } | null>(null)

	// Measured rather than hardcoded so the panel stays put if the nav's height
	// changes. Falls back to a sensible guess before the nav is in the DOM.
	function navBottom() {
		return document.querySelector('nav')?.getBoundingClientRect().bottom ?? 32
	}

	// A snapshotted rect, not the live Range: clicking into the input below clears
	// the document selection, which would collapse a Range anchor to a zero-size
	// box at the origin and throw the popover across the screen.
	//
	// Horizontally this tracks the selection, so the panel still reads as attached
	// to the words it's about. Vertically it's pinned just under the sticky nav:
	// anchoring to the selection would start the panel wherever in the page you
	// happened to be reading, leaving a long answer only a sliver of room before
	// it hit the viewport floor and had to scroll internally.
	let anchor = $derived(
		rect
			? {
					getBoundingClientRect: () => {
						// Enough clearance that the panel reads as floating over the text
						// rather than hanging off the nav's bottom border.
						const top = navBottom() + 16
						return new DOMRect(rect!.x, top, rect!.width, 0)
					}
				}
			: undefined
	)

	function startDrag(event: PointerEvent) {
		// Let the close button and the follow-up input keep their own behaviour.
		if ((event.target as HTMLElement).closest('button, input')) return
		event.preventDefault()
		event.stopPropagation()

		// Freeze wherever floating-ui currently has it, then move from there.
		const box = (event.currentTarget as HTMLElement).closest('[data-oxy-panel]')!
		const start = box.getBoundingClientRect()
		const origin = { x: event.clientX, y: event.clientY }
		moved ??= { x: start.x, y: start.y }
		const from = { ...moved }

		const move = (e: PointerEvent) => {
			// Clamp so the panel can never be dragged fully off screen.
			const x = from.x + (e.clientX - origin.x)
			const y = from.y + (e.clientY - origin.y)
			moved = {
				x: Math.min(Math.max(x, 8 - start.width + 48), innerWidth - 48),
				y: Math.min(Math.max(y, 8), innerHeight - 40)
			}
		}
		const up = () => {
			removeEventListener('pointermove', move)
			removeEventListener('pointerup', up)
		}
		addEventListener('pointermove', move)
		addEventListener('pointerup', up)
	}

	export function show() {
		// Word-clicking builds a flashcard deck in this mode; a popover on top of
		// that flow is just noise.
		if (g.selecting) return

		// Without a provider and key there's nothing the panel can do, so it stays
		// out of the way of ordinary reading rather than interrupting every
		// selection to advertise a setting.
		if (!configured()) return

		let next = readSelection()
		if (!next) return

		abort()
		output = ''
		error = ''
		status = 'idle'
		question = ''
		history = []
		ctx = next
		// Only the horizontal position comes from the selection (the anchor pins
		// the top to just below the nav), and even that is frozen once open:
		// extending a selection would otherwise slide the panel sideways with it,
		// which reads as it running away from the cursor. The word count next to
		// the translate button is what signals the selection changed.
		rect = open && rect ? rect : next.rect
		if (!open) moved = null
		open = true
	}

	function abort() {
		controller?.abort()
		controller = null
	}

	function close() {
		abort()
		open = false
	}

	async function run(messages: ChatMessage[]) {
		abort()
		controller = new AbortController()
		let signal = controller.signal

		output = ''
		error = ''
		status = 'streaming'

		try {
			for await (let delta of streamChat(messages, settings, signal)) {
				output += delta
			}
			if (signal.aborted) return
			history = [...messages, { role: 'assistant', content: output }]
			status = 'done'
		} catch (e) {
			// An abort is a deliberate user action, not a failure to report.
			if (signal.aborted || (e as Error)?.name === 'AbortError') return
			error = describeError(e)
			status = 'error'
		}
	}

	function translate() {
		if (ctx) run(translatePrompt(ctx))
	}

	function ask() {
		let q = question.trim()
		if (!q || !ctx) return
		question = ''
		// Follow-ups continue the thread; the first question starts one.
		run(history.length > 0 ? [...history, { role: 'user', content: q }] : askPrompt(ctx, q))
	}

	function onkeydown(event: KeyboardEvent) {
		if (event.key === 'Enter') {
			event.preventDefault()
			ask()
		}
	}

	// Navigating away closes the popover and stops any in-flight request. Only a
	// genuine change may close it — running `close()` unconditionally would undo
	// every `show()` on the effect's next run.
	let seen = page.url.pathname
	$effect(() => {
		const path = page.url.pathname
		if (path === seen) return
		seen = path
		close()
	})
</script>

<Popover.Root bind:open onOpenChange={o => !o && abort()}>
	<Popover.Portal>
		<Popover.Content
			customAnchor={anchor}
			side="right"
			align="start"
			sideOffset={12}
			collisionPadding={8}
			interactOutsideBehavior="close"
			trapFocus={false}
			preventOverflowTextSelection={false}
			class={[
				'elevated z-50 flex w-96 max-w-[90vw] flex-col gap-y-2 bg-white p-2',
				'font-sans text-sm text-gray-800',
				// Cap to the space floating-ui measured between the anchor and the
				// viewport edge, so a long answer scrolls instead of overflowing off
				// screen. The var is unset until the first measurement, hence the
				// fallback. min-h-0 lets the flex child below actually shrink.
				// The cap is generous because the anchor sits just below the nav, so
				// that measured space is nearly the whole viewport.
				// Once dragged the panel is fixed-positioned, so fall back to a plain
				// viewport cap — the floating-ui var no longer tracks it.
				moved
					? 'max-h-[85vh] min-h-0'
					: 'max-h-[min(var(--bits-floating-available-height,85vh),85vh)] min-h-0'
			]}>
			<!-- The `child` snippet is required for dragging: Popover.Content merges
			its own `style` and drops any we pass as a prop, so a `style` attribute set
			above never reaches the DOM. Here we own the final element. The wrapper's
			transform is also cleared while dragging — a transformed ancestor becomes
			the containing block for `position: fixed`, which would make our viewport
			coordinates resolve against the wrapper instead. -->
			{#snippet child({ props, wrapperProps })}
				{@const dragged = moved}
				{@const wrapStyle = (wrapperProps as { style?: string }).style ?? ''}
				{@const panelStyle = (props as { style?: string }).style ?? ''}
				<div
					{...wrapperProps}
					style={dragged ? 'position:static;transform:none;min-width:0' : wrapStyle}>
					<div
						{...props}
						data-oxy-panel
						style={dragged
							? `${panelStyle};position:fixed;left:${dragged.x}px;top:${dragged.y}px;margin:0`
							: panelStyle}>
						<!-- Doubles as the drag handle. -->
						<!-- svelte-ignore a11y_no_static_element_interactions -->
						<div
							onpointerdown={startDrag}
							class="flex shrink-0 cursor-grab items-baseline gap-x-2 active:cursor-grabbing">
							<DragIcon class="self-center text-gray-400" />
							<div class="grow"></div>
							<Button
								onclick={close}
								class="shrink-0 text-gray-600 hover:bg-gray-100"
								aria-label="close">
								<CloseIcon />
							</Button>
						</div>

						<!-- The same skeleton the definition panel uses, minus its 150ms
				delay: an LLM's first token takes seconds, so there is nothing to
				debounce and holding it back would leave the panel looking dead.
				It only covers the gap before any text arrives — once the stream
				produces a token the real answer takes over. -->
						{#if status === 'streaming' && !output}
							<div
								class="skeleton-immediate min-h-0 grow"
								aria-busy="true"
								aria-label="Waiting for a response">
								<div class="skeleton-lines">
									<div class="skeleton-line w-11/12"></div>
									<div class="skeleton-line w-4/5"></div>
									<div class="skeleton-line w-9/12"></div>
								</div>
							</div>
						{/if}

						<!-- Only the answer scrolls; the actions and input below stay pinned so
				they remain reachable however long the response gets. -->
						{#if output || status === 'error'}
							<div class="min-h-0 grow overflow-y-auto overscroll-contain">
								{#if output}
									<!-- Rendered as text, never with {@html}. The Greek in the page is
							the prompt, so this output is attacker-influenceable, and an API key
							sits in localStorage for injected script to exfiltrate. -->
									<p class="whitespace-pre-wrap">{output}</p>
								{/if}

								{#if status === 'error'}
									<p class="flex items-baseline gap-x-1 text-red-700">
										<WarningIcon class="self-center" />
										{error}
									</p>
								{/if}
							</div>
						{/if}

						<!-- Translate is the one-click entry point, so it only shows before
				there's an answer; afterwards the follow-up input carries the thread. -->
						{#if status === 'streaming'}
							<div class="flex shrink-0 items-baseline gap-x-2">
								<Button onclick={abort} danger>
									<StopIcon />
									stop
								</Button>
							</div>
						{:else if !output}
							<div class="flex shrink-0 items-baseline gap-x-2">
								<Button onclick={translate}>
									<TranslateIcon />
									translate
								</Button>
								<!-- The panel stays put while the selection is extended, so this
					count is the only feedback that what translate would send has changed. -->
								{#if ctx && ctx.wordCount > 0}
									<span class="font-sans-sc text-gray-500 lowercase">
										{ctx.wordCount}
										{ctx.wordCount === 1 ? 'word' : 'words'} selected
									</span>
								{/if}
							</div>
						{/if}

						<div
							class="flex shrink-0 items-baseline gap-x-1 border-t border-gray-300 pt-2">
							<input
								bind:value={question}
								{onkeydown}
								placeholder={output ? 'ask a follow-up…' : 'ask a question…'}
								class={[
									'min-w-0 grow bg-transparent px-1 py-0.5 outline-none',
									'placeholder:text-gray-500'
								]} />
							<Button onclick={ask} inert={!question.trim()}>
								<SendIcon />
							</Button>
						</div>
					</div>
				</div>
			{/snippet}
		</Popover.Content>
	</Popover.Portal>
</Popover.Root>
