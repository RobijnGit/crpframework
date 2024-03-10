<script>
    import MdwPanel from "../components/MdwPanel.svelte";
    import MdwPanelHeader from "../components/MdwPanel.Header.svelte";
    import MdwPanelList from "../components/MdwPanel.List.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";
    import MdwCard from "../components/MdwCard.svelte";
    import { onMount } from "svelte";
    import { GetTagById, HasCidPermission, SendEvent } from "../../../utils/Utils";
    import { CurrentEvidence, IsGov, IsHighcommand, IsPublic, MdwEvidence, MdwModalsTags, ShowLoader } from "../../../stores";
    import MdwChip from "../components/MdwChip.svelte";

    let Evidence = [];
    let FilteredEvidence = [];

    onMount(() => {
        SendEvent("Evidence/FetchAll", {}, (Success, Data) => {
            if (!Success) return;

            Evidence = Data;
            FilteredEvidence = Data;
        });
    });

    const FilterEvidence = Value => {
        const Search = Value.toLowerCase();

        FilteredEvidence = Evidence.filter(Val => {
            return String(Val.id).toLowerCase().includes(Search) ||
                Val.identifier.toLowerCase().includes(Search) ||
                Val.description.toLowerCase().includes(Search) ||
                Val.citizenid.toLowerCase().includes(Search)
        });
    };

    const FetchById = Id => {
        ShowLoader.set(true);
        SendEvent("Evidence/FetchById", {Id}, (Success, Data) => {
            ShowLoader.set(false);
            if (!Success) return;
            CurrentEvidence.set(Data);
        });
    };

    const OnEvidenceAction = (Type) => {
        if (Type == "Reset") {
            CurrentEvidence.set({ type: "", identifier: "", description: "", citizenid: "" })
        } else if (Type == "Save") {
            if ($CurrentEvidence.identifier.includes(".discordapp.")) {
                MdwModalsExport.set({
                    Show: true,
                    Msg: `cdn.discordapp.com kan niet gebruikt worden als identifier.`,
                });

                return;
            }

            ShowLoader.set(true);
            SendEvent("Evidence/SaveEvidence", {
                type: $CurrentEvidence.type,
                identifier: $CurrentEvidence.identifier,
                description: $CurrentEvidence.description,
                citizenid: $CurrentEvidence.citizenid,
                id: $CurrentEvidence.id,
            }, (Success, Data) => {
                ShowLoader.set(false);
                if (!Success) return;

                if (Data) {
                    let EvidenceIndex = Evidence.findIndex(Val => Val.id == $CurrentEvidence.id)
                    if (EvidenceIndex > -1) {
                        Evidence[EvidenceIndex] = Data
                    } else {
                        Evidence = [Data, ...Evidence];
                    }

                    FetchById(Data.id);
                    FilteredEvidence = Evidence;
                };
            });
        } else if (Type == "Delete") {
            ShowLoader.set(true);
            SendEvent("Evidence/DeleteEvidence", {
                Id: $CurrentEvidence.id,
            }, () => {
                let EvidenceIndex = Evidence.findIndex(Val => Val.id == $CurrentEvidence.id)
                if (EvidenceIndex > -1) Evidence.splice(EvidenceIndex, 1);
                FilteredEvidence = Profiles;

                ShowLoader.set(false);
                OnEvidenceAction("Reset");
            });
        };
    };

    const AddTag = () => {
        MdwModalsTags.set({
            Show: true,
            IgnoreFilter: $CurrentEvidence.tags,
            Cb: (TagId) => {
                SendEvent("Evidence/AddTag", {EvidenceId: $CurrentEvidence.id, TagId}, (Success, Data) => {
                    if (!Success) return;
                    $CurrentEvidence.tags = [...$CurrentEvidence.tags, TagId]
                });
            },
        });
    };

    const RemoveTag = TagId => {
        SendEvent("Evidence/RemoveTag", {EvidenceId: $CurrentEvidence.id, TagId}, (Success, Data) => {
            if (!Success) return;
            let NewEvidence = {...$CurrentEvidence};
            NewEvidence.tags.splice(TagId, 1);
            CurrentEvidence.set(NewEvidence);
        });
    };

    const GetEvidenceTypes = () => {
        return $MdwEvidence.filter(Val => !Val.deleted)
    }
</script>

<MdwPanel class="filled">
    <MdwPanelHeader>
        <h6>Bewijs</h6>
        <TextField Title='Zoeken' Icon='search' SubSet={FilterEvidence} />
    </MdwPanelHeader>

    <MdwPanelList>
        {#each FilteredEvidence as Data, Key}
            <MdwCard on:click={() => { FetchById(Data.id) }} Information={[
                [`${Data.type} - ${Data.description}`],
                [`ID: ${Data.id}`]
            ]} />
        {/each}
    </MdwPanelList>
</MdwPanel>

<MdwPanel class="filled">
    <MdwPanelHeader>
        {#if $CurrentEvidence.id}
            <h6>Bewijs Bewerken (#{$CurrentEvidence.id})</h6>
        {:else}
            <h6>Bewijs Toevoegen</h6>
        {/if}

        {#if !$IsPublic}
            <div class="mdw-box-title-icons">
                {#if $CurrentEvidence.id}
                    {#if HasCidPermission("Evidence.Create")} <i on:keyup on:click={() => { OnEvidenceAction("Reset") }} data-tooltip="Nieuw" class="fas fa-sync"></i> {/if}
                    {#if HasCidPermission("Evidence.Delete")} <i on:keyup on:click={() => { OnEvidenceAction("Delete") }} data-tooltip="Verwijderen" class="fas fa-trash"></i> {/if}
                    {#if HasCidPermission("Evidence.Edit")} <i on:keyup on:click={() => { OnEvidenceAction("Save") }} data-tooltip="Opslaan" class="fas fa-save"></i> {/if}
                {:else}
                    {#if HasCidPermission("Evidence.Create")} <i on:keyup on:click={() => { OnEvidenceAction("Save") }} data-tooltip="Opslaan" class="fas fa-save"></i> {/if}
                {/if}
            </div>
        {/if}
    </MdwPanelHeader>

    <div style="width: 97%; margin-left: auto; margin-right: auto;">
        <TextField style="margin-bottom: 0px;" bind:RealValue={$CurrentEvidence.type} Title='Type' Select={GetEvidenceTypes()} />
        <TextField style="margin-bottom: 0px;" bind:RealValue={$CurrentEvidence.identifier} Title='Identificatie' Icon='fingerprint' />
        <TextField style="margin-bottom: 0px;" bind:RealValue={$CurrentEvidence.description} Title='Beschrijving' Icon='clipboard' />
        <TextField style="margin-bottom: 0px;" bind:RealValue={$CurrentEvidence.citizenid} Title='BSN' Icon='user' />
    </div>
</MdwPanel>

<MdwPanel>
    <MdwPanel class="filled" style="width: 100%; height: max-content; margin-bottom: 0.5vh;">
        <MdwPanelHeader>
            <h6>Tags</h6>
    
            <div class="mdw-box-title-icons">
                {#if $CurrentEvidence.id}
                    <i on:keyup on:click={AddTag} class="fas fa-plus"></i>
                {/if}
            </div>
        </MdwPanelHeader>

        {#if $CurrentEvidence.id && $CurrentEvidence.tags}
            <div style="padding: 0.37vh; padding-top: 0; display: flex; flex-wrap: wrap; box-sizing: border-box;">
                {#each $CurrentEvidence.tags as Data, Key}
                    {#if $IsGov}
                        <MdwChip Text={GetTagById(Data).tag} Color={GetTagById(Data).color} PrefixIcon={GetTagById(Data).icon} SuffixIcon="times-circle" on:click={() => { RemoveTag(Key) }}/>
                    {:else}
                        <MdwChip Text={GetTagById(Data).tag} Color={GetTagById(Data).color} PrefixIcon={GetTagById(Data).icon} />
                    {/if}
                {/each}
            </div>
        {/if}
    </MdwPanel>
</MdwPanel>