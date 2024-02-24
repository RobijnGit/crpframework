<script>
    import { fade } from 'svelte/transition';
    import { OnEvent } from "../../utils/Utils";
    import AppWrapper from '../../components/AppWrapper.svelte';

    // Prompt
    let ShowPrompt = false;
    let PromptText = "";
    let PromptColor = "primary";

    OnEvent("Prompt", "SetInteraction", (Data) => {
        ShowPrompt = true;
        PromptText = Data.Text.replaceAll(`[`, `<span>[`).replaceAll(`]`, `]</span>`);
        PromptColor = Data.Type;
    });

    OnEvent("Prompt", "HideInteraction", () => {
        ShowPrompt = false;
    });

    // Notifications
    // rewrite this.
    let Notifications = [];

    OnEvent("Prompt", "AddNotification", (Data) => {
        AddNotification({
            Id: Data.Id,
            Text: Data.Message,
            Color: Data.Type,
            Duration: Data.TimeOut,
        });
    });

    function CreatePromptId() {
        return Math.floor(Math.random() * 9999);
    }

    const AddNotification = (Data) => {
        if (!Data.Id) Data.Id = CreatePromptId();

        const NotificationIndex = Notifications.findIndex(Val => Val.Id == Data.Id || (Val.Text == Data.Text && Val.Color == Data.Color));
        if (NotificationIndex > -1) {
            DeleteNotification(Notifications[NotificationIndex].Id, false);
        };

        Notifications = [
            {
                Id: Data.Id,
                Text: Data.Text,
                Color: Data.Color || "primary",
                Timeout: setTimeout(() => {
                    DeleteNotification(Data.Id, true);
                }, Data.Duration || 3500),
                Fade: true
            },
            ...Notifications
        ]
    };

    const DeleteNotification = (PromptId, Fade) => {
        const NotificationIndex = Notifications.findIndex(Val => Val.Id == PromptId);
        if (NotificationIndex > -1) {
            if (Notifications[NotificationIndex].Timeout) clearTimeout(Notifications[NotificationIndex].Timeout);
            Notifications[NotificationIndex].Fade = Fade;
            Notifications = Notifications.filter(Val => Val.Id != PromptId);
        };
    };
</script>

<AppWrapper AppName="Prompt" Focused={false} style="z-index: 999;">
    <div class="notify-container">
        {#each Notifications as Data (Data.Id)}
            <div
                class="notify {Data.Color}"
                in:fade={{ duration: 250 }}
                out:fade={{ duration: Data.Fade ? 1000 : 0 }}
            >
                {Data.Text}
            </div>
        {/each}
    </div>
    
    <div class="prompt-wrapper">
        <div class="prompt {PromptColor}" class:move-in={ShowPrompt}>
            {@html PromptText}
        </div>
    </div>
</AppWrapper>

<style>
    .ui-reload {
        position: absolute;
        bottom: 3vh;
        left: 0; right: 0;
        margin: 0 auto;

        padding: 1.2vh;
        width: fit-content;
        height: fit-content;

        font-family: Arial;
        letter-spacing: -0.01vh;
        font-size: 1.5vh;

        box-shadow: 0 0 .5vh rgba(0, 0, 0, 0.5);

        color: white;
        background-color: #1e95d6;
        border-radius: 0.3vh;
    }

    .prompt-wrapper {
        position: absolute;
        top: 47.6%;
        left: 0;
        transform: translateY(-50%);
    }

    .prompt {
        position: absolute;
        transform: translateX(-150%);

        padding: 1.5vh;

        width: max-content;
        height: max-content;

        transition: transform 1000ms cubic-bezier(0, 0, 0.2, 1) 0ms;

        margin: 0;

        font-style: normal;
        font-family: Arial, Helvetica, sans-serif;
        font-weight: 600;
        font-variant: small-caps;
        letter-spacing: -0.01vh;
        text-transform: none;
        text-decoration: none;
        font-size: 1.5vh;

        color: white;
        background-color: #0288d1;
        border-radius: 0.3vh;
    }

    :global(.prompt > span) {
        text-shadow: rgb(55 71 79) -0.1vh 0.1vh 0, rgb(55 71 79) 0.1vh 0.1vh 0, rgb(55 71 79) 0.1vh -0.1vh 0, rgb(55 71 79) -0.1vh -0.1vh 0;
    }

    .prompt.move-in {
        transform: translateX(6.5%);
    }
    .prompt.move-out {
        transform: translateX(-150%);
    }

    .prompt.error { background-color: #ee3939; }
    .prompt.success { background-color: #3bb041; }
    .prompt.primary { background-color: #2196f3; }

    .notify-container {
        position: absolute;
        left: 68%;
        top: 1%;

        width: 30%;
        height: 15%;

        padding: 0.1vh;

        color: white;
    }

    .notify {
        float: left;

        margin: 0.6vh;
        padding: 0.8vh;

        border-radius: 0.4vh;

        width: max-content;

        font-size: 1.2vh;
        font-weight: bold;
        font-family: 'Lato', sans-serif;

        max-width: 29vw;

        color: white;

        background-color: rgba(51, 112, 165, 0.7);
        border-bottom: .3vh solid rgba(25, 56, 82, 0.5);
        box-shadow: 0 0 .5vh rgba(0,0,0,0.3);
    }

    .notify-container > .notify.primary {
        background-color: rgba(51, 112, 165, 0.7);
        border-color: rgba(25, 56, 82, 0.5);
    }

    .notify-container > .notify.error {
        background-color: rgba(147, 62, 47, 0.7);
        border-color: rgba(73, 31, 23, 0.5);
    }

    .notify-container > .notify.success {
        background-color: rgba(32, 158, 85, 0.7);
        border-color: rgba(16, 69, 38, 0.5)
    }
</style>
