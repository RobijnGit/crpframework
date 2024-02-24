<script>
    import { FormatCurrency, OnEvent, SetExitHandler, SendEvent as _SendEvent } from "../../utils/Utils";
    const SendEvent = (Event, Parameters, Callback) => _SendEvent(Event, Parameters, Callback, "fw-financials");

    import Button from "../../lib/Button/Button.svelte";
    import AppWrapper from "../../components/AppWrapper.svelte";
    import AccountCard from "./components/AccountCard.svelte";
    import TransactionsCard from "./components/TransactionsCard.svelte";

    let Visible = false;
    let State = 'Loaded'
    let Accounts = [];

    import Deposit from "./modals/Deposit.svelte";
    import Export from "./modals/Export.svelte";
    import Transfer from "./modals/Transfer.svelte";
    import Withdraw from "./modals/Withdraw.svelte";
    import Checkmark from "./modals/Checkmark.svelte";
    import { Cash, CurrentAccount, CurrentTransactions, IsATM, ModalData } from "./financials.store";

    const Modals = { Deposit, Export, Transfer, Withdraw, Checkmark };

    OnEvent("Financials", "SetVisibility", (Data) => {
        if (!Data.Visible) {
            Visible = false;
            return
        };

        Accounts = Data.Accounts;
        Cash.set(Data.Cash);
        IsATM.set(Data.IsATM);

        CurrentAccount.set(Data.Accounts[0]);

        SendEvent("Financials/GetTransactions", {AccountId: $CurrentAccount.AccountId}, (Success, Data) => {
            if (!Success) return;
            CurrentTransactions.set(Data);
        })

        State = 'Loading';
        Visible = true;
        setTimeout(() => {
            State = 'Loaded';
        }, 1500);
    });

    OnEvent("Financials", "SetFinancials", (Data) => {
        Accounts = Data;
    })

    let TransactionsLimit = 50;

    SetExitHandler("", "Financials/Close", () => Visible, {__resource: "fw-financials"})
</script>

<AppWrapper AppName="Financials" Focused={Visible}>
    {#if Visible}

        <div class="financials-wrapper">
            <div class="financials-container" class:loading={State == 'Loading'}>
                {#if State == 'Loading'}
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
                {:else}
                    {#if $ModalData.Type && Modals[$ModalData.Type] && $ModalData.Show} 
                        <svelte:component this={Modals[$ModalData.Type]} />
                    {/if}

                    <div class="financials-accounts">
                        <div class="financials-accounts-title">
                            <p>Rekeningen</p>
                        </div>

                        <div class="financials-accounts-list">
                            {#each Accounts as Data (Data.AccountId)}
                                <AccountCard {...Data} />
                            {/each}
                        </div>

                        <div style="display: flex; align-items: flex-end;">
                            <p
                                style="color: white; font-size: 1.6vh; font-family: Roboto; font-weight: 400; line-height: 1.5; letter-spacing: 0.015008vh;"
                            >Contant: {FormatCurrency.format($Cash)}</p>
                        </div>
                    </div>

                    <div class="financials-transactions">
                        <div
                            class="financials-accounts-title"
                            style="height: 3.5vh; display: flex; flex-direction: row; justify-content: space-between; align-items: center; margin-bottom: 0.8vh; width: 100%;"
                        >
                            <p>Transactie Geschiedenis</p>
                            <Button Color="default" on:click={() => ModalData.set({AccountId: $CurrentAccount.AccountId, Type: "Export", Show: true})}>Exporteer</Button>
                            <p>
                                <i class="fas fa-university" style="font-size: 3vh; margin-right: 2vh;"></i>Chafe Bank
                            </p>
                        </div>

                        <div class="financials-transactions-list">
                            {#if !$CurrentAccount?.Permissions?.Transactions || $CurrentTransactions.length == 0}
                                <div class="financials-misc-empty">
                                    <i class="fas fa-frown"></i> 
                                    <p>GEEN TRANSACTIES BESCHIKBAAR.</p>
                                </div>
                            {:else}
                                {#each $CurrentTransactions.slice(0, TransactionsLimit) as Data (Data.Id)}
                                    <TransactionsCard {...Data} />
                                {/each}
                                
                                {#if $CurrentTransactions.length > 5 && $CurrentTransactions.length > TransactionsLimit}
                                    <div style="display: flex; justify-content: center; width: 100%;">
                                        <Button Color="success" on:click={() => TransactionsLimit = TransactionsLimit + 50}>Laad Meer</Button>
                                    </div>
                                {/if}
                            {/if}
                        </div>
                    </div>
                {/if}
            </div>
        </div>

    {/if}
</AppWrapper>

<style>
    .financials-wrapper {
        display: flex;
        position: absolute;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        overflow: hidden;
        margin: 0;
        align-items: center;
        justify-content: center;
    }

    .financials-container {
        display: flex;
        flex-direction: row;
        position: relative;
        overflow: hidden;
        width: 133.4vh;
        height: 75vh;
        border-radius: .4vh;
        background-color: #222831;
        transition: height 800ms ease 0s
    }

    .financials-container.loading {
        height: 20vh;
    }

    .financials-accounts {
        width: 22.8%;
        height: 100%;
        padding: 1.5vh
    }

    .financials-transactions {
        flex: 1 1 0%;
        height: 100%;
        padding: 1.5vh
    }

    .financials-accounts-title {
        display: flex;
        flex-direction: row;
        justify-content: space-between;
        height: 4.4vh
    }

    .financials-accounts-title > p {
        color: white;
        font-size: 2.2vh;
        letter-spacing: 0;
        font-family: Roboto;
        margin: 0
    }

    .financials-accounts-list::-webkit-scrollbar,
    .financials-transactions-list::-webkit-scrollbar {
        display: none
    }

    .financials-accounts-list,
    .financials-transactions-list {
        flex: 1 1 0%;
        height: calc(100% - 9vh);
        overflow-y: auto
    }

    .financials-misc-empty {
        position: relative;
        left: 0;
        right: 0;
        text-align: center;
        width: 100%;
        height: 100%;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        color: white
    }

    .financials-misc-empty > i {
        font-size: 4.5vh
    }

    .financials-misc-empty > p {
        margin-top: 3.3vh;
        font-size: 1.8vh;
        font-weight: bold;
        font-family: Roboto
    }
</style>