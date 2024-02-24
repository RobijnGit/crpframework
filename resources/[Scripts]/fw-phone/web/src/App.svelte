<script>
    import { onMount } from 'svelte';
    import Dropdown from './components/Dropdown/Dropdown.svelte';
    import AppProvider from './providers/AppProvider.svelte';
    import { DropdownData, ImageHoverData, Tax } from './stores';
    import { IsEnvBrowser, OnEvent } from './utils/Utils';

    onMount(() => {
        if (!IsEnvBrowser()) return;
        document.body.style.background = 'gray';
    });

    OnEvent("SetTax", (Data) => {
        Tax.set(Data.Tax);
    })
</script>

{#if !(window).GetParentResourceName || (window).GetParentResourceName() == "fw-phone"}
    {#if $ImageHoverData.Show}
        <div style="position: absolute; top: {$ImageHoverData.Top}px; left: {$ImageHoverData.Left}px; z-index: 999; pointer-events: none;">
            <img alt="" src="{$ImageHoverData.Source}" style="max-width: {$ImageHoverData.MaxWidth}%; height: auto"/>
        </div>
    {/if}

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