<script>
    import TextField from "../../../components/TextField/TextField.svelte"
    import Button from "../../../components/Button/Button.svelte"
    import MdwChip from "../components/MdwChip.svelte"
    import { MdwModalsUnits } from "../../../stores";
    import { onMount } from "svelte";
    import { SendEvent } from "../../../utils/Utils";

    let Units = [];
    let FilteredUnits = [];

    onMount(() => {
        SendEvent("Staff/FetchAll", {}, (Success, Data) => {
            if (!Success) return;
            Units = Data;
            FilteredUnits = Data;
        });
    });

    const FilterUnits = Value => {
        const Search = Value.toLowerCase();
        FilteredUnits = Units.filter(Val => {
            return Val.callsign.toLowerCase().includes(Search) ||
                Val.name.toLowerCase().includes(Search)
        });
    };
</script>

<div class="mdw-modal-units">
    <div class="mdw-modal-units-container">
        <p>Eenheid Toevoegen</p>
        <TextField Title='Zoeken' Icon='search' SubSet={FilterUnits} />
        <div class="mdw-modal-units-list">
            {#each FilteredUnits as Data, Key}
                {#if !$MdwModalsUnits.IgnoreFilter.includes(Data.id)}
                    <MdwChip on:click={() => {
                        $MdwModalsUnits.IgnoreFilter = [...$MdwModalsUnits.IgnoreFilter, Data.id]
                        $MdwModalsUnits.Cb(Data.id)
                    }} Text="({Data.callsign}) {Data.name}" Color="#5F6161" PrefixIcon={Data.icon} />
                {/if}
            {/each}
        </div>

        <div style="width: 100%; display: flex; justify-content: center; margin-top: 2.4vh;">
            <Button Color="warning" click={() => {
                MdwModalsUnits.set({
                    Show: false,
                    IgnoreFilter: [],
                    Cb: () => {}
                })
            }}>Sluiten</Button>
        </div>
    </div>
</div>

<style>
    .mdw-modal-units {
        position: absolute;
        z-index: 998;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7)
    }

    .mdw-modal-units-container {
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

    .mdw-modal-units-container > p {
        color: white;
        font-family: Roboto;
        font-size: 1.35vh;
        margin-bottom: 1.5vh
    }

    .mdw-modal-units-list {
        display: flex;
        flex-wrap: wrap;
        box-sizing: border-box;
        margin-top: -0.5vh;
        max-height: 13.3vh;
        overflow-y: auto
    }

    .mdw-modal-units-list::-webkit-scrollbar {
        display: none
    }

</style>