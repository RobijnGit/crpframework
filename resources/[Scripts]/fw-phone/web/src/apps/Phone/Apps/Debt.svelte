<script>
    import { onMount } from "svelte";
    import TextField from "../../../components/TextField/TextField.svelte";
    import AppWrapper from "../components/AppWrapper.svelte";
    import Paper from "../components/Paper.svelte";
    import PaperList from "../components/PaperList.svelte";
    import { FormatCurrency, GetTimeLabel, SendEvent, ShowSuccessModal } from "../../../utils/Utils";
    import Button from "../../../components/Button/Button.svelte";
    import { InputModal, LoaderModal } from "../phone.stores";

    let Debts = [];
    let FilteredDebts = [];
    let ShowingLimit = 100;

    const LoadMore = () => {
        ShowingLimit = ShowingLimit + 100;
    };

    const FilterDebts = (Value) => {
        const Query = Value.toLowerCase();

        FilteredDebts = Debts.filter(Val => {
            if (Val.AssetType === 'Vehicle') {
                return Val.Data.Model.toLowerCase().includes(Query);
            } else if (Val.AssetType === 'Housing') {
                return Val.Data.Name.toLowerCase().includes(Query);
            };
            return false;
        });
    };

    const PayDebt = (Debt) => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Type: "Text",
                    Text: "Weet je het zeker?",
                    Data: {
                        style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;"
                    },
                },
            ],
            OnSubmit: () => {
                LoaderModal.set(true);
                SendEvent("Debt/PayDebt", { ...Debt }, (Success, Data) => {
                    LoaderModal.set(false);
                    if (!Success) return;

                    if (Data.Success) {
                        Debts = Debts.filter(Val => Val.Id != Debt.Id);
                        FilteredDebts = FilteredDebts.filter(Val => Val.Id != Debt.Id);
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
            }
        });
    };

    onMount(() => {
        SendEvent("Debt/GetDebt", {}, (Success, Data) => {
            if (!Success) return;
            Debts = Data;
            FilteredDebts = Data;
        });
    });

</script>

<AppWrapper>

    <TextField
        Title="Zoeken"
        Icon="search"
        SubSet={FilterDebts}
        class="phone-misc-input"
    />

    <PaperList>
        {#each FilteredDebts.slice(0, ShowingLimit) as Data (Data.Id)}
            <Paper
                Icon={Data.AssetType == 'Vehicle' ? "car" : ""}
                Title={FormatCurrency.format(Data.Data.Due)}
                Description={Data.AssetType == "Vehicle" ? "Voertuigen" : Data.Data.Name}
                HasDrawer={true}
            >
                <div class="phone-card-drawer-item" data-tooltip="Vervaldatum" data-position="left">
                    <i class="fas fa-calendar" />
                    <p>{GetTimeLabel(Data.DueAt)}</p>
                </div>

                <div style="display: flex; justify-content: center;">
                    <Button
                        on:click={() => {
                            PayDebt(Data);
                        }}
                        Color="success">Betalen</Button
                    >
                </div>
            </Paper>
        {/each}

        {#if FilteredDebts.length > 5 && ShowingLimit < FilteredDebts.length}
            <div style="display: flex; justify-content: center; width: 100%;">
                <Button Color="success" on:click={LoadMore}>Laad Meer</Button>
            </div>
        {/if}
    </PaperList>

    <!-- <p style="margin-bottom: 1.4vh; font-size: 1.5vh; font-family: Roboto; font-weight: 400; line-height: 1.43; letter-spacing: 0.005vh;">Onderhoudskosten</p> -->

</AppWrapper>