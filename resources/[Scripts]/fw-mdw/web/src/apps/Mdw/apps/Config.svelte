<script>
    import { IsHighcommand } from "../../../stores";

    let CurrentTab = '';
    import ConfigTags from "./Config.Tags.svelte";
    import ConfigStaff from "./Config.Staff.svelte";
    import ConfigPermissions from "./Config.Permissions.svelte";
    import ConfigCharges from "./Config.Charges.svelte";
    import { HasCidPermission } from "../../../utils/Utils";
</script>

{#if $IsHighcommand}
    <div style="display: unset; width: 100%;">
        <div class="mdw-config-tags">
            <div class="mdw-config-tab" on:keyup on:click={() => CurrentTab = "Tags"} data-active={CurrentTab == "Tags"}>Tags & Types</div>
            <div class="mdw-config-tab" on:keyup on:click={() => CurrentTab = "Staff"} data-active={CurrentTab == "Staff"}>Staff & Roles</div>
            <div class="mdw-config-tab" on:keyup on:click={() => CurrentTab = "Permissions"} data-active={CurrentTab == "Permissions"}>Permissions</div>
            {#if HasCidPermission("Config.EditCharges") || HasCidPermission("Config.DeleteCharges")}
                <div class="mdw-config-tab" on:keyup on:click={() => CurrentTab = "Charges"} data-active={CurrentTab == "Charges"}>Charges</div>
            {/if}
        </div>
        
        <div style="display: flex; flex-direction: row;">
            {#if CurrentTab == 'Tags'}
                <ConfigTags/>
            {:else if CurrentTab == 'Staff'}
                <ConfigStaff/>
            {:else if CurrentTab == 'Permissions'}
                <ConfigPermissions/>
            {:else if CurrentTab == 'Charges'}
                <ConfigCharges/>
            {/if}
        </div>
    </div>
{/if}

<style>
    .mdw-config-tags {
        display: flex;
        flex-direction: row;
        flex-wrap: wrap;
        align-items: center;
        justify-content: center;
        position: relative;
        top: 0;
        left: 0;
        right: 0;
        width: 100%;
        height: 4vh;
        box-shadow: 0 .8vh .6vh -.6vh rgba(0, 0, 0, 0.25);
        margin: 0 auto;
        background-color: #424242
    }

    .mdw-config-tags > .mdw-config-tab {
        width: 15vh;
        cursor: pointer;
        font-size: 1.2vh;
        font-family: Roboto;
        font-weight: bold;
        text-transform: uppercase;
        color: #c1c3c8;
        line-height: 4vh;
        text-align: center
    }

    .mdw-config-tab[data-active="true"] {
        color: #f2a365;
        box-shadow: inset 0 -0.2vh 0 #f2a365
    }
</style>