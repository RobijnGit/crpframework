<script>
    import { IsEnvBrowser } from "../../../utils/Utils";

    export let App = 'details';
    export let Tooltip = 'Details';
    export let Icon = false;
    export let HasUnread = false;
</script>

<div {...$$restProps} data-tooltip="{Tooltip}{IsEnvBrowser() ? ` [${App}]` : ""}" class="phone-application {$$restProps.class}" on:keyup on:click>
    {#if Icon}
        <i class="fas fa-{Icon}"></i>
    {/if}
    {#if HasUnread}
        <div class="phone-app-unread"/>
    {/if}
</div>

<style>
    .phone-application {
        position: relative;
        width: 100%;
        height: 100%;
        background-size: 100% 100%;
        border-radius: 1.3vh;
        color: white;
        font-size: 3vh;
        text-align: center;
        line-height: 5.4vh
    }

    .phone-app-unread {
        top: -0.6vh;
        right: -0.6vh;
        width: .5vh;
        height: .5vh;
        position: absolute;
        border-radius: 100%;
        border: .65vh solid red;
        background-color: white
    }

    .phone-application > i {
        text-shadow: 0 0 .3vh rgba(0, 0, 0, 0.5);
    }

</style>