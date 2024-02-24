<script>
    export let FilmsLeft = 0;
    let innerHeight;
</script>

<svelte:window bind:innerHeight />

<div class="polaroid-camera">
    <div class="polaroid-camera-bar-left">

        <div class="polaroid-camera-help">
            <span>Hoe werkt het</span>
            <div class="polaroid-camera-help-entry">
                <kbd>E</kbd> om een foto te maken.
            </div>
            <div class="polaroid-camera-help-entry">
                <kbd>LMB</kbd> om een filter te selecteren.
            </div>
            <div class="polaroid-camera-help-entry">
                <kbd>ESC</kbd> of <kbd>RMB</kbd> om te stoppen.
            </div>
        </div>

    </div>
    <div class="polaroid-camera-center">
        <div class="polaroid-camera-top-left-corner">🔴 Clarity Polaroid</div>
        <div class="polaroid-camera-bottom-left-corner">{innerHeight}x{innerHeight}px</div>
        <div class="polaroid-camera-top-right-corner">📷 {FilmsLeft} over</div>
        <div class="polaroid-camera-bottom-right-corner">1:1 Aspect Ratio</div>
    </div>
    <div class="polaroid-camera-bar-right"></div>
</div>

<style>
    .polaroid-camera {
        width: 100vh;
        height: 100vh;
    }

    .polaroid-camera-bar-left {
        position: absolute;
        left: 0;
        top: 0;

        width: 38.84vh;
        height: 100vh;
        background-color: black;
    }

    .polaroid-camera-help {
        position: absolute;
        left: 50%;
        top: 50%;

        transform: translate(-50%, -50%);

        padding: 2vh 3.5vh;

        border-radius: 1vh;

        font-size: 1.2vh;

        color: black;

        width: 26.6vh;
        height: max-content;
        background-color: white;
    }

    .polaroid-camera-help > span {
        font-size: 1.5vh;
        font-weight: bold;

        display: block;
        margin-bottom: 2vh;
    }

    .polaroid-camera-help-entry {
        margin-bottom: 1vh;
    }

    .polaroid-camera-center { 
        position: absolute;
        top: 50%;
        left: 50%;
        
        transform: translate(-50%, -50%);

        width: 98vh;
        height: 98vh;

        border: white solid transparent;
        background:
        conic-gradient(from 90deg  at top    .2vh left  .2vh, transparent 90deg, white 0) 0    0,
        conic-gradient(from 180deg at top    .2vh right .2vh, transparent 90deg, white 0) 100% 0,
        conic-gradient(from 0deg   at bottom .2vh left  .2vh, transparent 90deg, white 0) 0    100%,
        conic-gradient(from -90deg at bottom .2vh right .2vh, transparent 90deg, white 0) 100% 100%;

        background-size: 12vh 6vh;
        background-repeat: no-repeat;
    }

    .polaroid-camera-bar-right {
        position: absolute;
        right: 0;
        top: 0;

        width: 38.84vh;
        height: 100vh;
        background-color: black;
    }


    .polaroid-camera-top-left-corner,
    .polaroid-camera-bottom-left-corner,
    .polaroid-camera-top-right-corner,
    .polaroid-camera-bottom-right-corner {
        font-family: Roboto Mono;
        font-size: 1.5vh;
        font-weight: bold;

        color: white;

        margin: 1.5vh;

        width: 12vh;
    }

    .polaroid-camera-bottom-left-corner {
        position: absolute;
        bottom: 0;
    }

    .polaroid-camera-top-right-corner {
        position: absolute;
        top: 0;
        right: 0;
        text-align: right;
        width: 6vh;
    }

    .polaroid-camera-bottom-right-corner {
        position: absolute;
        right: 0;
        bottom: 0;
        text-align: right;
    }
</style>