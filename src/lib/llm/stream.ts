import { LlmError, extractMessage } from './errors'
import { providers, type ChatMessage, type SseEvent } from './providers'
import type { Settings } from './types'

// The only network call in the LLM path.
//
// Raw fetch rather than the `ky` client used for BaseX: ky exposes no streaming
// affordance, and two of its defaults are actively wrong here — `retry` would
// silently re-issue a billable request, and `timeout` would kill a long
// generation. Provider SDKs are far too heavy for a reading app.
export async function* streamChat(
	messages: ChatMessage[],
	settings: Settings,
	signal: AbortSignal
): AsyncGenerator<string> {
	const provider = providers[settings.provider]
	const url = settings.baseUrl.replace(/\/+$/, '') + provider.endpoint

	const res = await fetch(url, {
		method: 'POST',
		headers: provider.headers(settings.apiKey),
		body: JSON.stringify(provider.body(messages, settings.model)),
		signal
	})

	// Read the error body as text before touching the stream — a failed response
	// is not SSE, and consuming it as one would mask the real message.
	if (!res.ok) {
		throw new LlmError(res.status, extractMessage(await res.text().catch(() => '')))
	}
	if (!res.body) throw new LlmError(res.status, 'the provider returned nothing')

	const reader = res.body.pipeThrough(new TextDecoderStream()).getReader()
	let buffer = ''

	try {
		while (true) {
			const { done, value } = await reader.read()
			if (done) break
			buffer += value

			// Split on the blank line separating events, not on newlines. Anthropic
			// puts `event:` and `data:` on separate lines of one event and they must
			// be read together; a per-line split works for OpenAI only by accident.
			const chunks = buffer.split(/\r?\n\r?\n/)
			buffer = chunks.pop() ?? ''

			for (const chunk of chunks) {
				const event = parseEvent(chunk)
				if (!event) continue

				// Anthropic reports mid-stream failures (overloaded, and so on) in
				// band, after the response has already committed to HTTP 200.
				if (event.event === 'error') {
					throw new LlmError(
						500,
						extractMessage(event.data) || 'the provider stopped early'
					)
				}

				const text = provider.decode(event)
				if (text) yield text
			}
		}
	} finally {
		// Without this an abort leaves the socket open and the response streaming.
		await reader.cancel().catch(() => {})
	}
}

function parseEvent(chunk: string): SseEvent | null {
	let event: string | undefined
	const data: string[] = []

	for (const line of chunk.split(/\r?\n/)) {
		// Comment/keep-alive frame. OpenRouter sends `: OPENROUTER PROCESSING`
		// between chunks; parsing one as JSON would crash on the first request.
		if (!line || line.startsWith(':')) continue

		const colon = line.indexOf(':')
		const field = colon === -1 ? line : line.slice(0, colon)
		let value = colon === -1 ? '' : line.slice(colon + 1)
		// A single leading space after the colon is part of the framing, not the value.
		if (value.startsWith(' ')) value = value.slice(1)

		if (field === 'event') event = value
		else if (field === 'data') data.push(value)
	}

	if (data.length === 0) return null
	return { event, data: data.join('\n') }
}
