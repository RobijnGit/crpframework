<script>
    import { CurrentModal, CurrentTab } from "./state.store.js";
    import { OnEvent, SetExitHandler, SendEvent as _SendEvent } from "../../utils/Utils";
    import AppWrapper from "../../components/AppWrapper.svelte";

    import NavbarItem from "./components/NavbarItem.svelte";

    import Taxes from "./layers/Taxes.svelte";
    import Ballots from "./layers/Ballots.svelte";

    import Success from "./modals/Success.svelte";
    import Loading from "./modals/Loading.svelte";
    import ChangeTax from "./modals/ChangeTax.svelte";
    import NewBallot from "./modals/NewBallot.svelte";

    const SendEvent = (Event, Parameters, Callback) => {
        _SendEvent(Event, Parameters, Callback, "fw-cityhall")
    }

    let Visible = false;
    const TabComponents = {
        Taxes,
        Ballots,
    };

    const ModalComponents = {
        Success,
        Loading,
        ChangeTax,
        NewBallot
    }

    OnEvent("State", "SetVisibility", (Data) => {
        Visible = Data.Visible;
    });

    SetExitHandler("", "State/Close", () => Visible, {__resource: "fw-cityhall"})
</script>

<AppWrapper AppName="State" Focused={Visible}>
    {#if Visible}
        <div class="state-wrapper">
            <div class="state-container">

                {#if $CurrentModal && $CurrentModal.Type}
                    <svelte:component this={ModalComponents[$CurrentModal.Type]}/>
                {/if}

                <div class="state-navbar" style="width: 25%">
                    <NavbarItem
                        Id="Taxes"
                        Name="Belasting"
                    />
                    <NavbarItem
                        Id="Ballots"
                        Name="Stembussen"
                    />
                </div>

                <div class="state-pages">
                    <!-- <div class="state-save-button">
                        <Button
                            Color="success"
                            on:click={() => SendEvent("state/Save", {state: $Mystate})}
                        >Opslaan</Button>
                    </div> -->

                    <div class="state-page-container">
                        <svelte:component this={TabComponents[$CurrentTab]} />
                    </div>
                </div>
            </div>
        </div>
    {/if}
</AppWrapper>

<style>
    .state-wrapper {
        position: absolute;
        top: 0;
        left: 0;
        display: flex;
        z-index: 150 !important;
        width: 100vw;
        height: 100vh;
        align-items: center;
        justify-content: center;
    }

    .state-container {
        color: white;
        width: 74vh;
        height: 55vh;
        display: flex;
        position: relative;
        user-select: unset;
        pointer-events: all;
        background-color: rgb(48, 71, 94);
    }

    .state-pages {
        flex: 1 1 0%;
        max-height: 55.5vh;
        overflow: hidden auto;
        background-color: rgb(34, 40, 49);
    }

    :global(.state-pages > .state-page-button) {
        position: relative;
        float: right;
        margin-top: 0.5vh;
        margin-right: 0.5vh;
        margin-bottom: 1vh;
        z-index: 1;
    }

    .state-page-container {
        position: relative;
        width: calc(100% - 3vh);
        padding: 1.5vh;
        margin: 0;
    }

    .state-pages::-webkit-scrollbar { display: none; }

    :global(.state-header) {
        font-size: 1.85vh;
        font-family: Roboto;
        font-weight: 500;
        line-height: 1.6;
        letter-spacing: 0.01vh;
    }

    :global(.state-page-container hr) {
        margin: 1vh 0 0.7vh 0;
    }

    :global(.state-flex) {
        display: flex;
        width: 100%;
        justify-content: space-between;
    }

    :global(.state-flex.column) {
        flex-direction: column;
    }
</style>