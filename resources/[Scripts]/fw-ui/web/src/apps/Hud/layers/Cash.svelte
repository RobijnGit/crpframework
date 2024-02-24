<script>
    import { fade } from "svelte/transition";
    import { AddSpaces, OnEvent } from "../../../utils/Utils";

    var ShowingCash = false;
    let FlashTimeout = false;
    var CashActions = [];
    var MyCash = 0;

    OnEvent("Hud", "ShowCash", Cash => {
        MyCash = Cash;
        ShowingCash = true;
        if (FlashTimeout) clearTimeout(FlashTimeout);
        FlashTimeout = setTimeout(() => {
            if (CashActions.length == 0) ShowingCash = false;
        }, 3500);
    });

    OnEvent("Hud", "ShowCashChange", (Data) => {
        MyCash = Data.MyCash;
        ShowingCash = true;

        var Id = Math.floor(Math.random() * 10000)
        const CashAction = {
            Id: Id,
            Plus: Data.Plus,
            Amount: Data.Amount,
        };

        CashActions = [CashAction, ...CashActions];
        setTimeout(() => {
            CashActions = CashActions.filter(C => C.Id !== Id);
            if (CashActions.length == 0) ShowingCash = false;
        }, 3500);
    });

</script>

{#if ShowingCash}
    <div out:fade={{duration: 500}} class="cash-flash">
        <div class="cash-flash-item player-cash">
            <span class="cash-flash-dollar">€</span>
            <span class="cash-flash-amount">{AddSpaces(MyCash)}</span>
        </div>
        {#each CashActions as Cash}
            <div out:fade={{duration: 500}} class="cash-flash-item cash-flash-{Cash.Id}">
                <span class="cash-flash-icon">{Cash.Plus ? '+' : '-'}</span>
                <span class="cash-flash-dollar" class:negative={!Cash.Plus}>€</span>
                <span class="cash-flash-amount">{AddSpaces(Cash.Amount)}</span>
            </div>
        {/each}
    </div>
{/if}

<style>
    .cash-flash {
        position: absolute;

        top: 20vh;
        right: 0;

        max-height: 30vh;
        overflow: hidden auto;

        color: white;
        width: 100vw;
        padding: 1.6vh;
        font-size: 3.6vh;
        text-align: right;
        font-family: pricedown;
        text-shadow: black 0.2vh 0.2vh;
    }

    .cash-flash::-webkit-scrollbar { display: none; }

    .cash-flash > .cash-flash-item > .cash-flash-icon {
        position: relative;
        left: .5vh;
        
        font-family: Arial;
        font-weight: bold;

        font-size: 3vh;
    }

    .cash-flash > .cash-flash-item > .cash-flash-dollar,
    .cash-flash > .cash-flash-item > .cash-flash-amount { margin-left: 0.8vh; }
    .cash-flash > .cash-flash-item > .cash-flash-dollar { color: green; }
    .cash-flash > .cash-flash-item > .cash-flash-dollar.negative { color: red; }
</style>