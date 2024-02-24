<script lang="ts">
    import { CurrentTab, MyPreferences } from "./preferences.store.js";
    import { OnEvent, SetExitHandler, SendEvent as _SendEvent } from "../../utils/Utils";
    import AppWrapper from "../../components/AppWrapper.svelte";

    import Button from "../../lib/Button/Button.svelte";
    import NavbarItem from "./components/NavbarItem.svelte";

    import Hud from "./layers/Hud.svelte";
    import Audio from "./layers/Audio.svelte";
    import Phone from "./layers/Phone.svelte";
    import Binding from "./layers/Binding.svelte";

    const SendEvent = (Event: string, Parameters?: any, Callback?: () => void) => {
        _SendEvent(Event, Parameters, Callback, "fw-hud")
    }

    let Visible: boolean = false;
    const TabComponents = {
        Hud,
        Phone,
        Audio,
        Binding,
    };

    OnEvent("Preferences", "SetVisibility", (Data: any) => {
        Visible = Data.Visible;
    });

    OnEvent("Preferences", "UpdatePreferences", (Data: any) => {
        MyPreferences.set(Data.Preferences);
    });

    SetExitHandler("", "Preferences/Close", () => Visible, {__resource: "fw-hud"})
</script>

<AppWrapper AppName="Preferences" Focused={Visible}>
    {#if Visible}
        <div class="preferences-wrapper">
            <div class="preferences-container">
                <div class="preferences-navbar" style="width: 25%">
                    <NavbarItem
                        Id="Hud"
                        Name="Hud"
                    />
                    <NavbarItem
                        Id="Phone"
                        Name="Telefoon"
                    />
                    <NavbarItem
                        Id="Audio"
                        Name="Audio"
                    />
                    <NavbarItem
                        Id="Binding"
                        Name="Emote Binds"
                    />
                </div>

                <div class="preferences-pages">
                    <div class="preferences-save-button">
                        <Button
                            Color="success"
                            on:click={() => SendEvent("Preferences/Save", {Preferences: $MyPreferences})}
                        >Opslaan</Button>
                    </div>

                    <div class="preferences-page-container">
                        <svelte:component this={TabComponents[$CurrentTab]} />
                    </div>
                </div>
            </div>
        </div>
    {/if}

    {#if $MyPreferences['BlackBars.Show']}
        <div style="position: absolute; top: 0; left: 0; height: {Math.min($MyPreferences['BlackBars.Percentage'], 40)}%; width: 100vw; background-color: black;"></div>
        <div style="position: absolute; bottom: 0; left: 0; height: {Math.min($MyPreferences['BlackBars.Percentage'], 40)}%; width: 100vw; background-color: black;"></div>
    {/if}
</AppWrapper>

<style>
    .preferences-wrapper {
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

    .preferences-container {
        color: white;
        width: 74vh;
        height: 55vh;
        display: flex;
        position: relative;
        user-select: unset;
        pointer-events: all;
        background-color: rgb(48, 71, 94);
    }

    .preferences-pages {
        flex: 1 1 0%;
        max-height: 55.5vh;
        overflow: hidden auto;
        background-color: rgb(34, 40, 49);
    }

    .preferences-pages > .preferences-save-button {
        position: relative;
        float: right;
        margin-top: 0.5vh;
        margin-right: 0.5vh;
        margin-bottom: 1vh;
        z-index: 1;
    }

    .preferences-page-container {
        position: relative;
        width: calc(100% - 3vh);
        padding: 1.5vh;
        margin: 0;
    }

    .preferences-pages::-webkit-scrollbar { display: none; }

    :global(.preferences-header) {
        font-size: 1.85vh;
        font-family: Roboto;
        font-weight: 500;
        line-height: 1.6;
        letter-spacing: 0.01vh;
    }

    :global(.preferences-page-container hr) {
        margin: 1vh 0 0.7vh 0;
    }

    :global(.preferences-flex) {
        display: flex;
        width: 100%;
        justify-content: space-between;
    }

    :global(.preferences-flex.column) {
        flex-direction: column;
    }
</style>