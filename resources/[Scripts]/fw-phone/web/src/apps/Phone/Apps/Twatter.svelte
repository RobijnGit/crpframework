<script>
    import "../components/Misc.css";
    import { onMount } from "svelte";
    import { ExtractImageUrls, GetTimeLabel, OnEvent, SendEvent, ShowSuccessModal } from "../../../utils/Utils";
    import { InputModal, LoaderModal } from "../phone.stores";

    import Button from "../../../components/Button/Button.svelte";
    import TextField from "../../../components/TextField/TextField.svelte";

    import AppWrapper from "../components/AppWrapper.svelte";
    import PaperList from "../components/PaperList.svelte";
    import ImageContainer from "../components/ImageContainer.svelte";
    import Empty from "../components/Empty.svelte";

    let Twats = [];
    let FilteredTwats = [];
    let ShowingLimit = 100;

    const FilterTwats = (Query) => {
        Query = Query.toLowerCase();
        FilteredTwats = Twats.filter(
            (Val) =>
                Val.Msg.toLowerCase().includes(Query) ||
                Val.Sender.toLowerCase().includes(Query)
        );
    };

    const LoadMore = () => {
        ShowingLimit = ShowingLimit + 100;
    };

    const PostAd = () => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Id: "Message",
                    Type: "TextArea",
                    Data: {
                        Title: "Twat",
                    },
                },
            ],
            OnSubmit: (Result) => {
                if (Result.Message.length <= 0) return;
                LoaderModal.set(true);
                SendEvent("Twitter/PostTweet", { Msg: Result.Message }, (Success, Data) => {
                        LoaderModal.set(false);
                        if (!Success) return;
                        if (Data) ShowSuccessModal();
                    }
                );
            },
        });
    };

    const ReplyTwat = (Data) => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Id: "Message",
                    Type: "TextArea",
                    Data: {
                        Title: "Twat",
                        Value: " @" + Data.Sender,
                    },
                },
            ],
            OnSubmit: (Result) => {
                if (Result.Message.length <= 0) return;
                LoaderModal.set(true);
                SendEvent("Twitter/PostTweet", { Msg: Result.Message }, (Success, Data) => {
                        LoaderModal.set(false);
                        if (!Success) return;
                        if (Data) ShowSuccessModal();
                    }
                );
            },
        });
    };

    const Retwat = (Data) => {
        InputModal.set({
            Visible: true,
            Inputs: [
                {
                    Id: "Message",
                    Type: "TextArea",
                    Data: {
                        Title: "Twat",
                        Value: " RT @" + Data.Sender + " " + Data.Msg,
                    },
                },
            ],
            OnSubmit: (Result) => {
                if (Result.Message.length <= 0) return;
                LoaderModal.set(true);
                SendEvent("Twitter/PostTweet", { Msg: Result.Message }, (Success, Data) => {
                        LoaderModal.set(false);
                        if (!Success) return;
                        if (Data) ShowSuccessModal();
                    }
                );
            },
        });
    };

    const ReportTwat = (Data) => {
        LoaderModal.set(true)
        SendEvent("Twitter/ReportTweet", { Id: Data.Id }, (Success, Data) => {
            LoaderModal.set(false);
            if (!Success) return;
            ShowSuccessModal();
        })
    };

    onMount(() => {
        SendEvent("Twitter/GetTweets", {}, (Success, Data) => {
            if (!Success) return;

            Twats = Data;
            FilteredTwats = Twats;
        });
    });

    OnEvent("Twitter/SetTweets", (Data) => {
        Twats = Data.Tweets;
        FilteredTwats = Twats;
    });
</script>

<AppWrapper>
    <div class="phone-misc-icons">
        <i
            data-tooltip="Twat"
            data-position="left"
            class="fab fa-twitter"
            on:keyup
            on:click={PostAd}
        />
    </div>

    <TextField
        Title="Zoeken"
        Icon="search"
        SubSet={FilterTwats}
        class="phone-misc-input"
    />

    <PaperList>
        {#if Twats.length == 0}
            <Empty />
        {/if}

        {#each FilteredTwats.slice(-ShowingLimit).reverse() as Data, Id}
            <div class="phone-twatter-twat">
                <div class="phone-twatter-twat-sender">@{Data.Sender}</div>
                <div class="phone-twatter-twat-message">
                    <span>{ExtractImageUrls(Data.Msg)[1]}</span>
                    {#if ExtractImageUrls(Data.Msg)[0].length > 0}
                        <ImageContainer
                            Attachments={ExtractImageUrls(Data.Msg)[0]}
                        />
                    {/if}
                </div>
                <div class="phone-twatter-twat-actions">
                    <i on:keyup on:click={()=>{ ReplyTwat(Data); }} data-tooltip="Reply" class="tooltip fas fa-reply" />
                    <i on:keyup on:click={()=>{ Retwat(Data); }} data-tooltip="RT" class="tooltip fas fa-retweet" />
                    <i on:keyup on:click={()=>{ ReportTwat(Data); }} data-tooltip="Report" class="tooltip fas fa-flag" />
                    <span>{GetTimeLabel(Data.Timestamp)}</span>
                </div>
            </div>
        {/each}

        {#if FilteredTwats.length > ShowingLimit}
            <div style="display: flex; justify-content: center; width: 100%;">
                <Button Color="success" on:click={LoadMore}>Laad Meer</Button>
            </div>
        {/if}
    </PaperList>
</AppWrapper>

<style>
    .phone-twatter-twat {
        background-color: #1565c0;
        border-radius: 0.5vh;
        margin-bottom: 1.5vh;
        padding: 0.3vh 0.6vh;
    }

    .phone-twatter-twat > .phone-twatter-twat-sender {
        font-size: 1.55vh;
        font-family: "Roboto";
        font-weight: 400;
        line-height: 1.43;
        letter-spacing: 0.0017136vh;
    }

    .phone-twatter-twat > .phone-twatter-twat-message {
        margin: 0.7vh 0 0.9vh 0.2vh;
        font-size: 1.33vh;
        font-family: "Roboto";
        font-weight: 400;
        line-height: 1.43;
        letter-spacing: 0.0019;
        word-wrap: break-word;
    }

    .phone-twatter-twat > .phone-twatter-twat-actions {
        margin: 0 0 0 0.3vh;
        font-size: 1.35vh;
    }

    .phone-twatter-twat > .phone-twatter-twat-actions > i {
        margin-right: 0.5vh;
    }

    .phone-twatter-twat > .phone-twatter-twat-actions > span {
        float: right;
        font-size: 1.35vh;
        font-family: "Roboto";
        font-weight: 400;
        letter-spacing: 0.0019;
    }
</style>
