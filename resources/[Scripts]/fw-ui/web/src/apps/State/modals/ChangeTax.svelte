<script>
    import Button from "../../../lib/Button/Button.svelte";
    import TextField from "../../../lib/TextField/TextField.svelte";
    import { CurrentModal } from "../state.store";
    import Modal from "./Modal.svelte";

    let Value;

    const Cancel = () => {
        CurrentModal.set(false);
    };

    const Submit = () => {
        const Cb = $CurrentModal.Cb;
        CurrentModal.set({Type: "Loading"});
        if (Cb) Cb(Value);
    };

</script>

<Modal>
    <TextField
        Title="Belasting Percentage na Tsunami"
        Icon="pencil-alt"
        Type="number"
        bind:RealValue={Value}
        style="width: 100%;"
    />

    <div style="margin-top: 2vh; width: 100%; display: flex; justify-content: space-between;">
        <Button
            Color="warning"
            style="margin: 0;"
            on:click={Cancel}
        >Annuleren</Button>
        <Button
            Color="success"
            style="margin: 0;"
            on:click={Submit}
        >Opslaan</Button>
    </div>
</Modal>