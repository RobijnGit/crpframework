<script>
    import Ripple from "@smui/ripple";
    import { FormatDate, GetTimeLabel } from "../../../../utils/Utils";
    export let Image = 'https://i.imgur.com/C7BzBQ4.png';
    export let Name = 'Een Holle-Bolle Kitten';
    export let Timestamp = new Date().getTime();
    export let Price = 5;
    export let CartAmount = 0;

</script>

<div class="item-card">
    {#if CartAmount > 0}
        <div class="item-cart-amount">{CartAmount}</div>
    {/if}

    <img alt="" src={Image} />

    <p class="name">{Name}</p>
    <p class="price">Price: <span>{Price} GNE</span></p>
    <p data-tooltip={GetTimeLabel(Timestamp)} class="stock">Verkoopdatum:<br/><span>{FormatDate(Timestamp)}</span></p>

    <div
        use:Ripple={{ surface: true, active: true }}
        class="cart-button"
        on:keyup on:click
    >
        Toevoegen aan Winkelmandje
    </div>
</div>

<style>
    .item-card {
        position: relative;

        display: flex;
        flex-direction: column;
        align-items: center;

        width: 15.5vh;
        height: 27.5vh;
        background-color: #212121;

        border-radius: .6vh;

        text-align: center;

        font-family: Roboto;
        color: white;
        font-size: 1.2vh;
    }

    .item-card > .item-cart-amount {
        position: absolute;
        top: .5vh;
        right: .5vh;

        display: flex;
        justify-content: center;
        align-items: center;

        font-size: 1.3vh;
        border-radius: 50%;
        background-color: #6360f5;
        color: white;

        font-family: 'Times New Roman';

        width: 2.5vh;
        height: 2.5vh;
    }

    .item-card > img {
        margin-top: 2vh;
        width: 8vh;
        height: auto;
    }

    .item-card > .name {
        margin-top: 2vh;
        max-width: 70%;
        font-weight: bold;
    }

    .item-card > .stock {
        margin-top: .5vh;
        width: 70%;
    }

    .item-card > .price > span {
        color: green;
    }

    .item-card > .price {
        margin-top: 2vh;
    }

    .item-card > .cart-button {
        margin-top: auto;
        margin-bottom: 1.5vh;

        padding: .8vh 1vh;
        border-radius: 4vh;
        font-size: 1vh;
        max-width: 60%;

        background-color: #6360f5;
    }
</style>