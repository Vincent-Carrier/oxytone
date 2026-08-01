<script lang="ts">
	import { DropdownMenu } from 'bits-ui'
	import Button from '$lib/components/button.svelte'
	import { providers, type ProviderId } from '$lib/llm/providers'
	import settings, { save, selectProvider } from '$lib/llm/settings.svelte'
	import SettingsIcon from '~icons/heroicons/cog-6-tooth-16-solid'

	const ids = Object.keys(providers) as ProviderId[]
	let models = $derived(providers[settings.provider].models)

	const field =
		'w-full rounded-sm border border-gray-300 bg-white px-1 py-0.5 outline-none focus:border-blue-500'
	const label = 'font-sans-sc block text-xs text-gray-600 lowercase'
</script>

<DropdownMenu.Root>
	<DropdownMenu.Trigger>
		{#snippet child({ props })}
			<Button {...props}>
				<SettingsIcon />
				<span class="max-sm:sr-only">settings</span>
			</Button>
		{/snippet}
	</DropdownMenu.Trigger>
	<DropdownMenu.Portal>
		<DropdownMenu.Content
			sideOffset={6}
			align="end"
			class={[
				'elevated z-50 flex w-80 flex-col gap-y-2 bg-white p-2',
				'font-sans text-sm text-gray-800'
			]}>
			<p class="text-xs text-gray-600">
				Translate and ask about passages using your own API key. It is stored in this
				browser only and sent directly to the provider.
			</p>

			<div>
				<span class={label}>provider</span>
				<div class="flex flex-wrap gap-x-1 gap-y-1 pt-0.5">
					{#each ids as id (id)}
						<Button
							onclick={() => selectProvider(id)}
							class={[settings.provider === id && 'bg-blue-100 hover:bg-blue-100']}>
							{providers[id].label}
						</Button>
					{/each}
				</div>
			</div>

			<label>
				<span class={label}>base url</span>
				<input
					bind:value={settings.baseUrl}
					onblur={save}
					spellcheck="false"
					placeholder={settings.provider === 'custom' ? 'https://…/v1' : ''}
					class={field} />
			</label>

			<label>
				<span class={label}>api key</span>
				<input
					bind:value={settings.apiKey}
					onblur={save}
					type="password"
					autocomplete="off"
					spellcheck="false"
					class={field} />
			</label>

			<div>
				<label>
					<span class={label}>model</span>
					<!-- Free text, because the suggestions below go stale and a user may
					have access to models we don't list. -->
					<input
						bind:value={settings.model}
						onblur={save}
						spellcheck="false"
						placeholder={settings.provider === 'custom' ? 'model id' : ''}
						class={field} />
				</label>
				<!-- Listed as buttons rather than a datalist: a datalist filters by
				prefix against the current value, so a prefilled model hides every
				other suggestion behind an invisible affordance. -->
				{#if models.length > 0}
					<div class="flex flex-wrap gap-x-1 gap-y-1 pt-1">
						{#each models as model (model)}
							<Button
								onclick={() => {
									settings.model = model
									save()
								}}
								class={[
									'font-sans lowercase',
									settings.model === model && 'bg-blue-100 hover:bg-blue-100'
								]}>
								{model}
							</Button>
						{/each}
					</div>
				{/if}
			</div>
		</DropdownMenu.Content>
	</DropdownMenu.Portal>
</DropdownMenu.Root>
