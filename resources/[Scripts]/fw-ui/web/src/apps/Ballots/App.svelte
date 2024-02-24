<script>
    import { OnEvent, SetExitHandler, SendEvent as _SendEvent } from "../../utils/Utils";
    import { Ballots, CurrentBallot } from "./ballots.store";

    import AppWrapper from "../../components/AppWrapper.svelte";
    import Button from "../../lib/Button/Button.svelte";
    import VoteeContainer from "./components/VoteeContainer.svelte";

    const SendEvent = (Event, Parameters, Callback) => {
        _SendEvent(Event, Parameters, Callback, "fw-cityhall")
    };

    let Visible = false;
    let VoteSent = false;

    SetExitHandler("", "Ballots/Close", () => Visible, { __resource: "fw-cityhall" });

    OnEvent("Ballots", "SetVisibility", (Data) => {
        VoteSent = false;
        if (Data.Visible) {
            Ballots.set(Data.Ballots);
            CurrentBallot.set(0);
        }
        Visible = Data.Visible;
    });
</script>

<AppWrapper AppName="Ballots" Focused={Visible}>
    {#if Visible}
        <div class="voting-container" style="height: {VoteSent ? 25 : 86 }vh">
            <div class="voting-header">
                {#if !VoteSent}
                    <p>Je stemt voor:</p>
                {:else}
                    <p></p>
                {/if}
                <div class="voting-header-tag" style="display: flex;">
                    <i class="fas fa-poll"></i>
                    <p>#ElectionSZN</p>
                </div>
            </div>

            {#if VoteSent}
                <div style="width: calc(100% - 2vh); top: 50%; transform: translateY(-50%); position: absolute;">
                    <p style="text-align: center; font-family: Roboto; font-size: 1.5vh; color: white;">JE STEMOPTIES ZIJN OPGESLAGEN</p>
                    <p style="text-align: center; font-family: Roboto; font-size: 2.5vh; color: white; ">BEDANKT VOOR HET STEMMEN!</p>
                </div>
            {:else}
                <hr style="margin-top: .5vh"/>

                <div style="display: flex; justify-content: space-between">
                    <p style="margin-top: 1.3vh; color: white; font-family: Roboto; font-weight: bold; font-size: 1.2vh;">{$Ballots[$CurrentBallot].Name}</p>
                    <p style="margin-top: 1.3vh; color: white; font-family: Roboto; font-size: 1.2vh;">{$Ballots[$CurrentBallot].MultipleChoice ? "SELECTEER TEN MINSTE EEN" : "SELECTEER UW KEUZE"}</p>
                </div>

                <div class="voting-list">
                    {#each $Ballots[$CurrentBallot].Nominees as Data, Key}
                        <VoteeContainer Id={Key + 1} Name={Data.Name} Party={Data.Party}/>
                    {/each}
                </div>
                
                <div style="width: 100%;">
                    {#if $CurrentBallot > 0}
                        <Button style="float: left" Color="warning" on:click={() => { CurrentBallot.set($CurrentBallot - 1) }}>Vorige Stemming</Button>
                    {/if}

                    {#if $Ballots[$CurrentBallot + 1]}
                        <Button style="float: right" Color={$Ballots[$CurrentBallot].Voted ? "success" : "disabled"} on:click={() => {
                            if ($Ballots[$CurrentBallot].Voted) CurrentBallot.set($CurrentBallot + 1);
                        }}>Volgende Stemming</Button>
                    {:else}
                    <Button style="float: right" Color={$Ballots[$CurrentBallot].Voted ? "success" : "disabled"} on:click={() => {
                        if ($Ballots[$CurrentBallot].Voted) {
                            VoteSent = !VoteSent

                            let Votes = [];
                            for (let i = 0; i < $Ballots.length; i++) {
                                const Ballot = $Ballots[i];
                                Votes.push({
                                    BallotId: Ballot.Id,
                                    Vote: Ballot.Voted,
                                })
                            }
                            SendEvent("Ballots/SaveBallots", {Votes})
                        };
                    }}>Stemming Bevestigen</Button>
                    {/if}
                </div>
            {/if}
        </div>
    {/if}
</AppWrapper>

<style>
    .voting-container {
        position: absolute;
        left: 0;
        right: 0;

        top: 50%;
        transform: translateY(-50%);

        width: 69vh;
        height: 86vh;
        padding: 1vh;

        transition: height 250ms linear;

        border-radius: .2vh;

        margin: 0 auto;

        background-color: #222832;
    }

    .voting-header {
        display: flex;
        justify-content: space-between;
    }

    .voting-header > p {
        font-family: Roboto;
        font-size: 1.7vh;

        color: white;
    }

    .voting-list {
        width: 100%;
        height: 75vh;
        margin-top: 1.3vh;
    }

    .voting-list::-webkit-scrollbar {
        display: none;
    }

    .voting-header-tag {
        font-family: Roboto;
        font-size: 1.7vh;
        color: white;
    }

    .voting-header-tag > i {
        font-size: 2.2vh;
        margin-right: .9vh;
    }
</style>