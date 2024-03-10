<script>
    import MdwPanel from "../components/MdwPanel.svelte";
    import MdwPanelHeader from "../components/MdwPanel.Header.svelte";
    import MdwPanelList from "../components/MdwPanel.List.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";

    import { onMount } from "svelte";
    import { AsyncSendEvent, GetEvidenceById, GetTimeLabel, HasCidPermission, SendEvent } from "../../../utils/Utils";
    import { CurrentReport, CurrentTab, ShowLoader } from "../../../stores";

    let Warrents = [];
    let FilteredWarrents = [];

    let Bulletins = [];
    let FilteredBulletins = [];

    onMount(() => {
        SendEvent("Dashboard/GetWarrents", {}, (Success, Data) => {
            if (!Success) return;
            Warrents = Data
            FilteredWarrents = Data
        });

        SendEvent("Dashboard/GetBulletin", {}, (Success, Data) => {
            if (!Success) return;
            Bulletins = Data
            FilteredBulletins = Data
        });
    });

    const FilterWarrents = Value => {
        const Search = Value.toLowerCase();

        FilteredWarrents = Warrents.filter(Val => {
            return Val.title.toLowerCase().includes(Search) ||
            Val.name.toLowerCase().includes(Search)
        });
    }

    const FilterBulletin = Value => {
        const Search = Value.toLowerCase();

        FilteredBulletins = Bulletins.filter(Val => {
            return Val.title.toLowerCase().includes(Search) ||
                Val.report.toLowerCase().includes(Search)
        });
    };

    const FetchReportById = Id => {
        ShowLoader.set(true);

        SendEvent("Reports/FetchById", {Id}, async (Success, Data) => {
            if (!Success) return;
            CurrentReport.set(Data);

            let formattedScums = Data.scums;
            for (let i = 0; i < formattedScums.length; i++) {
                if (!formattedScums[i].ReductionString) {
                    formattedScums[i].ReductionString = "0% / 0 maanden / € 0,00"
                };
            };
            $CurrentReport.scums = formattedScums;

            let formattedEvidence = [];
            for (let i = 0; i < Data.evidence.length; i++) {
                const [Success, Result] = await AsyncSendEvent("Evidence/FetchById", {Id: Data.evidence[i]});
                if (Success) {
                    const EvidenceData = GetEvidenceById(Result.type);
                    let EvidenceText = Result.description;
                    if (Result.type == "Foto") {
                        EvidenceText = `Foto (${EvidenceText})`
                    } else {
                        EvidenceText = `${Result.identifier} - (${EvidenceText})`
                    }

                    formattedEvidence.push({
                        Color: EvidenceData.Color,
                        Text: EvidenceText,
                        Image: Result.type == "Foto" ? Result.identifier : false,
                        Id: formattedEvidence.length,
                    });
                };
            };
            $CurrentReport.formattedEvidence = formattedEvidence;

            let formattedOfficers = [];
            for (let i = 0; i < Data.officers.length; i++) {
                const [Success, Result] = await AsyncSendEvent("Staff/FetchById", {Id: Data.officers[i]});
                if (Success) {
                    formattedOfficers.push({
                        Color: "#ffffff",
                        Text: `(${Result.callsign}) ${Result.name}`,
                        Id: formattedOfficers.length,
                    });
                };
            };
            $CurrentReport.formattedOfficers = formattedOfficers;

            let formattedPersons = [];
            for (let i = 0; i < Data.persons.length; i++) {
                const [Success, Result] = await AsyncSendEvent("Profiles/FetchById", {Id: Data.persons[i]});
                if (Success) {
                    formattedPersons.push({
                        Color: "#ffffff",
                        Text: `${Result.name} (#${Result.citizenid})`,
                        Id: formattedPersons.length,
                    });
                };
            };
            $CurrentReport.formattedPersons = formattedPersons;

            ShowLoader.set(false);
            CurrentTab.set("Reports");
        });
    };
</script>

{#if HasCidPermission("Dashboard.ShowWarrents")}
    <MdwPanel class="filled" style="width: {HasCidPermission("Dashboard.ShowBulletin") ? 50 : 100}%">
        <MdwPanelHeader>
            <h6>Arrestatiebevelen</h6>
            <TextField Title='Zoeken' Icon='search' SubSet={FilterWarrents} />
        </MdwPanelHeader>

        <MdwPanelList>
            {#each FilteredWarrents as Data, Key}
                <div class="mdw-warrent-card" on:keyup on:click={() => { FetchReportById(Data.id) }}>
                    <img src={Data.image || "./images/mugshot.png"} alt="" style="width: 15vh; height: 15vh; margin-right: 0.8vh;" />
                    <div class="mdw-warrent-card-details" style="width: 100%; display: flex; flex-direction: column;">
                        <div>
                            <p class="warrent-name">{Data.name}</p>
                            <p class="warrent-title">{Data.title}</p>
                        </div>
                        <div style="display: flex; justify-content: space-between; margin-top: auto; width: 100%;">
                            <p class="warrent-name">ID: {Data.id}</p>
                            <p class="warrent-title">{GetTimeLabel(Data.timestamp)}</p>
                        </div>
                    </div>
                </div>
            {/each}
        </MdwPanelList>
    </MdwPanel>
{/if}

{#if HasCidPermission("Dashboard.ShowBulletin")}
    <MdwPanel class="filled" style="width: {HasCidPermission("Dashboard.ShowWarrents") ? 50 : 100}%">
        <MdwPanelHeader>
            <h6>Prikbord</h6>
            <TextField Title='Zoeken' Icon='search' SubSet={FilterBulletin} />
        </MdwPanelHeader>
    
        <MdwPanelList>
            {#each FilteredBulletins as Data, Key}
                <div class="mdw-bulletin-card" on:keyup on:click={() => { FetchReportById(Data.id) }}>
                    <p style="font-weight: 500; margin: 0px;">{Data.title}</p>
                    <div class="mdw-bulletin-content">
                        {@html Data.report}
                    </div>
                    <div style="width: 100%; display: flex; flex-direction: column;">
                        <div style="display: flex; justify-content: space-between; margin-top: auto; width: 100%;">
                            <p class="warrent-name">ID: {Data.id}</p>
                            <p class="warrent-title">{GetTimeLabel(Data.timestamp)}</p>
                        </div>
                    </div>
                </div>
            {/each}
        </MdwPanelList>
    </MdwPanel>
{/if}
<style>
    .mdw-warrent-card {
        font-size: 1.4vh;
        font-family: Roboto;
        letter-spacing: 0.0017136vh;
        color: white;
        display: flex;
        padding: .8vh;
        margin-bottom: .8vh;
        background-color: rgb(34, 40, 49);
        height: fit-content
    }

    .mdw-bulletin-card {
        font-family: Roboto;
        font-size: 1.2vh;
        color: white;
        padding: .8vh;
        margin-bottom: .8vh;
        background-color: rgb(34, 40, 49);
        height: fit-content
    }

    .mdw-bulletin-content {
        padding: 0 !important;
        margin-bottom: .5vh;
    }

    :global(.mdw-bulletin-content ol) {
        padding: revert !important
    }

    :global(.mdw-bulletin-content ul) {
        padding: revert !important
    }
</style>