<script>
    import { fade } from "svelte/transition";

    export let Icon = 'microphone';
    export let Value = 0;
    export let Color = 'white';
    export let Buffed = false;
    export let Danger = false;
    export let Text = false;
</script>

<div class="circle-wrapper" style="transition-duration: 0s; transition-timing-function: ease; transition-delay: unset; transition-property: none;" out:fade={{duration: 1000}}>
    <div class="circle-ring circle-outer-background">
        <svg viewBox="0 0 48 48" version="1.1" xmlns="http://www.w3.org/2000/svg" style="height: 4.45vh; width: 4.45vh; transform: rotate(-90deg); z-index: 100;">
            <circle r="20" cx="24" cy="24" fill="transparent" stroke="{(!Buffed && Danger && Value <= 15.0) && 'red' || Color}" stroke-width="6" stroke-dasharray="125.66370614359172" stroke-dashoffset="0" stroke-opacity=" {(Danger && Value <= 15.0) && '1' || '0.35'}" style="transition: stroke-dashoffset 500ms linear 0s; will-change: transition;"></circle>
        </svg>
    </div>
    <div class="circle-ring circle-outer">
        <svg viewBox="0 0 48 48" version="1.1" xmlns="http://www.w3.org/2000/svg" style="height: 4.45vh; width: 4.45vh; transform: rotate(-90deg); z-index: 200;">
            <circle r="20" cx="24" cy="24" fill="transparent" stroke="{Color}" stroke-width="6" stroke-dasharray="125.66370614359172" stroke-dashoffset="{((100 - Value) / 100) * 125.66370614359172}" stroke-opacity="1" style="transition: stroke-dashoffset 500ms linear 0s; will-change: transition;"></circle>
        </svg>
    </div>
    <div class="circle-ring circle-inner">
        <div class="circle-inner-icon">
            <i style="color: {Buffed ? '#ffd700' : 'white'}; opacity: {Text ? 0.2 : 1.0};" class="fas fa-{Icon}"></i>
        </div>

        {#if Text}
            <div class="radio-number" transition:fade={{duration: 250}}>{Text}</div>
        {/if}
    </div>
</div>

<style>
    .circle-wrapper {
        display: flex;
        position: relative;

        width: 4.8vh;
        height: 4.8vh;

        align-items: center;
        justify-content: center;
    }

    .circle-ring {
        display: flex;
        position: absolute;

        top: 0;
        left: 0;

        width: 100%;
        height: 100%;

        align-items: center;
        justify-content: center;
    }

    .circle-inner-icon {
        display: flex;

        width: 3.3vh;
        height: 3.3vh;

        align-items: center;
        border-radius: 100%;
        background-color: rgb(33, 33, 33);
    }

    .circle-inner-icon > i {
        width: 100%;

        color: white;
        font-size: 1.5vh;
        text-align: center;

        transition: opacity 0.35s ease;
    }

    .circle-inner > .radio-number {
        color: white;
        font-family: Arial, Helvetica, sans-serif;
        font-size: 1.2vh;
        position: absolute;
    }
</style>