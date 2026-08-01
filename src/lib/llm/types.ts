import type { ProviderId } from './providers'

// Lives in a plain `.ts` module rather than alongside the state in
// `settings.svelte.ts`: importing a type from a `.svelte.ts` file resolves
// against the ambient `*.svelte` component module and fails.
export type Settings = {
	provider: ProviderId
	baseUrl: string
	apiKey: string
	model: string
}
