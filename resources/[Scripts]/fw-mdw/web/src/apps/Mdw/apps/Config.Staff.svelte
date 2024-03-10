<script>
    import MdwPanel from "../components/MdwPanel.svelte";
    import MdwPanelHeader from "../components/MdwPanel.Header.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";
    import { SendEvent } from "../../../utils/Utils";
    import Button from "../../../components/Button/Button.svelte";
    import { MdwCerts, MdwModalsExport, MdwRanks, ShowLoader } from "../../../stores";
    import { onMount } from "svelte";

    // Code Editor
    import { CodeJar } from "@novacbn/svelte-codejar";
    import Prism from 'prismjs';
    import 'prismjs/components/prism-json';
    const highlight = (code, syntax) => Prism.highlight(code, Prism.languages[syntax], syntax);

    let Staff = [];
    let FilteredStaff = [];

    onMount(() => {
        SendEvent("Config/FetchAllStaff", {}, (Success, Data) => {
            if (!Success) return;
            Staff = Data;
            FilterStaff("");
        })
    })

    const IsJson = str => {
        try {
            JSON.parse(str)
        } catch(e) {
            return false
        }
        return true
    }

    // Certs
    let FilteredCerts = [];
    let CertTemplate = JSON.stringify({ certificate: "", color: "" }, undefined, 2)

    const FilterCerts = Value => {
        const Search = Value.toLowerCase();
        const MatchedCerts = $MdwCerts.filter(Val => Val.certificate.toLowerCase().includes(Search))
        FilteredCerts = MatchedCerts.map(Val => {return JSON.stringify(Val, null, 2)})
    };

    const SaveCerts = (Create, Data) => {
        if (Create) {
            SendEvent("Config/CreateCert", JSON.parse(CertTemplate))
        } else {
            SendEvent("Config/SaveCert", JSON.parse(Data))
        };
    };

    const DeleteCerts = TagId => {
        if (TagId) SendEvent("Config/DeleteCert", {id: TagId})
    };

    MdwCerts.subscribe((Val) => { FilterCerts("") });

    // Roles
    let FilteredRoles = [];
    let RolesTemplate = JSON.stringify({ rank: "" }, undefined, 2)

    const FilterRoles = Value => {
        const Search = Value.toLowerCase();
        const MatchedRoles = $MdwRanks.filter(Val => Val.rank.toLowerCase().includes(Search))
        FilteredRoles = MatchedRoles.map(Val => {return JSON.stringify(Val, null, 2)})
    };

    const SaveRole = (Create, Data) => {
        if (Create) {
            SendEvent("Config/CreateRank", JSON.parse(RolesTemplate));
        } else {
            SendEvent("Config/SaveRank", JSON.parse(Data));
        };
    };

    const DeleteRole = RoleId => {
        if (RoleId) SendEvent("Config/DeleteRank", {id: RoleId});
    };

    MdwRanks.subscribe((Val) => { FilterRoles("") });

    // Staff
    let StaffTemplate = JSON.stringify({ citizenid: "", name: "", image: "", callsign: "", alias: "", phonenumber: "", department: "", rank: 1 }, undefined, 2)

    const FilterStaff = Value => {
        const Search = Value.toLowerCase();
        const MatchedStaff = Staff.filter(Val => { return Val.citizenid.toLowerCase().includes(Search) ||
            Val.name.toLowerCase().includes(Search) ||
            Val.callsign.toLowerCase().includes(Search) ||
            Val.alias.toLowerCase().includes(Search)
        });
        FilteredStaff = MatchedStaff.map(Val => {return JSON.stringify(Val, null, 2)})
    };

    const SaveStaff = (Create, Data, Refetch) => {
        if (Create) {
            SendEvent("Config/CreateStaff", JSON.parse(StaffTemplate))
        } else {
            SendEvent("Config/SaveStaff", JSON.parse(Data), () => {
                if (Refetch) {
                    SendEvent("Config/FetchAllStaff", {}, (Success, Data) => {
                        if (!Success) return;
                        Staff = Data;
                        FilterStaff("");
                    });
                };
            });
        };
    };

    const DeleteStaff = StaffId => {
        if (StaffId) {
            SendEvent("Config/DeleteStaff", {id: StaffId}, () => {
                SendEvent("Config/FetchAllStaff", {}, (Success, Data) => {
                    if (!Success) return;
                    Staff = Data;
                    FilterStaff("");
                });
            })
        };
    };

    const CreateBadge = ({callsign, image, name, rank: rankId}) => {
        const {rank} = $MdwRanks.find(Val => Val.id == rankId);
        if (!rank) return MdwModalsExport.set({
            Show: true,
            Msg: "Kon geen badge aanmaken: Rank niet gevonden.",
        });

        if (!callsign) return MdwModalsExport.set({
            Show: true,
            Msg: "Kon geen badge aanmaken: Callsign niet gevonden.",
        });

        if (!image) return MdwModalsExport.set({
            Show: true,
            Msg: "Kon geen badge aanmaken: Foto niet gevonden.",
        });

        if (!name) return MdwModalsExport.set({
            Show: true,
            Msg: "Kon geen badge aanmaken: Naam niet gevonden.",
        });

        const callsignSerial = callsign.charAt(0);
        let badgeType = false;
        let departmentLabel = false;

        switch (callsignSerial) {
            case "2":
                departmentLabel = "State Troopers"
                badgeType = "pd";
                break;
            case "3":
                departmentLabel = "Blaine County Sheriffs Office"
                badgeType = "pd";
                break;
            case "4":
                departmentLabel = "Los Santos PD"
                badgeType = "pd";
                break;
            case "5":
                departmentLabel = "State Park"
                badgeType = "pd";
                break;
            case "6":
                departmentLabel = "Unified PD"
                badgeType = "pd";
                break;
            default:
                departmentLabel = "Los Santos Medical Group"
                badgeType = "ems";
                break;
        }

        if (!badgeType || !departmentLabel) return MdwModalsExport.set({
            Show: true,
            Msg: "Kon geen badge aanmaken: Department niet geldig.",
        });

        ShowLoader.set(true);
        SendEvent("Config/CreateBadge", {callsign, departmentLabel, image, name, rank, badgeType}, (Success, Result) => {
            ShowLoader.set(false)
            if (!Success) return;

            MdwModalsExport.set({
                Show: true,
                Msg: `Successvol badge aangemaakt voor ${departmentLabel} (#${callsign}) ${name}!`,
            });
        });
    }
</script>

<MdwPanel style="margin-top: 1vh; height: 72.5vh;">
    <MdwPanelHeader style="height: 6vh">
        <h6>Certifications</h6>
        <TextField Title="Zoeken" Icon="search" SubSet={FilterCerts} />
    </MdwPanelHeader>

    <div style="border-top: 0.3vh solid rgb(30, 30, 30); margin-bottom: 1vh;">
        <CodeJar spellcheck={true} syntax="json" {highlight} bind:value={CertTemplate} />
        <div style="display: flex; flex-direction: row;">
            {#if IsJson(CertTemplate)}
                <Button click={() => { SaveCerts(true) }} Color="success">Create</Button>
            {:else}
                <p style="font-family: monospace; font-size: 1.5vh; color: #ff3d3d">Invalid JSON! Please fix.</p>
            {/if}
        </div>
    </div>

    {#each FilteredCerts as Data, Key}
        <div style="border-top: 0.3vh solid rgb(30, 30, 30); margin-bottom: 1vh;">
            <CodeJar spellcheck={true} syntax="json" {highlight} bind:value={Data} />
            <div style="display: flex; flex-direction: row;">
                {#if IsJson(Data)}
                    {#if JSON.parse(Data).deleted}
                        <Button click={() => { SaveCerts(false, Data) }} Color="warning">Restore</Button>
                    {:else}
                        <Button click={() => { SaveCerts(false, Data) }} Color="warning">Save</Button>
                        <Button click={() => { DeleteCerts(JSON.parse(Data).id) }} Color="warning">Delete</Button>
                    {/if}
                {:else}
                    <p style="font-family: monospace; font-size: 1.5vh; color: #ff3d3d">Invalid JSON! Please fix.</p>
                {/if}
            </div>
        </div>
    {/each}
</MdwPanel>

<MdwPanel style="margin-top: 1vh; height: 72.5vh;">
    <MdwPanelHeader style="height: 6vh">
        <h6>Roles</h6>
        <TextField Title="Zoeken" Icon="search" SubSet={FilterRoles} />
    </MdwPanelHeader>

    <div style="border-top: 0.3vh solid rgb(30, 30, 30); margin-bottom: 1vh;">
        <CodeJar spellcheck={true} syntax="json" {highlight} bind:value={RolesTemplate} />
        <div style="display: flex; flex-direction: row;">
            {#if IsJson(RolesTemplate)}
                <Button click={() => { SaveRole(true) }} Color="success">Create</Button>
            {:else}
                <p style="font-family: monospace; font-size: 1.5vh; color: #ff3d3d">Invalid JSON! Please fix.</p>
            {/if}
        </div>
    </div>

    {#each FilteredRoles as Data, Key}
        <div style="border-top: 0.3vh solid rgb(30, 30, 30); margin-bottom: 1vh;">
            <CodeJar spellcheck={true} syntax="json" {highlight} bind:value={Data} />
            <div style="display: flex; flex-direction: row;">
                {#if IsJson(Data)}
                    {#if JSON.parse(Data).deleted}
                        <Button click={() => { SaveRole(false, Data) }} Color="warning">Restore</Button>
                    {:else}
                        <Button click={() => { SaveRole(false, Data) }} Color="warning">Save</Button>
                        <Button click={() => { DeleteRole(JSON.parse(Data).id) }} Color="warning">Delete</Button>
                    {/if}
                {:else}
                    <p style="font-family: monospace; font-size: 1.5vh; color: #ff3d3d">Invalid JSON! Please fix.</p>
                {/if}
            </div>
        </div>
    {/each}
</MdwPanel>

<MdwPanel style="margin-top: 1vh; height: 72.5vh;">
    <MdwPanelHeader style="height: 6vh">
        <h6>Staff</h6>
        <TextField Title="Zoeken" Icon="search" SubSet={FilterStaff} />
    </MdwPanelHeader>

    <div style="border-top: 0.3vh solid rgb(30, 30, 30); margin-bottom: 1vh;">
        <CodeJar spellcheck={true} syntax="json" {highlight} bind:value={StaffTemplate} />
        <div style="display: flex; flex-direction: row;">
            {#if IsJson(StaffTemplate)}
                <Button click={() => { SaveStaff(true) }} Color="success">Create</Button>
            {:else}
                <p style="font-family: monospace; font-size: 1.5vh; color: #ff3d3d">Invalid JSON! Please fix.</p>
            {/if}
        </div>
    </div>

    {#each FilteredStaff as Data, Key}
        <div style="border-top: 0.3vh solid rgb(30, 30, 30); margin-bottom: 1vh;">
            <CodeJar spellcheck={true} syntax="json" {highlight} bind:value={Data} />
            <div style="display: flex; flex-direction: row; width: 100%;">
                {#if IsJson(Data)}
                    {#if JSON.parse(Data).deleted}
                        <Button click={() => { SaveStaff(false, Data, true) }} Color="warning">Restore</Button>
                    {:else}
                        <Button click={() => { SaveStaff(false, Data) }} Color="warning">Save</Button>
                        <Button click={() => { DeleteStaff(JSON.parse(Data).id) }} Color="warning">Delete</Button>
                        <div style="margin-left: auto">
                            <Button click={() => { CreateBadge(JSON.parse(Data)) }} Color="default">Create Badge</Button>
                        </div>
                    {/if}
                {:else}
                    <p style="font-family: monospace; font-size: 1.5vh; color: #ff3d3d">Invalid JSON! Please fix.</p>
                {/if}
            </div>
        </div>
    {/each}
</MdwPanel>