<script>
    import TextField from "../../../components/TextField/TextField.svelte"
    import Button from "../../../components/Button/Button.svelte"
    import MdwChip from "../components/MdwChip.svelte"
    import { MdwModalsTags, MdwTags } from "../../../stores";

    let FilteredTags = [...$MdwTags];
    const FilterTags = Value => {
        const Search = Value.toLowerCase();
        FilteredTags = $MdwTags.filter(Val => Val.tag.toLowerCase().includes(Search));
    };
</script>

<div class="mdw-modal-tags">
    <div class="mdw-modal-tags-container">
        <p>Tag Toevoegen</p>
        <TextField Title='Zoeken' Icon='search' SubSet={FilterTags} />
        <div class="mdw-modal-tags-list">
            {#each FilteredTags as Data, Key}
                {#if !$MdwModalsTags.IgnoreFilter.includes(Data.id)}
                    <MdwChip on:click={() => {
                        $MdwModalsTags.IgnoreFilter = [...$MdwModalsTags.IgnoreFilter, Data.id]
                        $MdwModalsTags.Cb(Data.id)
                    }} Text={Data.tag} Color="#5F6161" PrefixIcon={Data.icon} />
                {/if}
            {/each}
        </div>

        <div style="width: 100%; display: flex; justify-content: center; margin-top: 2.4vh;">
            <Button Color="warning" click={() => {
                MdwModalsTags.set({
                    Show: false,
                    IgnoreFilter: [],
                    Cb: () => {}
                })
            }}>Sluiten</Button>
        </div>
    </div>
</div>

<style>
    .mdw-modal-tags {
        position: absolute;
        z-index: 998;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7)
    }

    .mdw-modal-tags-container {
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

    .mdw-modal-tags-container > p {
        color: white;
        font-family: Roboto;
        font-size: 1.35vh;
        margin-bottom: 1.5vh
    }

    .mdw-modal-tags-list {
        display: flex;
        flex-wrap: wrap;
        box-sizing: border-box;
        margin-top: -0.5vh;
        max-height: 13.3vh;
        overflow-y: auto
    }

    .mdw-modal-tags-list::-webkit-scrollbar {
        display: none
    }

</style>