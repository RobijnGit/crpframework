<script>
    import { fade } from "svelte/transition";

    import { WheaterIcons } from "../../config";
    import { AddNotification, IsEnvBrowser, Notifications, OnEvent, RemoveNotification, SendEvent, SetDropdown, SetExitHandler, ShowSuccessModal, UpdateNotification } from "../../utils/Utils"
    import AppProvider from "./AppProvider.svelte";
    import Application from "./components/Application.svelte";
    import Container from "./Container.svelte";
    import Input from "./Modals/Input.svelte";
    import Loader from "./Modals/Loader.svelte";
    import Success from "./Modals/Success.svelte";
    import { HasVpn, HasRacingUsb, HasPDRacingUsb, RacingAlias, InputModal, JobManager, CurrentDocument, DocumentIsDrop, LoaderModal, PlayerData, SuccessModal, Brand, EmbedsEnabled, PhoneBackground } from "./phone.stores";
    import { ImageHoverData } from "../../stores";

    let PhoneVisible = IsEnvBrowser(); // Is A phone visible?
    let IsBurnerCurrent = false; // Is the phone a burner?
    let SoundsMuted = false;
    let IsNearNetwork = false;
    let IsNetworkEnabled = true;

    let CurrentNetwork = "";
    let CurrentApp = "home" // Default: "home";
    let CurrentTime = [12, 0]
    let CurrentWeather = "EXTRASUNNY";
    let UnreadApps = {};

    const SetCurrentApp = (App) => {
        CurrentApp = App;
        UnreadApps[App] = false;
        SendEvent("SetCurrentApp", {App})
    };

    const ToggleSound = () => {
        SoundsMuted = !SoundsMuted;
        SendEvent("Phone/ToggleSounds", {State: SoundsMuted})
    };

    const GoHome = () => {
        if (CurrentApp != "home") {
            CurrentApp = "home"
            SendEvent("SetCurrentApp", {App: "home"})
        };

        // PhoneVisible = false;
        // SendEvent("ClosePhone");
    };

    const ConnectNetwork = () => {
        if (!IsNearNetwork) return;

        SendEvent("Network/GetNetworks", {}, (Success, Data) => {
            if (!Success) return;

            InputModal.set({
                Visible: true,
                Inputs: [
                    {
                        Id: "Network",
                        Type: "TextField",
                        Data: {
                            Title: "Network:",
                            Select: Data.map(({ Id, Name }) => ({ Text: Name, Value: Id })),
                            Value: Data[0]?.Value,
                            RealValue: Data[0]?.Text,
                        },
                    },
                    {
                        Id: "Password",
                        Type: "TextField",
                        Data: {
                            Title: "Password",
                            Type: "password",
                            Icon: "user-lock"
                        },
                    },
                ],
                OnSubmit: (Result) => {
                    if (Result.Network.length <= 0) return;

                    LoaderModal.set(true);
                    SendEvent("Network/Connect", Result, (Success, Data) => {
                        LoaderModal.set(false);
                        if (!Success) return;
                        if (Data) ShowSuccessModal();
                    });
                },
            });
        })
    };

    let IsHomeFocused = false;
    let ShowHomeEaster = false;
    let EasterEggTimeout;
    const HomeEnter = () => {
        IsHomeFocused = true;

        EasterEggTimeout = setTimeout(() => {
            if (IsHomeFocused) {
                ShowHomeEaster = true
            }
        }, 1500);
    };

    const MouseLeave = () => {
        IsHomeFocused = false;
        ShowHomeEaster = false;
        clearTimeout(EasterEggTimeout);
    };

    const Selfie = () => {
        SendEvent("Phone/Selfie");
    };

    OnEvent("SetPhoneBrand", (Data) => {
        Brand.set(Data.Brand);
    });

    OnEvent("SetPhoneBackground", (Data) => {
        PhoneBackground.set(Data.Background);
    });

    OnEvent("SetEmbedsEnabled", (Data) => {
        EmbedsEnabled.set(Data.Enabled)
    });

    OnEvent("ClosePhone", (Data) => {
        CurrentApp = "home";
        PhoneVisible = false;
        InputModal.set({Visible: false});
        ImageHoverData.set({Show: false});
        SetDropdown(false);
    });

    OnEvent("OpenPhone", (Data) => {
        PhoneVisible = true;
        IsBurnerCurrent = Data.IsBurner;

        CurrentWeather = Data.Weather;
        HasVpn.set(Data.HasVPN);
        HasRacingUsb.set(Data.HasRacingUsb);
        HasPDRacingUsb.set(Data.HasPDRacingUsb);
        RacingAlias.set(Data.RacingAlias);
        CurrentTime = Data.Time;

        IsNearNetwork = Data.IsNearNetwork;
        IsNetworkEnabled = Data.IsNetworkEnabled;

        PlayerData.set(Data.PlayerData);
    });

    OnEvent("UpdatePlayerData", (Data) => {
        PlayerData.set(Data.PlayerData);
    });

    OnEvent("Notification", AddNotification);
    OnEvent("UpdateNotification", UpdateNotification);
    OnEvent("RemoveNotification", RemoveNotification);

    OnEvent("SetAppUnread", (Data) => {
        UnreadApps[Data.App] = true;
    });

    OnEvent("SetCurrentNetwork", (Data) => {
        CurrentNetwork = Data.Network;
    });

    OnEvent("SetJobManager", (Data) => {
        JobManager.set(Data.JobManager);
    });

    OnEvent("Documents/SetDocument", (Data) => {
        CurrentDocument.set(Data.Document);
        DocumentIsDrop.set(Data.IsDrop);
        CurrentApp = "documents";
    });

    SetExitHandler("ClosePhone", "ClosePhone", () => {
        return PhoneVisible
    });
</script>

<div class="phone-wrapper">
    <!-- <h1 style="margin-left: 37vh; margin-top: 1vh;">Current Network: {CurrentNetwork}</h1>
    <h1 style="margin-left: 37vh; margin-top: 1vh;">Current App: {CurrentApp}</h1>
    <h1 style="margin-left: 37vh; margin-top: 1vh;">Has VPN: {$HasVpn}</h1>

    <h1 style="margin-left: 37vh; margin-top: 1vh;">Input Modal JSON:</h1>
    <pre style="font-size: 1.25vh; margin-left: 37vh; margin-top: 1vh; border: 0.1vh solid rgba(0, 0, 0, 0.15); background-color: rgba(0, 0, 0, 0.05); width: fit-content; padding: 1vh;">{JSON.stringify($InputModal, undefined, 2)}</pre>

    <h1 style="margin-left: 37vh; margin-top: 1vh;">Notifications JSON:</h1>
    <pre style="font-size: 1.25vh; margin-left: 37vh; margin-top: 1vh; border: 0.1vh solid rgba(0, 0, 0, 0.15); background-color: rgba(0, 0, 0, 0.05); width: fit-content; padding: 1vh;">{JSON.stringify($Notifications, undefined, 2)}</pre> -->

    <Container
        isBurner={false}
        class="phone-container {IsEnvBrowser() ? "phone-debug" : ""} {PhoneVisible && !IsBurnerCurrent ? "phone-visible" : ($Notifications.length > 0 ? "phone-half" : "phone-hidden")}"
    >
        {#if $LoaderModal}
            <Loader/>
        {/if}

        {#if $SuccessModal}
            <Success/>
        {/if}

        {#if $InputModal.Visible}
            <Input/>
        {/if}

        {#if CurrentApp == "home"}
            <div in:fade={{ duration: 250 }} class="phone-applications">
                <Application
                    on:click={() => { SetCurrentApp("details") }}
                    HasUnread={UnreadApps["details"]}
                    Tooltip="Informatie"
                    style="background-image: url(./images/details.png)"
                />
                <Application
                    on:click={() => { SetCurrentApp("contacts") }}
                    HasUnread={UnreadApps["contacts"]}
                    Tooltip="Contacten"
                    style="background-image: url(./images/contacts.png)"
                />
                <Application
                    on:click={() => { SetCurrentApp("calls") }}
                    HasUnread={UnreadApps["calls"]}
                    Tooltip="Gesprekken"
                    style="background-image: url(./images/calls.png)"
                />
                <Application
                    on:click={() => { SetCurrentApp("messages") }}
                    HasUnread={UnreadApps["messages"]}
                    Tooltip="Berichten"
                    style="background-image: url(./images/conversations.png)"
                />
                <Application
                    on:click={() => { SetCurrentApp("pinger") }}
                    HasUnread={UnreadApps["pinger"]}
                    Tooltip="Pinger!"
                    style="background-image: url(./images/pinger.png)"
                />
                <Application
                    on:click={() => { SetCurrentApp("mails") }}
                    HasUnread={UnreadApps["mails"]}
                    Tooltip="Emails"
                    style="background-image: url(./images/email.png)"
                />
                <Application
                    on:click={() => { SetCurrentApp("yellowpages") }}
                    HasUnread={UnreadApps["yellowpages"]}
                    Tooltip="Yellow Pages"
                    style="background-image: url(./images/yellow-pages.png)"
                />
                <Application
                    on:click={() => { SetCurrentApp("twatter") }}
                    HasUnread={UnreadApps["twatter"]}
                    Tooltip="Twatter"
                    style="background-image: url(./images/twitter.png)"
                />
                <Application
                    on:click={() => { SetCurrentApp("vehicles") }}
                    HasUnread={UnreadApps["vehicles"]}
                    Tooltip="Voertuigen"
                    style="background-image: url(./images/vehicles.png)"
                />
                <Application
                    on:click={() => { SetCurrentApp("debt") }}
                    HasUnread={UnreadApps["debt"]}
                    Tooltip="Schulden"
                    style="background-image: url(./images/debt.png)"
                />
                <Application
                    on:click={() => { SetCurrentApp("wenmo") }}
                    HasUnread={UnreadApps["wenmo"]}
                    Tooltip="Wenmo"
                    style="background-image: url(./images/wenmo.png)"
                />
                <Application
                    on:click={() => { SetCurrentApp("documents") }}
                    HasUnread={UnreadApps["documents"]}
                    Tooltip="Documenten"
                    style="background-image: url(./images/documents.png)"
                />
                <Application
                    on:click={() => { SetCurrentApp("housing") }}
                    HasUnread={UnreadApps["housing"]}
                    Tooltip="Huizen"
                    Icon="house-user"
                    style="background-color: #46a145"
                />
                <Application
                    on:click={() => { SetCurrentApp("crypto") }}
                    HasUnread={UnreadApps["crypto"]}
                    Tooltip="Crypto"
                    style="background-image: url(./images/crypto.png)"
                />
                <Application
                    on:click={() => { SetCurrentApp("jobcenter") }}
                    HasUnread={UnreadApps["jobcenter"]}
                    Tooltip="Uitzendbureau"
                    style="background-image: url(./images/jobs.png)"
                />
                <Application
                    on:click={() => { SetCurrentApp("employment") }}
                    HasUnread={UnreadApps["employment"]}
                    Tooltip="Werkzaamheden"
                    style="background-image: url(./images/employment.png)"
                />
                <Application
                    on:click={() => { SetCurrentApp("news") }}
                    HasUnread={UnreadApps["news"]}
                    Tooltip="Weazel News"
                    style="background-image: url(./images/news.png)"
                />
                <Application
                    on:click={() => { SetCurrentApp("bin") }}
                    HasUnread={UnreadApps["bin"]}
                    Tooltip="Binsbergen International Network"
                    style="background-image: url(./images/bin.png)"
                />
                {#if $HasPDRacingUsb}
                    <Application
                        on:click={() => { SetCurrentApp("time-trials") }}
                        HasUnread={UnreadApps["time-trials"]}
                        Tooltip="Time Trials"
                        style="background-image: url(./images/time-trials.png)"
                    />
                {:else if $HasRacingUsb}
                    <Application
                        on:click={() => { SetCurrentApp("racing") }}
                        HasUnread={UnreadApps["racing"]}
                        Tooltip="Racing"
                        style="background-image: url(./images/racing.png)"
                    />
                {/if}
                {#if CurrentNetwork == "milkroad"}
                    <Application
                        on:click={() => { SetCurrentApp("milkroad") }}
                        HasUnread={UnreadApps["milkroad"]}
                        Tooltip="Milk Road"
                        Icon="user-secret"
                        style="background-color: #7c55bb"
                    />
                {/if}
                <Application
                    on:click={() => { SetCurrentApp("calculator") }}
                    HasUnread={UnreadApps["calculator"]}
                    Tooltip="Rekenmachine"
                    style="background-image: url(./images/calculator.png)"
                />
                <!-- {#if $HasVpn}
                    <Application
                        on:click={() => { SetCurrentApp("bankbusters") }}
                        HasUnread={UnreadApps["bankbusters"]}
                        Tooltip="Bank Busters"
                        Icon="piggy-bank"
                        style="background-color: #fdd800; color: black"
                    />
                {/if} -->
                <Application
                    on:click={() => { SetCurrentApp("doj") }}
                    HasUnread={UnreadApps["doj"]}
                    Tooltip="Department of Justice"
                    Icon="gavel"
                    style="background-color: #38489b; color: #afae19"
                />
                {#if $HasVpn}
                    <Application
                        on:click={() => { SetCurrentApp("tierup") }}
                        HasUnread={UnreadApps["tierup"]}
                        Tooltip="TierUp!"
                        Icon="trophy"
                        style="background-color: #4482c3; color: white"
                    />
                {/if}

                <!-- Networked Apps -->
                {#if CurrentNetwork == "pdm"}
                    <Application
                        on:click={() => { SetCurrentApp("cars") }}
                        HasUnread={UnreadApps["cars"]}
                        Tooltip="Premium Deluxe Motorsports"
                        Icon="car-alt"
                        style="background-color: #D60000; color: #dedede"
                    />
                {/if}

                {#if CurrentNetwork == "bennys"}
                    <Application
                        on:click={() => { SetCurrentApp("cars") }}
                        HasUnread={UnreadApps["cars"]}
                        Tooltip="Bennys Motorworks"
                        Icon="car-alt"
                        style="background-color: #D60000; color: #dedede"
                    />
                {/if}

                {#if CurrentNetwork == "flightschool"}
                    <Application
                        on:click={() => { SetCurrentApp("cars") }}
                        HasUnread={UnreadApps["cars"]}
                        Tooltip="Los Santos Vliegschool"
                        Icon="car-alt"
                        style="background-color: #D60000; color: #dedede"
                    />
                {/if}

                {#if CurrentNetwork == "lostmc"}
                    <Application
                        on:click={() => { SetCurrentApp("cars") }}
                        HasUnread={UnreadApps["cars"]}
                        Tooltip="The Lost Holland"
                        Icon="motorcycle"
                        style="background-color: #D60000; color: #dedede"
                    />
                {/if}

                {#if CurrentNetwork == "losmuertos"}
                    <Application
                        on:click={() => { SetCurrentApp("cars") }}
                        HasUnread={UnreadApps["cars"]}
                        Tooltip="Muertos Motorcycle Shop"
                        Icon="motorcycle"
                        style="background-color: #D60000; color: #dedede"
                    />
                {/if}

                <!-- {#if CurrentNetwork == "bearlymc"}
                    <Application
                        on:click={() => { SetCurrentApp("cars") }}
                        HasUnread={UnreadApps["cars"]}
                        Tooltip="Bearly Legal MC"
                        Icon="motorcycle"
                        style="background-color: #D60000; color: #dedede"
                    />
                {/if} -->

                {#if CurrentNetwork == "deathsinners"}
                    <Application
                        on:click={() => { SetCurrentApp("cars") }}
                        HasUnread={UnreadApps["cars"]}
                        Tooltip="Death Sinners MC"
                        Icon="motorcycle"
                        style="background-color: #D60000; color: #dedede"
                    />
                {/if}

                {#if CurrentNetwork == "darkwolves"}
                    <Application
                        on:click={() => { SetCurrentApp("cars") }}
                        HasUnread={UnreadApps["cars"]}
                        Tooltip="Dark Wolves MC"
                        Icon="motorcycle"
                        style="background-color: #D60000; color: #dedede"
                    />
                {/if}
            </div>
        {:else}
            <AppProvider App={CurrentApp} />
        {/if}

        <div class="phone-topbar">
            <div class="phone-topbar-time">
                {CurrentTime[0] < 10 ? `0${CurrentTime[0]}` : CurrentTime[0]}:{CurrentTime[1] < 10 ? `0${CurrentTime[1]}` : CurrentTime[1]}
            </div>
            <div class="phone-topbar-id">{$PlayerData.Id}</div>
            {#if IsNetworkEnabled}
                <div class:network-active={!IsNearNetwork || CurrentNetwork} class="phone-topbar-internet" on:keyup on:click={ConnectNetwork}>
                    <i class:fa-signal={!IsNearNetwork} class:fa-wifi={IsNearNetwork} class="fas" />
                </div>
            {:else}
                <div class="phone-topbar-internet">
                    <i class="fas fa-signal-slash"></i>
                </div>
            {/if}
            <div class="phone-topbar-vpn">
                {#if $HasVpn}
                    <i class="fas fa-lock" />
                {:else}
                    <i class="fas fa-unlock" />
                {/if}
            </div>
            <div class="phone-topbar-weather">
                <i class="fas fa-{WheaterIcons[CurrentWeather]}" />
            </div>
        </div>

        <div class="phone-bottombar">
            <div on:keyup on:click={ToggleSound} class="phone-bottombar-notifications">
                <i data-tooltip="Geluid Uit/Aanzetten" class="fas fa-bell{SoundsMuted ? "-slash" : ""}" />
            </div>
            <div on:keyup on:click={GoHome} on:mouseenter={HomeEnter} on:mouseleave={MouseLeave} data-tooltip="Home" class="phone-bottombar-home">
                {#if ShowHomeEaster}
                    <div class="phone-bottembar-home-mint" />
                {:else}
                    <div class="phone-bottembar-home-circle" />
                {/if}
            </div>
            <div on:keyup on:click={Selfie} class="phone-bottombar-camera">
                <i data-tooltip="Selfie!" class="fas fa-camera" />
            </div>
        </div>
    </Container>

    <Container
        isBurner={true}
        class="phone-container {PhoneVisible && IsBurnerCurrent ? "phone-visible" : "phone-hidden"}"
        style="right: 28vh !important;"
        backgroundOverride="linear-gradient(90deg, rgba(115,161,242,1) 0%, rgba(134,188,239,1) 100%)"
    >
        {#if PhoneVisible && IsBurnerCurrent}
            {#if $LoaderModal}
                <Loader/>
            {/if}

            {#if $SuccessModal}
                <Success/>
            {/if}

            {#if $InputModal.Visible}
                <Input/>
            {/if}

            {#if CurrentApp == "home"}
                <div in:fade={{ duration: 250 }} class="phone-applications">
                    <Application
                        on:click={() => { SetCurrentApp("calls") }}
                        HasUnread={UnreadApps["calls"]}
                        Tooltip="Gesprekken"
                        style="background-color: #028d7f;"
                        Icon="phone"
                    />
                    <Application
                        on:click={() => { SetCurrentApp("messages") }}
                        HasUnread={UnreadApps["messages"]}
                        Tooltip="Berichten"
                        style="background-color: #88c347;"
                        Icon="comment"
                    />
                </div>
            {:else}
                <AppProvider App={CurrentApp} />
            {/if}

            <div class="phone-topbar">
                <div class="phone-topbar-time">
                    {CurrentTime[0] < 10 ? `0${CurrentTime[0]}` : CurrentTime[0]}:{CurrentTime[1] < 10 ? `0${CurrentTime[1]}` : CurrentTime[1]}
                </div>
                <div class="phone-topbar-id">{$PlayerData.Id}</div>
                {#if IsNetworkEnabled}
                    <div class:network-active={!IsNearNetwork || CurrentNetwork} class="phone-topbar-internet" on:keyup on:click={ConnectNetwork}>
                        <i class:fa-signal={!IsNearNetwork} class:fa-wifi={IsNearNetwork} class="fas" />
                    </div>
                {:else}
                    <div class="phone-topbar-internet">
                        <i class="fas fa-signal-slash"></i>
                    </div>
                {/if}
                <div class="phone-topbar-vpn">
                    {#if $HasVpn}
                        <i class="fas fa-lock" />
                    {:else}
                        <i class="fas fa-unlock" />
                    {/if}
                </div>
                <div class="phone-topbar-weather">
                    <i class="fas fa-{WheaterIcons[CurrentWeather]}" />
                </div>
            </div>

            <div class="phone-bottombar">
                <div on:keyup on:click={ToggleSound} class="phone-bottombar-notifications">
                    <i data-tooltip="Geluid Uit/Aanzetten" class="fas fa-bell{SoundsMuted ? "-slash" : ""}" />
                </div>
                <div on:keyup on:click={GoHome} on:mouseenter={HomeEnter} on:mouseleave={MouseLeave} data-tooltip="Home" class="phone-bottombar-home">
                    {#if ShowHomeEaster}
                        <div class="phone-bottembar-home-mint" />
                    {:else}
                        <div class="phone-bottembar-home-circle" />
                    {/if}
                </div>
                <div on:keyup on:click={Selfie} class="phone-bottombar-camera">
                    <i data-tooltip="Selfie!" class="fas fa-camera" />
                </div>
            </div>
        {/if}
    </Container>
</div>

<style>
    .phone-wrapper {
        position: absolute;
        top: 0;
        left: 0;

        font-family: Roboto;
        font-size: 1vh;

        color: white;

        width: 100vw;
        height: 100vh;

        user-select: none;
    }

    .phone-bottombar {
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        height: 3.9vh;
        background-color: rgba(0, 0, 0, 0.25);
        border-top: 0.1vh solid rgba(0, 0, 0, 0.5);
    }

    .phone-bottombar > .phone-bottombar-notifications {
        position: absolute;
        top: 50%;
        transform: translateY(-50%);
        width: 50%;
        color: white;
        text-align: center;
        font-size: 1.3vh;
    }

    .phone-bottombar > .phone-bottombar-camera {
        position: absolute;
        right: 0;
        top: 50%;
        transform: translateY(-50%);
        width: 50%;
        color: white;
        text-align: center;
        font-size: 1.3vh;
    }

    .phone-bottombar-home {
        position: relative;
        top: 50%;
        left: 0;
        right: 0;
        transform: translateY(-50%);
        margin: 0 auto;
        z-index: 10;
        width: 15%;
        height: 1.5vh;
        padding: 1vh 0;
    }

    .phone-bottombar-home > .phone-bottembar-home-circle {
        position: absolute;
        left: 50%;
        top: 50%;
        pointer-events: none;
        transform: translate(-50%, -50%);
        border: 0.2vh solid white;
        border-radius: 50%;
        width: 1.5vh;
        height: 1.5vh;
    }

    .phone-bottombar-home > .phone-bottembar-home-mint {
        position: absolute;
        left: 50%;
        top: 50%;
        pointer-events: none;
        transform: translate(-50%, -50%);
        width: 3vh;
        height: 3vh;

        background: url(./../images/logo.svg);
        background-size: 100%;
        background-position: center;

        animation: pulse 1s infinite linear;
    }

    @keyframes pulse {
        0% {
            transform: translate(-50%, -50%) scale(0.85);
        }
        50% {
            transform: translate(-50%, -50%) scale(1.1);
        }
        100% {
            transform: translate(-50%, -50%) scale(0.85);
        }
    }

    .phone-topbar {
        position: absolute;
        top: 0.1vh;
        width: 100%;
        overflow: hidden;
        height: 2.3vh;
    }

    .phone-topbar > .phone-topbar-time {
        margin-top: 0.4vh;
        margin-left: 1vh;
        font-size: 1.2vh;
        float: left;
    }

    .phone-topbar > .phone-topbar-id:before {
        content: "#";
    }

    .phone-topbar > .phone-topbar-id {
        margin-top: 0.4vh;
        margin-left: 0.6vh;
        font-size: 1.2vh;
        float: left;
    }

    .phone-topbar > .phone-topbar-weather {
        float: right;
        margin-top: 0.4vh;
        width: 1.95vh;
        font-size: 1.3vh;
    }

    .phone-topbar > .phone-topbar-vpn {
        float: right;
        margin-top: 0.4vh;
        width: 1.95vh;
        font-size: 1.3vh;
    }

    .phone-topbar > .phone-topbar-vpn > .fa-unlock {
        color: #66797e;
    }

    .phone-topbar > .phone-topbar-vpn > .fa-lock {
        color: white;
    }

    .phone-topbar > .phone-topbar-internet {
        float: right;
        margin-top: 0.4vh;
        margin-right: 0.7vh;
        width: 1.95vh;
        font-size: 1.3vh;
        opacity: 0.5;
    }

    .phone-topbar > .phone-topbar-internet.network-active {
        opacity: 1;
    }

    .phone-applications {
        display: grid;
        grid-column-gap: 1.6vh;
        grid-row-gap: 1.47vh;
        grid-template-columns: 20% 20% 20% 20%;
        grid-template-rows: 9.5% 9.5% 9.5% 9.5% 9.5% 9.5% 9.5% 9.5%;
        margin-top: 3.8vh;
        margin-left: .8vh;
        width: 94.1%;
        height: 85.5%
    }
</style>
