<script>
    import Button from "../../../lib/Button/Button.svelte";
    import { FormatCurrency, SendEvent as _SendEvent } from "../../../utils/Utils";
    import { CurrentAccount, CurrentTransactions, IsATM, ModalData } from "../financials.store";
    const SendEvent = (Event, Parameters, Callback) => _SendEvent(Event, Parameters, Callback, "fw-financials");

    export let Type = '';
    export let Name = '';
    export let AccountId = '';
    export let Owner = '';
    export let Balance = 0;
    export let Permissions = {};
    export let Active = false;

    const Deposit = () => {
        if (!Permissions.Deposit || !Active) return;
        ModalData.set({AccountName: Name, AccountId, Type: "Deposit", Show: true});
    };

    const Withdraw = () => {
        if (!Permissions.Withdraw || !Active) return;
        ModalData.set({AccountName: Name, AccountId, Type: "Withdraw", Show: true});
    };

    const Transfer = () => {
        if (!Permissions.Transfer || !Active) return;
        ModalData.set({AccountName: Name, AccountId, Type: "Transfer", Show: true});
    };

    const LoadAccount = (e) => {
        if ($CurrentAccount?.AccountId != AccountId) CurrentTransactions.set([]); 

        CurrentAccount.set({Type, Name, AccountId, Owner, Balance, Permissions, Active});
        if (!Permissions.Transactions) return;

        SendEvent("Financials/GetTransactions", {AccountId}, (Success, Data) => {
            if (!Success) return;
            CurrentTransactions.set(Data);
        })
    };
</script>

<div
    class="financials-accountcard-container"
    class:selected={Active && $CurrentAccount?.AccountId == AccountId}
    class:disabled={!Active}
    on:keyup on:click={(e) => Active && LoadAccount(e)}
>
    <p
        class="financials-accountcard-name"
        data-tooltip="Bankrekeningnaam / Bankrekeningnummer"
    >{Name} / {AccountId}</p>

    <div class="financials-accountcard-details">
        <div style="flex: 1 1 0%;">
            <p
                data-tooltip="Account Type"
                style="font-size: 1.4vh; font-family: Roboto; font-weight: 400; line-height: 1.2; letter-spacing: 0.017136vh; word-break: break-word;"
            >{Type}</p>
            <p
                style="font-size: 1.4vh; font-family: Roboto; font-weight: 400; line-height: 1.2; letter-spacing: 0.017136vh; word-break: break-word;"
            >{Owner}</p>
        </div>
        <div style="flex: 1 1 0%; margin: 0.8vh 0px;">
            <p
                style="font-size: 2.4vh; font-family: Roboto; font-weight: 400; letter-spacing: 0px; text-align: right;"
            >{FormatCurrency.format(Balance)}</p>
            <p
                style="font-size: 1.6vh; font-family: Roboto; font-weight: 400; letter-spacing: 0.015008vh; text-align: right;"
            >Beschikbaar Balans</p>
        </div>
    </div>

    <div class="financials-accountcard-actions">
        {#if !$IsATM} <Button Color={!Permissions.Deposit || !Active ? "disabled" : "success"} style="margin: 0px;" on:click={() => Deposit()}>Storten</Button> {/if}
        <Button Color={!Permissions.Withdraw || !Active ? "disabled" : "warning"} style="margin: 0px;" on:click={() => Withdraw()}>Opnemen</Button>
        <Button Color={!Permissions.Transfer || !Active ? "disabled" : "default"} style="margin: 0px;" on:click={() => Transfer()}>Overmaken</Button>
    </div>
</div>

<style>
    .financials-accountcard-container:first-child {
        margin-top: 0
    }

    .financials-accountcard-container:last-child {
        margin-bottom: 0
    }

    .financials-accountcard-container {
        border: 0.1vh solid transparent;
        background-color: rgb(48, 71, 94);
        width: 94.8%;
        margin: 1.6vh 0;
        padding: .7vh;
        border-radius: .4vh;
        color: white
    }

    .financials-accountcard-container.disabled {
        border-color: azure;
        background-color: rgb(135, 135, 135) !important
    }

    .financials-accountcard-container.selected {
        border-color: rgb(120, 167, 216);
        background-color: rgb(30, 58, 86)
    }

    .financials-accountcard-name {
        font-size: 1.6vh;
        font-family: Roboto;
        font-weight: 400;
        line-height: 1.5;
        letter-spacing: 0.015008vh;
        color: white;
        display: inline-block
    }

    .financials-accountcard-details {
        width: 100%;
        display: flex;
        flex-direction: row
    }

    .financials-accountcard-actions {
        width: 100%;
        display: flex;
        align-items: center;
        justify-content: space-between
    }
</style>