<script>
    import "./soundcloud";
    import { Delay, OnEvent, SendEvent, SetExitHandler } from "../../utils/Utils";
    import AppWrapper from "../../components/AppWrapper.svelte";
    import { onMount } from "svelte";
    import Button from "../../lib/Button/Button.svelte";
    import Slider from "@smui/slider";
    
    let IsFocused = false;
    let IsMediaPlaying = false;
    let MediaSrc = "about:blank";
    let MediaRef;
    let SoundcloudWidget;
    let WalkmanVolume = 15;
    let WalkmanMaximized = true;

    $: if (SoundcloudWidget) {
        SoundcloudWidget.setVolume(WalkmanVolume);
    };

    SetExitHandler("", "Walkman/Unfocus", () => IsFocused, {__resource: "fw-misc"})
    
    const CloseWalkman = () => {
        MediaSrc = "about:blank"
        WalkmanMaximized = true;
        IsFocused = false;
        IsMediaPlaying = false;

        SendEvent("Walkman/Unfocus", undefined, undefined, "fw-misc");
        SendEvent("Walkman/StopMedia", undefined, undefined, "fw-misc");
    };

    OnEvent("Walkman", "PlayTape", async (Data) => {
        IsFocused = true;
        IsMediaPlaying = true;
        MediaSrc = `https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/${Data.TapeId}&color=%232cffb8&auto_play=true&hide_related=true&show_comments=false&show_user=false&show_reposts=false&show_teaser=false`

        while (!MediaRef) {
            await Delay(0.01);
        }

        SoundcloudWidget = SC.Widget(MediaRef);
        setTimeout(() => {
            SoundcloudWidget.setVolume(WalkmanVolume);
            SoundcloudWidget.play();
        }, 650);
    });

    OnEvent("Walkman", "SetFocus", (Bool) => {
        IsFocused = Bool;
    })

    OnEvent("Walkman", "StopTape", CloseWalkman);
</script>

<AppWrapper AppName="Walkman" Focused={IsFocused}>
    {#if IsMediaPlaying}
        <div class="walkman-wrapper" style="width: {WalkmanMaximized ? "55vh" : "20.5vh"}">
            {#if MediaSrc != "about:blank"}
                <iframe bind:this={MediaRef} id="walkman-media" scrolling="no" frameborder="no" allow="autoplay" src={MediaSrc} title=""></iframe>
            {/if}

            <div class="walkman-buttons">
                {#if WalkmanMaximized}
                    <div class="walkman-slider">
                        <i class="fas fa-volume-down"></i>
                        <Slider
                            step={1.0}
                            min={0.0}
                            max={100.0}
                            bind:value={WalkmanVolume}
                            style="padding: 0px; margin: 0px; width: 80%"
                        />
                        <i class="fas fa-volume-up"></i>
                    </div>
                {/if}

                <div>
                    <Button Color="success" on:click={() => WalkmanMaximized = !WalkmanMaximized}>{WalkmanMaximized ? "Minimaliseren" : "Maximaliseren"}</Button>
                    <Button Color="warning" on:click={CloseWalkman} style="margin-right: 0;">Sluiten</Button>
                </div>
            </div>
        </div>
    {/if}
</AppWrapper>

<style>
    .walkman-wrapper {
        display: flex;
        flex-direction: column;
        align-items: center;

        position: absolute;
        top: 0;
        right: 0;

        width: 55vh;
        height: max-content;

        background-color: #232832;
    }

    #walkman-media {
        width: 100%;
        border-radius: 0;
    }

    .walkman-buttons {
        display: flex;
        align-items: center;
        justify-content: space-between;

        width: 98%;
        height: 5vh;
        padding: .2vh 0;
    }

    .walkman-slider {
        display: flex;
        justify-content: space-around;
        align-items: center;

        width: 63%;

        color: white;
        font-size: 1.4vh;
    }
</style>