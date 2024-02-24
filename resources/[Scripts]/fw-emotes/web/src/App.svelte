<script>
    import AppProvider from './providers/AppProvider.svelte';
    import { OnEvent, SetExitHandler } from './utils/Utils';

    SetExitHandler("Close", "Emotes/Close", () => {
        return true
    });
</script>

{#if !(window).GetParentResourceName || (window).GetParentResourceName() == "fw-emotes"}
    <div class="root">
        <AppProvider />
    </div>
{:else}
    <h6 style="width: 100%; text-align: center; font-size: 40vh; font-family: Roboto; color: red;">loser</h6>
{/if}