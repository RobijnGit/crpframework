<script>
    import { onMount } from "svelte";
    import { SendEvent, ShowSuccessModal } from "../../../utils/Utils";
    import { InputModal, LoaderModal, PlayerData } from "../phone.stores";

    import AppWrapper from "../components/AppWrapper.svelte";
    import Paper from "../components/Paper.svelte";
    import PaperList from "../components/PaperList.svelte";

    let Heists = [];

    const GetExpirationTime = (Minutes) => {
        const Now = new Date();
        const ExpirationTime = new Date(Now.getTime() + Minutes * 1000);
        const TimeDiff = ExpirationTime.getTime() - Now.getTime();
        if (TimeDiff <= 0) return "Verlopen";

        const HoursRemaining = Math.floor(TimeDiff / (1000 * 60 * 60));
        const MinutesRemaining = Math.floor((TimeDiff / (1000 * 60)) % 60);
        return `Verloopt over: ${HoursRemaining}u ${MinutesRemaining}m`;
    };

    onMount(() => {
        SendEvent("BankBusters/GetBusters", {}, (Success, Data) => {
            if (!Success) return;
            Heists = Data;
        });
    });
</script>

<AppWrapper>
    <div class="bankbusters-logo"><i class="fas fa-piggy-bank" /></div>

    <PaperList>
        {#each Heists as Data, Id}
            <Paper
                Title={Data.Label}
                Description={[
                    GetExpirationTime(Data.Time),
                    GetExpirationTime(Data.Time) != "Verlopen" ? (Data.Claimers.includes($PlayerData.Cid) ? "Geclaimed" : "Beschikbaar") : ""
                ]}
                HasActions={true}
            >
                <i
                    data-tooltip="Claimen"
                    class="fas fa-hand-holding"
                    on:keyup on:click={() => {
                        InputModal.set({
                            Visible: true,
                            Inputs: [
                                {
                                    Type: "Text",
                                    Text: "Weet je het zeker?",
                                    Data: {
                                        style: "margin-top: 3vh; margin-bottom: 4vh; text-align: center; font-size: 1.5vh;"
                                    },
                                },
                            ],
                            OnSubmit: () => {
                                LoaderModal.set(true);
                                SendEvent("BankBusters/ClaimHeist", { HeistId: Id + 1 }, (Success, Data) => {
                                    LoaderModal.set(false);
                                    if (!Success) return;
                                    ShowSuccessModal();

                                    Heists[Id].Claimers = [...Heists[Id].Claimers, $PlayerData.Cid]
                                });
                            }
                        });
                    }}
                />
            </Paper>
        {/each}
    </PaperList>
</AppWrapper>

<style>
    .bankbusters-logo {
        width: 100%;
        margin-top: 2.6vh;
        font-size: 4.4vh;
        color: #fdd800;
        text-align: center;
    }
</style>
