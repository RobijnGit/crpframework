<script>
    import "../components/Misc.css";

    import { onMount } from "svelte";
    import { ExtractImageUrls, FormatCurrency, FormatPhone, GetContactsSelect, GetTimeLabel, OnEvent, SendEvent, ShowSuccessModal } from "../../../utils/Utils";
    import { InputModal, LoaderModal } from "../phone.stores";

    import Button from "../../../components/Button/Button.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";

    import AppWrapper from "../components/AppWrapper.svelte";
    import PaperList from "../components/PaperList.svelte";
    import Paper from "../components/Paper.svelte";
    import { Tax } from "../../../stores";

    let ShopData = {};
    let TestData = false;

    let Cars = [];
    let FilteredCars = [];
    let ShowingLimit = 100;

    const FilterCars = (Query) => {
        Query = Query.toLowerCase();
        FilteredCars = Cars.filter(
            (Val) =>
                Val.Name.toLowerCase().includes(Query) ||
                Val.Class.toLowerCase().includes(Query) ||
                Val.Vehicle.toLowerCase().includes(Query)
        );
    };

    const GetCarData = (Name, Type) => {
        const [Brand, Model ] = Name.split(' ');
        if (Type == "Brand") return Brand;
        return Model;
    };

    const TestVehicle = ({Vehicle}) => {
        SendEvent("Cars/TestDrive", { Vehicle })
    };

    const PreviewVehicle = ({Vehicle}) => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Id: "Spot",
                    Type: "TextField",
                    Data: {
                        Title: "Locatie:",
                        Select: Array.from({ length: ShopData.MaxPositions }, (_, i) => ({ Text: i + 1 })),
                        Data: {
                            ReadOnly: true,
                        }
                    },
                },
            ],
            OnSubmit: (Result) => {
                if (Result.Spot.length <= 0) return;

                LoaderModal.set(true);
                SendEvent("Cars/SetDisplay", {Vehicle, ...Result}, (Success, Data) => {
                    LoaderModal.set(false);
                    if (!Success) return;
                    if (Data) ShowSuccessModal();
                });
            },
        });
    };

    const ParkVehicle = () => {
        SendEvent("Cars/ReturnCar");
    };

    const SavePreset = () => {
        SendEvent("Cars/SavePreset");
        ShowSuccessModal();
    };

    const SellVehicle = () => {
        const VehicleData = Cars.find(Val => Val.Vehicle == TestData.Vehicle);
        if (!VehicleData) return;

        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Type: "Text",
                    Text: `Min: ${FormatCurrency.format(VehicleData.Price)}`,
                    Data: { style: "font-size: 1.3vh;" }
                },
                {
                    Type: "Text",
                    Text: `Verkoop: ${FormatCurrency.format(VehicleData.Price * (1.0 + ($Tax['Vehicle Sales'] / 100)))}`,
                    Data: { style: "font-size: 1.3vh;" }
                },
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
                    IsCurrency: true,
                    Data: {
                        Title: "Prijs (Incl. BTW)",
                        Icon: "dollar-sign",
                        Sub: "€ 0,00"
                    },
                },
            ],
            OnSubmit: (Result) => {
                if (Result.Cid.length <= 0) return;
                if (Result.Amount.length <= 0 || Number(Result.Amount) < VehicleData.Price) return;

                LoaderModal.set(true);
                SendEvent("Cars/Sell", {...Result}, (Success, Data) => {
                    LoaderModal.set(false);
                    if (!Success) return;
                });
            },
        });
    };

    OnEvent("Cars/SetTestDriving", (Data) => {
        TestData = Data.TestDrive;
    })

    onMount(() => {
        SendEvent("Cars/GetShopData", {}, (Success, Data) => {
            if (!Success) return;
            ShopData = Data;
            // BusinessName, MaxPositions
        });

        SendEvent("Cars/GetTestDriving", {}, (Success, Data) => {
            if (!Success) return;
            TestData = Data;
            // Vehicle, Shop, Entity
        });

        SendEvent("Cars/GetVehicles", {}, (Success, Data) => {
            if (!Success) return;

            Cars = Data;
            FilteredCars = Data;
        });
    });
</script>

<AppWrapper>
    {#if TestData}
        <div class="phone-misc-icons">
            <i
                data-tooltip="Voertuig Parkeren"
                data-position="left"
                class="fas fa-car-alt"
                on:keyup on:click={ParkVehicle}
            />
            <i
                data-tooltip="Preset Opslaan"
                data-position="left"
                class="fas fa-spray-can"
                on:keyup on:click={SavePreset}
            />
            <i
                data-tooltip="Voertuig Verkopen"
                data-position="left"
                class="fas fa-dollar-sign"
                on:keyup on:click={SellVehicle}
            />
        </div>
    {/if}

    <TextField
        Title="Zoeken"
        Icon="search"
        SubSet={FilterCars}
        class="phone-misc-input"
    />

    <PaperList>
        {#each FilteredCars as Data, Id}
            <div
                class="vehicles-card-wrapper"
                on:keyup
                on:click={() => {
                }}
            >
                <div class="vehicles-card">
                    <div
                        style="width: 100%; height: 100%; display: flex; flex-direction: column;"
                    >
                        <div class="vehicles-card-top">
                            <p>{GetCarData(Data.Name, "Brand")}</p>
                            <p style="text-align: right;">{GetCarData(Data.Name, "Model")}</p>
                        </div>
                        <div class="vehicles-card-bottom">
                            <p>{Data.Class}</p>
                            <p style="text-align: right;">{FormatCurrency.format(Data.Price)} ({Data.Stock})</p>
                        </div>
                    </div>

                    <div class="phone-card-actions">
                        {#if Data.Stock <= 0}
                            <i
                                data-tooltip="Niet op Voorraad"
                                class="fas fa-times-circle"
                            />
                        {:else}
                            <i
                                data-tooltip="Testrit"
                                class="fas fa-car-alt"
                                on:keyup on:click={() => { TestVehicle(Data); }}
                            />
                            <i
                                data-tooltip="Weergeven"
                                class="fas fa-eye"
                                on:keyup on:click={() => { PreviewVehicle(Data); }}
                            />
                        {/if}
                    </div>
                </div>
            </div>
        {/each}
    </PaperList>
</AppWrapper>

<style>
    .vehicles-card-wrapper {
        position: relative;
        display: flex;
        padding: 0.8vh;
        flex-direction: column;
        background-color: #30475e;
        margin-bottom: 0.74vh;
        border-top-left-radius: 0.37vh;
        border-top-right-radius: 0.37vh;
        border-bottom: 0.15vh solid #c8c6ca;
    }

    .vehicles-card {
        display: flex;
        font-size: 1.4vh;
    }

    .vehicles-card-top {
        display: flex;
        justify-content: space-between;
    }

    .vehicles-card-bottom {
        width: 100%;
        display: flex;
        margin-top: 0.8vh;
        justify-content: space-between;
    }

    .vehicles-card-wrapper:hover .phone-card-actions {
        display: flex
    }
</style>
