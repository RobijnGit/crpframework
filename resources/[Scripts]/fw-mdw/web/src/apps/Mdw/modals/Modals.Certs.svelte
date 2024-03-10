<script>
    import TextField from "../../../components/TextField/TextField.svelte"
    import Button from "../../../components/Button/Button.svelte"
    import MdwChip from "../components/MdwChip.svelte"
    import { MdwModalsCerts, MdwCerts } from "../../../stores";

    let FilteredCerts = [...$MdwCerts];
    const FilterCerts = Value => {
        const Search = Value.toLowerCase();
        FilteredCerts = $MdwCerts.filter(Val => Val.certificate.toLowerCase().includes(Search));
    };
</script>

<div class="mdw-modal-certs">
    <div class="mdw-modal-certs-container">
        <p>Specialisatie Toevoegen</p>
        <TextField Title='Zoeken' Icon='search' SubSet={FilterCerts} />
        <div class="mdw-modal-certs-list">
            {#each FilteredCerts as Data, Key}
                {#if !$MdwModalsCerts.IgnoreFilter.includes(Data.id)}
                    <MdwChip on:click={() => {
                        $MdwModalsCerts.IgnoreFilter = [...$MdwModalsCerts.IgnoreFilter, Data.id]
                        $MdwModalsCerts.Cb(Data.id)
                        }} Text={Data.certificate} Color="#5F6161"/>
                {/if}
            {/each}
        </div>

        <div style="width: 100%; display: flex; justify-content: center; margin-top: 2.4vh;">
            <Button Color="warning" click={() => {
                MdwModalsCerts.set({
                    Show: false,
                    IgnoreFilter: [],
                    Cb: () => {}
                })
            }}>Sluiten</Button>
        </div>
    </div>
</div>

<style>
    .mdw-modal-certs {
        position: absolute;
        z-index: 998;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7)
    }

    .mdw-modal-certs-container {
        position: absolute;
        top: 50%;
        left: 50%;
        width: 58.3%;
        height: max-content;
        max-height: 27vh;
        padding: 1.4vh;
        transform: translate(-50%, -50%);
        background-color: rgb(34, 40, 49)
    }

    .mdw-modal-certs-container > p {
        color: white;
        font-family: Roboto;
        font-size: 1.35vh;
        margin-bottom: 1.5vh
    }

    .mdw-modal-certs-list {
        display: flex;
        flex-wrap: wrap;
        box-sizing: border-box;
        margin-top: -0.5vh;
        max-height: 13.3vh;
        overflow-y: auto
    }

    .mdw-modal-certs-list::-webkit-scrollbar {
        display: none
    }

</style>