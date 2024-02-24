<script>
    import { FormatCurrency, GetContactsSelect, SendEvent, ShowSuccessModal } from "../../../utils/Utils";
    import { InputModal, LoaderModal, PlayerData } from "../phone.stores";

    import Button from "../../../components/Button/Button.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";

    import AppWrapper from "../components/AppWrapper.svelte";
    import Paper from "../components/Paper.svelte";
    import PaperList from "../components/PaperList.svelte";

    let Wallets = [];
    let FilteredWallets = [];
    let ShowingLimit = 100;

    const FilterWallets = (Query) => {
        Query = Query.toLowerCase();
        FilteredWallets = Wallets.filter(
            (Val) =>
                Val.Contact.toLowerCase().includes(Query) ||
                Val.Phone.toLowerCase().includes(Query)
        );
    };

    const LoadMore = () => {
        ShowingLimit = ShowingLimit + 100;
    };

    const PurchaseCrypto = (CryptoId) => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Id: "Amount",
                    Type: "TextField",
                    Data: {
                        Title: "Aantal",
                        Icon: "sliders-h",
                        Type: "number",
                    },
                },
            ],
            OnSubmit: (Result) => {
                if (Result.Amount.length <= 0 || Result.Amount < 0) return;

                LoaderModal.set(true);
                SendEvent("Crypto/BuyCrypto", { CryptoId, Amount: Result.Amount }, (Success, Data) => {
                    LoaderModal.set(false);
                    if (!Success) return;

                    if (Data.Success) {
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

    const TransferCrypto = async (Id, Data) => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Id: "Id",
                    Type: "TextField",
                    Data: {
                        Title: "Crypto ID",
                        Icon: "id-card",
                        Type: "number",
                        Value: Id,
                    },
                },
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
                    Data: {
                        Title: "Aantal",
                        Icon: "sliders-h",
                        Type: "number",
                    },
                },
            ],
            OnSubmit: (Result) => {
                if (Result.Phone.length <= 0) return;
                if (Result.Id.length <= 0 || Result.Id < 0) return;
                if (Result.Amount.length <= 0 || Result.Amount < 0) return;

                LoaderModal.set(true);
                SendEvent("Crypto/TransferCrypto", {...Result }, (Success, Data) => {
                    LoaderModal.set(false);
                    if (!Success) return;

                    if (Data.Success) {
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

    SendEvent("Crypto/GetCrypto", {}, (Success, Data) => {
        if (!Success) return;
        Wallets = Data;
        FilteredWallets = Data;
    });
</script>

<AppWrapper>
    <TextField
        Title="Zoeken"
        Icon="search"
        SubSet={FilterWallets}
        class="phone-misc-input"
    />

    <PaperList>
        {#each FilteredWallets as Data, Id}
            <Paper
                HasDrawer={true}
                Title={Data.Label}
                Description={$PlayerData.Crypto[Data.Id]}
                Icon={Data.Icon}
            >
                <div class="phone-card-drawer-item">
                    <i class="fas fa-id-card" />
                    <p>{Data.Id} ({Id + 1})</p>
                </div>
                <div class="phone-card-drawer-item">
                    <i class="fas fa-tag" />
                    <p>{Data.Label}</p>
                </div>
                <div class="phone-card-drawer-item">
                    <i class="fas fa-money-check" />
                    <p>{$PlayerData.Crypto[Data.Id]}</p>
                </div>
                <div class="phone-card-drawer-item">
                    <i class="fas fa-poll" />
                    <p>{FormatCurrency.format(Data.Costs)}</p>
                </div>

                <div style="display: flex; justify-content: center;">
                    {#if Data.Purchasable}
                        <Button
                            on:click={() => {
                                PurchaseCrypto(Data.Id);
                            }}
                            Color="success">Kopen</Button
                        >
                    {/if}
                    <Button
                        on:click={() => {
                            TransferCrypto(Id + 1, Data);
                        }}
                        Color="warning">Overmaken</Button
                    >
                </div>
            </Paper>
        {/each}

        {#if FilteredWallets.length > 5}
            <div style="display: flex; justify-content: center; width: 100%;">
                <Button Color="success" on:click={LoadMore}>Laad Meer</Button>
            </div>
        {/if}
    </PaperList>
</AppWrapper>
