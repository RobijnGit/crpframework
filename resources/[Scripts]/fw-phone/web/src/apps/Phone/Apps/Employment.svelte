<script>
    import * as BIZ from "./_employment";
    import { onMount } from "svelte";
    import { CurrentBusiness, PlayerData } from "../phone.stores";
    import { SendEvent, SetDropdown } from "../../../utils/Utils";

    import TextField from "../../../components/TextField/TextField.svelte";

    import AppWrapper from "../components/AppWrapper.svelte";
    import PaperList from "../components/PaperList.svelte";
    import Paper from "../components/Paper.svelte";

    let Businesses = [];
    let FilteredBusinesses = [];

    let SearchQuery = "";
    let FilteredEmployees = [];

    // Businesses
    const FilterBusinesses = (Search) => {
        const Query = Search.toLowerCase();
        FilteredBusinesses = Businesses.filter((Val) =>
            Val.business_name.toLowerCase().includes(Query)
        );
    };

    const GetRoleBusiness = (BizId) => {
        const Biz = FilteredBusinesses[BizId];
        if (!Biz) return "No Biz";

        if (Biz.business_owner == $PlayerData.Cid) {
            return "Eigenaar";
        }

        const Employee = Biz.business_employees.find(
            (Val) => Val.Cid == $PlayerData.Cid
        );
        if (!Employee) return "";

        return Employee.Role;
    };

    // Business Tab
    const SetCurrentBusiness = (BizId) => {
        if (!FilteredBusinesses[BizId]) return;
        CurrentBusiness.set(FilteredBusinesses[BizId]);
        FilteredEmployees = $CurrentBusiness.business_employees;
    };

    const HasPermission = (Permission) => {
        if (!$CurrentBusiness.id) return;

        const Biz = $CurrentBusiness;
        if (Biz.business_owner == $PlayerData.Cid) {
            return true;
        }

        const Employee = Biz.business_employees.find(
            (Val) => Val.Cid == $PlayerData.Cid
        );
        if (!Employee) return false;

        const Role = Biz.business_ranks.find(
            (Val) => Val.Name == Employee.Role
        );
        if (!Role) return false;

        return Role.Perms[Permission];
    };

    const GetOptionsDropdown = () => {
        let Retval = [];

        if (HasPermission("Hire"))
            Retval.push({
                Icon: "user-plus",
                Text: "Aannemen",
                Cb: BIZ.HireEmployee,
            });

        if (HasPermission("PayExternal"))
            Retval.push({
                Icon: "hand-holding-usd",
                Text: "Persoon Betalen",
                Cb: BIZ.PayExternal,
            });

        if (HasPermission("ChargeExternal"))
            Retval.push({
                Icon: "credit-card",
                Text: "Klant Factureren",
                Cb: BIZ.ChargeExternal,
            });

        if (HasPermission("ChangeRole")) {
            Retval.push({
                Icon: "user-tag",
                Text: "Rol Maken",
                Cb: BIZ.CreateRole,
            });
            if ($CurrentBusiness.business_ranks.length > 0) {
                Retval.push({
                    Icon: "user-tag",
                    Text: "Rol Bewerken",
                    Cb: BIZ.EditRole,
                });
                Retval.push({
                    Icon: "user-tag",
                    Text: "Rol Verwijderen",
                    Cb: BIZ.DeleteRole,
                });
            }
        }

        return Retval;
    };

    const FilterEmployees = (Value) => {
        SearchQuery = Value.toLowerCase();

        const Employees = $CurrentBusiness.business_employees.filter(
            (Val) =>
                Val.Name.toLowerCase().includes(SearchQuery) ||
                Val.Cid.toLowerCase().includes(SearchQuery) ||
                Val.Role.toLowerCase().includes(SearchQuery)
        );

        FilteredEmployees = Employees.sort(function (a, b) {
            return a.Role.localeCompare(b.Role);
        });
    };

    // onMount, onDestroy
    onMount(() => {
        SendEvent("Employment/GetBusinesses", {}, (Success, Data) => {
            if (!Success) return;

            Businesses = Data;
            FilteredBusinesses = Data;
        });
    });

    // Refresh employees
    $: {
        if ($CurrentBusiness.id) {
            FilterEmployees(SearchQuery);
        };
    };
</script>

<AppWrapper>
    {#if !$CurrentBusiness.id}
        <TextField
            Icon="search"
            Title="Zoeken"
            SubSet={FilterBusinesses}
            class="phone-misc-input"
        />

        <PaperList>
            {#each FilteredBusinesses as Data, Key}
                <Paper
                    Icon="business-time"
                    Title={Data.business_name}
                    Description={GetRoleBusiness(Key)}
                    on:click={() => {
                        SetCurrentBusiness(Key);
                    }}
                />
            {/each}
        </PaperList>
    {:else}
        <div class="phone-misc-icons phone-misc-back">
            <i
                class="fas fa-chevron-left"
                on:keyup
                on:click={() => {
                    CurrentBusiness.set({});
                }}
            />
        </div>

        <TextField
            Title="Zoeken"
            Icon="search"
            class="phone-misc-input phone-misc-input2"
            SubSet={FilterEmployees}
        />

        <div class="phone-misc-icons">
            {#if $CurrentBusiness.business_name == 'Los Santos Vliegschool'}
                <i
                    data-tooltip="Geef/Ontneem Brevet"
                    data-position="left"
                    class="fas fa-stamp"
                    on:keyup
                    on:click={BIZ.Flightschool.TogglePilotsLicense}
                />
            {/if}

            <i
                class="fas fa-ellipsis-v"
                on:keyup
                on:click={(event) => {
                    const IconPosition = event.target.getBoundingClientRect();
                    const Left = IconPosition.left;
                    const Top = IconPosition.bottom - 15;
                    SetDropdown(true, GetOptionsDropdown(), { Left, Top });
                }}
            />
        </div>

        <PaperList>
            {#if $CurrentBusiness.owner_name.toLowerCase().includes(SearchQuery) || $CurrentBusiness.business_owner.toLowerCase().includes(SearchQuery)}
                <Paper
                    Icon="user-secret"
                    Title={$CurrentBusiness.owner_name}
                    Description="Eigenaar"
                    HasActions={true}
                >
                    {#if HasPermission("PayEmployee")}
                        <i
                            on:keyup
                            on:click={() => { BIZ.PayEmployee($CurrentBusiness.business_owner) }}
                            data-tooltip="Werknemer Betalen"
                            class="fas fa-hand-holding-usd"
                        />
                    {/if}
                </Paper>
            {/if}

            {#each FilteredEmployees as Data, Id}
                <Paper
                    Icon="user-tie"
                    Title={Data.Name}
                    Description={Data.Role}
                    HasActions={true}
                >
                    {#if HasPermission("ChangeRole")}
                        <i
                            on:keyup
                            on:click={() => { BIZ.ChangeRole(Data.Cid) }}
                            data-tooltip="Rol Aanpassen"
                            class="fas fa-user-tag"
                        />
                    {/if}

                    {#if HasPermission("PayEmployee")}
                        <i
                            on:keyup
                            on:click={() => { BIZ.PayEmployee(Data.Cid) }}
                            data-tooltip="Werknemer Betalen"
                            class="fas fa-hand-holding-usd"
                        />
                    {/if}

                    {#if HasPermission("Fire")}
                        <i
                            on:keyup
                            on:click={() => { BIZ.FireEmployee(Data.Cid) }}
                            data-tooltip="Werknemer Ontslaan"
                            class="fas fa-user-slash"
                        />
                    {/if}

                    {#if $CurrentBusiness.business_owner == $PlayerData.Cid}
                        <i
                            on:keyup
                            on:click={() => { BIZ.BankAccess(Data.Cid) }}
                            data-tooltip="Bank Toegang"
                            class="fas fa-university"
                        />
                    {/if}
                </Paper>
            {/each}
        </PaperList>
    {/if}
</AppWrapper>
