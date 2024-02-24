<script>
    import { PhoneBackground } from "../phone.stores";

    export let backgroundOverride = false;
</script>

<div
    class="phone-screen"
    style="background: {backgroundOverride ? backgroundOverride : `url(${$PhoneBackground}) center center / cover repeat`}"
>
    <slot></slot>
    <div class="ios-notch">
        <div class="ios-notch-edges" />
        <div class="ios-notch-item">
            <div class="speaker" />
        </div>
        <div class="ios-notch-item">
            <div class="camera" />
        </div>
    </div>
</div>

<div class="ios-phone-frame">
    <div class="ios-phone-frame-border">
        <div class="ios-phone-top-ring" />
        <div class="ios-phone-bottom-ring" />
        <div class="ios-phone-buttons" />
        <div class="ios-phone-shadow">
            <div class="inner-shadow-bg" />
        </div>
    </div>
</div>

<style>
    .phone-screen {
        top: unset;
        left: unset;
        right: 1.66666667vh;
        width: 25.92vh;
        bottom: 1.7vh;
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
        border-radius: 1.48vh;
        background-repeat: repeat;
    }

    /* .phone-container.phone-burner>.phone-screen {
        background: linear-gradient(45deg, rgba(106, 158, 224, 1) 0%, rgba(144, 191, 239, 1) 100%) !important
    } */

    .ios-notch {
        top: 0;
        left: calc(50% - 5.64vh);
        width: 11.28vh;
        height: 2.2vh;
        display: flex;
        z-index: 200;
        position: absolute;
        background-color: black;
        border-bottom-left-radius: 1.85vh;
        border-bottom-right-radius: 1.85vh;
    }

    .ios-notch::before {
        top: 0;
        right: -0.74vh;
        width: 0.74vh;
        height: 0.74vh;
        content: "";
        position: absolute;
        background: radial-gradient(
            circle at right bottom,
            transparent 0,
            transparent 70%,
            black 70%,
            black 100%
        );
    }

    .ios-notch-edges {
        flex: 1 1 0%;
        width: 100%;
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .ios-notch-item {
        flex: 1 1 0%;
        width: 100%;
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .speaker {
        width: 100%;
        height: 0.5vh;
        background: rgb(23, 24, 24);
        border-radius: 0.5vh;
    }

    .ios-notch-item {
        flex: 1 1 0%;
        width: 100%;
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .camera {
        width: 0.55vh;
        height: 0.5vh;
        background: rgb(13, 77, 113);
        border-radius: 100%;
    }

    .ios-notch::after {
        top: 0;
        left: -0.74vh;
        width: 0.74vh;
        height: 0.74vh;
        content: "";
        position: absolute;
        background: radial-gradient(
            circle at left bottom,
            transparent 0,
            transparent 70%,
            black 70%,
            black 100%
        );
    }

    .ios-phone-frame {
        top: unset;
        left: unset;
        right: 1.66vh;
        width: 25.92vh;
        bottom: 1.6vh;
        height: 60.37vh;
        margin: unset;
        position: absolute;
        min-width: 25.92vh;
        transform: rotate(0deg) scale(1);
        min-height: 60.37vh;
        transition: bottom 800ms ease 0s;
        transform-style: preserve-3d;
    }

    .ios-phone-frame-border {
        top: -1.8vh;
        left: -1.85vh;
        width: 29.62vh;
        height: 64.07vh;
        padding: 1.85vh;
        z-index: 10;
        position: absolute;
        background: rgb(253, 253, 253);
        box-shadow: black 0 0 0.83vh 0 inset;
        box-sizing: border-box;
        border-radius: 2.7vh;
        transform-style: preserve-3d;
    }

    .ios-phone-frame-border::before {
        top: 0.462vh;
        left: 0.55vh;
        width: calc(100% - 0.93vh);
        height: calc(100% - 0.925vh);
        content: "";
        position: absolute;
        border-radius: 2.4vh;
        background-color: black;
    }

    .ios-phone-top-ring {
        top: 5.925vh;
        left: 0;
        width: 100%;
        height: 0.74vh;
        position: absolute;
        background: rgba(0, 0, 0, 0.1);
    }

    .ios-phone-bottom-ring {
        left: 0;
        width: 100%;
        bottom: 5.925vh;
        height: 0.74vh;
        position: absolute;
        background: rgba(0, 0, 0, 0.1);
    }

    .ios-phone-buttons {
        top: 8.51vh;
        left: -0.28vh;
        width: 0.28vh;
        height: 2.407vh;
        position: absolute;
        background: rgb(181, 181, 181);
        border-top-left-radius: 0.37vh;
        border-bottom-left-radius: 0.37vh;
    }

    .ios-phone-buttons::before {
        top: 4.62vh;
    }

    .ios-phone-buttons::before,
    .ios-phone-buttons::after {
        left: 0;
        width: 0.28vh;
        height: 4.62vh;
        content: "";
        position: absolute;
        background: rgb(181, 181, 181);
        border-top-left-radius: 0.37vh;
        border-bottom-left-radius: 0.37vh;
    }

    .ios-phone-buttons::after {
        top: 10.37vh;
    }

    .ios-phone-shadow {
        top: 0.925vh;
        left: 0.93vh;
        width: calc(100% - 1.85vh);
        height: calc(100% - 1.8vh);
        z-index: 101;
        overflow: hidden;
        position: absolute;
        box-shadow: rgb(255 255 255 / 66%) 0 0 1.38vh 0 inset;
        border-radius: 2.2vh;
    }

    .ios-phone-shadow::before {
        top: -8%;
        left: 0;
        width: 100%;
        height: 116%;
        content: "";
        position: absolute;
        box-shadow: rgb(255 255 255) 0 0 1.85vh 0 inset;
    }
</style>
