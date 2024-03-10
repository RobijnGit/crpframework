<script>
    import TextField from "../../../components/TextField/TextField.svelte"
    import Button from "../../../components/Button/Button.svelte"
    import { MdwModalsProfiles } from "../../../stores";
    import { SendEvent } from "../../../utils/Utils";

    let Profiles = [];
    let FilteredProfiles = [];
    SendEvent("Profiles/FetchAll", {}, (Success, Data) => {
        if (!Success) return;

        Profiles = Data;
        FilteredProfiles = Data;
    });

    const FilterProfiles = Value => {
        const Search = Value.toLowerCase();
        FilteredProfiles = Profiles.filter(Val => Val.citizenid.toLowerCase().includes(Search) || Val.name.toLowerCase().includes(Search));
    }
</script>

<div class="mdw-modal-profiles">
    <div class="mdw-modal-profiles-container">
        <TextField Title='Zoeken' Icon='user' SubSet={FilterProfiles} />

        <div class="mdw-profile-modal-result">
            {#each FilteredProfiles as Data (Data.id)}
                {#if !$MdwModalsProfiles.IgnoreFilter.includes(Data.citizenid)}
                    <div class="mdw-profile-modal-item">
                        <div style="height: 19.3vh; width: 19.3vh;">
                            <img src="{Data.image || "./images/mugshot.png"}" alt="" style="width: 19vh; height: 19vh; border: 0.15vh solid black;" />
                        </div>
                        
                        <div style="margin-left: 0.7vh; width: 100%;">
                            <TextField Icon="id-card" Title="BSN" RealValue={Data.citizenid} />
                            <TextField Icon="user" Title="Naam" RealValue={Data.name} />
                            <Button Color="success" click={() => {
                                $MdwModalsProfiles.Cb(Data);
                                $MdwModalsProfiles.IgnoreFilter = [...$MdwModalsProfiles.IgnoreFilter, Data.citizenid]
                            }}>Toevoegen</Button>
                        </div>
                    </div>
                {/if}
            {/each}
        </div>

        <div style="width: 100%; display: flex; justify-content: center; margin-top: 1vh;">
            <Button Color="warning" click={() => { $MdwModalsProfiles.Show = false }}>Sluiten</Button>
        </div>
    </div>
</div>

<style>
    .mdw-modal-profiles {
        position: absolute;
        z-index: 998;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7)
    }

    .mdw-modal-profiles-container {
        position: absolute;
        top: 50%;
        left: 50%;
        width: 39.3%;
        height: max-content;
        max-height: 83.5vh;
        padding: 0.6vh;
        transform: translate(-50%, -50%);
        background-color: rgb(34, 40, 49)
    }

    .mdw-profile-modal-result {
        display: flex;
        flex-wrap: wrap;
        box-sizing: border-box;
        margin-top: -0.5vh;
        max-height: 50vh;
        overflow-y: auto
    }

    .mdw-profile-modal-result::-webkit-scrollbar {
        display: none
    }

    .mdw-profile-modal-item {
        width: 100%;
        display: flex;
        flex-direction: row;
        margin-bottom: 1vh;
    }
</style>