// Turns provider failures into short lowercase messages matching the app's voice.

export class LlmError extends Error {
	constructor(
		public status: number,
		message: string
	) {
		super(message)
		this.name = 'LlmError'
	}
}

export function describeError(error: unknown): string {
	if (error instanceof LlmError) {
		switch (error.status) {
			case 401:
			case 403:
				return 'api key rejected — check it in settings'
			case 404:
				return 'model not found at this base url'
			case 429:
				return 'rate limited — wait a moment'
			// The provider's own message for a 400 is usually specific (bad model
			// name, malformed request), so it beats anything we could invent.
			case 400:
				return error.message || 'the provider rejected the request'
		}
		if (error.status >= 500) return 'the provider is having trouble'
		return error.message || 'something went wrong'
	}

	// A blocked CORS preflight and a dead network are indistinguishable here —
	// fetch rejects with an opaque TypeError in both cases, by design. Name both.
	if (error instanceof TypeError) {
		return "couldn't reach the provider — check the base url, or your network"
	}

	return error instanceof Error && error.message ? error.message : 'something went wrong'
}

// Providers return errors as JSON, but a misconfigured proxy in front of one may
// return an HTML page instead. Never throw a second error while handling the first.
export function extractMessage(body: string): string {
	try {
		const parsed = JSON.parse(body)
		const message = parsed?.error?.message ?? parsed?.message
		if (typeof message === 'string' && message) return message
	} catch {
		// fall through
	}
	return ''
}
