<script>
    import Ripple from "@smui/ripple";
    export let Image = 'https://i.imgur.com/C7BzBQ4.png';
    export let Name = 'Een Holle-Bolle Kitten';
    export let Price = 5;
</script>

<div class="cart-card">

    <img src="{Image}" alt="" class="cart-image" />

    <p class="cart-label">- {Name} (1x) - {Price} GNE</p>

    <div
        use:Ripple={{ surface: true, active: true }}
        class="cart-button"
        on:keyup on:click
    >
        Verwijderen van Winkelmandje
    </div>
</div>

<style>
    .cart-card {
        position: relative;

        display: flex;
        align-items: center;

        width: 100%;
        height: 6vh;
        background-color: #212121;

        border-radius: .6vh;

        text-align: center;

        font-family: Roboto;
        color: white;
        font-size: 1.4vh;

        margin-bottom: 1vh;
    }

    .cart-image {
        width: 5vh;
        height: auto;
        margin-left: 1vh;
        margin-right: 1.2vh;
    }

    .cart-button {
        margin-left: auto;
        margin-right: 2vh;

        padding: .8vh 1vh;
        border-radius: 4vh;
        font-size: 1.2vh;
        max-width: 60%;

        background-color: #f35451;
    }
</style>