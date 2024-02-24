<script>
    import TextField from "../../../lib/TextField/TextField.svelte";
    import { FormatCurrency, GetTimeLabel } from "../../../utils/Utils";

    export let AccountName = '';
    export let AccountId = '';
    export let TransactionType = '';
    export let TransactionUUID = '';
    export let Amount = 0;
    export let IsNegative = false;
    export let Sender = '';
    export let Receiver = '';
    export let Message = '';
    export let Timestamp = 0;
</script>

<div class="financials-transactioncard-container">
    <div style="display: flex; flex-direction: row; justify-content: space-between;">
        <p
            style="font-size: 1.4vh; font-family: Roboto; font-weight: 400; line-height: 1.2; letter-spacing: 0.017136vh; word-break: break-word; color: white;"
        >{AccountName} / {AccountId} [{TransactionType}]</p>
        <p
            style="font-size: 1.4vh; font-family: Roboto; font-weight: 400; line-height: 1.2; letter-spacing: 0.017136vh; word-break: break-word; color: white;"
        >{TransactionUUID}</p>
    </div>
    <hr style="width: 100%; margin: 1vh 0px;">
    <div style="display: flex; flex-direction: row; justify-content: space-between; width: 100%;">
        <p
            style="color: var(--mdc-theme-{IsNegative ? "secondary" : "primary"}); font-size: 2.4vh; font-family: Roboto; font-weight: 400; letter-spacing: 0px; width: 24vh;"
        >{IsNegative ? "-" : "+"}{FormatCurrency.format(Amount)}</p>
        <p
            style="flex: 1 1 0%; color: white; font-size: 1.8vh; font-weight: 500; letter-spacing: 0px; font-family: Roboto; margin: 0px;"
        >
            {Receiver}
        </p>
        <div style="max-width: 28vh; text-align: right;">
            <div>
                <p
                    style="color: white; font-size: 1.8vh; font-weight: 500; letter-spacing: 0px; font-family: Roboto; margin: 0px;"
                >
                    {GetTimeLabel(Timestamp)}
                </p>
            </div>
        </div>
    </div>
    <div style="display: flex; flex-direction: row; justify-content: space-between; width: 100%;">
        <p
            style="flex: 1 1 0%; text-align: right; color: white; font-size: 1.8vh; font-weight: 500; letter-spacing: 0px; font-family: Roboto; margin: 0px;"
        >
            {Sender}
        </p>
    </div>
    <div style="display: flex; flex-direction: row; justify-content: space-between; width: 100%;">
        {#if Message}
            <TextField
                Title="Comment"
                BorderType="dotted"
                bind:RealValue={Message}
                ReadOnly={true}
            />
        {/if}
    </div>
</div>

<style>
    .financials-transactioncard-container:first-child {
        margin-top: 0
    }

    .financials-transactioncard-container {
        width: 96.7%;
        padding: 1.6vh;
        margin-top: 1.6vh;
        border-radius: .4vh;
        background-color: rgb(48, 71, 94)
    }
</style>