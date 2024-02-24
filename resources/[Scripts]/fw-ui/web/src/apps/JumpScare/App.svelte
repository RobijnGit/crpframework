<script>
    import { fade } from "svelte/transition";
    import AppWrapper from "../../components/AppWrapper.svelte";
    import { PlaySound } from "../Sounds/Utils";
    import { OnEvent } from "../../utils/Utils";

    const AudioFiles = 10;
    const ImageFiles = 8;

    let ShowJumpscare = false;
    let JumpscareFile = '';

    const Jumpscare = () => {
        JumpscareFile = `scare-${Math.ceil(Math.random() * ImageFiles)}.png`

        ShowJumpscare = true;
        PlaySound(`scare-${Math.ceil(Math.random() * AudioFiles)}`, 1.2, "mp3", () => {
            ShowJumpscare = false;
        });
    };
    OnEvent("Halloween", "DoJumpscare", Jumpscare);
</script>

<AppWrapper AppName="JumpScare" Focused={ShowJumpscare}>
    {#if ShowJumpscare}
        <img
            alt=""
            src="./images/jumpscare/{JumpscareFile}"
            class="jumpscare-image"
            out:fade={{duration: 250}}
        />
    {/if}
</AppWrapper>

<style>
    .jumpscare-image {
        position: absolute;
        top: 0;
        left: 0;

        width: 100vw;
        height: 100vh;
    }
</style>