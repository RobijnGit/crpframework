<script>
    import TextField from "../../../components/TextField/TextField.svelte"
    import Button from "../../../components/Button/Button.svelte"
    import MdwChip from "../components/MdwChip.svelte"
    import { MdwModalsPerson } from "../../../stores";
    import { onMount } from "svelte";
    import { SendEvent } from "../../../utils/Utils";

    let Persons = [];
    let FilteredPersons = [];

    onMount(() => {
        SendEvent("Profiles/FetchAll", {}, (Success, Data) => {
            if (!Success) return;
            Persons = Data;
            FilteredPersons = Data;
        });
    });

    const FilterPersons = Value => {
        const Search = Value.toLowerCase();
        FilteredPersons = Persons.filter(Val => {
            return Val.citizenid.toLowerCase().includes(Search) ||
                Val.name.toLowerCase().includes(Search)
        });
    };
</script>

<div class="mdw-modal-persons">
    <div class="mdw-modal-persons-container">
        <p>Persoon Toevoegen</p>
        <TextField Title='Zoeken' Icon='search' SubSet={FilterPersons} />
        <div class="mdw-modal-persons-list">
            {#each FilteredPersons as Data, Key}
                {#if !$MdwModalsPerson.IgnoreFilter.includes(Data.id)}
                    <MdwChip on:click={() => {
                        $MdwModalsPerson.IgnoreFilter = [...$MdwModalsPerson.IgnoreFilter, Data.id]
                        $MdwModalsPerson.Cb(Data.id)
                    }} Text="{Data.name} (#{Data.citizenid})" Color="#5F6161" PrefixIcon={Data.icon} />
                {/if}
            {/each}
        </div>

        <div style="width: 100%; display: flex; justify-content: center; margin-top: 2.4vh;">
            <Button Color="warning" click={() => {
                MdwModalsPerson.set({
                    Show: false,
                    IgnoreFilter: [],
                    Cb: () => {}
                })
            }}>Sluiten</Button>
        </div>
    </div>
</div>

<style>
    .mdw-modal-persons {
        position: absolute;
        z-index: 998;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7)
    }

    .mdw-modal-persons-container {
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

    .mdw-modal-persons-container > p {
        color: white;
        font-family: Roboto;
        font-size: 1.35vh;
        margin-bottom: 1.5vh
    }

    .mdw-modal-persons-list {
        display: flex;
        flex-wrap: wrap;
        box-sizing: border-box;
        margin-top: -0.5vh;
        max-height: 13.3vh;
        overflow-y: auto
    }

    .mdw-modal-persons-list::-webkit-scrollbar {
        display: none
    }

</style>