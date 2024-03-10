<script>
    import { MdwTabs } from "../../config";
    import { CurrentTab, IsEms, IsHighcommand, IsPublic } from "../../stores";
    import { HasCidPermission } from "../../utils/Utils";

    const OnNavbarClick = Tab => {
        CurrentTab.set(Tab.Destination);
    };

    const GetNavbarLabel = Tab => {
        if (!$IsPublic && $IsEms && Tab.Destination == "Charges") return "Facturen";
        return Tab.Label
    }
</script>

<div class="mdw-navbar">
    {#each MdwTabs as Tab, Key}
        {#if ($IsPublic && !Tab.Hidden) || (!$IsPublic && (!Tab.Permission || HasCidPermission(Tab.Permission)))}
            <div on:keyup on:click={() => { OnNavbarClick(Tab) }} class="mdw-navbar-item {$CurrentTab == Tab.Destination ? "active" : ""}">
                <h6>
                    {GetNavbarLabel(Tab)}
                </h6>
            </div>
        {/if}
    {/each}

    {#if $IsHighcommand}
        <div on:keyup on:click={() => { OnNavbarClick({Destination: "Config"}) }} class="mdw-navbar-item {$CurrentTab == "Config" ? "active" : ""}" style="margin-top: auto;">
            <h6>Config</h6>
        </div>
    {/if}
</div>

<style>
    .mdw-navbar {
        display: flex;
        flex-direction: column;
        position: relative;
        float: left;
        height: 79vh;
        width: 17.5vh;
        background-color: #232730;
    }

    .mdw-navbar-item {
        display: flex;
        align-items: center;
        height: 5.9vh;
    }

    .mdw-navbar-item.active {
        background-color: rgba(48, 71, 93, 1.0);
    }

    .mdw-navbar-item > h6 {
        font-size: 2vh;
        font-family: Roboto;
        font-weight: 500;
        line-height: 1.6;
        letter-spacing: 0.012vh;
        color: white;
        margin: 0;
        margin-left: 1.55vh;
    }
</style>