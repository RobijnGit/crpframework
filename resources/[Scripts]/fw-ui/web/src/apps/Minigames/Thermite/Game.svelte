<script>
    import { Config } from "./config"
    import { PlaySound, StopSound } from "../../Sounds/Utils";
    import { Delay, OnEvent, SendEvent } from "../../../utils/Utils";
    import AppWrapper from "../../../components/AppWrapper.svelte";

    let DoingMinigame = false;
    let ShowCorrect = false;
    let SplashText = false;
    let ShowingSplash = false;
    let Positions = [], CorrectPositions = [], SelectedPositions = [];
    let ThermiteSize = 5;
    let TimeLeft = 0;
    let TimeInterval;
    let SoundInterval;

    const StartMinigameSound = () => {
        PlaySound("metronome", .5);
        SoundInterval = setInterval(() => {
            PlaySound("metronome", .5);
        }, 8000)
    };

    const StopMinigameSound = () => {
        StopSound();
        clearInterval(SoundInterval);
    }

    const Range = (start, end, length = end - start + 1) => {
        return Array.from({length}, (_, i) => start + i)
    };

    const Shuffle = (arr) => {
        for (let i = arr.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            const temp = arr[i];
            arr[i] = arr[j];
            arr[j] = temp;
        };
    };

    const StartMinigame = async (Size, HasBuff) => {
        ThermiteSize = Size;

        if (!Config.Size[ThermiteSize] || DoingMinigame) {
            return;
        }

        Positions = Range(0, Math.pow(ThermiteSize, 2) - 1);
        Shuffle(Positions);

        CorrectPositions = Positions.slice(0, Config.Size[ThermiteSize][0]);

        DoingMinigame = true;
        ShowingSplash = true;
        SplashText = 'Sequentie op Afstand Vereist';

        await Delay(5);

        ShowingSplash = false;
        ShowCorrect = true;

        await Delay(2)

        ShowCorrect = false;
        StartMinigameSound();

        let Timeout = Config.Timeouts[ThermiteSize]
        if (HasBuff) Timeout = Timeout + 1500;

        TimeInterval = setInterval(() => {
            TimeLeft++;
            if (TimeLeft == 100) {
                clearInterval(TimeInterval);
                CheckForWin();
            }
        }, Timeout / 100)
    };

    const ClickOnThermite = (Key) => {
        if (ShowCorrect) return;
        if (SelectedPositions.includes(Key)) return;
        SelectedPositions = [...SelectedPositions, Key];

        CheckForWin();
    };

    const CheckForWin = () => {
        let CorrectSelected = 0, WrongSelected = 0;
        for (let i = 0; i < SelectedPositions.length; i++) {
            if (CorrectPositions.includes(SelectedPositions[i])) {
                CorrectSelected++;
            } else {
                WrongSelected++;
            };
        };

        if (TimeLeft >= 100 || WrongSelected >= 3) {
            ShowingSplash = true;
            SplashText = 'Sequentie op Afstand Geweigerd';
            if (TimeInterval) clearInterval(TimeInterval);
            setTimeout(() => {
                SendEvent("Minigames/Thermite/Finished", {Success: false})
                ShowingSplash = false;
                DoingMinigame = false;
                ResetGameData();
            }, 5000);
            StopMinigameSound();
            PlaySound('beep-fail', .2);
            return;
        };

        if (CorrectSelected == CorrectPositions.length) {
            ShowingSplash = true;
            SplashText = 'Sequentie op Afstand Voltooid';
            if (TimeInterval) clearInterval(TimeInterval);
            setTimeout(() => {
                SendEvent("Minigames/Thermite/Finished", {Success: true})
                ShowingSplash = false;
                DoingMinigame = false;
                ResetGameData();
            }, 5000);
            StopMinigameSound();
            PlaySound('beep-success', .2);
            return;
        };
    };

    const ResetGameData = () => {
        ShowCorrect = false;
        ShowingSplash = false;
        Positions = [], CorrectPositions = [], SelectedPositions = [];
        ThermiteSize = 5;
        TimeLeft = 0;
    }

    OnEvent("Minigames/Thermite", "StartMinigame", (Data) => {
        StartMinigame(Data.Size, Data.HasBuff);
    })
</script>

<AppWrapper AppName="Minigames/Thermite" Focused={DoingMinigame}>
    {#if DoingMinigame}
        <div class="thermite-wrapper">
            <div class="thermite-container">
    
                {#if ShowingSplash}
                    <div class="thermite-splash">
                        <i class="fas fa-user-secret"></i>
                        <p>{SplashText}</p>
                    </div>
                {:else}
                    <div class="thermite-groups">
                        {#each Positions as Data, Key}
                            <div
                                on:keyup on:click={() => { ClickOnThermite(Key) }}
                                class="thermite-group"
                                style="
                                    width: {Config.Size[ThermiteSize][1]};
                                    height: {Config.Size[ThermiteSize][1]};
                                    background-color: {
                                        ShowCorrect ?
                                            (
                                                CorrectPositions.includes(Key) ? "#CCCCCC" : "#34475C"
                                            ) : (
                                                SelectedPositions.includes(Key) ? (CorrectPositions.includes(Key) ? "#CCCCCC" : "#F00F18") : "#34475C"
                                            )
                                    }"
                            />
                        {/each}
                    </div>
    
                    <div class="thermite-loading">
                        <div class="thermite-loading-bar" style="width: {TimeLeft}%" />
                    </div>
                {/if}
            </div>
        </div>
    {/if}
</AppWrapper>

<style>
    .thermite-wrapper {
        position: absolute;
        top: 0;
        left: 0;

        width: 100vw;
        height: 100vh;

        display: flex;
        justify-content: center;
        align-items: center;
    }

    .thermite-container {
        position: relative;
        width: 54vh;
        height: 54vh;

        padding: 2vh;
        padding-bottom: 3vh;

        background-color: #232832;
    }

    .thermite-splash {
        width: 100%;
        height: 100%;

        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;

        color: white;
    }

    .thermite-splash > i {
        font-size: 5vh;
        margin-bottom: 3vh;
    }

    .thermite-splash > p {
        font-size: 1.5vh;
        font-family: Roboto;
    }

    .thermite-groups {
        display: flex;
        flex-wrap: wrap;
        justify-content: space-evenly;
        user-select: none;
    }

    .thermite-group {
        width: 7vh;
        height: 7vh;
        margin: .8vh;
        background-color: #34475C;
    }

    .thermite-loading {
        position: relative;

        width: 97%;
        height: .7vh;
        border-radius: .5vh;

        margin: 0 auto;

        background-color: rgba(0, 0, 0, 0.342);
    }

    .thermite-loading-bar {
        width: 100%;
        height: 100%;

        border-radius: .3vh;
        background-color: #f2a365;

        transition: width linear 100ms;
    }
</style>