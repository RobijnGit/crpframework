<script>
    import { onMount } from 'svelte';
    import Dropdown from './lib/Dropdown/Dropdown.svelte';
    import AppProvider from './providers/AppProvider.svelte';
    import { DropdownData, PlayerData, Tax } from './stores';
    import { IsEnvBrowser, OnEvent, SendEvent } from './utils/Utils';

    onMount(() => {
        if (!IsEnvBrowser()) return;
        document.body.style.background = 'gray';
    });

    OnEvent("Root", "SetTax", (Data) => {
        Tax.set(Data.Tax);
    })

    OnEvent("Root", "SetPlayerData", (Data) => {
        PlayerData.set(Data);
    })
</script>

{#if !(window).GetParentResourceName || (window).GetParentResourceName() == "fw-ui"}
    {#if $DropdownData.Show}
        <Dropdown Options={$DropdownData.Options} Positioning={{
            Width: $DropdownData.Positioning?.Width,
            Top: $DropdownData.Positioning?.Top,
            Left: $DropdownData.Positioning?.Left
        }}/>
    {/if}

    <div class="root">
        <AppProvider />
    </div>
{:else}
    <h6 style="width: 100%; text-align: center; font-size: 40vh; font-family: Roboto; color: red;">loser</h6>
{/if}