<script>
    import "../components/Misc.css";
    import { onMount } from "svelte";
    import { FormatPhone, OnEvent, SendEvent, ShowSuccessModal } from "../../../utils/Utils";
    import { InputModal, LoaderModal, PlayerData } from "../phone.stores";

    import TextField from "../../../components/TextField/TextField.svelte";
    import Button from "../../../components/Button/Button.svelte";

    import AppWrapper from "../components/AppWrapper.svelte";
    import PaperList from "../components/PaperList.svelte";
    import Empty from "../components/Empty.svelte";

    let MyAd;
    let Ads = [];
    let FilteredAds = [];
    let ShowingLimit = 100;

    const FilterAds = (Query) => {
        Query = Query.toLowerCase();
        FilteredAds = Ads.filter(
            (Val) =>
                Val.Cid != $PlayerData.Cid &&
                (Val.Msg.toLowerCase().includes(Query) ||
                    Val.Sender.toLowerCase().includes(Query))
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
                        Title: "Advertentie",
                    },
                },
            ],
            OnSubmit: (Result) => {
                if (Result.Message.length <= 0) return;
                LoaderModal.set(true);
                SendEvent("YellowPages/PostAd", { Msg: Result.Message }, (Success, Data) => {
                    LoaderModal.set(false);
                    if (!Success) return;
                    if (Data) ShowSuccessModal();
                });
            },
        });
    };

    const DeleteAd = () => {
        LoaderModal.set(true);
        SendEvent("YellowPages/RemoveAd", {}, (Success, Data) => {
            LoaderModal.set(false);
            if (!Success) return;
            if (Data) ShowSuccessModal();
        });
    };

    const CallAdvertiser = (Phone) => {
        SendEvent("Contacts/Call", {Phone})
    }

    onMount(() => {
        SendEvent("YellowPages/GetPosts", {}, (Success, Data) => {
            if (!Success) return;

            Ads = Data.reverse();
            FilteredAds = Ads;
            MyAd = Ads.filter((Val) => Val.Cid == $PlayerData.Cid)[0];
            FilterAds("");
        });
    });

    OnEvent("YellowPages/SetPosts", (Data) => {
        Ads = Data.Posts.reverse();
        FilteredAds = Ads;
        MyAd = Ads.filter((Val) => Val.Cid == $PlayerData.Cid)[0];
        FilterAds("");
    })
</script>

<AppWrapper>
    {#if !MyAd}
        <div class="phone-misc-icons">
            <i
                data-tooltip="Advertentie Plaatsen"
                data-position="left"
                class="fas fa-plus"
                on:keyup
                on:click={PostAd}
            />
        </div>
    {/if}

    <TextField
        Title="Zoeken"
        Icon="search"
        SubSet={FilterAds}
        class="phone-misc-input"
    />

    <PaperList>
        {#if Ads.length == 0}
            <Empty/>
        {/if}

        {#if MyAd}
            <div class="phone-yellowpages-my-ad">
                <span>Jouw Advertentie</span>
                <Button
                    Color="warning"
                    style="position: relative; float: right; margin: 0px;"
                    on:click={DeleteAd}
                    >Verwijderen</Button
                >
            </div>

            <div class="phone-yellowpages-post">
                <div class="phone-yellowpages-post-message">{MyAd.Msg}</div>
                <div class="phone-yellowpages-post-sender">
                    <div class="name">{MyAd.Sender}</div>
                    <div class="number">{FormatPhone(MyAd.Phone)}</div>
                </div>
            </div>
        {/if}

        {#each FilteredAds.slice(0, ShowingLimit) as Data, Id}
            <div class="phone-yellowpages-post">
                <div class="phone-yellowpages-post-message">{Data.Msg}</div>
                <div class="phone-yellowpages-post-sender">
                    <div data-tooltip={Data.Sender} class="name">{Data.Sender}</div>
                    <div data-tooltip="Bellen" on:keyup on:click={() => { CallAdvertiser(Data.Phone) }} class="number">{FormatPhone(Data.Phone)}</div>
                </div>
            </div>
        {/each}

        {#if FilteredAds.length > ShowingLimit}
            <div style="display: flex; justify-content: center; width: 100%;">
                <Button Color="success" on:click={LoadMore}>Laad Meer</Button>
            </div>
        {/if}
    </PaperList>
</AppWrapper>

<style>
    .phone-yellowpages-my-ad {
        position: relative;
        overflow: hidden;
        margin-bottom: 1.3vh;
    }

    .phone-yellowpages-my-ad > span {
        position: relative;
        float: left;
        line-height: 2.5vh;
        font-size: 1.5vh;
    }

    .phone-yellowpages-post {
        background-color: #ffee5a;
        color: black;
        font-size: 1.33vh;
        font-family: "Roboto";
        font-weight: 400;
        line-height: 1.43;
        letter-spacing: 0.0019;
        margin-bottom: 1.5vh;
        padding: 0.6vh 0 0;
    }

    .phone-yellowpages-post > .phone-yellowpages-post-message {
        position: relative;
        text-align: center;
        margin-bottom: 0.7vh;
        word-break: keep-all;
        word-wrap: break-word;
        padding: 0 1vh;
    }

    .phone-yellowpages-post > .phone-yellowpages-post-sender {
        position: relative;
        display: flex;
        flex-direction: row;
        height: 2.5vh;
        border-top: 0.15vh solid black;
    }

    .phone-yellowpages-post > .phone-yellowpages-post-sender > div {
        position: relative;
        top: 50%;
        bottom: 0;
        transform: translateY(-50%);
        width: 50%;
        margin: 0;
        padding: 0;
        height: 1.6vh;
        line-height: 1.6vh;
        font-size: 1.2vh;
        text-align: center;
    }

    .phone-yellowpages-post
        > .phone-yellowpages-post-sender
        > div:first-of-type {
        border-right: 0.15vh solid black;
    }
</style>
