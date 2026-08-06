<script lang="ts">
	import { Popover } from 'bits-ui'
	import { MediaQuery } from 'svelte/reactivity'
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

	// Set once the panel is dragged, which switches it from anchor-positioned to a
	// fixed panel at these coordinates. floating-ui can't stay in charge past that
	// point: it re-runs flip/shift on every content resize, so a streaming
	// response would snap a dragged panel back over the text.
	let moved = $state<{ x: number; y: number } | null>(null)

	// Below lg the panel is the same bottom sheet the definition uses. `side="right"`
	// on a w-96 panel has nowhere to go on a phone, and a sheet is anchored to the
	// viewport rather than the selection — so this branch, like the dragged one,
	// takes positioning over from floating-ui entirely.
	let mobile = new MediaQuery('width < 64rem')
	// Dragging is a desktop affordance; on a sheet there is nowhere to drag to.
	let sheet = $derived(mobile.current)

	// Measured rather than hardcoded so the panel stays put if the nav's height
	// changes. Falls back to a sensible guess before the nav is in the DOM.
	function navBottom() {
		return document.querySelector('nav')?.getBoundingClientRect().bottom ?? 32
	}

	// Anchors the panel to the snapshotted `rect` rather than the live Range:
	// clicking into the input clears the document selection, which collapses a
	// Range anchor to a zero-size box at the origin.
	//
	// Only the horizontal position comes from the selection, so the panel still
	// reads as attached to the words it's about. Vertically it is pinned just under
	// the sticky nav, which leaves a long answer the full viewport height instead
	// of however much happened to be below the selection.
	let anchor = $derived(
		rect
			? {
					getBoundingClientRect: () => {
						// Clearance so the panel floats over the text rather than hanging
						// off the nav's bottom border.
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

	// Opens the panel on the current selection, discarding any answer already in
	// it. Called on every completed selection inside the text, so it declines the
	// cases where a panel would be unwelcome rather than expecting callers to.
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
		// The position is frozen while the panel is open, so extending a selection
		// doesn't slide the panel sideways as if running from the cursor. The word
		// count by the translate button is what signals the selection changed.
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

	// Streams a completion into `output`, replacing whatever was there. Cancels any
	// request still in flight, so a second ask can't interleave with the first.
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

	// Navigating away closes the popover and stops any in-flight request. Compared
	// against the previous path rather than closing unconditionally, which would
	// undo every `show()` on the effect's next run.
	let lastPath = page.url.pathname
	$effect(() => {
		const path = page.url.pathname
		if (path === lastPath) return
		lastPath = path
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
				'elevated z-50 flex flex-col gap-y-2 bg-white p-2',
				'font-sans text-sm text-gray-800',
				// Matches the definition sheet: full-width less a small margin, half
				// the viewport, hanging below the bottom edge by its own padding so the
				// bottom border falls out of sight. Only the parts the child snippet
				// below doesn't set — its geometry has to be inline to beat floating-ui.
				sheet
					? [
							'[--sheet-pad:max(0.5rem,env(safe-area-inset-bottom))]',
							'rounded-t-lg pb-[var(--sheet-pad)]'
						]
					: 'w-96 max-w-[90vw]',
				// Cap the height so a long answer scrolls instead of running off screen.
				// Anchored, that is the space floating-ui measured between the anchor and
				// the viewport edge — nearly the whole viewport, since the anchor sits
				// just under the nav — with a fallback for before it has measured.
				// Dragged, the panel is fixed-positioned and that var no longer tracks
				// it, so cap against the viewport. The sheet sets its own height.
				sheet
					? 'min-h-0'
					: moved
						? 'max-h-[85vh] min-h-0'
						: 'max-h-[min(var(--bits-floating-available-height,85vh),85vh)] min-h-0'
			]}>
			<!-- The `child` snippet is what makes dragging possible: Popover.Content
			merges its own `style` and drops any passed as a prop, so only here do we
			own the final element. The wrapper's transform is cleared while dragging
			too — a transformed ancestor becomes the containing block for
			`position: fixed`, resolving our viewport coordinates against it. -->
			{#snippet child({ props, wrapperProps })}
				{@const dragged = moved}
				{@const wrapStyle = (wrapperProps as { style?: string }).style ?? ''}
				{@const panelStyle = (props as { style?: string }).style ?? ''}
				<div
					{...wrapperProps}
					style={dragged || sheet
						? 'position:static;transform:none;min-width:0'
						: wrapStyle}>
					<div
						{...props}
						data-oxy-panel
						style={sheet
							? // Positioned inline rather than by class: floating-ui writes an
								// inline transform and coordinates, and inline always wins over a
								// class, so the sheet's geometry has to be inline as well.
								`${panelStyle};position:fixed;transform:none;margin:0;` +
								`left:0.5rem;right:0.5rem;top:auto;width:auto;` +
								`height:calc(50vh + var(--sheet-pad));` +
								`bottom:calc(var(--sheet-pad) * -1)`
							: dragged
								? `${panelStyle};position:fixed;left:${dragged.x}px;top:${dragged.y}px;margin:0`
								: panelStyle}>
						<!-- Doubles as the drag handle, except as a sheet: it is pinned to the
						viewport there, so there is nowhere to drag it to. -->
						<!-- svelte-ignore a11y_no_static_element_interactions -->
						<div
							onpointerdown={sheet ? undefined : startDrag}
							class={[
								'flex shrink-0 items-baseline gap-x-2',
								!sheet && 'cursor-grab active:cursor-grabbing'
							]}>
							{#if !sheet}
								<DragIcon class="self-center text-gray-400" />
							{/if}
							<div class="grow"></div>
							<Button
								onclick={close}
								class="shrink-0 text-gray-600 hover:bg-gray-100"
								aria-label="close">
								<CloseIcon />
							</Button>
						</div>

						<!-- The definition panel's skeleton without its 150ms delay: an
				LLM's first token takes seconds, so there is nothing to debounce
				and holding it back would leave the panel looking dead. -->
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
