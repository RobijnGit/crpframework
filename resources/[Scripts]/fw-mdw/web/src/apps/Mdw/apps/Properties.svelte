<script>
    import MdwPanel from "../components/MdwPanel.svelte";
    import MdwPanelHeader from "../components/MdwPanel.Header.svelte";
    import MdwPanelList from "../components/MdwPanel.List.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";
    import MdwCard from "../components/MdwCard.svelte";
    import { onMount } from "svelte";
    import { SendEvent } from "../../../utils/Utils";
    import { CurrentProperty, IsGov, IsJudge, ShowLoader } from "../../../stores";
    import Button from "../../../components/Button/Button.svelte";

    let Properties = [];
    let FilteredProperties = [];

    onMount(() => {
        SendEvent("Properties/FetchAll", {}, (Success, Data) => {
            if (!Success) return;
            Properties = Data;
            FilteredProperties = Data;
        });
    });

    const FilterProperties = Value => {
        const Search = Value.toLowerCase();

        FilteredProperties = Properties.filter(Val => {
            return String(Val.id).toLowerCase().includes(Search) ||
                Val.adress.toLowerCase().includes(Search)
        });
    };

    const FetchProfileById = Id => {
        ShowLoader.set(true);
        SendEvent("Properties/FetchProperty", {Id}, (Success, Data) => {
            ShowLoader.set(false);
            if (!Success) return;
            CurrentProperty.set(Data);
        });
    };

    const SetHousingGps = () => {
        if (!$CurrentProperty.id) return;
        SendEvent("Dispatch/SetGPS", {
            x: $CurrentProperty.coords.x,
            y: $CurrentProperty.coords.y,
        });
    };
</script>

<MdwPanel class="filled" style="width: 50%">
    <MdwPanelHeader>
        <h6>Eigendommen</h6>
        <TextField Title='Zoeken' Icon='search' SubSet={FilterProperties} />
    </MdwPanelHeader>

    <MdwPanelList>
        {#each FilteredProperties as Data, Key}
            <MdwCard on:click={() => { FetchProfileById(Data.id) }} Information={[
                [Data.adress],
                [`ID: ${Data.id}`]
            ]} />
        {/each}
    </MdwPanelList>
</MdwPanel>

<MdwPanel class="filled" style="width: 50%">
    <MdwPanelHeader>
        <h6>Eigendom</h6>
    </MdwPanelHeader>

    <div style="width: 97%; margin-left: auto; margin-right: auto;">
        <TextField ReadOnly={true} bind:RealValue={$CurrentProperty.id} Title='Eigendom ID' Icon='user' />
        <TextField ReadOnly={true} bind:RealValue={$CurrentProperty.adress} Title='Straatnaam & Huisnummer' Icon='user' />
        <TextField ReadOnly={true} bind:RealValue={$CurrentProperty.owned} Title='Verkocht' Icon='user' />
        {#if $IsGov || $IsJudge}
            <Button Color={$CurrentProperty.id ? "default" : "disabled"} click={SetHousingGps}>Lokaliseren</Button>
        {/if}
    </div>
</MdwPanel>