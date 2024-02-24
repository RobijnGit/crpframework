<script>
    import AppWrapper from "../../components/AppWrapper.svelte";
    import { OnEvent, SetExitHandler, SendEvent as _SendEvent } from "../../utils";
    import CloseModal from "./CloseModal.svelte";
    import { ComponentsValues, ClosingModal, ClothingPrice, CurrentSkin, PedId, IsCustomPed, CustomPeds } from "./clothing.store";
    import ClothingNavbar from "./components/Navigation/ClothingNavbar.svelte";
    import TabsContainer from "./components/TabsContainer.svelte";

    let Visible = false;
    let CurrentMenuType = "Creation";

    const SendEvent = (Event, Parameters, Callback) => {
        _SendEvent(Event, Parameters, Callback, "fw-clothes")
    };

    OnEvent("Clothing", "SetVisibility", (Data) => {
        Visible = Data.Visible;
        CurrentMenuType = Data.Type
        ClothingPrice.set(0);
    });

    OnEvent("Clothing", "SetComponentValues", (Data) => {
        if (Data.Values != undefined) {
            ComponentsValues.set(Data.Values);
        };

        if (Data.CurrentSkin != undefined) {
            CurrentSkin.set(Data.CurrentSkin);
        };

        if (Data.PedId != undefined) {
            PedId.set(Data.PedId);
        };

        if (Data.IsCustomPed != undefined) {
            IsCustomPed.set(Data.IsCustomPed);
        };

        if (Data.CustomPeds != undefined) {
            CustomPeds.set(Data.CustomPeds);
        };
    });

    SetExitHandler("", "", () => {
        if (Visible) ClosingModal.set(true);
        return Visible;
    })
</script>

<AppWrapper AppName="Clothing" Focused={Visible}>
    {#if Visible}
        {#if $ClosingModal}
            <CloseModal/>
        {/if}

        <div class="clothing-wrapper">
            <div class="clothing-container">
                <ClothingNavbar CurrentMenuType={CurrentMenuType} />
                <TabsContainer/>
            </div>

            <div class="clothing-switches">
                <div
                    class="clothing-switch-item"
                    data-position="left" data-tooltip="Hoed"
                    on:keyup on:click={() => SendEvent("Clothes/ToggleComponents", {Type: "Hat"})}
                >
                    <i class="fas fa-hat-cowboy-side" />
                </div>

                <div
                    class="clothing-switch-item"
                    data-position="left" data-tooltip="Masker"
                    on:keyup on:click={() => SendEvent("Clothes/ToggleComponents", {Type: "Masks"})}
                >
                    <i class="fas fa-mask" />
                </div>

                <div
                    class="clothing-switch-item"
                    data-position="left" data-tooltip="Bril"
                    on:keyup on:click={() => SendEvent("Clothes/ToggleComponents", {Type: "Glasses"})}
                >
                    <i class="fas fa-glasses" />
                </div>

                <div
                    class="clothing-switch-item"
                    data-position="left" data-tooltip="Shirt"
                    on:keyup on:click={() => SendEvent("Clothes/ToggleComponents", {Type: "Shirts"})}
                >
                    <i class="fas fa-tshirt" />
                </div>

                <div
                    class="clothing-switch-item"
                    data-position="left" data-tooltip="Tas"
                    on:keyup on:click={() => SendEvent("Clothes/ToggleComponents", {Type: "Bags"})}
                >
                    <i class="fas fa-shopping-bag" />
                </div>

                <div
                    class="clothing-switch-item"
                    data-position="left" data-tooltip="Broek"
                    on:keyup on:click={() => SendEvent("Clothes/ToggleComponents", {Type: "Pants"})}
                >
                    <i class="fas fa-drumstick-bite" />
                </div>

                <div
                    class="clothing-switch-item"
                    data-position="left" data-tooltip="Schoenen"
                    on:keyup on:click={() => SendEvent("Clothes/ToggleComponents", {Type: "Shoes"})}
                >
                    <i class="fas fa-socks" />
                </div>
            </div>
        </div>

        {#if !$ClosingModal}
            <div
                class="clothing-character-controls"
            />
        {/if}
    {/if}
</AppWrapper>

<style>
    .clothing-wrapper {
        display: flex;
        flex-direction: row-reverse;

        position: absolute;
        top: 0;
        right: 0;

        width: 48vh;
        height: 100vh;
    }

    .clothing-container {
        display: flex;
        flex-direction: row-reverse;

        height: 100%;
        width: 44.4vh;
        background-color: rgb(48, 71, 94);
    }

    .clothing-switches {
        width: 2.9vh;
        height: 100%;

        margin-right: .55vh;
    }

    .clothing-switches .clothing-switch-item {
        display: flex;
        justify-content: center;
        align-items: center;

        width: 2.9vh;
        height: 2.9vh;

        margin-top: .55vh;
        background-color: rgb(34, 40, 49);

        border-radius: .2vh;

        font-size: 1.4vh;
        color: white;
    }
</style>