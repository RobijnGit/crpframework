<script>
    import { onMount } from "svelte";
    import { SendEvent as _SendEvent, SetDropdown } from "../../../utils/Utils";
    import { CurrentModal } from "../state.store";

    const SendEvent = (Event, Parameters, Callback) => {
        _SendEvent(Event, Parameters, Callback, "fw-cityhall")
    };

    let Taxes = [];

    const ChangeTax = (Label) => {
        CurrentModal.set({
            Type: "ChangeTax",
            Cb: (NewValue) => {
                if (NewValue < 0 || NewValue > 50) {
                    CurrentModal.set(false);
                    return;
                };

                const Index = Taxes.findIndex(Val => Val.Label == Label);
                Taxes[Index].New = NewValue;
                Taxes = [...Taxes];

                SendEvent("State/SetTax", {Tax: Label, Value: NewValue}, (Success, Data) => {
                    CurrentModal.set({Type: "Success"});
                });
            }
        });
    };

    onMount(() => {
        SendEvent("State/GetTaxes", {}, (Success, Data) => {
            Taxes = [];

            const Current = Object.entries(Data.Current);
            for (let i = 0; i < Current.length; i++) {
                const Element = Current[i];

                Taxes.push({
                    Label: Element[0],
                    Current: Element[1],
                    New: Data.New[Element[0]]
                })
            }
        })
    });
</script>

<p class="preferences-header">Belasting</p>

{#each Taxes as Data, Key}
    <div class="tax-container">
        <p>{Data.Label} ({Data.Current}%)</p>
        <p>
            {#if Data.New && Data.Current != Data.New} Percentage na Tsunami: {Data.New}% {/if}
            <i
                class="fas fa-ellipsis-v"
                on:keyup
                on:click={(event) => {
                    const IconPosition = event.target.getBoundingClientRect();
                    const Left = IconPosition.left + 5;
                    const Top = IconPosition.top - 40;
                    SetDropdown(true,  [{ Text: "Belasting Veranderen", Cb: () => ChangeTax(Data.Label)}], { Left, Top });
                }}
            />
        </p>
    </div>
{/each}

<style>
    .tax-container {
        display: flex;
        justify-content: space-between;

        background-color: rgb(48, 71, 94);

        font-family: Roboto;
        font-size: 1.5vh;

        padding: 1vh;

        margin-bottom: .8vh;
    }

    .tax-container i {
        text-align: center;
        width: 2vh;
    }
</style>