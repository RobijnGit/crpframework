<script lang="ts">
    import Ripple from "@smui/ripple";
    import Button from "../../../../components/Button/Button.svelte";
    import TextField from "../../../../components/TextField/TextField.svelte";
    import { addResultNotification, FetchNui } from "../../../../utils/TypedUtils";
    import ModalContainer from "../components/ModalContainer.svelte";

    let ShowBiddingModal = false;
    let PlaceBidValue: string;
    $: PlaceBidAmount = +PlaceBidValue;

    export let Data = {
        Cid: "1001",
        Bidder: "1001", // adds a crown + gradient border
        Contractor: "Yeetus Deletus",
        StartBid: 42,
        Class: "S++",
        VehicleLabel: "Obey Ten-F Widebody",
        Bid: 69,
        Crypto: "GNE",
        Expire: new Date().getTime() + 1800000 * 5,
        AuctionEnd: new Date().getTime() + 1800000 * 1.5,
    };

    export let UserData = {
        Cid: "1001",
    };

    const CalculateTime = (Timestamp) => {
        let Total = Timestamp - new Date().getTime();
        const done = Total < 0;

        Total = Math.max(0, Total);

        let Seconds: number | string = Math.floor((Total / 1000) % 60);
        if (Seconds < 10) Seconds = `0${Seconds}`;
        let Minutes: number | string = Math.floor((Total / 1000 / 60) % 60);
        if (Minutes < 10) Minutes = `0${Minutes}`;
        let Hours: number | string = Math.floor((Total / (1000 * 60 * 60)) % 24);
        if (Hours < 10) Hours = `0${Hours}`;

        return { time: `${Hours}:${Minutes}:${Seconds}`, done };
    };

    const GetTimeColor = (Timestamp) => {
        const Total = Timestamp - new Date().getTime();
        const Minutes = Math.floor((Total / 1000 / 60) % 60);
        const Hours = Math.floor((Total / (1000 * 60 * 60)) % 24);

        if (Hours > 1 || (Hours == 1 && Minutes > 30)) {
            // if more than 1 hour and 30 min = greed
            return "green";
        } else if (Hours == 1 && Minutes <= 30) {
            // if less then 1,5 hours = orange
            return "orange";
        } else if (Minutes < 45) {
            // if less than 45 min = red
            return "red";
        }

        return "orange";
    };

    function getTimeValues(timestamp) {
        return { ...CalculateTime(timestamp), color: GetTimeColor(timestamp) };
    }

    let ends = getTimeValues(Data.AuctionEnd);
    let expires = getTimeValues(Data.Expire);

    $: if (ends.done) {
        ShowBiddingModal = false;
    }

    setInterval(() => {
        ends = getTimeValues(Data.AuctionEnd);
        expires = getTimeValues(Data.Expire);
    }, 1000);

    async function bid() {
        if (!PlaceBidAmount || PlaceBidAmount < 1) {
            addResultNotification("Boostin", { success: false, message: "Graag een geldig bod!" });
            return;
        }
        if ((!Data.Bid && PlaceBidAmount < Data.StartBid) || PlaceBidAmount <= Data.Bid) {
            addResultNotification("Boostin", {
                success: false,
                message: Data.Bid ? `Het bod moet hoger zijn dan ${Data.Bid || Data.StartBid} ${Data.Crypto}!` : `Bieden moet minimaal zijn ${Data.Bid || Data.StartBid} ${Data.Crypto}!`
            });
            return;
        }
        ShowBiddingModal = false;
        const result = await FetchNui("fw-laptop", "Boosting/PlaceBid", {
            contract: Data,
            bid: PlaceBidAmount,
        });
        PlaceBidAmount = 0;
        addResultNotification("Boostin", result);
    }
</script>

{#if ShowBiddingModal}
    <ModalContainer style="background-color: #1a1922;">
        <h1 style="color: white; font-size: 2vh; font-family: Roboto; font-weight: 500; margin-bottom: 2vh;">
            Bod plaatsen
        </h1>
        <div style="width: 100%; margin: 0 auto;">
            <TextField
                Title="Bod"
                Icon="fas fa-coin"
                style="width: 100%"
                Type="number"
                bind:RealValue={PlaceBidValue}
            />
            <div style="display: flex; justify-content: space-between; width: 100%;">
                <Button Color="success" style="margin: 0;" click={bid}
                    >Bieden</Button>

                <Button
                    Color="warning"
                    style="margin: 0;"
                    click={() => {
                        ShowBiddingModal = false;
                        PlaceBidAmount = undefined;
                    }}>Annuleren</Button
                >
            </div>
        </div>
    </ModalContainer>
{/if}

<div class="auction-card-wrapper {Data.Bidder === UserData.Cid ? 'cool-effect-bwo' : ''}">
    {#if Data.Bidder === UserData.Cid}
        <i class="auction-crown fas fa-crown" />
    {/if}
    <div class="auction-card-container">
        <div class="auction-card-text">
            <p>{Data.Contractor}</p>
            <p>Verkoper</p>
        </div>
        <div class="auction-card-text">
            <p>{Data.Class}</p>
            <p>Klasse</p>
        </div>
        <div class="auction-card-text">
            <p>{Data.VehicleLabel}</p>
            <p>Voertuig</p>
        </div>
        <div class="auction-card-text">
            {#if Data.Bid}
                <p>{Data.Bid} {Data.Crypto}</p>
                <p>Huidig Bod</p>
            {:else}
                <p>{Data.StartBid} {Data.Crypto}</p>
                <p>Openingsbod</p>
            {/if}
        </div>
        <div class="auction-card-text">
            <p style="color: {ends.color}">{ends.done ? "Verlopen" : ends.time}</p>
            <p>Eindigt over</p>
        </div>
        <div class="auction-card-text">
            <p style="color: {expires.color}">{expires.time}</p>
            <p>Verloopt over</p>
        </div>

        <div
            class="auction-card-btn {ends.done && 'disabled'}"
            use:Ripple={{ surface: true, active: true }}
            on:keyup
            on:click={() => {
                ShowBiddingModal = true;
            }}
        >
            Bieden
        </div>
    </div>
</div>

<style>
    .auction-card-wrapper {
        position: relative;

        width: 98%;
        height: fit-content;

        display: flex;
        align-items: center;

        border-radius: 0.8vh;
        background-color: #22212a;

        margin-bottom: 0.7vh;
    }

    .auction-card-wrapper.cool-effect-bwo {
        background: linear-gradient(
            135deg,
            rgba(93, 229, 207, 1) 0%,
            rgba(239, 227, 115, 1) 50%,
            rgba(202, 24, 173, 1) 100%
        );
        padding: 0.35vh 0;
        margin-top: 1.5vh;
    }

    .auction-card-wrapper.cool-effect-bwo > .auction-crown {
        position: absolute;
        top: -0.8vh;
        left: -0.5vh;

        z-index: 999;

        font-size: 2vh;

        color: rgba(239, 227, 115, 1);

        text-shadow: 0 0 0.5vh rgba(0, 0, 0, 0.5);

        transform: rotate(-15deg);
    }

    .auction-card-wrapper.cool-effect-bwo > .auction-card-container {
        padding: 2vh 2.1vh;
        border-radius: 0.5vh;
    }

    .auction-card-container {
        background-color: #22212a;
        width: 96%;

        padding: 2vh 0;

        margin: 0 auto;

        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .auction-card-container .auction-card-text {
        display: flex;
        flex-direction: column;
        justify-content: center;

        width: 14.2%;
    }

    .auction-card-container p {
        color: white;
        text-align: center;

        font-family: Roboto;
        font-size: 1.3vh;
    }

    .auction-card-btn {
        display: flex;
        justify-content: space-around;
        align-items: center;

        width: 16vh;

        height: 3.6vh;

        font-family: Roboto;
        font-size: 1.3vh;

        color: rgba(200, 200, 200, 1);

        cursor: pointer;

        background-color: #1a1922;
        margin-bottom: 0.8vh;
    }

    .auction-card-btn.disabled {
        background-color: #3d3c45;
        pointer-events: none;
        cursor: not-allowed;
    }
</style>
