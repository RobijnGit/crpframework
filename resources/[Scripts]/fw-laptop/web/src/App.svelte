<script>
    import Dropdown from './components/Dropdown/Dropdown.svelte';
    import AppProvider from './providers/AppProvider.svelte';
    import { DropdownData, ImageHoverData } from './stores';
    import { FetchNui } from './utils/TypedUtils';
    import { OnEvent, Debug, SetExitHandler } from './utils/Utils';

    SetExitHandler("Close", "Laptop/Close", () => {
        return true
    });

    OnEvent("Laptop/SetGlobalData", Data => {
        Debug("SetGlobalData -> " + JSON.stringify(Data));
    });
</script>

{#if !(window).GetParentResourceName || (window).GetParentResourceName() == "fw-laptop"}
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