<script>
    import TextField from "../../../components/TextField/TextField.svelte"
    import Button from "../../../components/Button/Button.svelte"
    import MdwChip from "../components/MdwChip.svelte"
    import { MdwModalsRoles, MdwRoles } from "../../../stores";

    let FilteredRoles = [...$MdwRoles];
    const FilterRoles = Value => {
        const Search = Value.toLowerCase();
        FilteredRoles = $MdwRoles.filter(Val => Val.name.toLowerCase().includes(Search));
    };
</script>

<div class="mdw-modal-certs">
    <div class="mdw-modal-certs-container">
        <p>Rollen Toevoegen</p>
        <TextField Title='Zoeken' Icon='search' SubSet={FilterRoles} />
        <div class="mdw-modal-certs-list">
            {#each FilteredRoles as Data, Key}
                {#if !$MdwModalsRoles.IgnoreFilter.includes(Data.id)}
                    <MdwChip on:click={() => {
                        $MdwModalsRoles.IgnoreFilter = [...$MdwModalsRoles.IgnoreFilter, Data.id]
                        $MdwModalsRoles.Cb(Data.id)
                        }} Text={Data.name} Color="#5F6161"/>
                {/if}
            {/each}
        </div>

        <div style="width: 100%; display: flex; justify-content: center; margin-top: 2.4vh;">
            <Button Color="warning" click={() => {
                MdwModalsRoles.set({
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