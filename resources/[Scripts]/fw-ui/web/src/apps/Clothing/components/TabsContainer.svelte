<script>
    import Button from "../../../lib/Button/Button.svelte";
    import { Tax } from "../../../stores";
    import { FormatCurrency, SendEvent as _SendEvent } from "../../../utils";
    import { ClothingPrice, CurrentTab } from "../clothing.store";

    const SendEvent = (Event, Parameters, Callback) => {
        _SendEvent(Event, Parameters, Callback, "fw-clothes")
    };

    import Accessoires from "../pages/Accessoires.svelte";
    import Clothes from "../pages/Clothes.svelte";
    import Face from "../pages/Face.svelte";
    import Hair from "../pages/Hair.svelte";
    import Makeup from "../pages/Makeup.svelte";
    import Parents from "../pages/Parents.svelte";
    import Peds from "../pages/Peds.svelte";
    import Skin from "../pages/Skin.svelte";
    import Tattoos from "../pages/Tattoos.svelte";

    const TabComponents = {
        "accessoires": Accessoires,
        "clothes": Clothes,
        "face": Face,
        "hair": Hair,
        "makeup": Makeup,
        "parents": Parents,
        "peds": Peds,
        "skin": Skin,
        "tattoos": Tattoos
    }

</script>
<div class="clothing-tabs-container">

    <div class="clothing-payment">
        {#if $ClothingPrice == 0}
            <p>Gratis</p>
        {:else}
            <p>{FormatCurrency.format($ClothingPrice)} Incl. {$Tax.Clothes}% btw</p>
        {/if}
        <div>
            <Button
                on:click={() => SendEvent("Clothing/CloseMenu", {Pay: true, Type: "Cash"}) }
                Color="success"
                style="padding: .8vh 1.8vh; margin: 0; border-top-right-radius: 0; border-bottom-right-radius: 0;"
            >Betalen</Button>
            <Button
                on:click={() => SendEvent("Clothing/CloseMenu", {Pay: false}) }
                Color="warning"
                style="padding: .8vh 1.8vh; margin: 0; border-top-left-radius: 0; border-bottom-left-radius: 0;"
            >Sluiten</Button>
        </div>
    </div>

    <div class="clothing-cards">
        <svelte:component this={TabComponents[$CurrentTab]} />
    </div>
</div>

<style>
    .clothing-tabs-container {
        display: flex;
        flex-direction: column;
        align-items: center;

        height: 100vh;
        width: 38.1vh;

        background-color: rgb(34, 40, 49);
    }

    .clothing-payment {
        display: flex;
        justify-content: space-between;
        align-items: center;

        width: 93%;
        height: 6vh;

        margin-bottom: .7vh;
    }

    .clothing-payment > p {
        color: #b6c4a1;

        font-size: 1.85vh;
        font-weight: bold;
        letter-spacing: .01vh;
    }
    
    .clothing-cards {
        height: calc(100% - 6.7vh);
        width: 94%;

        overflow: auto;
    }

    .clothing-cards::-webkit-scrollbar {
        display: none;
    }
</style>