<script>
    import TextField from "../../../components/TextField/TextField.svelte"
    import Button from "../../../components/Button/Button.svelte"
    import { MdwModalsEvidence, MdwEvidence, MdwModalsExport } from "../../../stores";

    let EvidenceId = '';
</script>

<div class="mdw-modal-evidence">
    <div class="mdw-modal-evidence-container">
        <p>Bewijs Toevoegen</p>
        <TextField style="margin-bottom: .5vh;" Title='Bewijs ID' Icon='fingerprint' Type="number" bind:RealValue={EvidenceId} />
        <div style="width: 100%; display: flex; justify-content: end;">
            <Button Color="success" click={() => {
                if (Number(EvidenceId) > 0) {
                    $MdwModalsEvidence.Cb(false, {Id: Number(EvidenceId)})
                    MdwModalsEvidence.set({ Show: false, Form: $MdwModalsEvidence.Form, Cb: () => {} });
                }
            }}>Toevoegen</Button>
        </div>

        <p>Nieuw Bewijs Aanmaken</p>
        <TextField style="margin-bottom: .5vh;" Title='Type' bind:RealValue={$MdwModalsEvidence.Form.Type} Select={$MdwEvidence} />
        <TextField style="margin-bottom: .5vh;" Title='Identifier' Icon='pencil-alt' bind:RealValue={$MdwModalsEvidence.Form.Identifier} />
        <TextField style="margin-bottom: .5vh;" Title='Beschrijving' Icon='clipboard' bind:RealValue={$MdwModalsEvidence.Form.Description} />
        <TextField style="margin-bottom: .5vh;" Title='BSN' Icon='user' bind:RealValue={$MdwModalsEvidence.Form.Cid} />
        <div style="width: 100%; display: flex; justify-content: end;">
            <Button Color="success" click={() => {
                if ($MdwModalsEvidence.Form.Type && $MdwModalsEvidence.Form.Identifier && $MdwModalsEvidence.Form.Description) {
                    if ($MdwModalsEvidence.Form.Identifier.includes(".discordapp.")) {
                        MdwModalsExport.set({
                            Show: true,
                            Msg: `cdn.discordapp.com kan niet gebruikt worden als identifier.`,
                        });

                        return;
                    }

                    $MdwModalsEvidence.Cb(true, $MdwModalsEvidence.Form)
                    MdwModalsEvidence.set({ Show: false, Form: $MdwModalsEvidence.Form, Cb: () => {} });
                }
            }}>Opslaan</Button>
        </div>

        <div style="width: 100%; display: flex; justify-content: center; margin-top: 2.4vh;">
            <Button Color="warning" click={() => {
                MdwModalsEvidence.set({ Show: false, Form: $MdwModalsEvidence.Form, Cb: () => {} });
            }}>Sluiten</Button>
        </div>
    </div>
</div>

<style>
    .mdw-modal-evidence {
        position: absolute;
        z-index: 997;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7)
    }

    .mdw-modal-evidence-container {
        position: absolute;
        top: 50%;
        left: 50%;
        width: 18.5%;
        height: 46.5vh;
        padding: 1.4vh;
        transform: translate(-50%, -50%);
        background-color: rgb(34, 40, 49)
    }

    .mdw-modal-evidence-container > p {
        color: white;
        font-family: Roboto;
        font-size: 1.35vh;
        margin-bottom: 1.5vh
    }
</style>