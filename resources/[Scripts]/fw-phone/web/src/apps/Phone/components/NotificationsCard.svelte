<script>

    // Default: hide after 3 seconds
    // If COUNTDOWN it hides after 30 seconds
    // 
    // If action is clicked, hide it UNLESS defined otherwise.
    // If told otherwise OR a timer is shown, do NOT fade out AT ALL, unless 'RemoveNotification' is called.
    // 
    // Fade State SHOULD not be handled here, instead handle it in utils.
    // 
    // ## PLEASE DO NOT TOUCH. IT WILL BREAK ##

    import { onDestroy, onMount } from "svelte";
    import { Notifications, RemoveNotification, SendEvent } from "../../../utils/Utils";

    export let Id = "";
    export let IconColor = "white";
    export let BgColor = "rgb(144, 202, 249)";
    export let Icon = "user-circle";
    export let Title = "Title";
    export let Text = "";
    export let ShowTimer = false;
    export let ShowCountdown = false;
    export let HasAccept = false;
    export let HasReject = false;
    export let Data = {};
    export let State = "in";

    // Actions
    const OnReject = () => {
        SendEvent("Notifications/Click", {Id, Accepted: false});
        if (!Data.HideOnAction) return;

        HasAccept = false, HasReject = false;
        ForceFade();
    };

    const OnAccept = () => {
        SendEvent("Notifications/Click", {Id, Accepted: true});
        if (!Data.HideOnAction) return;

        HasAccept = false, HasReject = false;
        ForceFade();
    };

    const SetState = (Value) => {
        let NewNotifications = $Notifications;
        const NotifIndex = NewNotifications.findIndex(Val => Val.Id == Id);
        if (NotifIndex == -1) return;
        NewNotifications[NotifIndex].State = Value;
        Notifications.set(NewNotifications);
    };

    // Fade In/Out
    let StateTimeout = setTimeout(() => {
        SetState("");
    }, 500);

    const FadeOut = () => {
        if (ShowTimer) return;
        if (HasAccept || HasReject && !Data.HideOnAction) return;
        if (Data.Sticky) return;

        StateTimeout = setTimeout(() => {
            SetState("out");
            setTimeout(() => {
                RemoveNotification({ Id });
            }, 500);
        }, ShowCountdown ? 30500 : 3500);
    };

    const ForceFade = () => {
        if ((HasAccept || HasReject) && !Data.HideOnAction) return;
        if ((ShowCountdown || ShowTimer) && !Data.HideOnAction) return;

        clearTimeout(StateTimeout);
        SetState("out");
        setTimeout(() => {
            RemoveNotification({ Id });
        }, 500);
    };

    // Timer
    let Prefix = "";
    let Timer = 0;
    let TimerInterval;
    if (ShowCountdown) Timer = 30;

    const FormatTime = () => {
        const Minutes = Math.floor(Timer / 60).toString().padStart(2, "0");
        const Seconds = (Timer % 60).toString().padStart(2, "0");
        return `${Minutes}:${Seconds}`;
    };

    onMount(() => {
        if (ShowTimer) {
            Prefix = FormatTime();
            TimerInterval = setInterval(() => {
                Timer = Timer + 1;
                Prefix = FormatTime();
            }, 1000);
            return;
        }

        if (ShowCountdown) {
            Prefix = FormatTime();
            TimerInterval = setInterval(() => {
                Timer = Timer - 1;
                Prefix = FormatTime();

                if (Timer <= 0 && State != "out") {
                    SetState("out");
                    setTimeout(() => {
                        RemoveNotification({ Id });
                    }, 500);
                }
            }, 1000);
        };

        FadeOut();
    });

    onDestroy(() => {
        clearInterval(TimerInterval);
    });

    $: if ((!ShowTimer && !ShowCountdown) && TimerInterval) {
        clearInterval(TimerInterval);
        Prefix = "";
    }
</script>

<div class="phone-notification phone-notification-{State}" on:keyup on:click={() => {
    if (HasAccept || HasReject) return;
    ForceFade(); 
}}>
    <div class="phone-notification-title">
        <div class="icon" style="color: {IconColor}; background-color: {BgColor};">
            <i class="{Icon}" />
        </div>
        <div class="app">
            <p>{Title}</p>
        </div>
        <p>zojuist</p>
    </div>
    <div class="phone-notification-message">
        <div class="text">
            <p>{Prefix}{(ShowTimer || ShowCountdown) && Text ? " - " + Text : Text}</p>
        </div>
        <div class="actions">
            {#if HasReject}
                <div on:keyup on:click={OnReject} data-tooltip="Weigeren" class="tooltip phone-notification-action action-reject">
                    <i class="fas fa-times-circle" />
                </div>
            {/if}
            {#if HasAccept}
                <div on:keyup on:click={OnAccept} data-tooltip="Accepteren" class="tooltip phone-notification-action action-accept">
                    <i class="fas fa-check-circle" />
                </div>
            {/if}
        </div>
    </div>
</div>

<style>
    .phone-notification {
        width: calc(100% - 2.96vh);
        height: 100%;
        padding: 0.5vh 0.64vh;
        border-radius: 0.7vh;
        color: white;
        max-width: 20.8vw;
        cursor: pointer;
        margin-bottom: 0.7vh;
        opacity: 1;
        transform: translateY(0);
        background-color: rgba(53, 49, 52, 0.95);
    }

    .phone-notification-in {
        animation: PhoneNotifFadeIn;
        animation-duration: 0.5s;
        animation-iteration-count: 1;
        animation-fill-mode: forwards;
    }

    .phone-notification-out {
        animation: PhoneNotifFadeOut;
        animation-duration: 0.5s;
        animation-iteration-count: 1;
        animation-fill-mode: forwards;
    }

    .phone-notification p {
        margin: 0;
        font-size: 1.3vh;
        font-family: "Roboto";
        font-weight: 400;
        line-height: 1.43;
        letter-spacing: 0.0017136vh;
    }

    .phone-notification > .phone-notification-title {
        display: flex;
        align-items: center;
    }

    .phone-notification > .phone-notification-title > .icon {
        position: relative;
        border-radius: 0.45vh;
        width: 2.3vh;
        height: 2.3vh;
        margin-right: 0.4vw;
        background-color: rgb(144, 202, 249);
        text-align: center;
    }

    .phone-notification > .phone-notification-title > .icon > i {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        font-size: 1.2vh;
        text-shadow: -0.1vh -0.1vh 0.1vh rgba(0, 0, 0, 0.3),
            0.1vh 0.1vh 0.1vh rgba(0, 0, 0, 0.3),
            0.1vh -0.1vh 0.1vh rgba(0, 0, 0, 0.3),
            -0.1vh 0.1vh 0.1vh rgba(0, 0, 0, 0.3);
    }

    .phone-notification > .phone-notification-title > .app {
        flex: 1 1;
        text-transform: uppercase;
        overflow: hidden;
    }

    .phone-notification > .phone-notification-title > .app > p {
        font-size: 1.2vh;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        padding-right: 0.4vw;
    }

    .phone-notification > .phone-notification-title > p {
        font-size: 1vh;
    }

    .phone-notification > .phone-notification-message {
        margin-top: 0.37vh;
        display: flex;
    }

    .phone-notification > .phone-notification-message > .text {
        flex: 1 1;
        padding-right: 0.4vw;
    }

    .phone-notification > .phone-notification-message > .text > p {
        font-size: 1.1vh;
        display: -webkit-box;
        -webkit-box-orient: vertical;
        -webkit-line-clamp: 1;
        overflow: hidden;
    }

    .phone-notification > .phone-notification-message > .actions {
        display: flex;
        align-items: center;
    }

    .phone-notification
        > .phone-notification-message
        > .actions
        > .phone-notification-action {
        font-size: 1.5vh;
        margin: 0 0.3vh;
    }

    .phone-notification
        > .phone-notification-message
        > .actions
        > .action-accept {
        color: #aed581;
    }

    .phone-notification
        > .phone-notification-message
        > .actions
        > .action-reject {
        color: #ffa726;
    }

    @keyframes PhoneNotifFadeIn {
        0% {
            opacity: 0;
            transform: translateY(-9.25vh);
        }

        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    @keyframes PhoneNotifFadeOut {
        0% {
            opacity: 1;
            transform: translateY(0);
            height: 5.5vh;
            max-height: 5.5vh;
        }

        to {
            opacity: 0;
            transform: translateY(-9.25vh);
            height: 0;
            max-height: 0;
        }
    }
</style>
