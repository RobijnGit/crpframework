<script>
    import { IsEnvBrowser } from "../utils/Utils.js";
    import Debug from "../apps/Debug/Debug.svelte";
    import Laptop from "../apps/Laptop/Laptop.svelte";
</script>

{#if IsEnvBrowser()} <Debug/> {/if}

<Laptop/>