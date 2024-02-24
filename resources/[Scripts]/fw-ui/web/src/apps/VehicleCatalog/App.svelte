<script>
    import { onMount } from "svelte";
    import AppWrapper from "../../components/AppWrapper.svelte";
    import { Delay, FormatCurrency, OnEvent, SetExitHandler, SendEvent as _SendEvent } from "../../utils/Utils";
    import Car from "./components/Car.svelte";

    const SendEvent = (Event, Parameters, Callback) => _SendEvent(Event, Parameters, Callback, "fw-businesses");

    let Visible = false;
    let IntroState = "Out";
    let CreatingVehicle = false;

    let VehiclesContainerRef;
    let VehicleRefs = [];
    let VehicleStats = false;

    let CurrentVehicle = 0;
    let Shop = "";

    let Categories = [];
    let Vehicles = [];

    SetExitHandler("", "VehicleCatalog/Close", () => (Visible && IntroState == "Out"), {__resource: "fw-businesses"});

    const GetNameData = (Name, Type) => {
        const [ Brand, Model ] = Name.split(' ');
        if (Type == "Brand") return (Brand || "");
        return (Model || "");
    };

    const LoadCatalog = async (Data) => {
        Visible = true;
        await Delay(0.1);

        IntroState = "In";

        await Delay(1.5)

        Vehicles = Data.Vehicles.sort((a, b) => a.Category.localeCompare(b.Category));
        Categories = [...new Set(Vehicles.map(Veh => Veh.Category))].sort((a, b) => a.localeCompare(b));

        await Delay(3);
        SetCurrentVehicle(0);

        IntroState = "Out";
    };

    const SetCurrentVehicle = async (NewVehicleIndex) => {
        if (CreatingVehicle) return;

        CurrentVehicle = NewVehicleIndex;
        CreatingVehicle = true;

        SendEvent("VehicleCatalog/SetVehicle", {Model: Vehicles[CurrentVehicle].Vehicle}, (Success, Data) => {
            CreatingVehicle = false;
            if (!Success) return;
            VehicleStats = Data;
            VehiclesContainerRef.scrollLeft = VehicleRefs[CurrentVehicle].offsetLeft;
        });
    };

    OnEvent("VehicleCatalog", "SetVisibility", (Data) => {
        if (!Data.Visible) {
            Visible = false;
            return;
        };

        Categories = [];
        Vehicles = [];
        Shop = Data.Shop;

        LoadCatalog(Data);
    });

    const HandleKeyDown = (Event) => {
        if (Event.keyCode === 87 && Visible) {
            SendEvent("VehicleCatalog/DoRPM")
        }
    };

    onMount(() => {
        document.addEventListener('keydown', HandleKeyDown);

        return () => {
            document.removeEventListener('keydown', HandleKeyDown);
        };
    });
</script>


<AppWrapper AppName="VehicleCatalog" Focused={Visible}>
    {#if Visible}
        <div class="catalog-wrapper">
            <div class="catalog-intro">
                <div
                    class="catalog-intro-top"
                    class:in={IntroState == "In"}
                    class:out={IntroState == "Out"}
                >
                    <p>{Shop}</p>
                </div>
                <div
                    class="catalog-intro-bottom"
                    class:in={IntroState == "In"}
                    class:out={IntroState == "Out"}
                >
                    <p>Customer Experience</p>
                </div>
            </div>

            {#if Vehicles[CurrentVehicle]}
                <div class="catalog-car-info">
                    <div class="catalog-info-stats-container">
                        <div class="catalog-info-class">{Vehicles[CurrentVehicle].Class}</div>
                        <div class="catalog-info-model">{GetNameData(Vehicles[CurrentVehicle].Name, "Brand")}</div>
                        <div class="catalog-info-name">{GetNameData(Vehicles[CurrentVehicle].Name, "Model")}</div>
                        <div class="catalog-info-stats">
                            {#if VehicleStats}
                                <div class="catalog-info-progress">
                                    <div class="catalog-info-progress-name">Acceleratie</div>
                                    <div class="catalog-info-progress-grade">{VehicleStats.Acceleration.toFixed(1)}</div>
                                    <div class="catalog-info-progress-width" style="width: {VehicleStats.Acceleration * 10}%"></div>
                                </div>
                                <div class="catalog-info-progress">
                                    <div class="catalog-info-progress-name">Snelheid</div>
                                    <div class="catalog-info-progress-grade">{VehicleStats.Speed.toFixed(1)}</div>
                                    <div class="catalog-info-progress-width" style="width: {VehicleStats.Speed * 10}%"></div>
                                </div>
                                <div class="catalog-info-progress">
                                    <div class="catalog-info-progress-name">Handling</div>
                                    <div class="catalog-info-progress-grade">{VehicleStats.Handling.toFixed(1)}</div>
                                    <div class="catalog-info-progress-width" style="width: {VehicleStats.Handling * 10}%"></div>
                                </div>
                                <div class="catalog-info-progress">
                                    <div class="catalog-info-progress-name">Remmen</div>
                                    <div class="catalog-info-progress-grade">{VehicleStats.Braking.toFixed(1)}</div>
                                    <div class="catalog-info-progress-width" style="width: {VehicleStats.Braking * 10}%"></div>
                                </div>
                            {/if}
                        </div>
                    </div>
                </div>

                <div class="catalog-info-price">{FormatCurrency.format(Vehicles[CurrentVehicle].Price)}</div>

                <div class="catalog-key-container">
                    <div class="catalog-key">W</div>
                    <div class="catalog-key-text">- Motorgeluid</div>
                </div>
    
                <div class="catelog-vehicles-amount">{CurrentVehicle + 1} / {Vehicles.length}</div>
    
                <div class="catalog-category-container">
                    {#each Categories as Data, Key}
                        <div
                            class="catalog-category"
                            class:catalog-category-selected={Vehicles[CurrentVehicle].Category == Data}
                            on:keyup on:click={() => {
                                const Index = Vehicles.findIndex(Val => Val.Category == Data);
                                if (Index != -1) SetCurrentVehicle(Index);
                            }}
                        >{Data}</div>
                    {/each}
                </div>
    
                <div class="catalog-car-container" bind:this={VehiclesContainerRef}>
                    {#each Vehicles as Data, Key}
                        <Car
                            bind:HtmlRef={VehicleRefs[Key]}
                            Image={Data.Vehicle}
                            Price={Data.Price}
                            Name={Data.Name}
                            Selected={CurrentVehicle == Key}
                            on:click={() => SetCurrentVehicle(Key)}
                        />
                    {/each}
                </div>
    
                <div class="catalog-category-buttons">
                    <p
                        on:keyup on:click={() => {
                            if (CurrentVehicle - 1 >= 0) SetCurrentVehicle(CurrentVehicle - 1);
                        }}
                    >Vorige</p>
                    <p
                        on:keyup on:click={() => {
                            if (CurrentVehicle + 1 < Vehicles.length) SetCurrentVehicle(CurrentVehicle + 1)
                        }}
                    >Volgende</p>
                </div>
            {/if}
        </div>
    {/if}
</AppWrapper>

<style>
    .catalog-wrapper {
        font-family: Lato;

        position: absolute;

        top: 0;
        left: 0;

        width: 100%;
        height: 100%;
    }

    .catalog-intro {
        position: absolute;
        top: 0;
        left: 0;

        width: 100vw;
        height: 100vh;

        pointer-events: none;

        z-index: 999;
    }

    .catalog-intro-top {
        position: absolute;
        display: flex;
        justify-content: center;
        align-items: center;

        top: 0;
        left: -100%;

        height: 50%;
        width: 100%;

        background-color: #982425;
        transition: left 1.5s ease;
    }

    .catalog-intro-bottom {
        position: absolute;
        display: flex;
        justify-content: center;
        align-items: center;

        bottom: 0;
        right: -100%;

        height: 50%;
        width: 100%;

        background-color: #1d3c80;
        transition: right 1.5s ease;
    }

    .catalog-intro-top.in {
        left: 0%;
    }

    .catalog-intro-bottom.in {
        right: 0%;
    }

    .catalog-intro-top.out {
        left: -100%;
    }

    .catalog-intro-bottom.out {
        right: -100%;
    }

    .catalog-intro-top > p {
        color: white;
        font-size: 4.2vh;
        font-weight: 530;
    }

    .catalog-intro-bottom > p {
        color: white;
        font-size: 3.9vh;
        font-weight: 530;
    }

    .catalog-info-stats-container {
        position: absolute;

        top: 5vh;
        left: 3vw;

        width: 16vw;
        height: 33vh;

        border-top: .2vh solid rgb(216, 81, 81);
        background-color: rgba(0, 0, 0, 0.5);
    }

    .catalog-info-class {
        position: absolute;

        top: .5vh;
        left: 1vw;

        color: orange;
        font-weight: 550;
        font-style: italic;
        font-size: 4.5vh;
    }

    .catalog-info-model {
        position: absolute;

        top: 1vh;
        right: .8vw;

        max-width: 10vw;
        height: fit-content;

        overflow: hidden;
        white-space: nowrap;
        text-overflow: ellipsis;

        font-size: 2.3vh;
        font-weight: 550;
        font-style: italic;
        color: rgb(255, 255, 255);
    }

    .catalog-info-name {
        position: absolute;

        top: 3.3vh;
        right: .8vw;

        max-width: 15vw;
        height: fit-content;

        font-size: 2vh;
        font-weight: 550;
        font-style: italic;
        color: rgb(219, 219, 219);
    }

    .catalog-info-stats {
        position: absolute;

        top: 7vh;
        left: 1vw;

        width: 14vw;
        height: 25.5vh;
    }

    .catalog-info-progress {
        position: relative;

        margin-top: 3vh;

        width: 87%;
        height: 2vh;

        border: .2vh solid black;
        background-color: #292a2c;
    }

    .catalog-info-progress-name {
        position: absolute;

        top: -2.4vh;

        font-size: 1.7vh;
        font-weight: 550;
        color: #c9c6cd;
        font-style: italic;
        text-shadow: 0.1vh 0.2vh 0vh rgba(0, 0, 0, 0.7);
    }

    .catalog-info-progress-grade {
        position: absolute;

        top: -0.7vh;
        right: -2.5vh;

        width: 2.5vw;
        height: 3vh;

        z-index: 101;

        color: black;
        font-size: 2vh;
        line-height: 3vh;
        font-weight: 550;
        font-style: italic;
        text-align: center;

        border: .2vh solid black;
        background-color: #c9c6cd;
    }

    .catalog-info-progress-width {
        position: absolute;

        width: 50%;
        height: 100%;
        max-width: 100%;

        background-color: #c9c6cd;
    }

    .catalog-info-price {
        position: absolute;

        top: 2.5vh;
        right: 2.5vw;

        color: orange;
        font-size: 4.5vh;
        font-weight: 1000;
        font-style: italic;

        text-shadow: 0.3vh 0.3vh 0 rgba(0, 0, 0, 0.7);
    }

    .catalog-key-container {
        position: absolute;

        top: 39vh;
        left: 5.5vw;

        width: 10vw;
        height: 5vh;
    }

    .catelog-vehicles-amount {
        position: absolute;
        left: 25.5%;
        bottom: 28%;

        cursor: pointer;

        font-size: 2vh;
        font-weight: 900;
        font-style: italic;
        color: rgb(219, 219, 219);
        text-shadow: 0.1vh 0.2vh 0.1vh rgba(0, 0, 0, 0.7);
    }

    .catalog-category-container {
        position: absolute;

        top: 74%;
        left: 50%;

        width: max-content;
        height: fit-content;

        transform: translate(-50%, -50%);
    }

    .catalog-category {
        position: relative;

        float: left;
        cursor: pointer;

        margin-left: 2.5vw;

        width: fit-content;
        height: fit-content;

        font-size: 2vh;
        font-weight: 550;
        font-style: italic;
        text-align: center;
        color: rgb(219, 219, 219);
        text-shadow: 0.1vh 0.2vh 0.1vh rgba(0, 0, 0, 0.7);
    }
    .catalog-category-selected { color: orange; }

    .catalog-key {
        position: relative;

        width: 2.5vw;
        height: 3vh;

        color: black;
        font-size: 2vh;
        line-height: 3vh;
        font-weight: 550;
        font-style: italic;
        text-align: center;

        border: .2vh solid black;
        background-color: #c9c6cd;
    }

    .catalog-key-text {
        position: absolute;

        top: .5vh;
        left: 3vw;

        font-size: 2vh;
        font-weight: 550;
        font-style: italic;
        color: rgb(219, 219, 219);
        text-shadow: 0.1vh 0.2vh 0.1vh rgba(0, 0, 0, 0.7);
    }

    .catalog-car-container {
        position: absolute;

        top: 87%;
        left: 50%;

        width: 168.8vh;
        height: 18vh;

        overflow-x: scroll;
        overflow-y: hidden;
        white-space: nowrap;

        transform: translate(-50%, -50%);
    }

    .catalog-car-container::-webkit-scrollbar {
        display: none;
    }


    .catalog-category-buttons {
        display: flex;
        justify-content: space-around;

        position: absolute;
        left: 0;
        right: 0;
        margin: 0 auto;

        bottom: 3%;

        width: 15%;
        height: fit-content;
    }

    .catalog-category-buttons > p {
        position: relative;
        cursor: pointer;

        font-size: 2vh;
        font-weight: 550;
        font-style: italic;
        color: rgb(219, 219, 219);
        text-shadow: 0.1vh 0.2vh 0.1vh rgba(0, 0, 0, 0.7);
    }
    .catalog-category-buttons > p:hover { color: orange; }
</style>