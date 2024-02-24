<script>
    import Button from "../../lib/Button/Button.svelte";
    import { Tax } from "../../stores";
    import { FormatCurrency, SendEvent as _SendEvent } from "../../utils";
    import { ClosingModal, ClothingPrice } from "./clothing.store";

    const SendEvent = (Event, Parameters, Callback) => {
        _SendEvent(Event, Parameters, Callback, "fw-clothes")
    };

    const Pay = (Type) => {
        ClosingModal.set(false);
        SendEvent("Clothing/CloseMenu", {Pay: true, Type})
    };

    const Discard = () => {
        ClosingModal.set(false);
        SendEvent("Clothing/CloseMenu", {Pay: false})
    };

    const Close = () => {
        ClosingModal.set(false);
    };
</script>

<div class="close-modal-wrapper">
    <div class="close-modal-container">
        {#if $ClothingPrice > 0}
            <h2>Totaal: <span>{FormatCurrency.format($ClothingPrice)} Incl. {$Tax.Clothes}% btw</span></h2>
        {:else}
            <h2>Totaal: <span>Gratis</span></h2>
        {/if}

        <div class="close-modal-buttons">
            {#if $ClothingPrice > 0}
                <Button
                    Color="success"
                    style="margin: 0;"
                    on:click={() => Pay("Cash")}
                >Betaal met Cash</Button>

                <Button
                    Color="success"
                    style="margin: 0;"
                    on:click={() => Pay("Bank")}
                >Betaal met Bank</Button>
            {:else}
                <Button
                    Color="success"
                    style="margin: 0;"
                    on:click={() => Pay("Cash")}
                >Opslaan</Button>
            {/if}
            <Button
                Color="warning"
                style="margin: 0;"
                on:click={() => Discard()}
            >Annuleren</Button>
            <Button
                Color="default"
                style="margin: 0;"
                on:click={() => Close()}
            >Ga Terug</Button>
        </div>
    </div>

</div>

<style>
    .close-modal-wrapper {
        position: absolute;
        top: 0;
        left: 0;

        width: 100vw;
        height: 100vh;

        display: flex;
        justify-content: center;
        align-items: center;

        z-index: 999;
    }

    .close-modal-container {
        width: 50vh;
        height: 7.5vh;

        padding: 2.7vh;

        background-color: rgb(34, 40, 49);
    }

    .close-modal-container h2 {
        font-weight: 400;
        font-size: 2.2vh;
        color: white;

        margin-bottom: 1.9vh;
    }

    .close-modal-container h2 span {
        font-weight: 450;
        color: #b6c4a1;
    }

    .close-modal-buttons {
        display: flex;
        justify-content: space-between;

        width: 100%;
    }
</style>