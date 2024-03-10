<script>
    import Button from "../../../components/Button/Button.svelte"
    import { MdwModalsVehicleHistory } from "../../../stores";

    import MdwPanel from "../components/MdwPanel.svelte";
    import MdwPanelHeader from "../components/MdwPanel.Header.svelte";
    import MdwPanelList from "../components/MdwPanel.List.svelte";
    import MdwCard from "../components/MdwCard.svelte";
    import { FormatCurrency, GetLongTimeLabel, SendEvent } from "../../../utils/Utils";
    import { onMount } from "svelte";

    let TotalStrikes = 0;
    let ImpoundHistory = [];
    let OwnershipHistory = [];

    onMount(() => {
        SendEvent("Vehicles/FetchImpoundHistory", {
            Plate: $MdwModalsVehicleHistory.Plate,
        }, (Success, Data) => {
            if (!Success) return;
            ImpoundHistory = Data;

            for (let i = 0; i < ImpoundHistory.length; i++) {
                const {strikes} = ImpoundHistory[i];
                TotalStrikes += strikes;
            }
        });

        SendEvent("Vehicles/FetchOwnershipHistory", {
            Plate: $MdwModalsVehicleHistory.Plate,
        }, (Success, Data) => {
            if (!Success) return;
            OwnershipHistory = Data;
        })
    })
</script>

<div class="mdw-modal-vehicle-history">
    <div class="mdw-modal-vehicle-history-container">
        <p>Acties</p>
        <div class="mdw-modal-vehicle-history-list">
            <MdwPanel class="filled" style="width: 49.25%">
                <MdwPanelHeader>
                    <h6>Impound Geschiedenis ({TotalStrikes} strikes)</h6>
                </MdwPanelHeader>
            
                <MdwPanelList style="max-height: 35vh;">
                    {#each ImpoundHistory as Data, Key}
                        <MdwCard Information={[
                            [`Uitgever: ${Data.actor} - Reden: ${Data.reason}`],
                            [`Vrijgavekosten: ${FormatCurrency.format(Data.fee)} - Strikes: ${Data.strikes}`],
                            [`Datum inbeslagname: ${GetLongTimeLabel(Data.retained_date)} - Datum vrijgave: ${GetLongTimeLabel(Data.retained_until)}`],
                            [`ID: ${Data.id}`]
                        ]} />
                    {/each}
                </MdwPanelList>
            </MdwPanel>

            <MdwPanel class="filled" style="width: 49.25%">
                <MdwPanelHeader>
                    <h6>Eigendomsgeschiedenis</h6>
                </MdwPanelHeader>
            
                <MdwPanelList style="max-height: 35vh;">
                    <!-- <p style="font-family: Roboto; font-size: 1.5vh; color: white; margin-bottom: 0.6vh;"><i class="fas fa-info-circle"></i> Informatie binnenkort beschikbaar..</p> -->

                    {#each OwnershipHistory as Data, Key}
                        <MdwCard Information={[
                            [`Van: ${Data.from}`],
                            [`Verkoopprijs: ${FormatCurrency.format(Data.price)} - Verkocht op: ${GetLongTimeLabel(Data.timestamp)}`],
                            [`ID: ${Data.id}`]
                        ]} />
                    {/each}
                </MdwPanelList>
            </MdwPanel>
        </div>

        <div style="width: 100%; display: flex; justify-content: center; margin-top: 2.4vh;">
            <Button Color="warning" click={() => {
                MdwModalsVehicleHistory.set({
                    Show: false,
                    Plate: ""
                })
            }}>Sluiten</Button>
        </div>
    </div>
</div>

<style>
    .mdw-modal-vehicle-history {
        position: absolute;
        z-index: 998;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7)
    }

    .mdw-modal-vehicle-history-container {
        position: absolute;
        top: 50%;
        left: 50%;
        width: 78.3%;
        height: 50vh;
        padding: 1.4vh;
        transform: translate(-50%, -50%);
        background-color: rgb(34, 40, 49)
    }

    .mdw-modal-vehicle-history-container > p {
        color: white;
        font-family: Roboto;
        font-size: 1.35vh;
        margin-bottom: 1.5vh
    }

    .mdw-modal-vehicle-history-list {
        width: 100%;
        display: flex;
        justify-content: space-between;
    }
</style>