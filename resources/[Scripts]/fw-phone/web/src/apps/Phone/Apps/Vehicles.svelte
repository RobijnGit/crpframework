<script>
    import "../components/Misc.css";
    import { onMount } from "svelte";
    import { SendEvent, ShowSuccessModal } from "../../../utils/Utils";
    import { InputModal, LoaderModal } from "../phone.stores";

    import TextField from "../../../components/TextField/TextField.svelte";
    import Button from "../../../components/Button/Button.svelte";

    import AppWrapper from "../components/AppWrapper.svelte";
    import PaperList from "../components/PaperList.svelte";
    import Paper from "../components/Paper.svelte";

    let Vehicles = [];
    let FilteredVehicles = [];
    let ShowingLimit = 100;

    const FilterVehicles = (Query) => {
        Query = Query.toLowerCase();
        FilteredVehicles = Vehicles.filter(
            (Val) =>
                Val.Plate.toLowerCase().includes(Query) ||
                Val.Label.toLowerCase().includes(Query) ||
                Val.State.toLowerCase().includes(Query) ||
                Val.Garage.toLowerCase().includes(Query)
        );
    };

    const LoadMore = () => {
        ShowingLimit = ShowingLimit + 100;
    };

    const SellVehicle = async (Data) => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Id: "Cid",
                    Type: "TextField",
                    Data: {
                        Title: "BSN",
                        Icon: "id-card",
                    },
                },
                {
                    Id: "Amount",
                    Type: "TextField",
                    Data: {
                        Title: "Prijs",
                        Icon: "dollar-sign",
                        Type: "number",
                    },
                },
            ],
            OnSubmit: (Result) => {
                if (Result.Cid.length <= 0) return;
                if (Result.Amount.length <= 0 || Result.Amount < 0) return;

                LoaderModal.set(true);
                SendEvent("Vehicles/SellVehicle", { ...Result, Plate: Data.Plate }, (Success, Data) => {
                    LoaderModal.set(false);
                    if (!Success) return;
                    ShowSuccessModal();
                });
            },
        });
    };

    const SpawnVehicle = (Data) => {
        SendEvent("Vehicles/SpawnVehicle", {Plate: Data.Plate})
    };

    const TrackVehicle = (Data) => {
        SendEvent("Vehicles/TrackVehicle", {Plate: Data.Plate})
    };

    onMount(() => {
        SendEvent("Vehicles/GetVehicles", {}, (Success, Data) => {
            if (!Success) return;

            Vehicles = Data;
            FilteredVehicles = Data;
        });
    });
</script>

<AppWrapper>
    <TextField
        Title="Zoeken"
        Icon="search"
        SubSet={FilterVehicles}
        class="phone-misc-input"
    />

    <PaperList>
        {#each FilteredVehicles.slice(0, ShowingLimit) as Data, Id}
            <Paper
                Icon={Data.Icon}
                Title={Data.Plate}
                Description={Data.Label}
                Aux={Data.State}
                HasDrawer={true}
            >
                <div class="phone-card-drawer-item">
                    <i class="fas fa-map-marker-alt" />
                    <p>{Data.Garage}</p>
                </div>
                <div class="phone-card-drawer-item">
                    <i class="fas fa-closed-captioning" />
                    <p>{Data.Plate}</p>
                </div>
                <div class="phone-card-drawer-item">
                    <i class="fas fa-oil-can" />
                    <p>{Math.floor(Data.Engine / 10)}%</p>
                </div>
                <div class="phone-card-drawer-item">
                    <i class="fas fa-car-crash" />
                    <p>{Math.floor(Data.Body / 10)}%</p>
                </div>

                <div style="display: flex; justify-content: center;">
                    {#if Data.State == "Buiten"}
                        <Button
                            on:click={() => {
                                SpawnVehicle(Data);
                            }}
                            Color="default">Spawn</Button
                        >
                    {/if}
                    <Button
                        on:click={() => {
                            TrackVehicle(Data);
                        }}
                        Color="success">Traceren</Button
                    >
                </div>

                {#if Data.State == "Buiten"}
                    <div style="display: flex; justify-content: center;">
                        <Button
                            on:click={() => {
                                SellVehicle(Data);
                            }}
                            Color="warning">Verkopen</Button
                        >
                    </div>
                {/if}
            </Paper>
        {/each}

        {#if FilteredVehicles.length > ShowingLimit}
            <div style="display: flex; justify-content: center; width: 100%;">
                <Button Color="success" on:click={LoadMore}>Laad Meer</Button>
            </div>
        {/if}
    </PaperList>
</AppWrapper>
