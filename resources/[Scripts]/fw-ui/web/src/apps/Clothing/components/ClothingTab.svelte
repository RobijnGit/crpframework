<script>
    import TextField from "../../../lib/TextField/TextField.svelte";
    import { SendEvent as _SendEvent } from "../../../utils";

    export let Title = "Haar";

    export let AmountComponents = 0;
    // export let AmountTextures = 0;
    // export let DisableTextureField = 0;

    export let DisableHighlight = false;
    export let HasPalette = false;
    export let PaletteColors = [];
    export let PaletteId = "";

    let PaletteCollapsed = true;

    const SendEvent = (Event, Parameters, Callback) => {
        _SendEvent(Event, Parameters, Callback, "fw-clothes")
    };

    const ProcessPaletteClick = (Index, isHighlight) => {
        SendEvent("Clothing/ProcessComponentChange", { paletteId: PaletteId, value: Index, type: isHighlight ? "Secondary" : "Primary" });
    };
</script>

<div class="clothing-card-container">
    <div class="clothing-card" {...$$restProps}>
        <h1>{Title}</h1>
        {#if AmountComponents > 0}
            <p>{AmountComponents} {AmountComponents == 1 ? "component" : "componenten"}</p>
        {/if}

        <div class="clothing-card-values">
            <slot/>
        </div>
    
        <!-- {#if !DisableTextureField}
            {#if AmountTextures <= 0}
                <TextField
                    Title=""
                    Select={[]}
                    Value="Texture 0"
                    ReadOnly={true}
                    style="margin-top: 1.5vh; margin-bottom: 0;"
                />
            {:else}
                <TextField
                    Title="{AmountTextures} {AmountTextures == 1 ? "texture" : "textures"}"
                    Select={[]}
                    Value="Texture 0"
                    ReadOnly={true}
                    style="margin-top: 1.5vh; margin-bottom: 0;"
                />
            {/if}
        {/if} -->
    </div>

    {#if HasPalette}
        <div class="clothing-card palette">
            <div class="palette-title" style="cursor: pointer;" on:keyup on:click={() => PaletteCollapsed = !PaletteCollapsed}>
                {#if Title == "Haar"}
                    <h1>Haar Kleur</h1>
                {:else}
                    <h1>Kleuren</h1>
                {/if}
            </div>

            {#if !PaletteCollapsed}
                <div class="palette-colors-container">
                    <h1 class="palette-title">Kleur</h1>

                    <div class="palette-colors">
                        {#each PaletteColors as Data, Index}
                            <div class="palette-color-block" class:active={false} style="background-color: {Data};" on:keyup on:click={() => ProcessPaletteClick(Index, false)}></div>
                        {/each}
                    </div>

                    {#if !DisableHighlight}
                        <h1 class="palette-title">{Title == "Haar" ? "Highlight" : "Secundaire Kleur"}</h1>

                        <div class="palette-colors">
                            {#each PaletteColors as Data, Index}
                                <div class="palette-color-block" class:active={false} style="background-color: {Data};" on:keyup on:click={() => ProcessPaletteClick(Index, true)}></div>
                            {/each}
                        </div>
                    {/if}
                </div>
            {/if}
        </div>
    {/if}

</div>

<style>
    .clothing-card-container {
        height: max-content;
        width: 100%;
        margin-bottom: 2.8vh;
    }

    .clothing-card {
        position: relative;
        width: calc(100% - .9vh);
        height: max-content;
        min-height: 4vh;

        border-top-left-radius: .3vh;
        border-top-right-radius: .3vh;

        padding: .45vh;

        background-color: rgb(48, 71, 94);
    }

    .clothing-card h1 {
        font-size: 2.25vh;
        font-weight: 400;
        padding: .3vh .1vh;
        padding-bottom: 0;
        letter-spacing: -.05vh;
        color: rgba(255, 255, 255, 0.9);
    }

    .clothing-card p {
        margin-left: .2vh;
        font-size: 1.25vh;
        font-weight: 400;
        color: rgba(255, 255, 255, 0.7);
    }

    .clothing-card-values {
        margin-top: .4vh;
        display: flex;
        justify-content: space-around;
        width: 100%;
        margin-bottom: 0.2vh;
    }

    /* Palette */
    .clothing-card.palette {
        display: flex;
        flex-direction: column;
        align-items: center;

        margin-top: 1vh;
        border-bottom: .15vh solid white;
    }

    .clothing-card.palette .palette-title {
        display: flex;
        align-items: center;
        height: 4vh;
        width: 100%;
    }

    .clothing-card.palette .palette-title h1 {
        font-weight: 450;
        padding: 0 .3vh;
        padding-bottom: 0;
    }

    .palette-colors-container {
        height: fit-content;
        width: 93%;
        margin-bottom: 2vh;
    }

    .palette-colors-container h1 {
        padding: 0;
        font-size: 2vh;
        font-weight: 500;
    }

    .palette-colors {
        width: 100%;
    }

    .palette-color-block {
        width: 4vh;
        height: 4vh;
        background-color: black;
        float: left;
        box-shadow: inset 0 0 0 .1vh white;
        cursor: pointer;
    }

    .palette-color-block.active {
        box-shadow: inset 0 0 0 .3vh #1465ab;
    }
</style>