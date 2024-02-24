<script>
    import { Notifications } from "../../utils/Utils";
    import NotificationsCard from "./components/NotificationsCard.svelte";
</script>

{#if $Notifications.length > 0}
    <div class="phone-notifications">
        {#each $Notifications.reverse() as Data (Data.Id)}
            <NotificationsCard {...Data}/>
        {/each}
    </div>
{/if}

<style>
    .phone-notifications::-webkit-scrollbar {
        display: none
    }

    .phone-notifications {
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        z-index: 200;
        transition: max-height .5s ease;
        position: absolute;
        top: 2.2vh;
        left: 0;
        right: 0;
        margin: 0 auto;
        padding-top: 0.37vh;
        width: 96.5%;
        min-height: 5.5vh;
        overflow: hidden
    }
</style>