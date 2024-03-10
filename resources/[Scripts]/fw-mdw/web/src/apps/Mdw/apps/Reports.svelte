<script>
    import { DefaultReport, MCUReport, DefaultMedicalReport, GetReportTypes, CivilianReport } from "../../../config";
    import BalloonEditor from '@ckeditor/ckeditor5-build-balloon';

    import MdwPanel from "../components/MdwPanel.svelte";
    import MdwPanelHeader from "../components/MdwPanel.Header.svelte";
    import MdwPanelList from "../components/MdwPanel.List.svelte";
    import MdwCard from "../components/MdwCard.svelte";
    import MdwChip from "../components/MdwChip.svelte";

    import Button from "../../../components/Button/Button.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";
    import Checkbox from "../../../components/Checkbox/Checkbox.svelte";
    import ImageHover from "../components/ImageHover.svelte";

    import { onMount } from "svelte";
    import { AsyncSendEvent, CopyToClipboard, Delay, FormatCurrency, GetChargeById, GetEvidenceById, GetTagById, GetTimeLabel, HasCidPermission, SendEvent } from "../../../utils/Utils";
    import { CurrentReport, IsPublic, IsEms, MdwModalsCharges, MdwModalsEvidence, MdwModalsPerson, MdwModalsProfiles, MdwModalsTags, MdwModalsUnits, MdwModalsExport, MdwProfile, ShowLoader } from "../../../stores";

    let Reports = [];
    let FilteredReports = [];
    let MaxReports = 15;
    let CurrentCategory = 'Alles'
    let ReportsEditor;

    const LoadMore = () => {
        MaxReports = MaxReports + 50;
    }

    const GenerateDefaultReport = () => {
        let Template = $IsEms ? DefaultMedicalReport : DefaultReport;

        switch ($CurrentReport.category) {
            case "MCU Onderzoek Rapport":
                Template = MCUReport;
                break;
            case "Burger Rapport":
                Template = CivilianReport;
                break;
            case "Burger Rapport":
                Template = CivilianReport;
                break;
            case "Voertuig Ongeluk Rapport":
                Template = VehicleReport;
                break;
            case "Mentale Status Rapport":
                Template = MentalReport;
                break;
            case "Fysio Rapport":
                Template = FysioReport;
                break;
            case "Brandwonden Rapport":
                Template = BurnReport;
                break;
            case "Schotwonden Rapport":
                Template = GunshotReport;
                break;
            case "Receptuur Rapport":
                Template = ReceiptReport;
                break;
        }

        // const Template = $IsEms ? DefaultMedicalReport : ($CurrentReport && $CurrentReport.category == "MCU Onderzoek Rapport" ? MCUReport : DefaultReport);
        return Template.replace("[DEPARTMENT]", ($MdwProfile.department == "RANGER" ? "SAPR" : $MdwProfile.department))
            .replace("[DATE_TIMESTAMP]", new Date().toLocaleString('nl-NL', { timeZone: 'Europe/Amsterdam', hour12: false, year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', timeZoneName: 'short' }))
            .replace("[REPORTING_OFFICER]", `@${$MdwProfile.callsign} ${$MdwProfile.name}`);
    };

    const OnReportCategoryUpdate = () => {
        if ($CurrentReport.id) return "";

        setTimeout(() => {
            window.editor.setData(GenerateDefaultReport());
        }, 100)

        return "";
    }

    onMount(() => {
        SendEvent("Reports/FetchAll", {}, (Success, Data) => {
            if (!Success) return;
            Reports = Data;
            FilterReports("");
        });

        if (ReportsEditor) {
            BalloonEditor.create(ReportsEditor, {
                supportAllValues: true,
                toolbar: {
                    items: [ 'heading', '|', 'bold', 'italic', '|', 'blockQuote', '|', 'undo', 'redo', '|', 'numberedList', 'bulletedList', '|', 'insertTable' ],
                    shouldNotGroupWhenFull: true,
                },
                placeholder: "Begin met typen...",
            }).then(Editor => {
                window.editor = Editor;
                if ($CurrentReport.report) {
                    window.editor.setData($CurrentReport.report)
                } else {
                    window.editor.setData(GenerateDefaultReport());
                    $CurrentReport.category = GetReportTypes($MdwProfile.certs)[0].Value;
                };
            }).catch(Error => {
                console.error(Error);
            });
        };
    });

    const DoesReportContainTag = (Tags, Query) => {
        for (let i = 0; i < Tags.length; i++) {
            const TagData = GetTagById(Tags[i]);
            if (TagData && TagData.tag.toLowerCase().includes(Query)) {
                return true;
            };
        };
        return false;
    };

    const FilterReports = Value => {
        const Search = Value.toLowerCase();

        // Get report types user is allowed to see
        const ReportTypes = GetReportTypes($MdwProfile.certs, true);
        // Get reports by report allowed types
        let CategorizedReports = Reports.filter(Val => {
            return ReportTypes.includes(Val.category)
        });

        // Get reports by current category if not 'Alles'
        if (CurrentCategory != 'Alles') CategorizedReports = CategorizedReports.filter(Val => Val.category == CurrentCategory);

        // Filter them by search query.
        FilteredReports = CategorizedReports.filter(Val => {
            return Val.title.toLowerCase().includes(Search) ||
                Val.author.toLowerCase().includes(Search) ||
                String(Val.id).toLowerCase().includes(Search) ||
                Val.scums.toLowerCase().includes(Search) || DoesReportContainTag(Val.tags, Search)
        });
    };

    const FetchById = Id => {
        ShowLoader.set(true);
        SendEvent("Reports/FetchById", {Id}, async (Success, Data) => {
            ShowLoader.set(false);
            if (!Success) return;
            CurrentReport.set(Data);
            window.editor.setData($CurrentReport.report);

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
                        Color: EvidenceData?.Color || "#ffffff",
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
        });
    };

    const OnReportAction = (Type) => {
        if (Type == "Reset") {
            CurrentReport.set({ category: GetReportTypes($MdwProfile.certs)[0].Value, title: '', report: '', evidence: [], tags: [], officers: [], persons: [], vehicles: [], scums: [] })
            window.editor.setData(GenerateDefaultReport());
        } else if (Type == "Export") {
            ShowLoader.set(true);

            SendEvent("Reports/Export", {
                id: $CurrentReport.id,
            }, (Success, Data) => {
                ShowLoader.set(false);
                if (!Success) return;

                MdwModalsExport.set({
                    Show: true,
                    Msg: Data.Msg,
                });

                if (Data.Url) CopyToClipboard(Data.Url);
            })
        } else if (Type == "Save") {
            ShowLoader.set(true);
            SendEvent("Reports/SaveReport", {
                report: window.editor.getData(),
                title: $CurrentReport.title,
                category: $CurrentReport.category,
                id: $CurrentReport.id,
            }, (Success, Data) => {
                ShowLoader.set(false);
                if (!Success) return;

                if (Data){
                    let ReportsIndex = Reports.findIndex(Val => Val.id == $CurrentReport.id)
                    if (ReportsIndex > -1) {
                        Reports[ReportsIndex] = Data
                    } else {
                        Reports = [Data, ...Reports];
                    };

                    FetchById(Data.id);
                    FilterReports("");
                };
            });
        } else if (Type == "Delete") {
            ShowLoader.set(true);
            SendEvent("Reports/RemoveReport", {
                Id: $CurrentReport.id,
            }, () => {
                let ReportsIndex = Reports.findIndex(Val => Val.id == $CurrentReport.id)
                if (ReportsIndex > -1) Reports.splice(ReportsIndex, 1);
                FilterReports("");

                ShowLoader.set(false);
                OnReportAction("Reset");
            });
        };
    };

    // Reports
    const GetReportsCategories = (WithAll) => {
        let Retval = [];
        if (WithAll) Retval.push({ Text: "Alles" });

        const Types = GetReportTypes($MdwProfile.certs);
        Retval = [...Retval, ...Types];

        return Retval
    };

    // Reports - Evidence
    const AddEvidence = () => {
        MdwModalsEvidence.set({
            Show: true,
            Form: $MdwModalsEvidence.Form,
            Cb: (Create, Form) => {
                ShowLoader.set(true);
                SendEvent("Reports/AddEvidence", { ReportId: $CurrentReport.id, Create, Form }, async (Success, Data) => {
                    ShowLoader.set(false);
                    if (!Success) return;

                    const [_Success, Result] = await AsyncSendEvent("Evidence/FetchById", {Id: Data });
                    const EvidenceData = GetEvidenceById(Result.type);
                    let EvidenceText = Result.description;

                    if (Result.type == "Foto") {
                        EvidenceText = `Foto (${EvidenceText})`
                    } else {
                        EvidenceText = `${Result.identifier} - (${EvidenceText})`
                    };

                    $CurrentReport.formattedEvidence = [...$CurrentReport.formattedEvidence, {
                        Color: EvidenceData?.Color || "#ffffff",
                        Text: EvidenceText,
                        Image: Result.type == "Foto" ? Result.identifier : false,
                        Id: $CurrentReport.formattedEvidence.length,
                    }];
                });
            }
        });
    };

    const RemoveEvidence = EvidenceId => {
        if (!HasCidPermission("Reports.Edit")) return;
        SendEvent("Reports/RemoveEvidence", {ReportId: $CurrentReport.id, EvidenceId}, (Success, Data) => {
            if (!Success) return;
            let NewReport = {...$CurrentReport};
            NewReport.evidence.splice(EvidenceId, 1);
            NewReport.formattedEvidence.splice(EvidenceId, 1);
            CurrentReport.set(NewReport);
        });
    };

    // Reports - Involved Officers
    const AddUnit = () => {
        MdwModalsUnits.set({
            Show: true,
            IgnoreFilter: $CurrentReport.officers,
            Cb: (OfficerId) => {
                SendEvent("Reports/AddOfficer", {ReportId: $CurrentReport.id, OfficerId}, async (Success, Data) => {
                    if (!Success) return;
                    $CurrentReport.officers = [...$CurrentReport.officers, OfficerId];
                    const [_Success, Result] = await AsyncSendEvent("Staff/FetchById", {Id: OfficerId});
                    $CurrentReport.formattedOfficers = [...$CurrentReport.formattedOfficers, {
                        Color: "#ffffff",
                        Text: `(${Result.callsign}) ${Result.name}`,
                        Id: $CurrentReport.formattedOfficers.length,
                    }];
                });
            }
        })
    };

    const RemoveUnit = OfficerId => {
        if (!HasCidPermission("Reports.Edit")) return;
        SendEvent("Reports/RemoveOfficer", {ReportId: $CurrentReport.id, OfficerId}, (Success, Data) => {
            if (!Success) return;
            let NewReport = {...$CurrentReport};
            NewReport.officers.splice(OfficerId, 1);
            NewReport.formattedOfficers.splice(OfficerId, 1);
            CurrentReport.set(NewReport);
        });
    };

    // Reports - Involved Persons
    const AddPerson = () => {
        MdwModalsPerson.set({
            Show: true,
            IgnoreFilter: $CurrentReport.persons,
            Cb: (PersonId) => {
                SendEvent("Reports/AddPerson", {ReportId: $CurrentReport.id, PersonId}, async (Success, Data) => {
                    if (!Success) return;
                    $CurrentReport.persons = [...$CurrentReport.persons, PersonId];
                    const [_Success, Result] = await AsyncSendEvent("Profiles/FetchById", {Id: PersonId});
                    $CurrentReport.formattedPersons = [...$CurrentReport.formattedPersons, {
                        Color: "#ffffff",
                        Text: `${Result.name} (#${Result.citizenid})`,
                        Id: $CurrentReport.formattedPersons.length,
                    }];
                });
            }
        })
    };

    const RemovePerson = PersonId => {
        if (!HasCidPermission("Reports.Edit")) return;
        SendEvent("Reports/RemovePerson", {ReportId: $CurrentReport.id, PersonId}, (Success, Data) => {
            if (!Success) return;
            let NewReport = {...$CurrentReport};
            NewReport.persons.splice(PersonId, 1);
            NewReport.formattedPersons.splice(PersonId, 1);
            CurrentReport.set(NewReport);
        });
    };

    // Reports - Tags
    const AddTag = () => {
        MdwModalsTags.set({
            Show: true,
            IgnoreFilter: $CurrentReport.tags,
            Cb: (TagId) => {
                SendEvent("Reports/AddTag", {ReportId: $CurrentReport.id, TagId}, (Success, Data) => {
                    if (!Success) return;
                    $CurrentReport.tags = [...$CurrentReport.tags, TagId]
                });
            },
        });
    };

    const RemoveTag = TagId => {
        SendEvent("Reports/RemoveTag", {ReportId: $CurrentReport.id, TagId}, (Success, Data) => {
            if (!Success) return;
            let NewReport = {...$CurrentReport};
            NewReport.tags.splice(TagId, 1);
            CurrentReport.set(NewReport);
        });
    };

    const AddSuspect = () => {
        MdwModalsProfiles.set({
            Show: true,
            IgnoreFilter: $CurrentReport.scums.map(Value => Value.Cid),
            Cb: (Data) => {
                const ScumData = {
                    Charges: [], Reduction: 0, ReductionString: "0% / 0 maanden / € 0,00",
                    PleadedGuilty: false, Processed: false,
                    Warrent: false, WarrentExpiration: false,
                    Cid: Data.citizenid, Name: Data.name, Id: Data.id
                };

                ShowLoader.set(true);
                SendEvent("Reports/AddCriminalScum", { ReportId: $CurrentReport.id, ScumData }, (Success, Data) => {
                    ShowLoader.set(false);
                    if (!Success) return;
                    $CurrentReport.scums = [...$CurrentReport.scums, ScumData]
                });
            }
        });
    };

    const SaveScum = ScumId => {
        ShowLoader.set(true);

        let ScumData = $CurrentReport.scums[ScumId];
        if (ScumData.Warrent) {
            let NowDate = new Date().getTime()
            let WarrentDate = new Date(ScumData.WarrentExpiration).getTime()
            if (Number.isNaN(WarrentDate) || NowDate >= WarrentDate) {
                ScumData.Warrent = false
                $CurrentReport.scums[ScumId] = ScumData
            };
        };

        SendEvent("Reports/SaveScum", { ReportId: $CurrentReport.id, ScumId, ScumData: ScumData }, (Success, Data) => {
            if (!Success) return;
            ShowLoader.set(false);
        });
    };

    const RemoveSuspect = ScumId => {
        SendEvent("Reports/DeleteScum", {ReportId: $CurrentReport.id, ScumId}, (Success, Data) => {
            if (!Success) return;
            let NewReport = {...$CurrentReport};
            NewReport.scums.splice(ScumId, 1);
            CurrentReport.set(NewReport);
        });
    };

    const OpenChargesModal = ScumData => {
        MdwModalsCharges.set({
            Show: true,
            Charges: ScumData.Charges,
            Cb: (Charges) => {
                let ScumId = $CurrentReport.scums.findIndex(Val => Val.Cid == ScumData.Cid)
                if (ScumId > -1) $CurrentReport.scums[ScumId].Charges = Charges;
            }
        });
    }

    const GetFinalString = (Reduction, Charges) => {
        let TotalJail = 0;
        let TotalFine = 0;
        let TotalPoints = 0;
        let TotalParole = 0;
        let Charged = [];

        for (let i = 0; i < Charges.length; i++) {
            const Type = Charges[i].Type
            const Data = GetChargeById(Charges[i].Id)
            if (Data) {
                if (Type == "Principal") {
                    if (!Charged.includes(Charges[i].Id)) {
                        TotalJail += Number(Data.jail)
                        TotalFine += Number(Data.fine)
                        TotalPoints += Number(Data.points)
                    } else {
                        TotalParole += Data.jail
                    };
                } else if (Type == "Accomplice") {
                    if (!Charged.includes(Charges[i].Id)) {
                        TotalJail += Number(Data?.accomplice?.jail || 0)
                        TotalFine += Number(Data?.accomplice?.fine || 0)
                        TotalPoints += Number(Data?.accomplice?.points || 0)
                    } else {
                        TotalParole += Data?.accomplice?.jail || 0
                    };
                } else if (Type == "Attempted") {
                    if (!Charged.includes(Charges[i].Id)) {
                        TotalJail += Number(Data?.attempted?.jail || 0)
                        TotalFine += Number(Data?.attempted?.fine || 0)
                        TotalPoints += Number(Data?.attempted?.points || 0)
                    } else {
                        TotalParole += Number(Data?.attempted?.jail || 0)
                    };
                };

                Charged.push(Charges[i].Id);
            };
        };

        let _Reduction = (100 - Number(Reduction)) / 100
        if (_Reduction < 1.0) {
            const ReductedJail = 1.0 - _Reduction;
            TotalParole += Math.ceil(TotalJail * ReductedJail);
        };

        if (TotalParole > 0) {
            return `${Math.ceil(TotalJail * _Reduction)} maanden (+${TotalParole} voorwaardelijk) / ${FormatCurrency.format(TotalFine * _Reduction)} boete / ${TotalPoints} punt(en)`
        };

        return `${Math.ceil(TotalJail * _Reduction)} maanden / ${FormatCurrency.format(TotalFine * _Reduction)} boete / ${TotalPoints} punt(en)`
    };

    const GetMedicalBill = (Charges) => {
        let TotalFine = 0;

        for (let i = 0; i < Charges.length; i++) {
            const Data = GetChargeById(Charges[i].Id)
            if (Data) {
                TotalFine += Data.fine
            };
        };

        return `${FormatCurrency.format(TotalFine)} factuur`
    };

    const GetReductionDropdown = (Charges) => {
        let TotalJail = 0;
        let TotalFine = 0;
        let Charged = [];

        for (let i = 0; i < Charges.length; i++) {
            const Type = Charges[i].Type
            const Data = GetChargeById(Charges[i].Id)
            if (Data) {
                if (Type == "Principal") {
                    TotalJail += Number(Data.jail)
                    if (!Charged.includes(Charges[i].Id)) TotalFine += Number(Data.fine);
                } else if (Type == "Accomplice") {
                    TotalJail += Number(Data?.accomplice?.jail || 0)
                    if (!Charged.includes(Charges[i].Id)) TotalFine += Number(Data?.accomplice?.fine || 0);
                } else if (Type == "Attempted") {
                    TotalJail += Number(Data?.attempted?.jail || 0)
                    if (!Charged.includes(Charges[i].Id)) TotalFine += Number(Data?.attempted?.fine || 0);
                };

                Charged = [...Charged, Charges[i].Id]
            };
        };

        return [
            { Text: `0% / ${TotalJail} maanden / ${FormatCurrency.format(TotalFine)}`, Value: "0" },
            { Text: `20% / ${Math.ceil(TotalJail * 0.8)} maanden / ${FormatCurrency.format(TotalFine * 0.8)}`, Value: "20" },
            { Text: `40% / ${Math.ceil(TotalJail * 0.6)} maanden / ${FormatCurrency.format(TotalFine * 0.6)}`, Value: "40" },
            { Text: `60% / ${Math.ceil(TotalJail * 0.4)} maanden / ${FormatCurrency.format(TotalFine * 0.4)}`, Value: "60" },
        ]
    };
</script>

<MdwPanel class="filled">
    <MdwPanelHeader>
        <h6>Rapporten</h6>
        <TextField Title='Zoeken' Icon='search' SubSet={FilterReports} />
    </MdwPanelHeader>

    <div style="width: 97%; margin-left: auto; margin-right: auto;">
        <TextField style="margin-bottom: 0px;" bind:RealValue={CurrentCategory} Title='Categorie' Select={GetReportsCategories(true)} />
    </div>

    <MdwPanelList style="height: 86%">
        {#each FilteredReports.slice(0, MaxReports) as Data, Key}
            {#if (CurrentCategory == 'Alles' || CurrentCategory == Data.category) && (Data.category != 'Recherche Rapport' || ($MdwProfile.certs.includes(10) || $MdwProfile.certs.includes(11)))}
                <MdwCard on:click={() => { FetchById(Data.id) }} Information={[
                    [Data.title, Data.category],
                    [`ID: ${Data.id}`, `${Data.author} - ${GetTimeLabel(Data.created)}`]
                ]} />
            {/if}
        {/each}

        {#if FilteredReports.length > 5}
            <div style="display: flex; justify-content: center; width: 100%;">
                <Button Color="success" click={LoadMore}>Laad Meer</Button>
            </div>
        {/if}
    </MdwPanelList>
</MdwPanel>

<MdwPanel>
    <MdwPanel class="filled" style="width: 100%; height: max-content; padding-bottom: 1vh; margin-bottom: 0.5vh;">
        <MdwPanelHeader>
            {#if $CurrentReport.id}
                <h6>Rapport Bewerken (#{$CurrentReport.id})</h6>
            {:else}
                <h6>Rapport Toevoegen</h6>
            {/if}
    
            {#if !$IsPublic}
                <div class="mdw-box-title-icons">
                    {#if $CurrentReport.id}
                        {#if HasCidPermission("Reports.Create")} <i on:keyup on:click={() => { OnReportAction("Reset") }} data-tooltip="Nieuw" class="fas fa-sync"></i> {/if}
                        {#if HasCidPermission("Reports.Export")} <i on:keyup on:click={() => { OnReportAction("Export") }} data-tooltip="Export" class="fas fa-file-export"></i> {/if}
                        {#if HasCidPermission("Reports.Delete")} <i on:keyup on:click={() => { OnReportAction("Delete") }} data-tooltip="Verwijderen" class="fas fa-trash"></i> {/if}
                        {#if HasCidPermission("Reports.Edit")} <i on:keyup on:click={() => { OnReportAction("Save") }} data-tooltip="Opslaan" class="fas fa-save"></i> {/if}
                    {:else}
                        {#if HasCidPermission("Reports.Create")} <i on:keyup on:click={() => { OnReportAction("Save") }} data-tooltip="Opslaan" class="fas fa-save"></i> {/if}
                    {/if}
                </div>
            {/if}
        </MdwPanelHeader>
    
        <div style="width: 97%; margin-left: auto; margin-right: auto;">
            <TextField style="margin-bottom: 0px;" bind:RealValue={$CurrentReport.category} SubSet={OnReportCategoryUpdate} Title='Categorie' Select={GetReportsCategories()} />
        </div>
        
        <div style="width: 97%; margin-left: auto; margin-right: auto;">
            <TextField style="margin-bottom: 0px;" bind:RealValue={$CurrentReport.title} Title='Titel' Icon='pencil-alt' />
        </div>
    
        <div bind:this={ReportsEditor} class="mdw-reports-editor"></div>
    </MdwPanel>

    <!-- Bewijs -->
    <MdwPanel class="filled" style="width: 100%; height: max-content; margin-bottom: 0.5vh;">
        <MdwPanelHeader>
            <h6>{$IsEms ? "Fotos" : "Bewijs"}</h6>
    
            <div class="mdw-box-title-icons">
                {#if $CurrentReport.id && HasCidPermission("Reports.Edit")}
                    <i on:keyup on:click={AddEvidence} class="fas fa-plus"></i>
                {/if}
            </div>
        </MdwPanelHeader>

        {#if $CurrentReport.id && $CurrentReport.formattedEvidence}
            <div style="padding: 0.37vh; padding-top: 0; display: flex; flex-wrap: wrap; box-sizing: border-box;">
                {#each $CurrentReport.formattedEvidence as Data, Key}
                    {#if Data.Image}
                        <ImageHover Source={Data.Image}>
                            <MdwChip Text={Data.Text} Color={Data?.Color || "#ffffff"} SuffixIcon="times-circle" on:click={() => { RemoveEvidence(Data.Id) }}/>
                        </ImageHover>
                    {:else}
                        <MdwChip Text={Data.Text} Color={Data?.Color || "#ffffff"} SuffixIcon="times-circle" on:click={() => { RemoveEvidence(Data.Id) }}/>
                    {/if}
                {/each}
            </div>
        {/if}
    </MdwPanel>
    
    <!-- Betrokken Agenten -->
    <MdwPanel class="filled" style="width: 100%; height: max-content; margin-bottom: 0.5vh;">
        <MdwPanelHeader>
            <h6>{$IsEms ? "Betrokken Collegas" : "Betrokken Agenten"}</h6>
    
            <div class="mdw-box-title-icons">
                {#if $CurrentReport.id && HasCidPermission("Reports.Edit")}
                    <i on:keyup on:click={AddUnit} class="fas fa-plus"></i>
                {/if}
            </div>
        </MdwPanelHeader>

        {#if $CurrentReport.id && $CurrentReport.formattedOfficers}
            <div style="padding: 0.37vh; padding-top: 0; display: flex; flex-wrap: wrap; box-sizing: border-box;">
                {#each $CurrentReport.formattedOfficers as Data, Key}
                    <MdwChip Text={Data.Text} Color={Data?.Color || "#ffffff"} SuffixIcon="times-circle" on:click={() => { RemoveUnit(Data.Id) }}/>
                {/each}
            </div>
        {/if}
    </MdwPanel>

    <!-- Betrokken Personen -->
    <MdwPanel class="filled" style="width: 100%; height: max-content; margin-bottom: 0.5vh;">
        <MdwPanelHeader>
            <h6>Betrokken Personen</h6>
    
            <div class="mdw-box-title-icons">
                {#if $CurrentReport.id && HasCidPermission("Reports.Edit")}
                    <i on:keyup on:click={AddPerson} class="fas fa-plus"></i>
                {/if}
            </div>
        </MdwPanelHeader>

        {#if $CurrentReport.id && $CurrentReport.formattedPersons}
            <div style="padding: 0.37vh; padding-top: 0; display: flex; flex-wrap: wrap; box-sizing: border-box;">
                {#each $CurrentReport.formattedPersons as Data, Key}
                    <MdwChip Text='{Data.Text}' Color={Data?.Color || "#ffffff"} SuffixIcon="times-circle" on:click={() => { RemovePerson(Data.Id) }}/>
                {/each}
            </div>
        {/if}
    </MdwPanel>

    <!-- Tags -->
    <MdwPanel class="filled" style="width: 100%; height: max-content; margin-bottom: 0.5vh;">
        <MdwPanelHeader>
            <h6>Tags</h6>
    
            <div class="mdw-box-title-icons">
                {#if $CurrentReport.id && HasCidPermission("Reports.Edit")}
                    <i on:keyup on:click={AddTag} class="fas fa-plus"></i>
                {/if}
            </div>
        </MdwPanelHeader>

        {#if $CurrentReport.id && $CurrentReport.tags}
            <div style="padding: 0.37vh; padding-top: 0; display: flex; flex-wrap: wrap; box-sizing: border-box;">
                {#each $CurrentReport.tags as Data, Key}
                    {#if HasCidPermission("Reports.Edit")}
                        <MdwChip Text={GetTagById(Data).tag} Color={GetTagById(Data)?.color || "#ffffff"} PrefixIcon={GetTagById(Data).icon} SuffixIcon="times-circle" on:click={() => { RemoveTag(Key) }}/>
                    {:else}
                        <MdwChip Text={GetTagById(Data).tag} Color={GetTagById(Data)?.color || "#ffffff"} PrefixIcon={GetTagById(Data).icon} />
                    {/if}
                {/each}
            </div>
        {/if}
    </MdwPanel>
</MdwPanel>

<!-- Verdachte Toevoegen -->
<MdwPanel>
    <MdwPanel class="filled" style="width: 100%; height: 4.3vh; margin-bottom: 0.5vh;">
        <MdwPanelHeader>
            <h6>{$IsEms ? "Slachtoffer" : "Verdachte"} Toevoegen</h6>
    
            <div class="mdw-box-title-icons">
                {#if $CurrentReport.id && HasCidPermission("Reports.Edit")}
                    <i on:keyup on:click={AddSuspect} class="fas fa-plus"></i>
                {/if}
            </div>
        </MdwPanelHeader>
    </MdwPanel>

    {#if $CurrentReport.id && $CurrentReport.scums}
        {#each $CurrentReport.scums as Data, Key}
            <MdwPanel class="filled" style="width: 100%; height: max-content; margin-bottom: 0.5vh;">
                <MdwPanelHeader>
                    <h6>{Data.Name} (#{Data.Cid})</h6>
                    
                    <div class="mdw-box-title-icons">
                        {#if HasCidPermission("Reports.Edit")}
                            <i on:keyup on:click={() => { RemoveSuspect(Key) }} data-tooltip="Verwijderen" class="fas fa-trash"></i>
                            <i on:keyup on:click={() => { SaveScum(Key) }} data-tooltip="Opslaan" class="fas fa-save"></i>
                        {/if}
                    </div>
                </MdwPanelHeader>

                <div style="padding: 0.37vh; padding-top: 0; display: flex; flex-wrap: wrap; box-sizing: border-box;">
                    <MdwChip Text={$IsEms ? "Facturen Bewerken" : "Straffen Bewerken"} Color="#ffffff" on:click={() => { OpenChargesModal(Data) }}/>
                    {#each Data.Charges as Charge, CKey}
                        <MdwChip Text={(Charge.Type != "Principal" ? (Charge.Type == "Accomplice" ? "(Mp) " : "(Pt) ") : "") + GetChargeById(Charge.Id)?.name || "Onbekende Straf."} Color="#000000"/>
                    {/each}
                </div>

                <hr style="margin: 1vh auto; width: 96.8%; border: none; height: 0.2vh; background-color: rgb(34, 40, 49);">
                {#if !$IsEms}
                    <div style="display: flex; flex-direction: row; justify-content: space-between; width: 96.8%; margin: 0 auto;">
                        <Checkbox bind:Checked={Data.Warrent} Title="Arrestatiebevel"/>
                        {#if Data.Warrent}
                            <TextField Title='Vervaldatum' Type="date" bind:RealValue={Data.WarrentExpiration} />
                        {/if}
                    </div>

                    <hr style="margin: 1vh auto; width: 96.8%; border: none; height: 0.2vh; background-color: rgb(34, 40, 49);">

                    <TextField style="width: 96.8%; margin: 0 auto;" Title='Strafvermindering' Select={GetReductionDropdown(Data.Charges)} bind:Value={Data.Reduction} bind:RealValue={Data.ReductionString}/>

                    <MdwPanelHeader style="flex-direction: column; height: max-content; padding-bottom: 0.5vh;">
                        <h6 style="font-size: 2.4vh; height: 2.5vh;">Final</h6>
                        <h6>{GetFinalString(Data.Reduction, Data.Charges)}</h6>
                    </MdwPanelHeader>

                    <div style="display: flex; flex-direction: row; justify-content: space-between; width: 96.8%; margin: 0 auto;">
                        <Checkbox bind:Checked={Data.PleadedGuilty} Title="Schuldig Gepleit"/>
                        <Checkbox bind:Checked={Data.Processed} Title="Afgehandeld"/>
                    </div>
                {:else}
                    <MdwPanelHeader style="flex-direction: column; height: max-content; padding-bottom: 0.5vh;">
                        <h6 style="font-size: 2.4vh; height: 2.5vh;">Final</h6>
                        <h6>{GetMedicalBill(Data.Charges)}</h6>
                    </MdwPanelHeader>

                    <div style="display: flex; flex-direction: row; justify-content: space-between; width: 96.8%; margin: 0 auto;">
                        <Checkbox bind:Checked={Data.Processed} Title="Afgehandeld"/>
                    </div>
                {/if}
            </MdwPanel>
        {/each}
    {/if}
</MdwPanel>

<style>
    .mdw-reports-editor {
        width: 93%;
        min-height: 43.3vh;
        height: max-content;
        background-color: rgb(34, 40, 49);
        outline: none !important;
        border: none !important;
        box-shadow: none !important;
        color: white;
        font-family: Roboto;
        font-size: 1.5vh;
        margin: 0 auto;
        margin-top: 1.3vh;
        padding: 0
    }

    :global(.mdw-reports-editor ol) {
        padding: revert !important
    }

    :global(.mdw-reports-editor ul) {
        padding: revert !important
    }

    .mdw-reports-editor::-webkit-scrollbar {
        display: none
    }
</style>