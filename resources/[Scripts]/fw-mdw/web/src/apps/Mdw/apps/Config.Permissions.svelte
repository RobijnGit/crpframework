<script>
    import MdwPanel from "../components/MdwPanel.svelte";
    import MdwPanelHeader from "../components/MdwPanel.Header.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";
    import { SendEvent } from "../../../utils/Utils";
    import Button from "../../../components/Button/Button.svelte";
    import { MdwModalsPermissions, MdwRoles } from "../../../stores";
    import { onMount } from "svelte";

    // Code Editor
    import { CodeJar } from "@novacbn/svelte-codejar";
    import Prism from 'prismjs';
    import 'prismjs/components/prism-json';
    const highlight = (code, syntax) => Prism.highlight(code, Prism.languages[syntax], syntax);

    const IsJson = str => {
        try {
            JSON.parse(str)
        } catch(e) {
            return false
        }
        return true
    }

    // Roles
    let FilteredRoles = [];
    let RoleTemplate = JSON.stringify({ name: "", icon: "", color: "#ffffff" }, undefined, 2)

    const FilterRoles = Value => {
        const Search = Value.toLowerCase();
        const MatchedRoles = $MdwRoles.filter(Val => Val.name.toLowerCase().includes(Search) || Val.id.toLowerCase().includes(Search))
        FilteredRoles = MatchedRoles.map(Val => {return JSON.stringify({id: Val.id, name: Val.name, icon: Val.icon, color: Val.color}, null, 2)});
    };

    const SaveRole = (Create, Data) => {
        if (Create) {
            SendEvent("Config/CreateRole", JSON.parse(RoleTemplate))
        } else {
            const RoleIndex = $MdwRoles.findIndex(Val => Val.id == JSON.parse(Data).id);
            if (RoleIndex == -1) return;
            SendEvent("Config/SaveRole", {...JSON.parse(Data), permissions: $MdwRoles[RoleIndex].permissions});
        };
    };

    const DeleteRole = RoleId => {
        if (RoleId) SendEvent("Config/DeleteRole", {id: RoleId})
    };

    const EditPermissions = RoleId => {
        MdwModalsPermissions.set({
            Show: true,
            Role: $MdwRoles.filter(Val => Val.id == RoleId)[0],
            Cb: (Permissions) => {
                const RoleIndex = $MdwRoles.findIndex(Val => Val.id == RoleId);
                if (RoleIndex == -1) return;
                $MdwRoles[RoleIndex].permissions = Permissions;
            }
        })
    }

    MdwRoles.subscribe((Val) => { FilterRoles("") });
</script>

<MdwPanel style="margin-top: 1vh; height: 72.5vh; width: 100%;">
    <MdwPanelHeader style="height: 6vh; width: 98.6%;">
        <h6>Roles</h6>
        <TextField Title="Zoeken" Icon="search" SubSet={FilterRoles} />
    </MdwPanelHeader>

    <div style="border-top: 0.3vh solid rgb(30, 30, 30); margin-bottom: 1vh;">
        <CodeJar spellcheck={true} syntax="json" {highlight} bind:value={RoleTemplate} />
        <div style="display: flex; flex-direction: row;">
            {#if IsJson(RoleTemplate)}
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
                    <Button click={() => { SaveRole(false, Data) }} Color="warning">Save</Button>
                    <Button click={() => { DeleteRole(JSON.parse(Data).id) }} Color="warning">Delete</Button>
                    <Button click={() => { EditPermissions(JSON.parse(Data).id) }} Color="default">Edit Permissions</Button>
                {:else}
                    <p style="font-family: monospace; font-size: 1.5vh; color: #ff3d3d">Invalid JSON! Please fix.</p>
                {/if}
            </div>
        </div>
    {/each}
</MdwPanel>