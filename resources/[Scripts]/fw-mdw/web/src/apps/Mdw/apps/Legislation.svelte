<script>
    import MdwPanel from "../components/MdwPanel.svelte";
    import MdwPanelHeader from "../components/MdwPanel.Header.svelte";
    import MdwPanelList from "../components/MdwPanel.List.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";
    import MdwCard from "../components/MdwCard.svelte";
    import { onMount } from "svelte";
    import { GetTagById, HasCidPermission, SendEvent } from "../../../utils/Utils";
    import { CurrentLegislation, IsHighcommand, IsJudge, IsPublic, MdwModalsTags, ShowLoader } from "../../../stores";
    import BalloonEditor from '@ckeditor/ckeditor5-build-balloon';
    import MdwChip from "../components/MdwChip.svelte";

    let Legislations = [];
    let FilteredLegislations = [];
    let LegislationEditor;

    onMount(() => {
        if (LegislationEditor) {
            BalloonEditor.create(LegislationEditor, {
                supportAllValues: true,
                toolbar: {
                    items: [ 'heading', '|', 'bold', 'italic', '|', 'blockQuote', '|', 'undo', 'redo', '|', 'numberedList', 'bulletedList', '|', 'insertTable' ],
                    shouldNotGroupWhenFull: true,
                },
                placeholder: "Begin met typen...",
            }).then(Editor => {
                window.editor = Editor;
                if ($CurrentLegislation.content) window.editor.setData($CurrentLegislation.content);
            }).catch(Error => {
                console.error(Error);
            });
        }

        SendEvent("Legislation/FetchAll", {}, (Success, Data) => {
            if (!Success) return;

            Legislations = Data;
            FilteredLegislations = Data;
        });
    });

    const FilterLegislation = Value => {
        const Search = Value.toLowerCase();

        FilteredLegislations = Legislations.filter(Val => Val.title.toLowerCase().includes(Search));
    };

    const FetchById = Id => {
        ShowLoader.set(true);
        SendEvent("Legislation/FetchById", {Id}, (Success, Data) => {
            ShowLoader.set(false);
            if (!Success) return;
            CurrentLegislation.set(Data);
            window.editor.setData($CurrentLegislation.content);
        });
    };

    const OnLegislationAction = (Type) => {
        if (Type == "Reset") {
            CurrentLegislation.set({ title: "", content: "" })
            window.editor.setData("");
        } else if (Type == "Save") {
            ShowLoader.set(true);
            SendEvent("Legislation/SaveLegislation", {
                content: window.editor.getData(),
                title: $CurrentLegislation.title,
                id: $CurrentLegislation.id,
            }, (Success, Data) => {
                ShowLoader.set(false);
                if (!Success) return;

                if (Data){
                    let LegislationsIndex = Legislations.findIndex(Val => Val.id == $CurrentLegislation.id)
                    if (LegislationsIndex > -1) {
                        Legislations[LegislationsIndex] = Data
                    } else {
                        Legislations = [Data, ...Legislations];
                    }

                    FetchById(Data.id);
                    FilteredLegislations = Legislations;
                };
            });
        } else if (Type == "Delete") {
            ShowLoader.set(true);
            SendEvent("Legislation/DeleteLegislation", {
                Id: $CurrentLegislation.id,
            }, () => {
                let LegislationsIndex = Legislations.findIndex(Val => Val.id == $CurrentLegislation.id)
                if (LegislationsIndex > -1) Legislations.splice(LegislationsIndex, 1);
                FilteredLegislations = Legislations;

                ShowLoader.set(false);
                OnLegislationAction("Reset");
            });
        };
    };

    const AddTag = () => {
        MdwModalsTags.set({
            Show: true,
            IgnoreFilter: $CurrentLegislation.tags,
            Cb: (TagId) => {
                SendEvent("Legislation/AddTag", {LegislationId: $CurrentLegislation.id, TagId}, (Success, Data) => {
                    if (!Success) return;
                    $CurrentLegislation.tags = [...$CurrentLegislation.tags, TagId]
                });
            },
        });
    };

    const RemoveTag = TagId => {
        SendEvent("Legislation/RemoveTag", {LegislationId: $CurrentLegislation.id, TagId}, (Success, Data) => {
            if (!Success) return;
            let NewLegislation = {...$CurrentLegislation};
            NewLegislation.tags.splice(TagId, 1);
            CurrentLegislation.set(NewLegislation);
        });
    };
</script>

<MdwPanel class="filled">
    <MdwPanelHeader>
        <h6>Wetgeving</h6>
        <TextField Title='Zoeken' Icon='search' SubSet={FilterLegislation} />
    </MdwPanelHeader>

    <MdwPanelList>
        {#each FilteredLegislations as Data, Key}
            <MdwCard on:click={() => { FetchById(Data.id) }} Information={[
                [Data.title],
                [`ID: ${Data.id}`]
            ]} />
        {/each}
    </MdwPanelList>
</MdwPanel>

<MdwPanel class="filled">
    <MdwPanelHeader>
        {#if $CurrentLegislation.id}
            <h6>Wetgeving Bewerken (#{$CurrentLegislation.id})</h6>
        {:else}
            <h6>Wetgeving Toevoegen</h6>
        {/if}

        {#if !$IsPublic}
            <div class="mdw-box-title-icons">
                {#if $CurrentLegislation.id}
                    {#if HasCidPermission("Legislation.Create")} <i on:keyup on:click={() => { OnLegislationAction("Reset") }} data-tooltip="Nieuw" class="fas fa-sync"></i> {/if}
                    {#if HasCidPermission("Legislation.Delete")} <i on:keyup on:click={() => { OnLegislationAction("Delete") }} data-tooltip="Verwijderen" class="fas fa-trash"></i> {/if}
                    {#if HasCidPermission("Legislation.Edit")} <i on:keyup on:click={() => { OnLegislationAction("Save") }} data-tooltip="Opslaan" class="fas fa-save"></i> {/if}
                {:else}
                    {#if HasCidPermission("Legislation.Create")} <i on:keyup on:click={() => { OnLegislationAction("Save") }} data-tooltip="Opslaan" class="fas fa-save"></i> {/if}
                {/if}
            </div>
        {/if}
    </MdwPanelHeader>

    <div style="width: 97%; margin-left: auto; margin-right: auto;">
        <TextField style="margin-bottom: 0px;" bind:RealValue={$CurrentLegislation.title} Title='Titel' Icon='pencil-alt' />
    </div>

    <div bind:this={LegislationEditor} class="mdw-legislation-editor"></div>
</MdwPanel>

<MdwPanel>
    <MdwPanel class="filled" style="width: 100%; height: max-content; margin-bottom: 0.5vh;">
        <MdwPanelHeader>
            <h6>Tags</h6>
    
            {#if HasCidPermission("Legislation.Edit")}
                <div class="mdw-box-title-icons">
                    {#if $CurrentLegislation.id}
                        <i on:keyup on:click={AddTag} class="fas fa-plus"></i>
                    {/if}
                </div>
            {/if}
        </MdwPanelHeader>

        {#if $CurrentLegislation.id && $CurrentLegislation.tags}
            <div style="padding: 0.37vh; padding-top: 0; display: flex; flex-wrap: wrap; box-sizing: border-box;">
                {#each $CurrentLegislation.tags as Data, Key}
                    {#if HasCidPermission("Legislation.Edit")}
                        <MdwChip Text={GetTagById(Data).tag} Color={GetTagById(Data).color} PrefixIcon={GetTagById(Data).icon} SuffixIcon="times-circle" on:click={() => { RemoveTag(Key) }}/>
                    {:else}
                        <MdwChip Text={GetTagById(Data).tag} Color={GetTagById(Data).color} PrefixIcon={GetTagById(Data).icon} />
                    {/if}
                {/each}
            </div>
        {/if}
    </MdwPanel>
</MdwPanel>

<style>
    .mdw-legislation-editor {
        width: 93%;
        height: 65.5vh;
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

    :global(.mdw-legislation-editor ol) {
        padding: revert !important
    }

    :global(.mdw-legislation-editor ul) {
        padding: revert !important
    }

    .mdw-legislation-editor::-webkit-scrollbar {
        display: none
    }
</style>