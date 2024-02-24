<script>
    import * as HOUSING from "./_housing";
    import Ripple from '@smui/ripple';

    import { HouseCategoryIcons } from "../../../config";
    import { PlayerData } from "../phone.stores";

    import AppWrapper from "../components/AppWrapper.svelte";
    import Paper from "../components/Paper.svelte";
    import PaperList from "../components/PaperList.svelte";

    import Button from "../../../components/Button/Button.svelte";
    import { onMount } from "svelte";
    import { AsyncSendEvent, FormatCurrency, IsEnvBrowser, SendEvent } from "../../../utils/Utils";
    import TextField from "../../../components/TextField/TextField.svelte";

    let CurrentTab = 'Apartments';
    let IsRealtor = IsEnvBrowser();
    let ShowQuickEdit = false;
    let Houses = [];

    let EditingKeys = false;
    let Keyholders = [];
    let AddingKeyCid = '';
    let RemoveKeyCid = '';

    let Editing = false;
    let CurrentEditingId = false;

    const ToggleEditing = async (HouseId) => {
        if (!await HOUSING.IsNearHouse(HouseId)) return;

        CurrentEditingId = HouseId;
        Editing = !Editing;
        CurrentTab = 'Housing';
    }

    const SetCurrentTab = (Tab) => {
        CurrentTab = Tab;
    };

    const ToggleLock = (HouseId) => {
        SendEvent("Housing/ToggleLock", {HouseId})
        Houses = Houses.map(Val => {
            if (Val.Id === HouseId) return { ...Val, Locked: !Val.Locked };
            return Val;
        });
    };

    const EditKeys = async (HouseId) => {
        const [Success, Result] = await AsyncSendEvent("Housing/GetKeys", {HouseId})
        if (!Success) return;
        Keyholders = Result;
        EditingKeys = HouseId;
    };

    const CloseKeyholder = () => {
        EditingKeys = false;
        Keyholders = [];
        AddingKeyCid = '';
        RemoveKeyCid = '';
    };

    const LocateApartments = () => {
        SendEvent("Utils/SetWaypoint", { x: -258.7, y: -976.47 })
    };

    onMount(() => {
        SendEvent("Housing/CanRealtor", {}, (Success, Data) => {
            if (!Success) return;
            IsRealtor = Data;
        });

        SendEvent("Housing/GetHouses", {}, (Success, Data) => {
            if (!Success) return;
            ShowQuickEdit = Data.QuickEdit;
            Houses = Data.Houses;
        });
    });
</script>

{#if EditingKeys}
    <div class="phone-housing-keys">
        <div class="phone-housing-keys-container">
            <p style="font-size: 1.5vh; font-family: Roboto; font-weight: 400; line-height: 1.43; letter-spacing: 0.005vh;">Toevoegen:</p>
            <TextField Title="BSN" Icon="id-card" bind:RealValue={AddingKeyCid} />
            <div class="phone-housing-keys-buttons">
                <Button Color="warning" on:click={CloseKeyholder}>Terug</Button>
                <Button Color="success" on:click={() => { HOUSING.AddKeyholder(EditingKeys, AddingKeyCid, Keyholders.length), CloseKeyholder() }} >Bevestigen</Button>
            </div>
            <hr style="margin: 1vh 0px;">
            <TextField Placeholder="Verwijderen" Title="" Select={Keyholders} ReadOnly={true} bind:Value={RemoveKeyCid} />
            <div class="phone-housing-keys-buttons">
                <Button Color="warning" on:click={CloseKeyholder}>Terug</Button>
                <Button Color="success" on:click={() => { HOUSING.RemoveKeyholder(EditingKeys, RemoveKeyCid), CloseKeyholder() }} >Bevestigen</Button>
            </div>
        </div>
    </div>
{/if}

<AppWrapper>
    <div class="phone-housing-topbar">
        <div
            class="phone-housing-option"
            class:phone-housing-option-active={CurrentTab == 'Apartments'}
            use:Ripple={{ surface: true, active: true, color: 'primary' }}
            on:keyup on:click={() => { SetCurrentTab('Apartments') }}
        >
            <i class="fas fa-house-user" />
        </div>
        <div
            class="phone-housing-option"
            class:phone-housing-option-active={CurrentTab == 'Housing'}
            use:Ripple={{ surface: true, active: true, color: 'primary' }}
            on:keyup on:click={() => { SetCurrentTab('Housing') }}
        >
            <i class="fas fa-building" />
        </div>
        {#if IsRealtor}
            <div
                class="phone-housing-option"
                class:phone-housing-option-active={CurrentTab == 'Realtor'}
                use:Ripple={{ surface: true, active: true, color: 'primary' }}
                on:keyup on:click={() => { SetCurrentTab('Realtor') }}
            >
                <i class="fas fa-hammer" />
            </div>
        {/if}
    </div>

    <PaperList style="top: 8vh; height: 48.3vh;">
        {#if CurrentTab == 'Apartments'}
            <p style="margin-bottom: 1.4vh; font-size: 1.5vh; font-family: Roboto; font-weight: 400; line-height: 1.43; letter-spacing: 0.005vh;">Huidig</p>
            <Paper
                Icon="house-user"
                Title="Room: {$PlayerData.RoomId || "000000"}"
                Description="No3"
                HasActions={true}
            >
                <i on:keyup on:click={LocateApartments} data-tooltip="Zet GPS" class="fas fa-map-marked" />
            </Paper>
        {:else if CurrentTab == 'Housing'}
            {#if Editing}
                <div style="display: flex; flex-direction: column; justify-content: center; align-items: center; width: 100%;">
                    <Button
                        Color="success"
                        on:click={() => { ToggleEditing(); }}
                    >Verlaat Edit Mode</Button>
                    <div style="margin-top: 1vh; margin-bottom: 1vh; width: 100%; border-bottom: 0.2vh solid white;" />
                    {#if IsRealtor}
                        <Button on:click={() => { HOUSING.PlaceGarage(CurrentEditingId)}} Color="success">Plaats Garage Hier</Button>
                    {:else}
                        <Button Color="disabled">Plaats Garage Hier</Button>
                    {/if}

                    <Button on:click={() => { HOUSING.PlaceStash(CurrentEditingId)}} Color="success">Plaats Stash Hier</Button>

                    {#if IsRealtor}
                        <Button on:click={() => { HOUSING.PlaceBackdoor(CurrentEditingId)}} Color="success">Plaats Achterdeur Hier</Button>
                    {:else}
                        <Button Color="disabled">Plaats Achterdeur Hier</Button>
                    {/if}

                    <Button on:click={() => { HOUSING.PlaceWardrobe(CurrentEditingId)}} Color="success">Plaats Kledingkast Hier</Button>
                    <Button on:click={() => { HOUSING.OpenDecoration(CurrentEditingId)}} Color="success">Open Decoratie</Button>
                </div>
            {:else}
                <div style="display: flex; flex-direction: column; justify-content: center; align-items: center; width: 100%;">
                    <Button
                        Color="success"
                        on:click={HOUSING.CheckCurrentLocation}
                    >Controleer Huidige Locatie</Button>

                    {#if ShowQuickEdit}
                        <Button
                            Color="success"
                            style="padding: 0.4vh 2vh;"
                            on:click={() => { ToggleEditing(); }}
                        ><i class="fas fa-edit"></i></Button>
                    {/if}
                </div>

                {#if Houses.some(House => House.IsOwner)}
                    <p style="margin-bottom: 1.4vh; font-size: 1.5vh; font-family: Roboto; font-weight: 400; line-height: 1.43; letter-spacing: 0.005vh;">In Bezit</p>

                    {#each Houses.filter(Val => Val.IsOwner) as Data (Data.Id)}
                        <Paper
                            Icon={HouseCategoryIcons[Data.Category]}
                            Title={FormatCurrency.format(Data.Price)}
                            Description={Data.Adress}
                            HasActions={true}
                        >
                            <i on:keyup on:click={() => { HOUSING.Locate(Data) }} data-tooltip="Zet GPS" class="fas fa-map-marked" />
                            <i on:keyup on:click={() => { ToggleLock(Data.Id) }} data-tooltip={Data.Locked ? "Ontgrendelen" : "Vergrendelen"} class="fas fa-{Data.Locked ? "lock" : "lock-open"}"/>
                            <i on:keyup on:click={() => { ToggleEditing(Data.Id) }} data-tooltip="Eigendom Bewerken" class="fas fa-edit" />
                            <i on:keyup on:click={() => { EditKeys(Data.Id) }} data-tooltip="Sleutels" class="fas fa-key" />
                        </Paper>
                    {/each}
                {/if}

                {#if Houses.some(House => !House.IsOwner)}
                    <p style="margin-bottom: 1.4vh; font-size: 1.5vh; font-family: Roboto; font-weight: 400; line-height: 1.43; letter-spacing: 0.005vh;">Toegang Tot</p>

                    {#each Houses.filter(Val => !Val.IsOwner) as Data (Data.Id)}
                        <Paper
                            Icon={HouseCategoryIcons[Data.Category]}
                            Title={FormatCurrency.format(Data.Price)}
                            Description={Data.Adress}
                            HasActions={true}
                        >
                            <i on:keyup on:click={() => { HOUSING.Locate(Data) }} data-tooltip="Zet GPS" class="fas fa-map-marked" />
                            <i on:keyup on:click={() => { ToggleLock(Data.Id) }} data-tooltip={Data.Locked ? "Ontgrendelen" : "Vergrendelen"} class="fas fa-{Data.Locked ? "lock" : "lock-open"}"/>
                            <i on:keyup on:click={() => { ToggleEditing(Data.Id) }} data-tooltip="Eigendom Bewerken" class="fas fa-edit" />
                        </Paper>
                    {/each}
                {/if}
            {/if}
        {:else if CurrentTab == 'Realtor' && IsRealtor}
            <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; width: 100%;">
                <Button
                    Color="success"
                    on:click={HOUSING.CheckCurrentLocation}
                >Controleer Huidige Locatie</Button>

                <div style="display: flex; align-items: center;">
                    <Button
                        Color="success"
                        style="padding: 0.4vh 2vh;"
                        on:click={() => {
                            ToggleEditing();
                        }}
                    ><i class="fas fa-edit"></i></Button>

                    <Button
                        Color="success"
                        on:click={HOUSING.SellHousing}
                    >Huis Verkopen</Button>
                </div>

                <Button
                    Color="success"
                    on:click={HOUSING.CreateHousing}
                >Locatie Toevoegen</Button>

                <Button
                    Color="success"
                    on:click={HOUSING.EditHousing}
                >Locatie Aanpassen</Button>

                <Button
                    Color="success"
                    on:click={HOUSING.DeleteHousing}
                >Locatie Verwijderen</Button>
            </div>
        {/if}
    </PaperList>
</AppWrapper>

<style>
    .phone-housing-topbar {
        display: flex;
        flex-direction: row;
        flex-wrap: wrap;
        position: absolute;
        top: 3vh;
        left: 0;
        right: 0;
        width: 89%;
        height: 4.8vh;
        margin: 0 auto
    }

    .phone-housing-topbar > .phone-housing-option {
        flex-grow: 1;
        cursor: pointer;
        font-size: 1.5vh;
        color: #c1c3c8;
        line-height: 4.8vh;
        text-align: center
    }

    .phone-housing-option-active {
        color: #95ef77 !important;
        box-shadow: inset 0 -0.2vh 0 #95ef77
    }

    .phone-housing-keys {
        position: absolute;
        width: 100%;
        height: 100%;
        z-index: 100;
        background-color: rgba(0, 0, 0, 0.5)
    }

    .phone-housing-keys-container {
        position: relative;
        top: 50%;
        left: 0;
        right: 0;
        transform: translateY(-50%);
        clear: both;
        overflow-y: auto;
        margin: 0 auto;
        width: 66%;
        height: max-content;
        max-height: 70%;
        padding: 1.5vh;
        background-color: #30475d
    }

    .phone-housing-keys-container::-webkit-scrollbar { display: none }
    .phone-housing-keys-container > .phone-housing-keys-buttons {
        height: 4vh;
        width: 100%
    }
</style>