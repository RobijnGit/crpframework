<script>
    import { FormatCurrency, SendEvent as _SendEvent } from "../../../utils/Utils";
    import { Cash, CurrentAccount, CurrentTransactions, ModalData } from "../financials.store";
    const SendEvent = (Event, Parameters, Callback) => _SendEvent(Event, Parameters, Callback, "fw-financials");

    import TextField from "../../../lib/TextField/TextField.svelte";
    import Modal from "../components/Modal.svelte";
    import Button from "../../../lib/Button/Button.svelte";

    let Amount;
    let Comment = '';
    let Loading = false;

    const Deposit = () => {
        const AccountId = $ModalData.AccountId
        Loading = true; 
        SendEvent("Financials/Deposit", {
            Amount,
            Comment,
            AccountId: $ModalData.AccountId
        }, (Success, Data) => {
            ModalData.set({Type: "Checkmark", Show: Success})
            Loading = false;
            if (Data.Cash != undefined) Cash.set(Data.Cash);
            if (!Success || !$CurrentAccount?.Permissions?.Transactions) return;
            SendEvent("Financials/GetTransactions", {AccountId}, (Success, Data) => {
                if (!Success) return;
                CurrentTransactions.set(Data);
            });
        });
    };
</script>

<Modal>
    {#if !Loading}
        <div class="financials-input-title">
            <p>{$ModalData.AccountName} / {$ModalData.AccountId}</p>
        </div>

        <TextField
            Title="Aantal"
            Icon="$"
            IconText={true}
            bind:RealValue={Amount}
            Type="number"
            Sub="€ 0,00"
            SubSet={() => FormatCurrency.format(Amount)}
        />

        <TextField
            Title="Comment"
            Icon="//"
            IconText={true}
            bind:RealValue={Comment}
        />

        <div class="financials-input-buttons">
            <Button
                on:click={() => ModalData.set({})}
                Color="warning"
            >Annuleren</Button>
            <Button
                on:click={Deposit}
                Color="success"
            >Storten</Button>
        </div>
    {:else}
        <div style="display: flex; justify-content: center; align-items: center; height: 20vh; width: 100%;">
            <svg xmlns="http://www.w3.org/2000/svg"
                xmlns:xlink="http://www.w3.org/1999/xlink" style="margin: auto; background: transparent; display: block; shape-rendering: auto;" width="15vh" height="15vh" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid">
                <g transform="rotate(0 50 50)">
                    <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                        <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.9166666666666666s" repeatCount="indefinite"></animate>
                    </rect>
                </g>
                <g transform="rotate(30 50 50)">
                    <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                        <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.8333333333333334s" repeatCount="indefinite"></animate>
                    </rect>
                </g>
                <g transform="rotate(60 50 50)">
                    <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                        <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.75s" repeatCount="indefinite"></animate>
                    </rect>
                </g>
                <g transform="rotate(90 50 50)">
                    <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                        <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.6666666666666666s" repeatCount="indefinite"></animate>
                    </rect>
                </g>
                <g transform="rotate(120 50 50)">
                    <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                        <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.5833333333333334s" repeatCount="indefinite"></animate>
                    </rect>
                </g>
                <g transform="rotate(150 50 50)">
                    <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                        <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.5s" repeatCount="indefinite"></animate>
                    </rect>
                </g>
                <g transform="rotate(180 50 50)">
                    <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                        <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.4166666666666667s" repeatCount="indefinite"></animate>
                    </rect>
                </g>
                <g transform="rotate(210 50 50)">
                    <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                        <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.3333333333333333s" repeatCount="indefinite"></animate>
                    </rect>
                </g>
                <g transform="rotate(240 50 50)">
                    <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                        <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.25s" repeatCount="indefinite"></animate>
                    </rect>
                </g>
                <g transform="rotate(270 50 50)">
                    <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                        <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.16666666666666666s" repeatCount="indefinite"></animate>
                    </rect>
                </g>
                <g transform="rotate(300 50 50)">
                    <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                        <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="-0.08333333333333333s" repeatCount="indefinite"></animate>
                    </rect>
                </g>
                <g transform="rotate(330 50 50)">
                    <rect x="47.5" y="24" rx="1.92" ry="1.92" width="5" height="12" fill="#ffffff">
                        <animate attributeName="opacity" values="1;0" keyTimes="0;1" dur="1s" begin="0s" repeatCount="indefinite"></animate>
                    </rect>
                </g>
            </svg>
        </div>
    {/if}
</Modal>