<script>
    import { onMount } from "svelte";
    import AppContainer from "../components/AppContainer.svelte";
    import { SendEvent } from "../../../../utils/Utils";

    let Grid = [];
    let Clicks = 0;
    const MaxClicks = 20;
    let BlocksRemaining = 0;

    let Loading = true;
    let GameData = {};

    let ShowSplash = false;
    let SplashText = '';
    let LightsField = [];

    function GenerateGrid() {
        const Rows = 7;
        const Columns = 15;
        const TargetClicks = 50;
        Grid = [];

        for (let row = 0; row < Rows; row++) {
            Grid[row] = Array.from({ length: Columns }, () => 0);
        }

        let EnabledBlocks = 0;
        while (EnabledBlocks < TargetClicks) {
            const randomRow = Math.floor(Math.random() * Rows);
            const randomColumn = Math.floor(Math.random() * Columns);

            if (Grid[randomRow][randomColumn] === 0) {
                Grid[randomRow][randomColumn] = 1;
                EnabledBlocks++;
            }
        }

        GetRemainingBlocks();
    };

    const ToggleLight = (Row, Col, State) => {
        Grid[Row][Col] = State;
    };

    const HandleLightClick = () => {
        for (let i = 0; i < LightsField.length; i++) {
            const LightId = LightsField[i];

            const Row = Math.floor(LightId / 15);
            const Col = LightId % 15;
            ToggleLight(Row, Col, true);
        };
        Clicks++;
        GetRemainingBlocks();

        CheckForWin();
    };

    const PreviewLightClick = (Row, Col) => {
        LightsField = [Col + 15 * Row];

        // Top center
        if (Row > 0 && Row < 7)
            LightsField = [...LightsField, Col + 15 * (Row - 1)];

        // Bottom center
        if (Row >= 0 && Row < 6)
            LightsField = [...LightsField, Col + 15 * (Row + 1)];

        // Left center
        if (Col > 0 && Col < 15)
            LightsField = [...LightsField, Col - 1 + 15 * Row];

        // Right center
        if (Col >= 0 && Col < 14)
            LightsField = [...LightsField, Col + 1 + 15 * Row];
    };

    const ClearLightPreview = () => {
        LightsField = [];
    };

    const GetRemainingBlocks = () => {
        let DisabledBlocks = 7 * 15;
        for (let Row = 0; Row < 7; Row++) {
            const Columns = Grid[Row]
            if (!Columns) return;
            for (let Col = 0; Col < Columns.length; Col++) {
                if (Columns[Col]) DisabledBlocks--;
            }
        }
        BlocksRemaining = DisabledBlocks
    };

    const CheckForWin = () => {
        if (Clicks <= 20 && BlocksRemaining == 0) {
            SplashText = 'Code Decrypted: ' + GameData.Code;
            ShowSplash = true;
            SendEvent("SecureGuard/Finished", {Success: true})
            return;
        }

        if (Clicks > 20 || Clicks == 20 && BlocksRemaining != 0) {
            SplashText = 'Decryption Gefaald..';
            ShowSplash = true;
            SendEvent("SecureGuard/Finished", {Success: false})
            return;
        }
    };

    onMount(() => {
        SendEvent("SecureGuard/GetGameData", {}, (Success, Data) => {
            if (!Success) return;
            GameData = Data;
            GenerateGrid();

            setTimeout(() => {
                Loading = false;
            }, 5000);
        })
    });
</script>

<AppContainer
    class="app-secureguard-container"
    AppId="SecureGuard"
    App="SecureGuard Decrypter - v1.6.9 - Licensed to Hackerman"
>
    {#if Loading}
        <div class="loader-container">
            <div class="loader">
                <div class="loader__bar"/>
            </div>
            <p style="font-size: 1.5vh; margin-top: 1vh;">Laden...</p>
        </div>
    {:else if ShowSplash}
        <div style="height: 100%; display: flex; align-items: center;">
            <p style="margin-top: 0; user-select: text; font-size: 3vh;">{SplashText}</p>
        </div>
    {:else}
        <p>{BlocksRemaining} Resterende Blokken - {Clicks} / {MaxClicks}</p>

        <div class="grid-wrapper">
            <div class="grid">
                {#each Grid as Row, i}
                    {#each Row as State, j}
                        <div
                            class="light"
                            class:on={State}
                            class:hover={LightsField.includes(j + i * 15)}
                            on:keyup
                            on:mouseenter={() => PreviewLightClick(i, j)}
                            on:mouseleave={() => ClearLightPreview()}
                            on:click={() => HandleLightClick()}
                        />
                    {/each}
                {/each}
            </div>
        </div>
    {/if}
</AppContainer>

<style>
    :global(.app-secureguard-container) {
        width: 127.8vh !important;
        background-color: #222426 !important;
    }

    :global(.app-secureguard-container > .app-topbar) {
        background-color: rgb(30, 32, 34) !important;
    }

    p {
        width: 92%;
        left: 0;
        right: 0;

        text-align: center;

        margin: 0 auto;
        margin-top: 2vh;

        font-family: Roboto;
        font-size: 2vh;
        color: white;
    }

    .loader-container {
        width: 100%;
        height: 100%;

        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }

    .loader { 
        position:relative;
        margin: 0 auto;

        width: 80%;
        height: .3vh;
    }
    .loader:before {
        content:'';

        background-color: #4a7137;

        position:absolute;
        top: 0;
        right: 0;
        bottom: 0;
        left: 0;
    }

    .loader__bar {
        position:absolute;
        top: 0;
        left: 0;
        right:100%;

        width: 0;
        height: 100%;

        background-color:#95ef77; 
        animation: barAnimation 2s linear infinite;
    }

    .grid-wrapper {
        position: absolute;
        top: 10.5vh;

        left: 0;
        right: 0;

        margin: 0 auto;

        width: 92%;
        height: 77%;
    }

    .grid {
        display: grid;
        grid-template-Columns: repeat(15, 6.3vh);
        gap: 1.3vh;
    }

    .light {
        cursor: pointer;
        width: 6.3vh;
        height: 6.3vh;
        background-color: #05431c;
        border-radius: 0.2vh;
        transition: background-color ease-in-out 50ms;
        color: white;
    }

    .light.on {
        background-color: #32d252;
    }

    .light.hover {
        background-color: #bff3c4;
    }

    .light.on.hover {
        background-color: #469850 !important;
    }

    @keyframes barAnimation {
        0% {
            left:0%;
            right:100%;
            width:0%;
        }
        10% {
            left:0%;
            right:75%;
            width:25%;
        }
        90% {
            right:0%;
            left:75%;
            width:25%;
        }
        100% {
            left:100%;
            right:0%;
            width:0%;
        }
    }
</style>
