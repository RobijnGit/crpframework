<script>
    import MdwPanel from "../components/MdwPanel.svelte";
    import MdwPanelHeader from "../components/MdwPanel.Header.svelte";
    import MdwPanelList from "../components/MdwPanel.List.svelte";
    import MdwCard from "../components/MdwCard.svelte";
    import MdwChip from "../components/MdwChip.svelte";

    import Button from "../../../components/Button/Button.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";
    
    import { onMount, onDestroy } from "svelte";

    import { GetChargeById, GetTagById, HasCidPermission, SendEvent } from "../../../utils/Utils";
    import { CurrentProfile, IsGov, IsJudge, IsPublic, MdwModalsTags, MdwModalsVehicleHistory, ShowLoader } from "../../../stores";
    import { LicensesLocale } from "../../../config";

    import BalloonEditor from '@ckeditor/ckeditor5-build-balloon';

    let Profiles = [];
    let FilteredProfiles = [];
    let MaxProfiles = 15;
    let ProfileEditor;

    const LoadMore = () => {
        MaxProfiles = MaxProfiles + 50
    }

    onMount(() => {
        SendEvent("Profiles/FetchAll", {}, (Success, Data) => {
            if (!Success) return;
            Profiles = Data;
            FilteredProfiles = Data;
        });

        if (ProfileEditor) {
            BalloonEditor.create(ProfileEditor, {
                supportAllValues: true,
                toolbar: {
                    items: [ 'heading', '|', 'bold', 'italic', '|', 'blockQuote', '|', 'undo', 'redo', '|', 'numberedList', 'bulletedList', '|', 'insertTable' ],
                    shouldNotGroupWhenFull: true,
                },
                placeholder: "Begin met typen...",
            }).then(Editor => {
                window.editor = Editor;
                if ($CurrentProfile.notes) window.editor.setData($CurrentProfile.notes);
            }).catch(Error => {
                console.error(Error);
            });
        };
    });

    onDestroy(() => {
        if (window.editor) window.editor.destroy();
    });

    const DoesProfileContainTag = (Tags, Query) => {
        for (let i = 0; i < Tags.length; i++) {
            const TagData = GetTagById(Tags[i]);
            if (TagData && TagData.tag.toLowerCase().includes(Query)) {
                return true;
            };
        };
        return false;
    };

    const FilterProfiles = Value => {
        const Search = Value.toLowerCase();

        FilteredProfiles = Profiles.filter(Val => {
            return Val.citizenid.toLowerCase().includes(Search) ||
                Val.name.toLowerCase().includes(Search) ||
                Val.notes.toLowerCase().includes(Search) ||
                DoesProfileContainTag(Val.tags, Search)
        });
    };

    const FetchById = Id => {
        ShowLoader.set(true);
        SendEvent("Profiles/FetchById", {Id}, (Success, Data) => {
            ShowLoader.set(false);
            if (!Success) return;
            CurrentProfile.set(Data);
            window.editor.setData(Data.notes)
        });
    };

    const OnProfileAction = (Type) => {
        if (Type == "Reset") {
            CurrentProfile.set({ citizenid: "", name: "", image: "", notes: "" })
            window.editor.setData("");
        } else if (Type == "Save") {
            ShowLoader.set(true);
            SendEvent("Profiles/SaveProfile", {
                citizenid: $CurrentProfile.citizenid,
                name: $CurrentProfile.name,
                image: $CurrentProfile.image,
                notes: window.editor.getData(),
                id: $CurrentProfile.id,
            }, (Success, Data) => {
                ShowLoader.set(false);
                if (!Success) return;

                if (Data){
                    let ProfileIndex = Profiles.findIndex(Val => Val.id == $CurrentProfile.id)
                    console.log(ProfileIndex)
                    if (ProfileIndex > -1) {
                        Profiles[ProfileIndex] = Data
                    } else {
                        Profiles = [Data, ...Profiles];
                    }

                    FetchById(Data.id);
                    FilteredProfiles = Profiles;
                };
            });
        } else if (Type == "Delete") {
            ShowLoader.set(true);
            SendEvent("Profiles/DeleteProfile", {
                Id: $CurrentProfile.id,
            }, () => {
                let ProfilesIndex = Profiles.findIndex(Val => Val.id == $CurrentProfile.id)
                if (ProfilesIndex > -1) Profiles.splice(ProfilesIndex, 1);
                FilteredProfiles = Profiles;

                ShowLoader.set(false);
                OnProfileAction("Reset");
            });
        };
    };

    const RevokeLicense = (License) => {
        if (!License) return;
        ShowLoader.set(true);
        $CurrentProfile.licenses[License] = false;

        SendEvent("Profiles/RevokeLicense", {
            citizenid: $CurrentProfile.citizenid,
            license: License
        }, () => {
            ShowLoader.set(false);
        });
    };

    const AddTag = () => {
        MdwModalsTags.set({
            Show: true,
            IgnoreFilter: $CurrentProfile.tags,
            Cb: (TagId) => {
                SendEvent("Profiles/AddTag", {ProfileId: $CurrentProfile.id, TagId}, (Success, Data) => {
                    if (!Success) return;
                    $CurrentProfile.tags = [...$CurrentProfile.tags, TagId]
                });
            },
        });
    };

    const RemoveTag = TagId => {
        SendEvent("Profiles/RemoveTag", {ProfileId: $CurrentProfile.id, TagId}, (Success, Data) => {
            if (!Success) return;
            let NewProfile = {...$CurrentProfile};
            NewProfile.tags.splice(TagId, 1);
            CurrentProfile.set(NewProfile);
        });
    };

    const GetPriorPoints = (Priors) => {
        if (!Priors) return 0;

        let TotalPoints = 0;
        for (let i = 0; i < Priors.length; i++) {
            const Prior = GetChargeById(Priors[i].Id);
            if (Prior && Number(Prior.points) > 0) TotalPoints += Number(Prior.points);
        };

        return TotalPoints;
    };
</script>

<MdwPanel class="filled">
    <MdwPanelHeader>
        <h6>Profielen</h6>
        <TextField Title='Zoeken' Icon='search' SubSet={FilterProfiles} />
    </MdwPanelHeader>

    <MdwPanelList>
        {#each FilteredProfiles.slice(0, MaxProfiles) as Data, Key}
            <MdwCard on:click={() => { FetchById(Data.id) }} Information={[
                [Data.name],
                [`ID: ${Data.citizenid}`]
            ]} />
        {/each}

        {#if FilteredProfiles.length > 5}
            <div style="display: flex; justify-content: center; width: 100%;">
                <Button Color="success" click={LoadMore}>Laad Meer</Button>
            </div>
        {/if}
    </MdwPanelList>
</MdwPanel>

<MdwPanel class="filled">
    <MdwPanelHeader>
        {#if $CurrentProfile.id}
            <h6>Profiel Bewerken (#{$CurrentProfile.citizenid})</h6>
        {:else}
            <h6>Profiel Toevoegen</h6>
        {/if}

        {#if !$IsPublic}
            <div class="mdw-box-title-icons">
                {#if $CurrentProfile.id}
                    {#if HasCidPermission("Profiles.Create")} <i on:keyup on:click={() => { OnProfileAction("Reset") }} data-tooltip="Nieuw" class="fas fa-sync"></i> {/if}
                    {#if HasCidPermission("Profiles.Delete")} <i on:keyup on:click={() => { OnProfileAction("Delete") }} data-tooltip="Verwijderen" class="fas fa-trash"></i> {/if}
                    {#if HasCidPermission("Profiles.Edit")} <i on:keyup on:click={() => { OnProfileAction("Save") }} data-tooltip="Opslaan" class="fas fa-save"></i> {/if}
                {:else}
                    {#if HasCidPermission("Profiles.Create")} <i on:keyup on:click={() => { OnProfileAction("Save") }} data-tooltip="Opslaan" class="fas fa-save"></i> {/if}
                {/if}
            </div>
        {/if}
    </MdwPanelHeader>

    <div style="display: flex; flex-direction: row; width: 97%; height: 19.4vh; margin-left: auto; margin-right: auto;">
        <div style="height: 19.3vh; width: 19.3vh;">
            {#if $CurrentProfile.wanted}
                <div style="position: absolute; width: 19vh; height: 19vh; transform: rotate(-45deg); background-image: url(./images/wanted.png); background-position: center center; background-repeat: no-repeat; background-size: 100% 80%;"></div>
            {/if}
            <img src="{$CurrentProfile.image || "./images/mugshot.png"}" alt="" style="width: 19vh; height: 19vh; border: 0.15vh solid black;" />
        </div>

        <div style="margin-left: 0.7vh; width: 100%;">
            <TextField style="margin-bottom: 0px;" bind:RealValue={$CurrentProfile.citizenid} Title='BSN' Icon='id-card' />
            <TextField style="margin-bottom: 0px;" bind:RealValue={$CurrentProfile.name} Title='Naam' Icon='user' />
            <TextField style="margin-bottom: 0px;" bind:RealValue={$CurrentProfile.image} Title='Profiel Foto URL' Icon='clipboard' />
        </div>
    </div>

    {#if HasCidPermission("Profiles.ShowNotes")}
        <div bind:this={ProfileEditor} class="mdw-profile-editor"></div>
    {/if}
</MdwPanel>

<MdwPanel>
    <MdwPanel class="filled" style="width: 100%; height: max-content; margin-bottom: 0.5vh;">
        <MdwPanelHeader>
            <h6>Licensies ({GetPriorPoints($CurrentProfile.priors)} punten)</h6>
        </MdwPanelHeader>

        {#if $CurrentProfile.id && $CurrentProfile.licenses}
            <div style="padding: 0.37vh; padding-top: 0; display: flex; flex-wrap: wrap; box-sizing: border-box;">
                {#each Object.entries($CurrentProfile.licenses) as [License, Value]}
                    {#if Value}
                        {#if $IsGov || $IsJudge}
                            <MdwChip Text={LicensesLocale[License]} SuffixIcon='times-circle' on:click={() => { RevokeLicense(License) }}/>
                        {:else}
                            <MdwChip Text={LicensesLocale[License]}/>
                        {/if}
                    {/if}
                {/each}
            </div>
        {/if}
    </MdwPanel>

    {#if !$IsPublic}
        <MdwPanel class="filled" style="width: 100%; height: max-content; margin-bottom: 0.5vh;">
            <MdwPanelHeader>
                <h6>Tags</h6>
        
                <div class="mdw-box-title-icons">
                    {#if $CurrentProfile.id && HasCidPermission("Profiles.Edit")}
                        <i on:keyup on:click={AddTag} class="fas fa-plus"></i>
                    {/if}
                </div>
            </MdwPanelHeader>

            {#if $CurrentProfile.id && $CurrentProfile.tags}
                <div style="padding: 0.37vh; padding-top: 0; display: flex; flex-wrap: wrap; box-sizing: border-box;">
                    {#each $CurrentProfile.tags as Data, Key}
                        {#if HasCidPermission("Profiles.Edit")}
                            <MdwChip Text={GetTagById(Data).tag} Color={GetTagById(Data).color} PrefixIcon={GetTagById(Data).icon} SuffixIcon="times-circle" on:click={() => { RemoveTag(Key) }}/>
                        {:else}
                            <MdwChip Text={GetTagById(Data).tag} Color={GetTagById(Data).color} PrefixIcon={GetTagById(Data).icon}/>
                        {/if}
                    {/each}
                </div>
            {/if}
        </MdwPanel>
    {/if}

    <MdwPanel class="filled" style="width: 100%; height: max-content; margin-bottom: 0.5vh;">
        <MdwPanelHeader>
            <h6>Voertuigen</h6>
        </MdwPanelHeader>

        {#if $CurrentProfile.id && $CurrentProfile.vehicles}
            <div style="padding: 0.37vh; padding-top: 0; display: flex; flex-wrap: wrap; box-sizing: border-box;">
                {#each $CurrentProfile.vehicles as Data, Key}
                    <MdwChip on:click={() => MdwModalsVehicleHistory.set({ Show: true, Plate: Data.Plate })} Text="{Data.Plate} - {Data.Vehicle}"/>
                {/each}
            </div>
        {/if}
    </MdwPanel>

    {#if HasCidPermission("Profiles.ShowHousing")} 
        <MdwPanel class="filled" style="width: 100%; height: max-content; margin-bottom: 0.5vh;">
            <MdwPanelHeader>
                <h6>Huisvesting</h6>
            </MdwPanelHeader>
            {#if $CurrentProfile.id && $CurrentProfile.housing}
                <div style="padding: 0.37vh; padding-top: 0; display: flex; flex-wrap: wrap; box-sizing: border-box;">
                    {#each $CurrentProfile.housing as Data, Key}
                        <MdwChip Text="{Data.Adress} ({Data.Owner ? "Eigenaar" : "Keyholder"})"/>
                    {/each}
                </div>
            {/if}
        </MdwPanel>
    {/if}

    <MdwPanel class="filled" style="width: 100%; height: max-content; margin-bottom: 0.5vh;">
        <MdwPanelHeader>
            <h6>Werkgelegenheid</h6>
        </MdwPanelHeader>

        {#if $CurrentProfile.id && $CurrentProfile.employment}
            <div style="padding: 0.37vh; padding-top: 0; display: flex; flex-wrap: wrap; box-sizing: border-box;">
                {#each $CurrentProfile.employment as Data, Key}
                    <MdwChip Text="{Data.Business} ({Data.Role})"/>
                {/each}
            </div>
        {/if}
    </MdwPanel>

    <MdwPanel class="filled" style="width: 100%; height: max-content; margin-bottom: 0.5vh;">
        <MdwPanelHeader>
            <h6>Historie</h6>
        </MdwPanelHeader>

        {#if $CurrentProfile.id && $CurrentProfile.priors}
            <div style="padding: 0.37vh; padding-top: 0; display: flex; flex-wrap: wrap; box-sizing: border-box;">
                {#each $CurrentProfile.priors as Data, Key}
                    {@const Charge = GetChargeById(Data.Id)}
                    {#if Charge}
                        <MdwChip Text="{Data.Amount > 1 ? `(${Data.Amount}x) ` : ""}{Charge.name}"/>
                    {/if}
                {/each}
            </div>
        {/if}
    </MdwPanel>
</MdwPanel>

<style>
    .mdw-profile-editor {
        width: 93%;
        height: 51vh;
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

    :global(.mdw-profile-editor ol) {
        padding: revert !important
    }

    :global(.mdw-profile-editor ul) {
        padding: revert !important
    }

    .mdw-profile-editor::-webkit-scrollbar {
        display: none
    }
</style>