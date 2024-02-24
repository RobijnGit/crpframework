<script>
    import "../components/Misc.css";
    import BalloonEditor from '@ckeditor/ckeditor5-build-balloon';
    import { onDestroy, onMount } from "svelte";
    import { CurrentArticle, LoaderModal } from "../phone.stores";
    import { Delay, GetTimeLabel, IsEnvBrowser, SendEvent, ShowSuccessModal } from "../../../utils/Utils";
    
    import ImageHover from '../components/ImageHover.svelte';
    import Button from "../../../components/Button/Button.svelte";

    import TextField from "../../../components/TextField/TextField.svelte";
    import AppWrapper from "../components/AppWrapper.svelte";
    import PaperList from "../components/PaperList.svelte";
    import Empty from "../components/Empty.svelte";

    export let NewsNetwork = "weazelnews";

    let IsJournalist = IsEnvBrowser();
    let Articles = [];
    let FilteredArticles = [];
    let ArticleEditor;
    let CurrentImageIndex = 0;
    let WritingArticle = false;
    let EditingAttachments = false;
    let NewAttachmentUrl;
    let ShowingLimit = 100;

    const FilterArticles = (Query) => {
        Query = Query.toLowerCase();
        FilteredArticles = Articles.filter(
            (Val) =>
                Val.title.toLowerCase().includes(Query) ||
                Val.author.toLowerCase().includes(Query)
        );
    };

    const LoadMore = () => {
        ShowingLimit = ShowingLimit + 100;
    };

    const AddArticle = async () => {
        LoaderModal.set(true);
        WritingArticle = true;
        CurrentArticle.set({
            id: false,
            title: "",
            content: "",
            images: [],
            Editing: true,
        });

        while (!ArticleEditor) {
            await Delay(0.25)
        };

        LoadArticleEditor();
    };

    const LoadArticleEditor = () => {
        BalloonEditor.create(ArticleEditor, {
            supportAllValues: true,
            toolbar: {
                items: [ 'heading', '|', 'bold', 'italic', '|', 'blockQuote', '|', 'undo', 'redo', '|', 'numberedList', 'bulletedList', '|', 'insertTable' ],
                shouldNotGroupWhenFull: true,
            },
            placeholder: "Begin met typen...",
        }).then(Editor => {
            window.editor = Editor;
            LoaderModal.set(false);
            if ($CurrentArticle.content) {
                window.editor.setData($CurrentArticle.content);
            } else {
                window.editor.setData("");
            };

            if (!$CurrentArticle.Editing) window.editor.enableReadOnlyMode("suck dick ok?");
        }).catch(Error => {
            console.error(Error);
            CloseArticle();
            LoaderModal.set(false);
        });
    }

    const OpenArticle = async (Data) => {
        CurrentImageIndex = 0;
        LoaderModal.set(true);
        Data.Editing = false;
        CurrentArticle.set(Data);

        while (!ArticleEditor) {
            await Delay(0.25)
        };

        LoadArticleEditor();
    };

    const CloseArticle = () => {
        if (window.editor) window.editor.destroy();
        window.editor = null;
        CurrentArticle.set({});
        WritingArticle = false;
    };

    const DeleteArticle = () => {
        LoaderModal.set(true);
        SendEvent("News/DeleteArticle", {
            id: $CurrentArticle.id
        }, () => {
            CurrentArticle.set({});
            LoaderModal.set(false);

            SendEvent("News/GetArticles", {Network: NewsNetwork}, (Success, Data) => {
                if (!Success) return;
                Articles = Data;
                FilteredArticles = Data;
            });
        })
    };

    const ToggleAttachments = () => {
        EditingAttachments = !EditingAttachments;
    };

    const SaveArticle = () => {
        LoaderModal.set(true);
        SendEvent("News/SaveArticle", {
            Network: NewsNetwork,
            Id: $CurrentArticle.id,
            Content: window.editor.getData(),
            Title: $CurrentArticle.title,
            Images: $CurrentArticle.images,
        }, (Success, Data) => {
            LoaderModal.set(false);
            if (!Success) return;

            Articles = Data;
            FilteredArticles = Data;

            ShowSuccessModal();

            let Article = Articles.filter(Val => Val.id == $CurrentArticle.id)[0];
            CloseArticle();
            if (Article) OpenArticle(Article);
        })
    };

    onDestroy(() => {
        if (window.editor) window.editor.destroy();
        window.editor = null;
        CurrentArticle.set({});
    });

    onMount(() => {
        SendEvent("News/IsJournalist", {Network: NewsNetwork}, (Success, Data) => {
            if (!Success) return;
            IsJournalist = Data;
        });

        SendEvent("News/GetArticles", {Network: NewsNetwork}, (Success, Data) => {
            if (!Success) return;
            Articles = Data;
            FilteredArticles = Data;
        });
    });
</script>

{#if EditingAttachments}
    <div class="phone-news-images">
        <div class="phone-news-images-container">
            <TextField Title="Foto URL (.png/.jpg/.jpeg/.gif)" Icon="file-image" bind:Value={NewAttachmentUrl} />
            <div class="phone-news-images-buttons">
                <Button Color="success" on:click={() => {
                    $CurrentArticle.images = [...$CurrentArticle.images, NewAttachmentUrl];
                }}>Toevoegen</Button>
            </div>
            <hr style="margin: 1vh 0px;">
            
            {#each $CurrentArticle.images as Data, Id}
                <TextField Title="Foto URL (.png/.jpg/.jpeg/.gif)" bind:Value={$CurrentArticle.images[Id]} />
                <div class="phone-news-images-buttons">
                    <Button Color="warning" on:click={() => {
                        $CurrentArticle.images = $CurrentArticle.images.filter((Data, Index) => Index !== Id);
                    }}>Verwijderen</Button>
                </div>
                <hr style="margin: 1vh 0px;">
            {/each}
            <div style="width: 100%; display: flex; justify-content: center;">
                <Button Color="warning" on:click={ToggleAttachments}>Sluiten</Button>
            </div>
        </div>
    </div>
{/if}

<AppWrapper>
    {#if !$CurrentArticle.id && !WritingArticle}
        {#if IsJournalist}
            <div class="phone-misc-icons">
                <i
                    data-tooltip="Artikel Schrijven"
                    data-position="left"
                    class="fas fa-edit"
                    on:keyup
                    on:click={AddArticle}
                />
            </div>
        {/if}

        <TextField
            Title="Zoeken"
            Icon="search"
            SubSet={FilterArticles}
            class="phone-misc-input"
        />

        <PaperList>
            {#if Articles.length == 0}
                <Empty />
            {/if}

            {#each FilteredArticles.slice(0, ShowingLimit) as Data, Id}
                <div
                    class="phone-container-news"
                    on:keyup
                    on:click={() => { OpenArticle(Data) }}
                >
                    {#if Data.images && Data.images.length > 0}
                        <img
                            alt=""
                            src={Data.images[0]}
                            style="width: 100%; height: auto; margin-bottom: 0.6vh;"
                        />
                    {/if}
                    <p style="width: 100%; margin-bottom: 0.5vh;">
                        {Data.title}
                    </p>
                    <div
                        style="width: 100%; display: flex; justify-content: right;"
                    >
                        <p style="text-align: right;">
                            {Data.author} - {GetTimeLabel(Data.timestamp)}
                        </p>
                    </div>
                </div>
            {/each}

            {#if FilteredArticles.length > 5}
                <div
                    style="display: flex; justify-content: center; width: 100%;"
                >
                    <Button Color="success" on:click={LoadMore}
                        >Laad Meer</Button
                    >
                </div>
            {/if}
        </PaperList>
    {:else if $CurrentArticle.id || WritingArticle}
        {#if $CurrentArticle.id || IsJournalist}
            <div class="phone-misc-icons phone-misc-back">
                <i class="fas fa-chevron-left" on:keyup on:click={CloseArticle} />
            </div>

            <TextField
                Title="Titel"
                Icon="tags"
                class="phone-misc-input phone-misc-input2"
                bind:RealValue={$CurrentArticle.title}
            />

            {#if IsJournalist}
                <div class="phone-misc-icons">
                    {#if !$CurrentArticle.Editing}
                        <i
                            data-tooltip="Artikel Bewerken"
                            data-position="left"
                            class="fas fa-pencil-alt"
                            on:keyup
                            on:click={() => {
                                $CurrentArticle.Editing = !$CurrentArticle.Editing
                                if (window.editor) window.editor.destroy();
                                LoadArticleEditor();
                            }}
                        />
                        {#if $CurrentArticle.id}
                            <i
                                data-tooltip="Verwijderen"
                                data-position="left"
                                class="fas fa-trash"
                                on:keyup
                                on:click={DeleteArticle}
                            />
                        {/if}
                    {:else}
                        <i
                            data-tooltip="Fotos"
                            data-position="left"
                            class="fas fa-file-image"
                            on:keyup
                            on:click={ToggleAttachments}
                        />
                        <i
                            data-tooltip="Opslaan"
                            data-position="left"
                            class="fas fa-cloud-upload"
                            on:keyup
                            on:click={SaveArticle}
                        />
                    {/if}
                </div>
            {/if}

            {#if $CurrentArticle.images.length > 0 && !$CurrentArticle.Editing}
                <div class="phone-news-article-carousel">
                    <ImageHover Url={$CurrentArticle.images[CurrentImageIndex]} class="phone-news-article-carousel-current" />
                    <div class="phone-news-article-carousel-buttons">
                        {#each $CurrentArticle.images as Data, Id}
                            <div
                                style="flex-shrink: 0; border-radius: 50%; margin: 0px 0.5vh; width: 1.2vh; height: 1.2vh; background-color: white; opacity: {CurrentImageIndex == Id ? 1.0 : 0.5}"
                                on:keyup
                                on:click={() => {
                                    CurrentImageIndex = Id;
                                }}
                            />
                        {/each}
                    </div>
                </div>
            {/if}

            <div
                bind:this={ArticleEditor}
                class:phone-news-editor-compact={$CurrentArticle.images.length > 0 && !$CurrentArticle.Editing}
                class="phone-news-editor"
            />
        {/if}
    {/if}
</AppWrapper>

<style>
    .phone-news-images {
        position: absolute;
        width: 100%;
        height: 100%;
        z-index: 100;
        background-color: rgba(0, 0, 0, 0.5);
    }

    .phone-news-images-container {
        position: relative;
        top: 50%;
        left: 0;
        right: 0;
        transform: translateY(-50%);
        clear: both;
        overflow-y: auto;
        margin: 0 auto;
        width: 66%;
        height: max-content;
        max-height: 70%;
        padding: 1.5vh;
        background-color: #30475d;
    }

    .phone-news-images-container::-webkit-scrollbar {
        display: none;
    }

    .phone-news-images-container > .phone-news-images-buttons {
        height: 4vh;
        width: 100%;
    }

    .phone-container-news {
        display: flex;
        flex-direction: column;
        position: relative;
        cursor: pointer;
        justify-content: space-between;
        align-items: center;
        background-color: #30475e;
        height: max-content;
        min-height: 3.5vh;
        padding: 1vh 1vh 0.5vh 1vh;
        font-size: 1.4vh;
        color: #e0e0e0;
        margin-bottom: 0.74vh;
        border-top-left-radius: 0.37vh;
        border-top-right-radius: 0.37vh;
        border-bottom: 0.15vh solid #c8c6ca;
    }

    .phone-container-news > p {
        margin: 0;
        letter-spacing: -0.035vh;
    }

    .phone-news-article-carousel {
        position: absolute;
        top: 9vh;
        left: 0;
        right: 0;
        width: 95.8%;
        height: 20%;
        margin: 0 auto;
    }

    :global(.phone-news-article-carousel-current) {
        width: 100%;
        height: 90%;
        margin-bottom: 0.5vh;
        background-repeat: no-repeat;
        background-size: contain;
        background-position: center;
    }

    .phone-news-article-carousel-buttons {
        display: flex;
        width: max-content;
        max-width: 100%;
        position: relative;
        left: 0;
        right: 0;
        margin: 0 auto;
        overflow-x: auto;
    }

    .phone-news-article-carousel-buttons::-webkit-scrollbar {
        display: none;
    }

    .phone-news-editor.phone-news-editor-compact {
        height: 58% !important;
        top: 21.5vh !important;
    }

    .phone-news-editor {
        position: absolute;
        top: 9.7vh;
        left: 0;
        right: 0;
        margin: 0 auto;
        outline: none;
        border: none !important;
        box-shadow: none !important;
        font-size: 1.5vh;
        width: 89%;
        height: 46.5vh;
        color: white;
    }

    .phone-news-editor::-webkit-scrollbar {
        display: none;
    }
</style>
