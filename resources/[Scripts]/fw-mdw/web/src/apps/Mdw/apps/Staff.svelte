<script>
    import MdwPanel from "../components/MdwPanel.svelte";
    import MdwPanelHeader from "../components/MdwPanel.Header.svelte";
    import MdwPanelList from "../components/MdwPanel.List.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";
    import MdwCard from "../components/MdwCard.svelte";
    import { onMount } from "svelte";
    import { GetCertById, GetRankById, GetRoleById, GetTimeLabel, HasCidPermission, SendEvent } from "../../../utils/Utils";
    import { CurrentStaff, IsEms, IsHighcommand, IsPublic, MdwModalsCerts, MdwModalsRoles, ShowLoader } from "../../../stores";
    import MdwChip from "../components/MdwChip.svelte";

    let Staff = [];
    let FilteredStaff = [];
    let AmountOfStrikes = 0;
    let CurrentRank = '';

    onMount(() => {
        SendEvent("Staff/FetchAll", {}, (Success, Data) => {
            if (!Success) return;

            Staff = Data;
            FilteredStaff = Data;
        });
    });

    const FilterStaff = Value => {
        const Search = Value.toLowerCase();

        FilteredStaff = Staff.filter(Val => {
            return Val.citizenid.toLowerCase().includes(Search) ||
                Val.name.toLowerCase().includes(Search) ||
                Val.callsign.toLowerCase().includes(Search) ||
                Val.alias.toLowerCase().includes(Search)
        });
    };

    const FetchById = Id => {
        ShowLoader.set(true);
        SendEvent("Staff/FetchById", {Id}, (Success, Data) => {
            ShowLoader.set(false);
            if (!Success) return;
            CurrentStaff.set(Data);

            AmountOfStrikes = 0;
            for (let i = 0; i < Data.strikes.length; i++) {
                if (!Data.strikes[i].Deleted) {
                    AmountOfStrikes = AmountOfStrikes + Data.strikes[i].Points;
                };
            };

            CurrentRank = GetRankById(Data.rank)?.rank || 'Niet Bekend';
        });
    };

    const AddCert = () => {
        MdwModalsCerts.set({
            Show: true,
            IgnoreFilter: $CurrentStaff.certs,
            Cb: (CertId) => {
                SendEvent("Staff/AddCert", {Id: $CurrentStaff.id, Cert: CertId}, (Success, Data) => {
                    if (!Success) return;
                    $CurrentStaff.certs = [...$CurrentStaff.certs, CertId]
                });
            },
        });
    };

    const RemoveCert = Id => {
        ShowLoader.set(true);
        SendEvent("Staff/RemoveCert", {Id: $CurrentStaff.id, Cert: Id}, (Success, Data) => {
            ShowLoader.set(false);
            if (!Success) return;
            let NewStaff = {...$CurrentStaff};
            NewStaff.certs.splice(Id - 1, 1);
            CurrentStaff.set(NewStaff);
        });
    };

    const AddRole = () => {
        MdwModalsRoles.set({
            Show: true,
            IgnoreFilter: $CurrentStaff.roles,
            Cb: (RoleId) => {
                SendEvent("Staff/AddRole", {Id: $CurrentStaff.id, Role: RoleId}, (Success, Data) => {
                    if (!Success) return;
                    $CurrentStaff.roles = [...$CurrentStaff.roles, RoleId]
                });
            },
        });
    };

    const RemoveRole = Id => {
        ShowLoader.set(true);
        SendEvent("Staff/RemoveRole", {Id: $CurrentStaff.id, Role: Id}, (Success, Data) => {
            ShowLoader.set(false);
            if (!Success) return;
            let NewStaff = {...$CurrentStaff};
            NewStaff.roles.splice(Id - 1, 1);
            CurrentStaff.set(NewStaff);
        });
    };
</script>

<MdwPanel class="filled">
    <MdwPanelHeader>
        <h6>Personeel</h6>
        <TextField Title='Zoeken' Icon='search' SubSet={FilterStaff} />
    </MdwPanelHeader>

    <MdwPanelList>
        {#each FilteredStaff as Data, Key}
            {#if (!$IsPublic && $IsEms && Data.department.toLowerCase() == 'los santos medical group') || (!$IsEms && Data.department.toLowerCase() != 'los santos medical group')}
                <MdwCard on:click={() => { FetchById(Data.id) }} Information={[
                    [Data.callsign ? `(${Data.callsign}) ${Data.name}` : Data.name],
                    [`ID: ${Data.id}`]
                ]} />
            {/if}
        {/each}
    </MdwPanelList>
</MdwPanel>

<MdwPanel class="filled">
    <MdwPanelHeader>
        <h6>Profiel</h6>
    </MdwPanelHeader>

    <div style="display: flex; flex-direction: row; width: 97%; height: 19.4vh; margin-left: auto; margin-right: auto;">
        <div style="height: 19.3vh; width: 19.3vh;">
            <img src="{$CurrentStaff.image || "./images/mugshot.png"}" alt="" style="width: 19vh; height: 19vh; border: 0.15vh solid black;" />
        </div>

        <div style="margin-left: 0.7vh; width: 100%;">
            <TextField ReadOnly={true} style="margin-bottom: 0px;" bind:RealValue={$CurrentStaff.citizenid} Title='BSN' Icon='id-card' />
            <TextField ReadOnly={true} style="margin-bottom: 0px;" bind:RealValue={$CurrentStaff.name} Title='Naam' Icon='user' />
            <TextField ReadOnly={true} style="margin-bottom: 0px;" bind:RealValue={$CurrentStaff.callsign} Title='Roepnummer' Icon='tag' />
            <TextField ReadOnly={true} style="margin-bottom: 0px;" bind:RealValue={$CurrentStaff.alias} Title='Alias' Icon='mask' />
            <TextField ReadOnly={true} style="margin-bottom: 0px;" bind:RealValue={$CurrentStaff.phonenumber} Title='Telefoonnummer' Icon='mobile-alt' />
            <TextField ReadOnly={true} style="margin-bottom: 0px;" bind:RealValue={$CurrentStaff.department} Title='Eenheid' Icon='house-user' />
            <TextField ReadOnly={true} style="margin-bottom: 0px;" bind:RealValue={CurrentRank} Title='Rang' Icon='certificate' />
            <TextField ReadOnly={true} style="margin-bottom: 0px;" bind:RealValue={AmountOfStrikes} Title='Strikes' Icon='times-circle' />
        </div>
    </div>
</MdwPanel>

<MdwPanel>
    <MdwPanel class="filled" style="width: 100%; height: max-content; margin-bottom: 0.5vh;">
        <MdwPanelHeader>
            <h6>Rollen</h6>
    
            {#if !$IsPublic && $IsHighcommand}
                <div class="mdw-box-title-icons">
                    {#if $CurrentStaff.id}
                        <i on:keyup on:click={AddRole} class="fas fa-plus"></i>
                    {/if}
                </div>
            {/if}
        </MdwPanelHeader>

        {#if $CurrentStaff.id && $CurrentStaff.roles}
            <div style="padding: 0.37vh; padding-top: 0; display: flex; flex-wrap: wrap; box-sizing: border-box;">
                {#each $CurrentStaff.roles as Data, Key}
                    {#if $IsHighcommand}
                        <MdwChip PrefixIcon={GetRoleById(Data).icon} Color={GetRoleById(Data).color} Text={GetRoleById(Data).name} SuffixIcon='times-circle' on:click={() => { RemoveRole(Key + 1) }} />
                    {:else}
                        <MdwChip PrefixIcon={GetRoleById(Data).icon} Text={GetRoleById(Data).name} />
                    {/if}
                {/each}
            </div>
        {/if}
    </MdwPanel>

    <MdwPanel class="filled" style="width: 100%; height: max-content; margin-bottom: 0.5vh;">
        <MdwPanelHeader>
            <h6>Specialisaties</h6>
    
            {#if !$IsPublic}
                <div class="mdw-box-title-icons">
                    {#if $CurrentStaff.id && HasCidPermission("Staff.GiveCerts")}
                        <i on:keyup on:click={AddCert} class="fas fa-plus"></i>
                    {/if}
                </div>
            {/if}
        </MdwPanelHeader>

        {#if $CurrentStaff.id && $CurrentStaff.certs}
            <div style="padding: 0.37vh; padding-top: 0; display: flex; flex-wrap: wrap; box-sizing: border-box;">
                {#each $CurrentStaff.certs as Data, Key}
                    {#if HasCidPermission("Staff.GiveCerts")}
                        <MdwChip PrefixIcon='certificate' Color={GetCertById(Data).color} Text={GetCertById(Data).certificate} SuffixIcon='times-circle' on:click={() => { RemoveCert(Key + 1) }} />
                    {:else}
                        <MdwChip PrefixIcon='certificate' Text={GetCertById(Data).certificate} />
                    {/if}
                {/each}
            </div>
        {/if}
    </MdwPanel>

    {#if !$IsPublic && HasCidPermission("Staff.ShowStrikes")}
        <MdwPanel class="filled" style="width: 100%; height: max-content; margin-bottom: 0.5vh;">
            <MdwPanelHeader>
                <h6>Strikes</h6>
            </MdwPanelHeader>

            <MdwPanelList>
                {#if $CurrentStaff.id && $CurrentStaff.strikes}
                    {#each $CurrentStaff.strikes as Data, Key}
                        {#if !Data.Deleted || $IsHighcommand}
                            <MdwCard Information={[
                                [Data.Reason, (Data.Points > 1 ? `${Data.Points} strikes` : `${Data.Points} strike`)],
                                [`ID: ${Key + 1} ${Data.Deleted ? "(Ingetrokken)" : ""}`, `${Data.Issuer} - ${GetTimeLabel(Data.Timestamp)}`]
                            ]} />
                        {/if}
                    {/each}
                {/if}
            </MdwPanelList>
        </MdwPanel>
    {/if}
</MdwPanel>