import { browser } from '$app/environment'
import { isProviderId, providers, type ProviderId } from './providers'
import type { Settings } from './types'

export type { Settings }

const KEY = 'llm'

const defaults: Settings = {
	provider: 'anthropic',
	baseUrl: providers.anthropic.defaultBaseUrl,
	apiKey: '',
	model: providers.anthropic.defaultModel
}

// Read once at init and written explicitly by `save()`, rather than through
// `LocalStore`: its constructor registers an `$effect`, which throws
// `effect_orphan` at module level, and `stream.ts` imports this outside any
// component.
const settings = $state<Settings>(load())

export default settings

function load(): Settings {
	if (!browser) return { ...defaults }

	const raw = localStorage.getItem(KEY)
	if (!raw) return { ...defaults }

	try {
		const parsed = JSON.parse(raw)
		// Merge field-wise so a stale or hand-edited entry can't leave holes.
		const merged: Settings = { ...defaults, ...parsed }
		// `provider` indexes the provider table, so it must be a known id.
		if (!isProviderId(merged.provider)) return { ...defaults }
		return merged
	} catch {
		return { ...defaults }
	}
}

export function save() {
	if (!browser) return
	localStorage.setItem(KEY, JSON.stringify($state.snapshot(settings)))
}

export function configured() {
	return Boolean(settings.apiKey && settings.baseUrl && settings.model)
}

// Switching provider must also reset the base url and model: pointing a Claude
// model id at OpenAI (or the reverse) 404s in a way that reads like a broken
// base url. `custom` has empty defaults, so it clears both for the user to fill.
export function selectProvider(provider: ProviderId) {
	settings.provider = provider
	settings.baseUrl = providers[provider].defaultBaseUrl
	settings.model = providers[provider].defaultModel
	save()
}
