<script>
    import MdwPanel from "../components/MdwPanel.svelte";
    import MdwPanelHeader from "../components/MdwPanel.Header.svelte";
    import MdwPanelList from "../components/MdwPanel.List.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";
    import MdwCard from "../components/MdwCard.svelte";
    import { onMount } from "svelte";
    import { SendEvent } from "../../../utils/Utils";
    import { CurrentBusiness, ShowLoader } from "../../../stores";

    let Businesses = [];
    let FilteredBusinesses = [];

    let FilteredEmployees = [];

    onMount(() => {
        SendEvent("Businesses/FetchAll", {}, (Success, Data) => {
            if (!Success) return;
            Businesses = Data;
            FilteredBusinesses = Data;
        });
    });

    const FilterEmployees = Value => {
        const Search = Value.toLowerCase();

        FilteredEmployees = $CurrentBusiness.Employees.filter(Val => {
            return Val.Cid.toLowerCase().includes(Search) ||
            Val.Role.toLowerCase().includes(Search) ||
            Val.Name.toLowerCase().includes(Search)
        });
    }

    const FilterBusinesses = Value => {
        const Search = Value.toLowerCase();

        FilteredBusinesses = Businesses.filter(Val => {
            return Val.business_name.toLowerCase().includes(Search) ||
                Val.business_account.toLowerCase().includes(Search)
        });
    };

    const FetchById = Id => {
        ShowLoader.set(true);
        SendEvent("Businesses/FetchEmployees", {Id}, (Success, Data) => {
            ShowLoader.set(false);
            if (!Success) return;
            CurrentBusiness.set(Data);
            FilteredEmployees = $CurrentBusiness.Employees
        });
    };
</script>

<MdwPanel class="filled" style="width: 50%">
    <MdwPanelHeader>
        <h6>Bedrijvengids</h6>
        <TextField Title='Zoeken' Icon='search' SubSet={FilterBusinesses} />
    </MdwPanelHeader>

    <MdwPanelList>
        {#each FilteredBusinesses as Data, Key}
            <MdwCard on:click={() => { FetchById(Data.id) }} Information={[
                [Data.business_name, Data.business_account ? `Bankrekening: ${Data.business_account}` : ""],
                [""]
            ]} />
        {/each}
    </MdwPanelList>
</MdwPanel>

<MdwPanel class="filled" style="width: 50%">
    <MdwPanelHeader>
        <h6>Medewerkerslijst ({$CurrentBusiness.Employees.length})</h6>
        <TextField Title='Zoeken' Icon='search' SubSet={FilterEmployees} />
    </MdwPanelHeader>

    <MdwPanelList>
        {#each FilteredEmployees as Data, Key}
            <MdwCard Information={[
                [Data.Name, `Rol: ${Data.Role}`],
                [`BSN: ${Data.Cid}`]
            ]} />
        {/each}
    </MdwPanelList>
</MdwPanel>