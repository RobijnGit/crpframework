<script>
    import { IsEnvBrowser } from "../utils/Utils.js";
    import Debug from "../apps/Debug/Debug.svelte";
    import Menu from "../apps/Menu/App.svelte";
</script>

{#if IsEnvBrowser()} <Debug/> {/if}
<Menu/>