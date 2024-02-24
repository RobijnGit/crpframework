<script>
    import { PresetBackgrounds } from "../../../config";
    import { LaptopPreferences } from "../../../stores";
    import TextField from "../../../components/TextField/TextField.svelte";
    import Checkbox from "../../../components/Checkbox/Checkbox.svelte";
    import Button from "../../../components/Button/Button.svelte";
    import { SendEvent } from "../../../utils/Utils";
    
    let ShowPresets = false;

    const SavePreferences = () => {
        SendEvent("Laptop/SaveSettings", $LaptopPreferences)
    };

    const TogglePresets = () => {
        ShowPresets = !ShowPresets;
    };

    const SetBackground = Background => {
        $LaptopPreferences.background = Background
    };
</script>

{#if !ShowPresets}
    <div class="laptop-settings-wrapper">
        <p>Instellingen</p>
        <div class="laptop-settings">
            <TextField Title="Enter Background (16:9)" Icon="images" style="margin-bottom: 0;" bind:RealValue={$LaptopPreferences.background}/>
            <div style="display: flex; justify-content: space-between; width: 85%; margin: 0 auto; margin-bottom: .7vh;">
                <div style="width: 50%; display: flex; justify-content: center;">
                    <Button click={SavePreferences} Color="success">Save</Button>
                </div>
                <div style="width: 50%; display: flex; justify-content: center;">
                    <Button click={TogglePresets} Color="success">Presets</Button>
                </div>
            </div>
            <Checkbox bind:Checked={$LaptopPreferences.whiteFont} Title="White Font"/>
        </div>
    </div>
{:else}
    <div class="laptop-background-presets-wrapper">
        <p>Preset Backgrounds</p>
        <div class="laptop-background-presets-grid">
            {#each PresetBackgrounds as Data, Key}
                <div on:keyup on:click={() => { SetBackground(Data) }} class="laptop-background-preset-image" style="background-image: url({Data || './images/wallpapers/default.png'})"></div>
            {/each}
        </div>
        <div style="width: 100%; display: flex; justify-content: center; margin-top: 2vh;">
            <Button click={TogglePresets} Color="warning">Sluiten</Button>
        </div>
    </div>
{/if}

<style>
    .laptop-settings-wrapper {
        position: absolute;
        top: 1.7%;
        right: 1%;
        border-radius: 1vh;

        overflow-y: auto;

        z-index: 999;

        height: 85%;
        width: 25%;

        background-color: rgba(0, 0, 0, 0.5);
        backdrop-filter: blur(1.5vh);

        animation: historyFadeIn 250ms ease-in-out;
    }

    .laptop-settings-wrapper > p {
        width: 100%;

        font-family: Roboto;
        font-size: 2vh;

        color: white;
        text-align: center;
        margin-top: 1.7vh;
    }

    .laptop-settings-wrapper > .laptop-settings {
        margin: 0 auto;
        margin-top: 1.6vh;
        width: 90%;
        height: 61vh;
    }

    @keyframes historyFadeIn {
        0% {
            transform: translateX(100%);
        }
        100% {
            transform: translateX(0%);
        }
    }

    .laptop-settings::-webkit-scrollbar {
        display: none;
    }

    .laptop-background-presets-wrapper {
        position: absolute;
        top: 1.5%;
        left: 50%;

        transform: translateX(-50%);

        width: 75vh;
        height: 69vh;
        /* 63.5vh */

        background-color: rgba(0, 0, 0, 0.5);
        backdrop-filter: blur(1.5vh);

        border-radius: 1vh;
    }

    .laptop-background-presets-wrapper > p {
        width: 100%;

        font-family: Roboto;
        font-size: 2vh;

        color: white;
        text-align: center;
        margin-top: 1.7vh;
    }

    .laptop-background-presets-grid {
        width: 95%;
        height: max-content;

        display: grid;
        grid-template-columns: repeat(3, 22.5vh);
        grid-template-rows: repeat(4, 13vh);
        grid-column-gap: 2vh;
        grid-row-gap: 1.5vh;

        margin: 0 auto;
        margin-top: 1vh;
    }

    .laptop-background-preset-image {
        background-size: cover;
        background-position: center;
        background-repeat: no-repeat;
        border-radius: 1vh;
        transition: transform ease 250ms;

        border: 0.15vh solid rgba(1, 226, 192, 0.5);
    }

    .laptop-background-preset-image:hover {
        transform: scale(1.1);
        border: 0.15vh solid rgba(1, 226, 192, 1.0);
    }
</style>