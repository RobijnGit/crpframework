<script>
    import { EmbedsEnabled } from "../phone.stores";
    import ImageHover from "./ImageHover.svelte";

    export let Hidden = true;
    export let Attachments = [];

    const ToggleHide = () => {
        Hidden = !Hidden;
    };
</script>

{#if $EmbedsEnabled}
    <div class="component-image-container">
        <div>
            <p class="component-image-text" style="word-break: break-word;">
                Aantal bijlages: {Attachments.length}
            </p>
            {#if !Hidden}
                <div>
                    <p
                        class="component-image-text"
                        on:keyup
                        on:click={ToggleHide}
                        style="text-decoration: underline;"
                    >
                        Verbergen (klik om de URL te kopiëren)
                    </p>
                </div>
            {/if}
        </div>
        <div class="container">
            {#if Hidden}
                <div class="blocker" on:keyup on:click={ToggleHide}>
                    <i style="font-size: 4.8vh;" class="fas fa-eye" />
                    <p
                        class="component-image-click-hint"
                        style="word-break: break-word;"
                    >
                        Klik om te Bekijken
                    </p>
                    <p
                        class="component-image-text"
                        style="text-align: center; margin-top: .8vh;"
                    >
                        Bekijk alleen afbeeldingen van mensen waarvan je weet dat ze
                        geen eikels zijn
                    </p>
                </div>
            {:else}
                {#each Attachments as Data, Id}
                    <ImageHover Url={Data}/>
                {/each}
            {/if}
            <div class="spacer" />
        </div>
    </div>
{/if}

<style>
    .component-image-text {
        font-size: 1.4vh;
        font-family: "Roboto", "Helvetica", "Arial", sans-serif;
        font-weight: 400;
        line-height: 1.43;
        letter-spacing: 0.017136vh;
    }

    .component-image-click-hint {
        font-size: 1.6vh;
        font-family: "Roboto", "Helvetica", "Arial", sans-serif;
        font-weight: 400;
        line-height: 1.5;
        letter-spacing: 0.015008vh;
    }

    .component-image-container {
        width: 100%;
        min-height: 12.5vh;
        position: relative;
        margin-top: 1.6vh;
        pointer-events: all;
    }

    .component-image-container > .container {
        width: 100%;
        border-radius: 0.4vh;
        min-height: 12.5vh;
        overflow: hidden;
        margin-top: 0.8vh;
        padding: 0.8vh 0;
        position: relative;
        display: flex;
        flex-wrap: wrap;
        justify-content: space-around;
    }

    .component-image-container > .container > .blocker {
        min-height: 12.5vh;
        cursor: pointer;
        position: absolute;
        top: 0;
        left: 0;
        height: 98%;
        width: 98%;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        z-index: 2;
        border: 0.1vh solid #fff;
        border-radius: 0.4vh;
        text-shadow: -0.1vh 0.1vh 0 #37474f, 0.1vh 0.1vh 0 #37474f,
            0.1vh -0.1vh 0 #37474f, -0.1vh -0.1vh 0 #37474f;
    }

    .component-image-container > .container > .spacer {
        flex: 1 1;
        min-width: 21.8vh;
    }

    :global(.component-image-container > .container > .image) {
        width: 100%;
        min-width: 21.8vh;
        max-width: 21.8vh;
        min-height: 14vh;
        background-size: contain;
        background-repeat: no-repeat;
        background-position: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        position: relative;
    }
</style>
