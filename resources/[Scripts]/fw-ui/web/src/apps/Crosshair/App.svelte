<script lang="ts">
    import { OnEvent } from "../../utils/Utils";
    import { fade } from "svelte/transition";
    import AppWrapper from "../../components/AppWrapper.svelte";

    let ShowCrosshair: boolean = false;
    let ShowScope: boolean = false;

    // Crosshair/ToggleCrosshair
    OnEvent("Crosshair", "ToggleCrosshair", (Data: { Visible: boolean }) => {
        ShowCrosshair = Data.Visible;
    });

    // Crosshair/ToggleScope
    OnEvent("Crosshair", "ToggleScope", (Data: { Visible: boolean }) => {
        ShowScope = Data.Visible;
    });
</script>

<AppWrapper AppName="Crosshair" Focused={false}>
    {#if ShowCrosshair}
        <div class="crosshair" />
    {/if}
    
    {#if ShowScope}
        <img
            in:fade={{ duration: 500 }} out:fade={{ duration: 500 }}
            class="scope-hunting"
            src="./images/scope.png"
            alt=""
        />
    {/if}
</AppWrapper>

<style>
    .crosshair {
        position: absolute;
        left: 50%;
        top: 50%;
        height: 0.18vh;
        width: 0.18vh;
        background-color: #ffffffd7;
        border: 0.2vh solid rgb(0, 0, 0);
        border-radius: 50%;
        transform: translate(-50%, -50%);
    }

    .scope-hunting {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
    }
</style>
