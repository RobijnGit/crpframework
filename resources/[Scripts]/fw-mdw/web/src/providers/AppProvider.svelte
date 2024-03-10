<script>
    import { IsEnvBrowser, SendEvent } from "../utils/Utils.js";
    import Debug from "../apps/Debug/Debug.svelte";
    import Mdw from "../apps/Mdw/Mdw.svelte";
    import { fade } from "svelte/transition";
    import { onMount } from "svelte";

    let ShowCrashNotify = false;
    let CrashedApp = "root";

    onMount(() => {
        ShowCrashNotify = localStorage.getItem("isUiCrashed") == "yes";
        if (ShowCrashNotify) {
            ShowCrashNotify = true;
            CrashedApp = localStorage.getItem("crashedAppName");

            setTimeout(() => {
                ShowCrashNotify = false;
                CrashedApp = "root";
            }, 3000);

            localStorage.setItem("isUiCrashed", "no")
            localStorage.setItem("crashedAppName", "root")

            SendEvent("Mdw/Close");
        };
    })
</script>

{#if IsEnvBrowser()} <Debug/> {/if}

{#if CrashedApp != "Mdw"}
    <Mdw/>
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