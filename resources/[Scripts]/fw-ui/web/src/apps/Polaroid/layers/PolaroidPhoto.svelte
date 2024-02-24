<script>
    export let ShowTape = false;
    export let RotateText = false;

    export let Image;
    export let Date = '04-07-2023';

    const Rotation = ShowTape ? Math.ceil(Math.random() * 3) * (Math.round(Math.random()) ? 1 : -1) : 0
    const TextRotation = RotateText ? Math.ceil(Math.random() * 3) * (Math.round(Math.random()) ? 1 : -1) : 0
</script>

<div class="polaroid-photo" style="transform: rotate({Rotation}deg)" on:keyup on:click>
    {#if ShowTape}
        <div class="polaroid-photo-tape"></div>
    {/if}
    <div class="polaroid-date">{Date}</div>
    <div class="polaroid-image" style="background-image: url({Image});"></div>
    <div class="polaroid-text" style="transform: rotate({TextRotation}deg)"><slot/></div>
    {#if ShowTape}
        <div class="polaroid-photo-tape"></div>
    {/if}
</div>

<style>
    .polaroid-photo {
        position: relative;

        width: 35.73vh;
        min-height: 43.9vh;
        height: max-content;

        background-color: white;
        
        border-radius: .4vh;
    }

    .polaroid-photo > .polaroid-date {
        position: relative;
        right: 0;
        left: 0;
        
        margin: 0 auto;
        padding-top: 1.5vh;

        width: 90%;

        font-family: Roboto;
        font-size: 1vh;
        font-weight: bold;
        
        text-align: right;
        color: rgba(150, 150, 150, 1);
    }

    .polaroid-photo > .polaroid-image {
        position: relative;
        left: 0;
        right: 0;
        
        margin: 0 auto;
        margin-bottom: 1vh;
        margin-top: 1vh;
        
        width: 89%;
        height: 70vh;
        max-height: 37vh;

        background-position: center center;
        background-size: cover;

        background-image: url(https://cdn.discordapp.com/attachments/967915908049797151/969010678692200458/fw1651100547.jpg)
    }

    .polaroid-text {
        position: relative;
        left: 0;
        right: 0;

        margin: 0 auto;
        
        text-align: center;

        width: 90%;
        height: max-content;

        padding-bottom: 1vh;

        font-family: PinkChicken;
        font-size: 1.5vh;

        /* transform: rotate(-2deg); */

        color: black;
    }

    .polaroid-photo-tape {
        position: absolute;
        width: 100%;
    }

    .polaroid-photo-tape:first-of-type { top: 0 }
    .polaroid-photo-tape:last-of-type { bottom: 0 }

    .polaroid-photo-tape::before,
    .polaroid-photo-tape::after {
        content: "";
        position: absolute;

        width: 6vh;
        height: 2.5vh;
        
        opacity: 0.5;
        
        background-color: #dbd8be;
        border-right: .1vh dotted #b7b49d;
        border-left: .1vh dotted #b7b49d;
    }

    .polaroid-photo-tape:last-of-type::after {
        top: -1.5vh;
        right: -3vh;
        transform: rotate(-45deg);
    }

    .polaroid-photo-tape:first-of-type::before {
        top: -1vh;
        left: -3vh;
        transform: rotate(-45deg);
    }

    .polaroid-photo-tape:last-of-type::before,
    .polaroid-photo-tape:first-of-type::after { display: none }
</style>