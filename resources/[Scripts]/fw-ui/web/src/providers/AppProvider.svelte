<script>
    import { onMount } from "svelte";
    import { fade } from "svelte/transition";
    import { IsEnvBrowser, OnEvent, SendEvent } from "../utils/Utils.js";

    import Debug from "../apps/Debug/App.svelte";
    import DeathText from "../apps/DeathText/App.svelte";
    import Helicam from "../apps/Helicam/App.svelte";
    import Crosshair from "../apps/Crosshair/App.svelte";
    import Peek from "../apps/Peek/App.svelte";
    import Prompt from "../apps/Prompt/App.svelte";
    import Info from "../apps/Info/App.svelte";
    import Input from "../apps/Input/App.svelte";
    import Tablet from "../apps/Tablet/App.svelte";
    import Context from "../apps/Context/App.svelte";
    import TextDisplay from "../apps/TextDisplay/App.svelte";
    import Badge from "../apps/Badge/App.svelte";
    import Minigames from "../apps/Minigames/App.svelte";
    import Sounds from "../apps/Sounds/App.svelte";
    import Radio from "../apps/Radio/App.svelte";
    import Racing from "../apps/Racing/App.svelte";
    import Spawn from "../apps/Spawn/App.svelte";
    import Preferences from "../apps/Preferences/App.svelte";
    import Hud from "../apps/Hud/App.svelte";
    import Financials from "../apps/Financials/App.svelte";
    import Ballots from "../apps/Ballots/App.svelte";
    import State from "../apps/State/App.svelte";
    import Books from "../apps/Books/App.svelte";
    import VehicleCatalog from "../apps/VehicleCatalog/App.svelte";
    import Dispatch from "../apps/Dispatch/App.svelte";
    // import ObjectManager from "../apps/ObjectManager/App.svelte";
    import Polaroid from "../apps/Polaroid/App.svelte";
    import Characters from "../apps/Characters/App.svelte";
    import Walkman from "../apps/Walkman/App.svelte";
    import Notepad from "../apps/Notepad/App.svelte";
    import JumpScare from "../apps/JumpScare/App.svelte";
    import Clothing from "../apps/Clothing/App.svelte";
    import Bennys from "../apps/Bennys/App.svelte";

    let Restarting = false;
    let ShowCrashNotify = false;
    let CrashedApp = "root";

    OnEvent("Prompt", "Reload", () => {
        Restarting = true;
        setTimeout(() => {
            Restarting = false;
            SendEvent("appRestart", {App: "root"})
        }, 5000);
    })

    const ProductionApps = [
        // AppName, AppComponent
        ["Clothing", Clothing],
        ["DeathText", DeathText],
        ["Helicam", Helicam],
        ["Crosshair", Crosshair],
        ["Peek", Peek],
        ["Prompt", Prompt],
        ["Info", Info],
        ["Input", Input],
        ["Tablet", Tablet],
        ["Context", Context],
        ["TextDisplay", TextDisplay],
        ["Badge", Badge],
        ["Minigames", Minigames],
        ["Sounds", Sounds],
        ["Radio", Radio],
        ["Racing", Racing],
        ["Spawn", Spawn],
        ["Preferences", Preferences],
        ["Hud", Hud],
        ["Financials", Financials],
        ["Ballots", Ballots],
        ["State", State],
        ["VehicleCatalog", VehicleCatalog],
        ["Dispatch", Dispatch],
        // ["ObjectManager", ObjectManager],
        ["Polaroid", Polaroid],
        ["Books", Books],
        ["Characters", Characters],
        ["Walkman", Walkman],
        ["Notepad", Notepad],
        ["JumpScare", JumpScare],
        ["Bennys", Bennys],
    ]

    onMount(() => {
        ShowCrashNotify = localStorage.getItem("isUiCrashed") == "yes";
        if (ShowCrashNotify) {
            ShowCrashNotify = true;
            CrashedApp = localStorage.getItem("crashedAppName");

            setTimeout(() => {
                SendEvent("appRestart", {App: CrashedApp})
                ShowCrashNotify = false;
                CrashedApp = "root";
            }, 5000);

            localStorage.setItem("isUiCrashed", "no")
            localStorage.setItem("crashedAppName", "root")
        };

        SendEvent("uiReady")
    })
</script>

{#if IsEnvBrowser()} <Debug/> {/if}

{#if !Restarting}
    {#each ProductionApps as Data, Key}
        {#if CrashedApp != Data[0]}
            <svelte:component this={Data[1]} />
        {/if}
    {/each}
{:else}
    <div
        class="crash-reload blue"
        transition:fade={{ duration: 250 }}
    >
        <i class="fal fa-info-circle"/>
        <p>Volledige restart bezig...</p>
    </div>
{/if}

{#if ShowCrashNotify}
    <div
        class="crash-reload"
        transition:fade={{ duration: 250 }}
    >
        <i class="fal fa-exclamation-circle"/>
        {#if CrashedApp != "root"}
            <p>Error occured in app: {CrashedApp.toLowerCase()} - restarting...</p>
        {:else}
            <p>Error occured in root ui - restarting...</p>
        {/if}
    </div>
{/if}

<style>
    .crash-reload {
        display: flex;
        align-items: center;

        position: absolute;
        bottom: 2vh;
        left: 0; right: 0;
        margin: 0 auto;

        padding: .5vh 1.48vh;
        width: fit-content;
        height: fit-content;

        font-family: Roboto;
        letter-spacing: 0.0158vh;
        font-size: 1.3vh;
        font-weight: 500;

        box-shadow: 0 0 .5vh rgba(0, 0, 0, 0.5);

        color: white;
        background-color: rgb(211, 47, 47);
        background-image: linear-gradient(rgba(255, 255, 255, 0.11), rgba(255, 255, 255, 0.11));

        border-radius: 0.3vh;
    }

    .crash-reload.blue {
        background-color: rgb(2, 136, 209);
    }

    .crash-reload > i {
        margin-right: .5vh;
        opacity: 0.9;
        padding: 0.648vh 0;
        font-size: 1.77vh;
    }

    .crash-reload > p {
        padding: 0.74vh;
    }
</style>