<script>
    import { PhoneBackground } from "../phone.stores";
    export let backgroundOverride = false;
</script>

<div
    class="phone-screen"
    style="background: {backgroundOverride ? backgroundOverride : `url(${$PhoneBackground}) center center / cover repeat`}"
>
    <slot></slot>
</div>

<div class="android-phone-frame">
    <div class="android-phone-border">
        <div class="android-phone-highlight" />
        <div class="android-phone-shadow">
            <div class="android-phone-shadow-bg" />
        </div>
    </div>
</div>

<style>
    .phone-screen {
        top: unset;
        left: unset;
        right: 1.5vh;
        width: 25.92vh;
        bottom: 1.11vh;
        height: 60.37vh;
        z-index: 20;
        position: absolute;
        min-width: 25.92vh;
        min-height: 60.37vh;
        pointer-events: all;
        margin: unset;
        overflow: hidden;
        background: url(https://i.imgur.com/3KTfLIV.jpg) center center / cover repeat;
        background-size: 100% 100%;
        border-radius: 0.5vh;
        background-repeat: repeat
    }

    .android-phone-frame {
        top: unset;
        left: unset;
        right: 1.47vh;
        width: 25.92vh;
        bottom: 1.1vh;
        height: 60.37vh;
        margin: unset;
        position: absolute;
        animation: 500ms ease 0s 1 normal none running rotateportrait;
        min-width: 25.92vh;
        transform: rotate(0deg) scale(1);
        min-height: 60.37vh;
        transition: bottom 800ms ease 0s;
        transform-style: preserve-3d
    }

    .android-phone-border {
        top: -0.74vh;
        left: -0.36vh;
        width: 26.66vh;
        height: 61.85vh;
        padding: 0.92vh 0.55vh;
        z-index: 10;
        position: absolute;
        background: black;
        box-sizing: border-box;
        border-radius: 1.1vh
    }

    .android-phone-highlight {
        top: 0.18vh;
        left: 0;
        width: 100%;
        height: calc(100% - 0.74vh);
        content: "";
        z-index: 1;
        position: absolute;
        background: black;
        border-top: .2vh solid rgb(159, 160, 162);
        box-shadow: rgb(255 255 255 / 50%) 0 0 0.5vh 0 inset;
        border-bottom: .2vh solid rgb(159, 160, 162);
        border-radius: 1.1vh
    }

    .android-phone-shadow {
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        overflow: hidden;
        position: absolute;
        border-radius: 1.1vh
    }

    .android-phone-shadow-bg {
        top: -0.5%;
        left: 0.92vh;
        width: calc(100% - 1.84vh);
        height: 101%;
        content: "";
        z-index: 5;
        position: absolute;
        box-shadow: white 0 0 5.5vh 0 inset, rgb(255 255 255 / 50%) 0 0 2.7vh 0 inset, white 0 0 1.85vh 0, rgb(255 255 255 / 50%) 0 0 1.85vh 0;
        border-radius: 2.2vh;
        pointer-events: none
    }
</style>