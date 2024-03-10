<script>
    import Button from "../../../components/Button/Button.svelte"
    import TextField from "../../../components/TextField/TextField.svelte";
    import TextArea from "../../../components/TextArea/TextArea.svelte";
    import { MdwCharges, MdwModalsChargeEditor, MdwModalsExport, ShowLoader } from "../../../stores";
    import { SendEvent } from "../../../utils/Utils";

</script>

{#if $MdwModalsChargeEditor.Show && $MdwModalsChargeEditor.Charge != undefined && $MdwModalsChargeEditor.Charge.category != undefined}
    <div class="mdw-modal-chargeEditor">
        <div class="mdw-modal-chargeEditor-container">
            <p>Straf Bewerken</p>

            <div style="display: flex; justify-content: space-around; width: 100%;">
                <TextField
                    Title="Categorie"
                    style="width: 49%;"
                    bind:Value={$MdwModalsChargeEditor.Charge.category}
                />
                <TextField
                    Title="Naam"
                    style="width: 49%;"
                    bind:Value={$MdwModalsChargeEditor.Charge.name}
                />
            </div>

            <TextArea
                Title="Beschrijving"
                Rows={3}
                MaxLength={false}
                bind:Value={$MdwModalsChargeEditor.Charge.description}
            />

            <div style="display: flex; justify-content: space-around; width: 100%;">
                <TextField
                    Title="Gov Type"
                    style="width: 49%;"
                    Select={[
                        {Text: "pd"},
                        {Text: "ems"},
                    ]}
                    bind:Value={$MdwModalsChargeEditor.Charge.gov_type}
                />
                <TextField
                    Title="Charge Type"
                    style="width: 49%;"
                    Select={[
                        {Text: "normal"},
                        {Text: "major"},
                        {Text: "extreme"},
                    ]}
                    bind:Value={$MdwModalsChargeEditor.Charge.type}
                />
            </div>

            <hr style="margin: 2vh 0;"/>

            <p>Straf Doenpleger</p>
            <div style="display: flex; justify-content: space-around; width: 100%;">
                <TextField
                    Title="Boete"
                    style="width: 32.33%;"
                    Type="number"
                    bind:Value={$MdwModalsChargeEditor.Charge.fine}
                />
                <TextField
                    Title="Celstraf"
                    style="width: 32.33%;"
                    Type="number"
                    bind:Value={$MdwModalsChargeEditor.Charge.jail}
                />
                <TextField
                    Title="Punten"
                    style="width: 32.33%;"
                    Type="number"
                    bind:Value={$MdwModalsChargeEditor.Charge.points}
                />
            </div>

            {#if $MdwModalsChargeEditor.Charge.gov_type == "pd"}
                <p>Straf Medeplichtige</p>
                <div style="display: flex; justify-content: space-around; width: 100%;">
                    <TextField
                        Title="Boete"
                        style="width: 32.33%;"
                        Type="number"
                        bind:Value={$MdwModalsChargeEditor.Charge.accomplice.fine}
                    />
                    <TextField
                        Title="Celstraf"
                        style="width: 32.33%;"
                        Type="number"
                        bind:Value={$MdwModalsChargeEditor.Charge.accomplice.jail}
                    />
                    <TextField
                        Title="Punten"
                        style="width: 32.33%;"
                        Type="number"
                        bind:Value={$MdwModalsChargeEditor.Charge.accomplice.points}
                    />
                </div>
            
                <p>Straf Poging Tot</p>
                <div style="display: flex; justify-content: space-around; width: 100%;">
                    <TextField
                        Title="Boete"
                        style="width: 32.33%;"
                        Type="number"
                        bind:Value={$MdwModalsChargeEditor.Charge.attempted.fine}
                    />
                    <TextField
                        Title="Celstraf"
                        style="width: 32.33%;"
                        Type="number"
                        bind:Value={$MdwModalsChargeEditor.Charge.attempted.jail}
                    />
                    <TextField
                        Title="Punten"
                        style="width: 32.33%;"
                        Type="number"
                        bind:Value={$MdwModalsChargeEditor.Charge.attempted.points}
                    />
                </div>
            {/if}

            <div style="width: 100%; display: flex; justify-content: center; margin-top: 2.4vh;">
                <Button Color="warning" click={() => {
                    MdwModalsChargeEditor.set({
                        Show: false,
                    })
                }}>Annuleren</Button>
                
                <Button Color="success" click={() => {
                    ShowLoader.set(true);

                    SendEvent("Config/EditCharge", {...$MdwModalsChargeEditor.Charge}, (Success, Data) => {
                        const newCharges = $MdwCharges;
                        const Index = newCharges.findIndex(Val => Val.id == $MdwModalsChargeEditor.Charge.id)
                        if (Index == -1) {
                            newCharges.push($MdwModalsChargeEditor.Charge);
                        } else {
                            newCharges[Index] = $MdwModalsChargeEditor.Charge;
                        }

                        MdwCharges.set(newCharges);

                        ShowLoader.set(false);
                        MdwModalsChargeEditor.set({
                            Show: false,
                        })

                        if (!Success) return;

                        if (!Data.Success) {
                            MdwModalsExport.set({Show: true, Msg: Data.Msg});
                        }
                    });
                }}>Opslaan</Button>
            </div>
        </div>
    </div>
{/if}

<style>
    .mdw-modal-chargeEditor {
        position: absolute;
        z-index: 998;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7)
    }

    .mdw-modal-chargeEditor-container {
        position: absolute;
        top: 50%;
        left: 50%;
        width: 35%;
        height: max-content;
        max-height: 70vh;
        padding: 1.4vh;
        transform: translate(-50%, -50%);
        background-color: rgb(34, 40, 49);
        overflow-y: auto;
    }

    .mdw-modal-chargeEditor-container::-webkit-scrollbar {
        display: none;
    }

    .mdw-modal-chargeEditor-container > p {
        color: white;
        font-family: Roboto;
        font-size: 1.35vh;
        margin-bottom: 1.5vh
    }
</style>