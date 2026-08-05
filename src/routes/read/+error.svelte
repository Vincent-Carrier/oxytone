<!-- The treebank is awaited in load now, so a BaseX failure surfaces here rather
     than in a {:catch} on the page. -->
<script lang="ts">
	import { page } from '$app/state'
</script>

<p class="font-sc mt-32 self-center text-center text-2xl lowercase">
	{page.error?.message ?? 'Something went wrong'}
</p>
