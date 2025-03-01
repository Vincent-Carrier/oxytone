<script lang="ts">
	interface Props {
		definition: string;
		lemma: string;
	}

	const { lemma, definition }: Props = $props();
</script>

<div
	id="definition"
	class="absolute right-2 bottom-8 max-h-32 w-72 overflow-y-scroll border-1 border-gray-300 bg-gray-50 px-2 text-sm md:max-h-[80%]"
>
	{@html definition}
	<a
		target="_blank"
		href={`https://lsj.gr/wiki/${lemma}`}
		class="mt-4 mb-2 block text-right text-blue-600"
	>
		<span class="underline">lsj.gr/</span> 🡽
	</a>
</div>
