<script>
    import { onMount } from "svelte";
    import { GetTimeLabel, SendEvent } from "../../../utils/Utils";
    import "../components/Misc.css";

    import Button from "../../../components/Button/Button.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";
    
    import AppWrapper from "../components/AppWrapper.svelte";
    import PaperList from "../components/PaperList.svelte";

    let Mails = [];
    let FilteredMails = [];
    let ShowingLimit = 100;

    const FilterMails = (Value) => {
        const Query = Value.toLowerCase();
        FilteredMails = Mails.filter(
            (Val) =>
                Val.From.toLowerCase().includes(Query) ||
                Val.Subject.toLowerCase().includes(Query) ||
                Val.Msg.toLowerCase().includes(Query)
        );
    };

    const LoadMore = () => {
        ShowingLimit = ShowingLimit + 100;
    };

    onMount(() => {
        SendEvent("Mails/GetMails", {}, (Success, Data) => {
            if (!Success) return;

            Mails = Data.reverse();
            FilteredMails = Mails;
        });
    });
</script>

<AppWrapper>
    <TextField
        Title="Zoeken"
        Icon="search"
        SubSet={FilterMails}
        class="phone-misc-input"
    />

    <PaperList>
        {#each FilteredMails.slice(0, ShowingLimit) as Data, Id}
            <div class="phone-mails-item">
                <div class="phone-mails-item-from">Verzender: {Data.From}</div>
                <div class="phone-mails-item-subject">Onderwerp: {Data.Subject}</div>
                <div class="phone-mails-item-message">{@html Data.Msg}</div>
                <div class="phone-mails-item-time">{GetTimeLabel(Data.Timestamp)}</div>
            </div>
        {/each}

        {#if FilteredMails.length > ShowingLimit}
            <div style="display: flex; justify-content: center; width: 100%;">
                <Button Color="success" on:click={LoadMore}>Laad Meer</Button>
            </div>
        {/if}
    </PaperList>
</AppWrapper>

<style>
    .phone-mails-item {
        position: relative;
        background-color: #30475d;
        font-size: 1.3vh;
        font-family: "Roboto";
        font-weight: 400;
        line-height: 1.43;
        letter-spacing: 0.0017136vh;
        height: max-content;
        min-height: 6vh;
        line-height: 2.4vh;
        padding: 1vh 0.7vh 0;
        margin-bottom: 0.6vh;
        border-top-left-radius: 0.5vh;
        border-top-right-radius: 0.5vh;
        border-bottom: 0.15vh solid white
    }

    .phone-mails-item-message {
        margin-top: 0.5vh;
        font-family: Georgia;
        letter-spacing: 0.04vh;
        font-weight: 500;
        margin-bottom: 0.7vh;
        line-height: 1.8vh
    }

    .phone-mails-item-time {
        border-top: 0.1vh solid rgba(255, 255, 255, 0.5);
        text-align: center;
        width: 100%;
        height: 3.7vh;
        line-height: 3.7vh
    }
</style>