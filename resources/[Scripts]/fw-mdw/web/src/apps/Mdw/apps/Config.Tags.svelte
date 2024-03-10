<script>
    import MdwPanel from "../components/MdwPanel.svelte";
    import MdwPanelHeader from "../components/MdwPanel.Header.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";
    import { onMount } from "svelte";

    // Code Editor
    import { CodeJar } from "@novacbn/svelte-codejar";
    import Prism from 'prismjs';
    import 'prismjs/components/prism-json';
    import { SendEvent } from "../../../utils/Utils";
    import Button from "../../../components/Button/Button.svelte";
    import { MdwTags, MdwEvidence } from "../../../stores";
    const highlight = (code, syntax) => Prism.highlight(code, Prism.languages[syntax], syntax);

    const IsJson = str => {
        try {
            JSON.parse(str)
        } catch(e) {
            return false
        }
        return true
    }

    // Tags
    let FilteredTags = [];
    let TagsTemplate = JSON.stringify({ tag: "", color: "#ffffff", icon: "" }, undefined, 2)

    const FilterTags = Value => {
        const Search = Value.toLowerCase();
        const MatchedTags = $MdwTags.filter(Val => Val.tag.toLowerCase().includes(Search))
        FilteredTags = MatchedTags.map(Val => {return JSON.stringify(Val, null, 2)})
    };

    const SaveTag = (Create, Data) => {
        if (Create) {
            SendEvent("Config/CreateTag", JSON.parse(TagsTemplate))
        } else {
            SendEvent("Config/SaveTag", JSON.parse(Data))
        };
    };

    const DeleteTag = TagId => {
        if (TagId) SendEvent("Config/DeleteTag", {id: TagId})
    };

    MdwTags.subscribe((Val) => { FilterTags("") });

    // Evidence Types
    let FilteredEvidence = [];
    let EvidenceTemplate = JSON.stringify({ Text: "" }, undefined, 2)

    const FilterEvidenceTypes = Value => {
        const Search = Value.toLowerCase();
        const MatchedEvidence = $MdwEvidence.filter(Val => Val.Text.toLowerCase().includes(Search))
        FilteredEvidence = MatchedEvidence.map(Val => {return JSON.stringify(Val, null, 2)})
    };

    const SaveEvidence = (Create, Data) => {
        if (Create) {
            SendEvent("Config/CreateEvidenceType", JSON.parse(EvidenceTemplate))
        } else {
            SendEvent("Config/SaveEvidenceType", JSON.parse(Data))
        };
    };

    const DeleteEvidence = EvidenceId => {
        if (EvidenceId) SendEvent("Config/DeleteEvidenceType", {Id: EvidenceId})
    };

    MdwEvidence.subscribe((Val) => { FilterEvidenceTypes("") });
</script>

<MdwPanel style="margin-top: 1vh; height: 72.5vh;">
    <MdwPanelHeader style="height: 6vh">
        <h6>Tags</h6>
        <TextField Title="Zoeken" Icon="search" SubSet={FilterTags} />
    </MdwPanelHeader>

    <div style="border-top: 0.3vh solid rgb(30, 30, 30); margin-bottom: 1vh;">
        <CodeJar spellcheck={true} syntax="json" {highlight} bind:value={TagsTemplate} />
        <div style="display: flex; flex-direction: row;">
            {#if IsJson(TagsTemplate)}
                <Button click={() => { SaveTag(true) }} Color="success">Create</Button>
            {:else}
                <p style="font-family: monospace; font-size: 1.5vh; color: #ff3d3d">Invalid JSON! Please fix.</p>
            {/if}
        </div>
    </div>

    {#each FilteredTags as Data, Key}
        <div style="border-top: 0.3vh solid rgb(30, 30, 30); margin-bottom: 1vh;">
            <CodeJar spellcheck={true} syntax="json" {highlight} bind:value={Data} />
            <div style="display: flex; flex-direction: row;">
                {#if IsJson(Data)}
                    {#if JSON.parse(Data).deleted}
                        <Button click={() => { SaveTag(false, Data) }} Color="warning">Restore</Button>
                    {:else}
                        <Button click={() => { SaveTag(false, Data) }} Color="warning">Save</Button>
                        <Button click={() => { DeleteTag(JSON.parse(Data).id) }} Color="warning">Delete</Button>
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
        <h6>Evidence Types</h6>
        <TextField Title="Zoeken" Icon="search" SubSet={FilterEvidenceTypes} />
    </MdwPanelHeader>

    <div style="border-top: 0.3vh solid rgb(30, 30, 30); margin-bottom: 1vh;">
        <CodeJar spellcheck={true} syntax="json" {highlight} bind:value={EvidenceTemplate} />
        <div style="display: flex; flex-direction: row;">
            {#if IsJson(EvidenceTemplate)}
                <Button click={() => { SaveEvidence(true) }} Color="success">Create</Button>
            {:else}
                <p style="font-family: monospace; font-size: 1.5vh; color: #ff3d3d">Invalid JSON! Please fix.</p>
            {/if}
        </div>
    </div>

    {#each FilteredEvidence as Data, Key}
        <div style="border-top: 0.3vh solid rgb(30, 30, 30); margin-bottom: 1vh;">
            <CodeJar spellcheck={true} syntax="json" {highlight} bind:value={Data} />
            <div style="display: flex; flex-direction: row;">
                {#if IsJson(Data)}
                    {#if JSON.parse(Data).deleted}
                        <Button click={() => { SaveEvidence(false, Data) }} Color="warning">Restore</Button>
                    {:else}
                        <Button click={() => { SaveEvidence(false, Data) }} Color="warning">Save</Button>
                        <Button click={() => { DeleteEvidence(JSON.parse(Data).Id) }} Color="warning">Delete</Button>
                    {/if}
                {:else}
                    <p style="font-family: monospace; font-size: 1.5vh; color: #ff3d3d">Invalid JSON! Please fix.</p>
                {/if}
            </div>
        </div>
    {/each}
</MdwPanel>