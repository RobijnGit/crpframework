<script>
    import Ripple from "@smui/ripple";
    import { onMount } from "svelte";
    import { AddNotification, IsEnvBrowser, OnEvent, SendEvent } from "../../../../utils/Utils";
    import AppContainer from "../components/AppContainer.svelte";
    import BoostingCard from "./BoostingCard.svelte";
    import AuctionCard from "./AuctionCard.svelte";

    // let Player = [];
    let CurrentPage = "contracts";
    let MyContracts = [];
    let AuctionsContracts = [];
    let BoostingProgress = { Current: "B", Next: "B+", Progress: 50 };
    let UserData = {};

    onMount(() => {
        SendEvent("Boosting/GetData", {}, (Success, Result) => {
            if (!Success) return;
            UserData = Result;
            BoostingProgress = Result.Progress;
        });

        SendEvent("Boosting/GetContracts", {}, (Success, Result) => {
            if (!Success) return;
            MyContracts = Result;
        });

        SendEvent("Boosting/GetAuctions", {}, (Success, Result) => {
            if (!Success) return;
            AuctionsContracts = Result;
        });
    });

    OnEvent("Boosting/SetUserData", (Data) => {
        UserData = Data;
        BoostingProgress = Data.Progress;
    });

    OnEvent("Boosting/SetContracts", (contracts) => {
        MyContracts = contracts;
    });

    OnEvent("Boosting/SetAuctions", (contracts) => {
        AuctionsContracts = contracts;
    });

    let IsQueuing = false;
    const ToggleQueue = () => {
        if (IsQueuing) return;

        IsQueuing = true;
        SendEvent("Boosting/SetQueue", { State: !UserData.IsQueued }, () => {
            setTimeout(() => {
                IsQueuing = false;
                UserData.IsQueued = !UserData.IsQueued;
                if (UserData.IsQueued) {
                    return AddNotification(
                        "boosting-notif.png",
                        ["#1a1922", "white"],
                        "Boostin",
                        "Wachtrij binnengegaan.."
                    );
                }
                AddNotification("boosting-notif.png", ["#1a1922", "white"], "Boostin", "Wachtrij verlaten..");
            }, 1500);
        });
    };

    const ChangeTab = (Tab) => {
        CurrentPage = Tab;
    };
</script>

<AppContainer class="app-boosting-container" AppId="Boosting" App="Boosting Contracts">
    <div class="app-container">
        <!-- Navbar -->
        <div class="boosting-navbar">
            <div
                on:keyup
                on:click={() => {
                    ChangeTab("contracts");
                }}
                use:Ripple={{ surface: true, active: true }}
                class="boosting-navbar-button {CurrentPage == 'contracts' ? 'active' : ''}"
            >
                <p>Mijn contracten</p>
            </div>
            <div
                on:keyup
                on:click={() => {
                    ChangeTab("auctions");
                }}
                use:Ripple={{ surface: true, active: true }}
                class="boosting-navbar-button {CurrentPage == 'auctions' ? 'active' : ''}"
            >
                <p>Contract veilingen</p>
            </div>
            <div
                on:keyup
                on:click={ToggleQueue}
                use:Ripple={{ surface: true, active: true }}
                class="boosting-navbar-button"
            >
                {#if IsQueuing}
                    <i class="fas fa-spinner" />
                {:else}
                    <p>{UserData.IsQueued ? "Wachtrij verlaten" : "Wachtrij binnengaan"}</p>
                {/if}
            </div>
        </div>

        <!-- Progressbar -->
        <div class="boosting-progress">
            <p>{BoostingProgress.Current}</p>
            <div class="boosting-progress-bar">
                <div class="boosting-progress-bar__fill" style="width: {BoostingProgress.Progress}%;" />
            </div>
            <p>{BoostingProgress.Next}</p>
        </div>

        <!-- Cards -->
        {#if CurrentPage == "contracts"}
            {#if MyContracts.length == 0}
                <p
                    style="color: white; opacity: 0.8; font-size: 1.3vh; text-align: center; font-family: Roboto; margin-top: 0.5vh;"
                >
                    Postvak IN leeg... :(
                </p>
            {/if}

            <div class="boosting-cards-container">
                {#each MyContracts as Data, Key}
                    <BoostingCard {Data} {UserData} />
                {/each}
                {#if IsEnvBrowser()}
                    <BoostingCard />
                {/if}
            </div>
        {:else}
            {#if AuctionsContracts.length == 0}
                <p
                    style="color: white; opacity: 0.8; font-size: 1.3vh; text-align: center; font-family: Roboto; margin-top: 0.5vh;"
                >
                    Geen lopende veilingen... :(
                </p>
            {/if}

            <div class="boosting-auctions-container">
                {#each AuctionsContracts as Data, Key}
                    <AuctionCard {Data} {UserData} />
                {/each}
                {#if IsEnvBrowser()}
                    <AuctionCard />
                {/if}
            </div>
        {/if}
    </div>
</AppContainer>

<style>
    :global(.app-boosting-container) {
        width: 127.8vh !important;
        background-color: #1a1922 !important;
    }

    :global(.app-boosting-container > .app-topbar) {
        background-color: #22212a !important;
    }

    .app-container {
        margin: 0 auto;
        margin-top: 4vh;
        width: 94%;
        height: 84%;
    }

    .boosting-navbar {
        display: flex;
        height: 3.8vh;
    }

    .boosting-navbar-button {
        display: flex;
        justify-content: space-around;
        align-items: center;

        color: white;

        font-size: 1.3vh;
        font-family: Roboto;
        margin-right: 1.35vh;

        border-radius: 0.2vh;

        padding: 1.1vh 1.5vh;
    }

    .boosting-navbar-button.active {
        background-color: #22212a;
    }

    .boosting-navbar-button:last-of-type {
        margin-left: auto;
        margin-right: 0;
        text-transform: uppercase;
        font-size: 1vh;
        background-color: #22212a;
    }

    .boosting-navbar-button:last-of-type > i {
        margin-right: 0.5vh;
        animation: fa-spin 1s linear infinite;
    }

    .boosting-progress {
        display: flex;

        justify-content: space-between;

        font-family: Roboto;
        font-size: 1.2vh;

        color: white;

        margin-top: 1.5vh;
    }

    .boosting-progress-bar {
        width: 94.4%;
        background-color: #22212a;

        border-radius: 5vh;

        height: 0.5vh;
        margin: auto 0;
    }

    .boosting-progress-bar__fill {
        width: 50%;
        height: 100%;
        background: linear-gradient(90deg, rgba(241, 82, 138, 1) 0%, rgba(46, 215, 182, 1) 100%);
        border-radius: 5vh;
    }

    .boosting-cards-container {
        margin-top: 1.6vh;

        display: grid;
        grid-template-columns: repeat(5, 20.5vh);
        grid-column-gap: 1.65vh;
        grid-row-gap: 3vh;

        max-height: 48vh;
        overflow-y: auto;
    }

    .boosting-cards-container::-webkit-scrollbar {
        display: none;
    }

    .boosting-auctions-container {
        margin-top: 2.2vh;

        width: 100%;

        max-height: 44vh;
        overflow-y: auto;

        padding: 1vh;
    }

    .boosting-auctions-container::-webkit-scrollbar {
        display: none;
    }
</style>
