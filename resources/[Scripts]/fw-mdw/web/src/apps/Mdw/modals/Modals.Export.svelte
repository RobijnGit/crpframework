<script>
    import Button from "../../../components/Button/Button.svelte"
    import { MdwModalsExport } from "../../../stores";
</script>

<div class="mdw-modal-export">
    <div class="mdw-modal-export-container">
        <p>{@html $MdwModalsExport.Msg}</p>

        <div style="width: 100%; display: flex; justify-content: center; margin-top: 2.4vh;">
            <Button Color="warning" click={() => {
                MdwModalsExport.set({
                    Show: false,
                    Msg: '',
                })
            }}>Sluiten</Button>
        </div>
    </div>
</div>

<style>
    .mdw-modal-export {
        position: absolute;
        z-index: 999;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7)
    }

    .mdw-modal-export-container {
        position: absolute;
        top: 50%;
        left: 50%;
        width: fit-content;
        max-width: 53%;
        height: max-content;
        max-height: 27vh;
        padding: 1.4vh;
        transform: translate(-50%, -50%);
        background-color: rgb(34, 40, 49)
    }

    .mdw-modal-export-container > p {
        color: white;
        font-family: Roboto;
        font-size: 2vh;
        margin: 1.5vh 0;

        width: 100%;
        text-align: center;
    }
</style>