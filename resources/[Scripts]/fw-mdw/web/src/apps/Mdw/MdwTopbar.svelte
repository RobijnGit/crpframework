<script>
    import { MdwProfile } from "../../stores";
    import { GetRankById } from "../../utils/Utils";
    import MdwDepartmentLogo from "./MdwDepartmentLogo.svelte";
</script>
<div class="mdw-topbar" on:mouseenter on:mouseleave>
    <MdwDepartmentLogo/>

    <p class="mdw-profile-name">
        {$MdwProfile.rank && GetRankById($MdwProfile.rank).rank || ""}

        {#if $MdwProfile.alias}
            "{$MdwProfile.alias}"
        {/if}

        {#if $MdwProfile.name}
            {$MdwProfile.name}
        {:else}
            Geen Profiel Gevonden
        {/if}
    </p>
</div>

<style>
    .mdw-topbar {
        position: relative;
        width: 100%;
        height: 17vh;
        background-color: #1f3a57;
        box-shadow: inset 0 -0.2vh 0 0 #ce3340;
    }

    .mdw-profile-name {
        position: absolute;
        bottom: 1.4vh;
        right: 0.9vh;
        font-size: 1.5vh;
        font-family: Roboto;
        font-weight: bold;
        color: white;
    }
</style>