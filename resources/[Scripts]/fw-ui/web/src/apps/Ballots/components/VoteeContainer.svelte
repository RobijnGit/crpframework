<script>
    import { Ballots, CurrentBallot } from "../ballots.store"
    import VoteeCheckbox from "./VoteeCheckbox.svelte"

    export let Name = '';
    export let Party = '';
    export let Id = 0;
</script>

<div class="voting-votee-container">
    <div class="voting-votee-name" style="display: flex; flex-direction: column;">
        <p style="font-size: 1.7vh;">{Name}</p>
        <p style="margin-top: .55vh;">{Party}</p>
    </div>

    <VoteeCheckbox Checked={$Ballots[$CurrentBallot].Voted.includes(Id)} click={() => {
        if ($Ballots[$CurrentBallot].MultipleChoice) {
            const Index = $Ballots[$CurrentBallot].Voted.findIndex(Val => Val == Id);
            if (Index == -1) {
                $Ballots[$CurrentBallot].Voted = [...$Ballots[$CurrentBallot].Voted, Id]
            } else {
                $Ballots[$CurrentBallot].Voted = $Ballots[$CurrentBallot].Voted.filter(Val => Val != Id);
            }
        } else {
            $Ballots[$CurrentBallot].Voted = [Id]
        }
    }} />
</div>

<style>
    .voting-votee-container {
        background-color: #30475e;
        width: calc(100% - 2vh);
        height: 5.3vh;
        margin-bottom: 1vh;

        border-radius: .5vh;

        padding: 1vh;

        display: flex;
        justify-content: space-between;
    }

    .voting-votee-name > p {
        font-family: Roboto;
        font-size: 1.2vh;
        font-weight: 450;
        color: white;
    }
</style>