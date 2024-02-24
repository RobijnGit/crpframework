<script>
    export let ShowContainer = false;

    import { Notifications, TempNotifications } from "../../../utils/Utils";
    import NotificationCard from "../components/NotificationCard.svelte";
    import NotificationCardLogo from "../components/NotificationCard.Logo.svelte";
    import NotificationCardText from "../components/NotificationCard.Text.svelte";

    if (ShowContainer) TempNotifications.set({});
</script>

{#if ShowContainer}
    <div class="laptop-notifications-history">
        <p>Notificaties</p>
        <div class="actual-notifications">
            {#each $Notifications as Data (Data.Id)}
                <NotificationCard style="background-color: rgba(10, 10, 10, 0.1); backdrop-filter: none;">
                    <div on:keyup on:click={() => {
                        let NewNotifications = $Notifications.filter(Val => Val.Id != Data.Id);
                        Notifications.set(NewNotifications);
                    }} style="cursor: pointer; position: absolute; top: .5vh; right: .5vh; color: white; font-size: 1.5vh;">
                        <i class="fas fa-times"></i>
                    </div>
                    {#if Data.Icon.endsWith('.svg') || Data.Icon.endsWith('.png')}
                        <NotificationCardLogo style="background-color: transparent;">
                            <div class="laptop-app-icon" style="background-image: url(./images/app-icons/{Data.Icon}); width: 3vh; height: 3vh; margin-bottom: 0;"></div>
                        </NotificationCardLogo>
                    {:else}
                        <NotificationCardLogo style="background-color: {Data.Colors[0]}; color: {Data.Colors[1]};">
                            <i class="fas fa-{Data.Icon}"></i>
                        </NotificationCardLogo>
                    {/if}
                    <NotificationCardText Header={Data.Header} Text={Data.Text} />
                </NotificationCard>
            {/each}
        </div>
    </div>
{:else}
    <div class="laptop-notifications">
        {#each $TempNotifications as Data (Data.Id)}
            <NotificationCard class="animate-{Data.AnimateState}">
                {#if Data.Icon.endsWith('.svg') || Data.Icon.endsWith('.png')}
                    <NotificationCardLogo style="background-color: transparent;">
                        <div class="laptop-app-icon" style="background-image: url(./images/app-icons/{Data.Icon}); width: 3vh; height: 3vh; margin-bottom: 0;"></div>
                    </NotificationCardLogo>
                {:else}
                    <NotificationCardLogo style="background-color: {Data.Colors[0]}; color: {Data.Colors[1]};">
                        <i class="fas fa-{Data.Icon}"></i>
                    </NotificationCardLogo>
                {/if}
                <NotificationCardText Header={Data.Header} Text={Data.Text} />
            </NotificationCard>
        {/each}
    </div>
{/if}

<style>
    .laptop-notifications {
        display: flex;
        flex-direction: column-reverse;

        position: absolute;
        top: 1%;
        right: .1%;

        pointer-events: none;

        overflow-y: auto;
        overflow-x: hidden;

        z-index: 999;

        height: 92%;
        width: 25%;
    }

    .laptop-notifications-history {
        position: absolute;
        top: 1.7%;
        right: 1%;
        border-radius: 1vh;

        overflow-y: auto;

        z-index: 999;

        height: 85%;
        width: 25%;

        background-color: rgba(0, 0, 0, 0.5);
        backdrop-filter: blur(1.5vh);

        animation: historyFadeIn 250ms ease-in-out;
    }

    .laptop-notifications-history > p {
        width: 100%;

        font-family: Roboto;
        font-size: 2vh;

        color: white;
        text-align: center;
        margin-top: 1.7vh;
    }

    .laptop-notifications-history > .actual-notifications {
        margin: 0 auto;
        margin-top: 1.6vh;
        width: 90%;
        height: 61vh;
    }

    @keyframes historyFadeIn {
        0% {
            transform: translateX(100%);
        }
        100% {
            transform: translateX(0%);
        }
    }

    .laptop-notifications-history::-webkit-scrollbar,
    .laptop-notifications::-webkit-scrollbar {
        display: none;
    }
</style>