<script>
    import { LaptopApps } from "../../config";
    import { CurrentApps, FocusedApp, HasVPN, LaptopPreferences, PlayerData } from "../../stores";
    import { AddNotification, IsEnvBrowser, OnEvent } from "../../utils/Utils";

    import AppInternet from "./apps/Internet.svelte";
    import AppBoosting from "./apps/Boosting/App.svelte";
    import AppBennys from "./apps/Bennys.svelte";
    import AppUnknown from "./apps/Unknown.svelte";
    import AppSecureGuard from "./apps/SecureGuard/App.svelte";
    import AppMarket from "./apps/Market/App.svelte";

    import Settings from "./modals/Settings.svelte";
    import NotificationsWrapper from "./modals/NotificationsWrapper.svelte";

    let LaptopVisible = IsEnvBrowser();
    let NotificationsHistory = false;
    let LaptopType = 'Crime'; // Crime | Vault
    let LaptopSettings = false;
    let LaptopTime = '12:00';
    let LaptopDate = '1/1/2023';

    OnEvent("Laptop/SetVisiblity", (Data) => {
        LaptopVisible = Data.Visible
        HasVPN.set(Data.HasVPN)

        if (!Data.Visible) {
            CurrentApps.set([]);
            FocusedApp.set(false);
        };

        LaptopTime = Data.Time || "69:69";
        const RealDate = new Date();
        LaptopDate = `${RealDate.getDate()}/${RealDate.getMonth()}/${RealDate.getFullYear()}`
        LaptopPreferences.set(Data.Preferences);
        LaptopType = Data.Type;

        PlayerData.set(Data.PlayerData);
    });

    OnEvent("Laptop/AddNotification", (Data) => {
        AddNotification(Data.Logo, Data.Colors, Data.Title, Data.Message)
    });

    const SetCurrentApps = AppData => {
        if (AppData.IsFake) return;
        FocusedApp.set(AppData.Id);
        if ($CurrentApps.findIndex(Val => Val.Id == AppData.Id) > -1) return;
        CurrentApps.set([...$CurrentApps, AppData]);
    };
</script>

{#if LaptopVisible}
    <div class="laptop-container" style="background-image: url({$LaptopPreferences.background ? $LaptopPreferences.background : './images/wallpapers/default.png'})">

        <!-- Settings & Notifications = dogshit. Don't judge, let me. -->
        {#if LaptopSettings}
            <Settings/>
        {/if}

        <NotificationsWrapper bind:ShowContainer={NotificationsHistory}/>

        {#each $CurrentApps as Data (Data.Id)}
            {#if Data.Id == "Unknown"}
                <AppUnknown/>
            {:else if Data.Id == "Internet"}
                <AppInternet/>
            {:else if Data.Id == "Boosting"}
                <AppBoosting/>
            {:else if Data.Id == "Bennys"}
                <AppBennys/>
            {:else if Data.Id == "SecureGuard"}
                <AppSecureGuard/>
            {:else if Data.Id == "Market"}
                <AppMarket/>
            {/if}
        {/each}

        <div class="laptop-container-apps">
            {#each LaptopApps as Data, Key}
                {#if !Data.Hidden && (!Data.RequiresVPN || $HasVPN) && (Data.Type == LaptopType || Data.IgnoreType)}
                    <div class="laptop-apps-item" on:keyup on:click={() => { SetCurrentApps(Data) }}>
                        {#if Data.IsSvg}
                            <div class="laptop-app-icon" style="background-image: url(./images/app-icons/{Data.Image}); height: 3.8vh;"></div>
                        {:else}
                            <div class="laptop-app-icon" style="background-image: url(./images/app-icons/{Data.Image})"></div>
                        {/if}

                        <p style="color: {$LaptopPreferences.whiteFont ? "white" : "black"};">{Data.Label}</p>
                    </div>
                {/if}
            {/each}
        </div>

        <div class="laptop-container-taskbar">
            <div class="laptop-container-taskbar-row">
                <div class="laptop-taskbar-app">
                    <div class="laptop-taskbar-icon" style="background-size: 60%; background-position: center; background-image: url(./images/logo.png)"></div>
                </div>
                <div class="laptop-taskbar-app">
                    <div class="laptop-taskbar-icon" style="background-size: 60%; background-position: center; background-image: url(./images/app-icons/explorer.svg)"></div>
                </div>
                <div class="laptop-taskbar-app {$FocusedApp == "Internet" ? "active" : ""}" on:keyup on:click={() => { SetCurrentApps({ Id: "Internet", Label: "Interfox Explorer", Image: "internetexplorer.svg", IsSvg: true, IsFake: false, RequiresVPN: false, Hidden: true }) }}>
                    <div class="laptop-taskbar-icon" style="background-size: 65%; background-position: center; background-image: url(./images/app-icons/internetexplorer.svg)"></div>
                </div>
                {#if $CurrentApps.length > 0}
                    {#each $CurrentApps as Data (Data.Id)}
                        {#if Data.Id != "Internet"} 
                            <div class="laptop-taskbar-app {$FocusedApp == Data.Id ? "active" : ""}">
                                <div on:keyup on:click={(e) => { FocusedApp.set(Data.Id) }} on:auxclick={() => {
                                    CurrentApps.set($CurrentApps.filter(Val => Val.Id != Data.Id));
                                    if ($CurrentApps.length > 0) FocusedApp.set($CurrentApps[$CurrentApps.length - 1].Id);
                                }} class="laptop-taskbar-icon" style="background-size: 65%; background-image: url(./images/app-icons/{Data.Image})"></div>
                            </div>
                        {/if}
                    {/each}
                {/if}
            </div>
            <div class="laptop-container-taskbar-row">
                <div on:keyup on:click={() => { NotificationsHistory = false; LaptopSettings = !LaptopSettings; }} class="laptop-taskbar-app {LaptopSettings ? "active" : ""}" style="line-height: 3.9vh; color: white; font-size: 1.5vh;">
                    <i class="fas fa-cog"></i>
                </div>
                <div class="laptop-taskbar-app" style="line-height: 3.9vh; color: white; font-size: 1.5vh;">
                    <i class="fas fa-wifi"></i>
                </div>
                <div class="laptop-taskbar-app" style="display: flex; flex-direction: column; justify-content: center; width: max-content; color: white; font-size: 1vh; font-family: Roboto; text-align: center;">
                    <p>{LaptopTime}</p>
                    <p>{LaptopDate}</p>
                </div>
                <div on:keyup on:click={() => { LaptopSettings = false; NotificationsHistory = !NotificationsHistory; }} class="laptop-taskbar-app {NotificationsHistory ? "active" : ""}" style="margin-right: 1vh;">
                    <div class="laptop-taskbar-icon" style="background-size: 40%; background-position: center; background-image: url(./images/app-icons/notifications.png)"></div>
                </div>
            </div>
        </div>
    </div>
{/if}

<style>
    .laptop-container {
        position: absolute;
        top: 50%;
        left: 50%;

        width: 150.1vh;
        height: 84vh;

        overflow: hidden;

        /* opacity: 0.7; */

        background-size: cover;
        background-repeat: no-repeat;
        background-position: center center;

        border: 0.5vh solid black;

        transform: translate(-50%, -50%);
    }

    /*
        todo: make into grid penis
    */
    .laptop-container-apps {
        width: calc(100% - 3vh);
        height: calc(95.7% - 3vh);
        max-height: calc(95.7% - 3vh);
        overflow-y: auto;
        padding: 1.5vh;
    }

    .laptop-apps-item {
        width: 7vh;
        min-height: 6vh;
        height: max-content;

        margin-right: 1.2vh;
        margin-bottom: 1.2vh;
    }

    :global(.laptop-app-icon) {
        width: auto;
        height: 4.5vh;
        margin-bottom: .5vh;
        background-size: contain;
        background-position: center 0;
        background-repeat: no-repeat;
    }

    .laptop-apps-item > p {
        font-family: Roboto;
        font-size: 1.15vh;
        color: white;
        text-align: center;
    }
    
    .laptop-container-taskbar {
        position: absolute;
        bottom: 0;

        width: 100%;
        height: 4.3%;
        display: flex;
        justify-content: space-between;

        z-index: 100;

        background-color: rgba(0, 0, 0, 0.5);
        backdrop-filter: blur(.5vh);
    }

    .laptop-container-taskbar-row {
        display: flex;
        flex-direction: row;
    }

    .laptop-taskbar-app {
        height: 100%;
        width: 3.612vh;
        padding: 0 .5vh;
        text-align: center;
    }

    .laptop-taskbar-app.active {
        background-color: rgba(255, 255, 255, 0.2);
    }

    .laptop-taskbar-app > .laptop-taskbar-icon {
        width: 100%;
        height: 100%;

        background-size: 80%;
        background-repeat: no-repeat;
        background-position: center;
    }
</style>