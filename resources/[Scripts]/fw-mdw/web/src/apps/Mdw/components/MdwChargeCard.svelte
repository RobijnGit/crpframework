<script>
    import { FormatCurrency } from "../../../utils/Utils";

    export let name = '';
    export let type = 'Normal';
    export let description = '';

    export let fine = 0;
    export let jail = 0;
    export let points = 0;
    export let accomplice = [];
    export let attempted = [];

    const IsChargeValid = (Data) => {
        console.log(JSON.stringify(Data));
        if (
            (!Data || Data == "")
            || ((!Data.jail || Data.jail == "" || Data.jail == "0" || Data.jail <= 0)
            && (!Data.fine || Data.fine == "" || Data.fine == "0" || Data.fine <= 0)
            && (!Data.points || Data.points == "" || Data.points == "0" || Data.points <= 0))
        ) return false;

        return true;
    }
</script>

<div data-tooltip={description || ' '} class="mdw-charge-container charge-{type.toLowerCase()}" on:click on:keyup>
    <p class="mdw-charge-header">{name}</p>
    <div class="mdw-charge-info">
        <p>{jail} maand(en)</p>
        <p>{FormatCurrency.format(fine)}</p>
        <p>{points} punt(en)</p>
    </div>
    {#if IsChargeValid(accomplice)}
        <hr style="border-top: none; border-right: none; border-bottom: 0.1vh solid black; border-left: none; border-image: initial;">
        <p class="mdw-charge-subheader">Medeplichtigheid</p>
        <div class="mdw-charge-info">
            <p>{accomplice.jail} maand(en)</p>
            <p>{FormatCurrency.format(accomplice.fine)}</p>
            <p>{accomplice.points} punt(en)</p>
        </div>
    {/if}
    {#if IsChargeValid(attempted)}
        <hr style="border-top: none; border-right: none; border-bottom: 0.1vh solid black; border-left: none; border-image: initial;">
        <p class="mdw-charge-subheader">Poging Tot</p>
        <div class="mdw-charge-info">
            <p>{attempted.jail} maand(en)</p>
            <p>{FormatCurrency.format(attempted.fine)}</p>
            <p>{attempted.points} punt(en)</p>
        </div>
    {/if}
</div>

<style>
    .mdw-charge-container {
        position: relative;
        float: left;
        width: 18.4vw;
        height: fit-content;
        margin-right: .5vw;
        margin-bottom: 2vh;
        font-family: Roboto;
        padding: 1vh;
        user-select: text;
        text-shadow: 0 0 .2vh black;
        border: .25vh solid #212730
    }

    .mdw-charge-container.charge-normal {
        background-color: #406f10
    }

    .mdw-charge-container.charge-major {
        background-color: #7e5802
    }

    .mdw-charge-container.charge-extreme {
        background-color: #7c2000
    }

    .mdw-charge-container > .mdw-charge-header {
        position: relative;
        color: white;
        font-size: 1.7vh;
        text-align: center
    }

    .mdw-charge-container > .mdw-charge-subheader {
        position: relative;
        color: white;
        font-size: 1.3vh;
        text-align: center;
        margin-top: 1vh
    }

    .mdw-charge-container > .mdw-charge-info {
        display: flex;
        justify-content: space-between;
        width: 90%;
        margin: .5vh auto;
        font-size: 1.3vh;
        color: white;
        padding-bottom: .7vh
    }

    .mdw-charge-container > .mdw-charge-info:last-of-type {
        padding-bottom: 0
    }
</style>