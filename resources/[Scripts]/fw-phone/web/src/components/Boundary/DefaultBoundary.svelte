<script>
  export let error = null;
  export let onError = null;

$: if ($error && onError) onError($error);
</script>

{#if !$error}
  <slot />
{/if}
