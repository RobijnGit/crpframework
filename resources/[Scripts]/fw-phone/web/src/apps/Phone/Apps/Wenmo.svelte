<script>
    import "../components/Misc.css";
    import { onMount } from "svelte";
    import { FormatCurrency, GetContactsSelect, GetTimeLabel, SendEvent, ShowSuccessModal } from "../../../utils/Utils";
    import { InputModal, LoaderModal } from "../phone.stores";

    import Button from "../../../components/Button/Button.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";

    import AppWrapper from "../components/AppWrapper.svelte";
    import PaperList from "../components/PaperList.svelte";

    let Transactions = [];
    let FilteredTransactions = [];
    let ShowingLimit = 100;

    let ExpandedTransactions = [];

    const FilterTransactions = (Query) => {
        Query = Query.toLowerCase();
        FilteredTransactions = Transactions.filter(
            (Val) =>
                Val.Cid.toLowerCase().includes(Query) ||
                Val.Name.toLowerCase().includes(Query) ||
                Val.Comment.toLowerCase().includes(Query)
        );
    };

    const LoadMore = () => {
        ShowingLimit = ShowingLimit + 100;
    };

    const SendMoney = async (Data) => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Id: "Phone",
                    Type: "TextField",
                    IsPhone: true,
                    ContactPicker: true,
                    Data: {
                        Title: "Telefoonnummer",
                        Icon: "phone",
                        Value: Data.phone,
                        Select: await GetContactsSelect(),
                        SearchSelect: true,
                    },
                },
                {
                    Id: "Amount",
                    Type: "TextField",
                    IsCurrency: true,
                    Data: {
                        Title: "Aantal",
                        Icon: "dollar-sign",
                        Type: "number",
                    },
                },
                {
                    Id: "Comment",
                    Type: "TextArea",
                    Data: {
                        Title: "Commentaar",
                    },
                },
            ],
            OnSubmit: (Result) => {
                if (Result.Phone.length <= 0) return;
                if (Result.Amount <= 0) return;
                if (Result.Comment.length <= 0) Result.Comment = "Geen Commentaar";

                LoaderModal.set(true);
                SendEvent("Wenmo/SendMoney", { ...Result }, (Success, Data) => {
                    LoaderModal.set(false);
                    if (!Success) return;

                    if (Data.Succces) {
                        ShowSuccessModal();
                        return;
                    }

                    InputModal.set({
                        Visible: true,
                        Inputs: [
                            {
                                Type: "Text",
                                Text: Data.Msg,
                                Data: {
                                    style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;",
                                },
                            },
                        ],
                        Buttons: [
                            {
                                Color: "success",
                                Text: "Okay",
                                Cb: () => {},
                            },
                        ],
                    });
                });
            },
        });
    };

    onMount(() => {
        SendEvent("Wenmo/GetTransactions", {}, (Success, Data) => {
            if (!Success) return;

            Transactions = Data;
            FilteredTransactions = Data;
        });
    });
</script>

<AppWrapper>
    <div class="phone-misc-icons">
        <i
            data-tooltip="Stuur Monnies"
            data-position="left"
            class="fas fa-hand-holding-usd"
            on:keyup
            on:click={SendMoney}
        />
    </div>

    <TextField
        Title="Zoeken"
        Icon="search"
        SubSet={FilterTransactions}
        class="phone-misc-input"
    />

    <PaperList>
        {#each FilteredTransactions.slice(0, ShowingLimit) as Data, Id}
            <div
                class="wenmo-card-wrapper"
                on:keyup
                on:click={() => {
                    ExpandedTransactions[Id] = !ExpandedTransactions[Id];
                }}
            >
                <div class="wenmo-card">
                    <div
                        style="width: 100%; height: 100%; display: flex; flex-direction: column;"
                    >
                        <div class="wenmo-card-top">
                            {#if Data.IsSender}
                                <p style="color: #f2a365">
                                    - {FormatCurrency.format(Data.Amount)}
                                </p>
                            {:else}
                                <p style="color: #95ef77">
                                    + {FormatCurrency.format(Data.Amount)}
                                </p>
                            {/if}
                            <p style="text-align: right;">{Data.Name}</p>
                        </div>
                        <div class="wenmo-card-bottom">
                            <p />
                            <p style="text-align: right;">
                                {GetTimeLabel(Data.Timestamp)}
                            </p>
                        </div>
                    </div>
                </div>
                {#if ExpandedTransactions[Id]}
                    <div
                        class="phone-card-drawer"
                        style="margin-top: 0.5vh; width: 90.5%;"
                    >
                        <div class="phone-card-drawer-item">
                            <i class="fas fa-comment" />
                            <p>{Data.Comment}</p>
                        </div>
                        <div class="phone-card-drawer-item">
                            <i class="fas fa-calendar" />
                            <p>
                                {new Date(Data.Timestamp).toLocaleString(
                                    "nl-NL",
                                    {
                                        timeZone: "UTC",
                                        day: "2-digit",
                                        month: "2-digit",
                                        year: "numeric",
                                        hour: "2-digit",
                                        minute: "2-digit",
                                        second: "2-digit",
                                    }
                                )}
                            </p>
                        </div>
                    </div>
                {/if}
            </div>
        {/each}

        {#if FilteredTransactions.length > 5}
            <div style="display: flex; justify-content: center; width: 100%;">
                <Button Color="success" on:click={LoadMore}>Laad Meer</Button>
            </div>
        {/if}
    </PaperList>
</AppWrapper>

<style>
    .wenmo-card-wrapper {
        display: flex;
        padding: 0.8vh;
        flex-direction: column;
        background-color: #30475e;
        margin-bottom: 0.74vh;
        border-top-left-radius: 0.37vh;
        border-top-right-radius: 0.37vh;
        border-bottom: 0.15vh solid #c8c6ca;
    }

    .wenmo-card {
        display: flex;
        font-size: 1.4vh;
    }

    .wenmo-card-top {
        display: flex;
        justify-content: space-between;
    }

    .wenmo-card-bottom {
        width: 100%;
        display: flex;
        margin-top: 0.8vh;
        justify-content: space-between;
    }
</style>
