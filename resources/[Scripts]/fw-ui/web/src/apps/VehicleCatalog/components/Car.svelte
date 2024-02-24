<script>
    import { FormatCurrency } from "../../../utils/Utils";

    export let Image = 'preview';
    export let Price = 0;
    export let Name = 'Unknown Car';
    export let Selected = false;
    export let HtmlRef;
</script>

<div
    on:keyup on:click
    bind:this={HtmlRef}
    class="catalog-car-item"
    class:catalog-car-item-selected={Selected}
    style="background-image: url('./images/pdm/{Image}.jpg')"
>
    <div class="catalog-car-item-price">{FormatCurrency.format(Price)}</div>
    <div class="catalog-car-item-name">{Name}</div>
</div>

<style>
    .catalog-car-item {
        display: inline-block;
        position: relative;

        margin-right: .5vw;
        margin-left: .5vw;
        margin-bottom: 1vh;

        width: 26.93vh;
        height: 15vh;

        cursor: pointer;

        background-size: cover;
        background-position: center;
        border-bottom: .4vh solid white;
        background-color: black;
    }

    .catalog-car-item-price {
        position: absolute;

        right: 1.2vh;
        top: 1vh;

        font-size: 1.6vh;
        font-weight: 900;
        text-align: right;
        font-style: italic;
        color: rgb(219, 219, 219);
    }

    .catalog-car-item-name {
        position: absolute;

        right: 1.2vh;
        bottom: 1vh;

        font-size: 1.6vh;
        font-weight: 900;
        text-align: right;
        font-style: italic;
        color: rgb(219, 219, 219);
    }
    .catalog-car-item-selected { border-color: orange; }
    .catalog-car-item-selected > .catalog-car-item-price { color: orange; }
</style>