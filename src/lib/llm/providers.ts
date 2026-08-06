// Provider adapters for browser-direct LLM calls.
//
// Users bring their own API key (there are no accounts), so requests go straight
// from the browser to the provider and the key never touches our server. Every
// provider below sends permissive CORS headers for this; Anthropic additionally
// requires the `anthropic-dangerous-direct-browser-access` opt-in header.
//
// This module is pure: it describes *how* to build a request and *how* to read a
// chunk, but never performs I/O. See `stream.ts` for the single fetch call.

export type ProviderId = 'anthropic' | 'openai' | 'gemini' | 'deepseek' | 'custom'

export type ChatMessage = {
	role: 'system' | 'user' | 'assistant'
	content: string
}

// One parsed server-sent event. Framing is identical across providers, so
// `stream.ts` produces these and each provider only interprets them.
export type SseEvent = {
	event?: string
	data: string
}

export type Provider = {
	id: ProviderId
	label: string
	defaultBaseUrl: string
	defaultModel: string
	// Suggested models for the picker. Free text is always allowed, since these
	// lists go stale and users may have access to models we don't list.
	models: string[]
	// Appended to the user's base URL, which is stored without a trailing slash.
	endpoint: string
	headers: (apiKey: string) => Record<string, string>
	body: (messages: ChatMessage[], model: string) => unknown
	// Returns the text delta this event carries, or null if it carries none.
	decode: (event: SseEvent) => string | null
}

const MAX_TOKENS = 1024

// Everything other than Anthropic speaks the OpenAI wire format, so Gemini (via
// its OpenAI-compatible endpoint) and custom endpoints reuse these.
const openaiCompatible = {
	endpoint: '/chat/completions',
	headers: (apiKey: string) => ({
		'content-type': 'application/json',
		authorization: `Bearer ${apiKey}`
	}),
	body: (messages: ChatMessage[], model: string) => ({ model, stream: true, messages }),
	decode: ({ data }: SseEvent) => {
		if (data === '[DONE]') return null
		const delta = parse(data)?.choices?.[0]?.delta?.content
		return typeof delta === 'string' ? delta : null
	}
}

export const providers: Record<ProviderId, Provider> = {
	anthropic: {
		id: 'anthropic',
		label: 'anthropic',
		defaultBaseUrl: 'https://api.anthropic.com/v1',
		defaultModel: 'claude-haiku-4-5',
		models: ['claude-haiku-4-5', 'claude-sonnet-5', 'claude-opus-5'],
		endpoint: '/messages',
		headers: apiKey => ({
			'content-type': 'application/json',
			'x-api-key': apiKey,
			'anthropic-version': '2023-06-01',
			'anthropic-dangerous-direct-browser-access': 'true'
		}),
		body: (messages, model) => ({
			model,
			stream: true,
			// Required by the Messages API — omitting it is a hard 400.
			max_tokens: MAX_TOKENS,
			system: messages.find(m => m.role === 'system')?.content,
			messages: messages.filter(m => m.role !== 'system')
		}),
		decode: ({ event, data }) => {
			if (event !== 'content_block_delta') return null
			const delta = parse(data)?.delta
			return delta?.type === 'text_delta' ? (delta.text ?? null) : null
		}
	},

	openai: {
		id: 'openai',
		label: 'openai',
		defaultBaseUrl: 'https://api.openai.com/v1',
		defaultModel: 'gpt-5.6-terra',
		models: ['gpt-5.6-luna', 'gpt-5.6-terra', 'gpt-5.6-sol'],
		...openaiCompatible
	},

	gemini: {
		id: 'gemini',
		label: 'gemini',
		// Google's OpenAI-compatible surface, so it needs no adapter of its own.
		defaultBaseUrl: 'https://generativelanguage.googleapis.com/v1beta/openai',
		defaultModel: 'gemini-3.6-flash',
		models: ['gemini-3.5-flash-lite', 'gemini-3.6-flash', 'gemini-3.5-flash'],
		...openaiCompatible
	},

	deepseek: {
		id: 'deepseek',
		label: 'deepseek',
		// No /v1 suffix — DeepSeek serves the OpenAI-shaped route at the root.
		defaultBaseUrl: 'https://api.deepseek.com',
		defaultModel: 'deepseek-v4-flash',
		models: ['deepseek-v4-flash', 'deepseek-v4-pro'],
		...openaiCompatible
	},

	// Anything else that speaks the OpenAI format: OpenRouter, Groq, a local
	// Ollama or llama.cpp, a company proxy. The user supplies url and model.
	custom: {
		id: 'custom',
		label: 'custom',
		defaultBaseUrl: '',
		defaultModel: '',
		models: [],
		...openaiCompatible
	}
}

export function isProviderId(value: unknown): value is ProviderId {
	return typeof value === 'string' && value in providers
}

// Providers occasionally emit a malformed or truncated frame; a bad chunk should
// skip rather than abort a response that is otherwise streaming fine.
function parse(data: string) {
	try {
		return JSON.parse(data)
	} catch {
		return null
	}
}
