<script>
    import { DateTime } from "luxon";

    import { onMount } from "svelte";
    import { SendEvent as _SendEvent } from "../../../utils/Utils";
    import { CurrentModal } from "../state.store";

    import Button from "../../../lib/Button/Button.svelte";

    const SendEvent = (Event, Parameters, Callback) => {
        _SendEvent(Event, Parameters, Callback, "fw-cityhall")
    };

    let ActiveBallots = [];
    let ExpiredBallots = [];

    const FormatDate = (Timestamp) => {
        const date = DateTime.fromMillis(Timestamp);
        return date.toFormat('dd-MM-yyyy');
    };

    const CreateBallot = () => {
        CurrentModal.set({
            Type: "NewBallot",
            Cb: (Data) => {
                SendEvent("Ballots/CreateBallot", Data, (Success, Data) => {
                    CurrentModal.set(Success ? {Type: "Success"} : {});

                    setTimeout(() => {
                        SendEvent("Ballots/GetBallotsLogs", {}, (getSuccess, getData) => {
                            if (!getSuccess) return;
    
                            ActiveBallots = getData.filter(Val => Val.Active);
                            ExpiredBallots = getData.filter(Val => !Val.Active);
                        });
                    }, 1500);
                });
            }
        });
    };

    onMount(() => {
        SendEvent("Ballots/GetBallotsLogs", {}, (Success, Data) => {
            if (!Success) return;

            ActiveBallots = Data.filter(Val => Val.Active);
            ExpiredBallots = Data.filter(Val => !Val.Active);
        });
    });
</script>

<div class="new-ballot">
    <Button Color="success" style="margin: 0;" on:click={CreateBallot}>Stemming Aanmaken</Button>
</div>
<p class="preferences-header">Actief / Aanstaande</p>

{#each ActiveBallots as Data, Key}
    <div class="ballot-container">
        <div class="ballot-row">
            <p>{Data.Name} ({Data.Type})</p>
            <p>{FormatDate(Data.StartTimestamp)} / {FormatDate(Data.EndTimestamp)}</p>
        </div>

        {#each Data.Votes as Nominee, NomineeId}
            <div class="ballot-row">
                <p>{Nominee.Name}</p>
                <!-- <p>{Nominee.Votes} {Nominee.Votes == 1 ? "stem" : "stemmen"} ({ Data.TotalVotes == 0 ? 0 : Math.ceil((100 / Data.TotalVotes) * Nominee.Votes) }%)</p> -->
            </div>
        {/each}
    </div>
{/each}

<p class="preferences-header">Verlopen</p>
{#each ExpiredBallots as Data, Key}
    <div class="ballot-container">
        <div class="ballot-row">
            <p>{Data.Name} ({Data.Type})</p>
            <p>{FormatDate(Data.StartTimestamp)} / {FormatDate(Data.EndTimestamp)}</p>
        </div>

        {#each Data.Votes as Nominee, NomineeId}
            <div class="ballot-row">
                <p>{Nominee.Name}</p>
                <p>{Nominee.Votes} {Nominee.Votes == 1 ? "stem" : "stemmen"} ({ Data.TotalVotes == 0 ? 0 : Math.ceil((100 / Data.TotalVotes) * Nominee.Votes) }%)</p>
            </div>
        {/each}
    </div>
{/each}

<style>
    .ballot-container {
        display: flex;
        flex-direction: column;

        background-color: rgb(48, 71, 94);

        font-family: Roboto;
        font-size: 1.5vh;

        padding: 1vh;

        margin-bottom: .8vh;
    }

    .ballot-container > .ballot-row {
        display: flex;
        justify-content: space-between;
        align-items: center;

        width: 100%;

        padding-bottom: 1vh;
        margin-bottom: 1vh;
        border-bottom: 0.15vh solid white;
    }

    .ballot-container > .ballot-row:last-of-type {
        border-bottom: none;
        margin-bottom: 0;
    }

    .new-ballot {
        position: absolute;
        top: 1vh;
        right: 1.5vh;
    }
</style>