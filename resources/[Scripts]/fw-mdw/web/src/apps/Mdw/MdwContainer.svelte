<script>
    import { CurrentTab } from "../../stores";
    import Dashboard from "./apps/Dashboard.svelte";
    import Reports from "./apps/Reports.svelte";
    import Profiles from "./apps/Profiles.svelte";
    import Evidence from "./apps/Evidence.svelte";
    import Properties from "./apps/Properties.svelte";
    import Charges from "./apps/Charges.svelte";
    import Staff from "./apps/Staff.svelte";
    import Legislation from "./apps/Legislation.svelte";
    import Businesses from "./apps/Businesses.svelte";
    import Roster from "./apps/Roster.svelte";
    import Config from "./apps/Config.svelte";
</script>

<div class="mdw-inside-container">
    {#if $CurrentTab == 'Dashboard'}
        <Dashboard/>
    {:else if $CurrentTab == 'Reports'}
        <Reports/>
    {:else if $CurrentTab == 'Profiles'}
        <Profiles/>
    {:else if $CurrentTab == 'Evidence'}
        <Evidence/>
    {:else if $CurrentTab == 'Properties'}
        <Properties/>
    {:else if $CurrentTab == 'Charges'}
        <Charges/>
    {:else if $CurrentTab == 'Staff'}
        <Staff/>
    {:else if $CurrentTab == 'Legislation'}
        <Legislation/>
    {:else if $CurrentTab == 'Businesses'}
        <Businesses/>
    {:else if $CurrentTab == 'Roster'}
        <Roster/>
    {:else if $CurrentTab == 'Config'}
        <Config/>
    {/if}
</div>

<style>
    .mdw-inside-container {
        display: flex;
        flex-direction: row;
        position: relative;
        margin: .6vh 1vh 0 0;
        float: right;
        width: 89%;
        height: 81%;
    }
</style>