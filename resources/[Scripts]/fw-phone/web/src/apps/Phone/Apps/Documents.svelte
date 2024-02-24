<script>
    import BalloonEditor from '@ckeditor/ckeditor5-build-balloon';
    import TextField from "../../../components/TextField/TextField.svelte";
    import AppWrapper from "../components/AppWrapper.svelte";
    import PaperList from "../components/PaperList.svelte";

    import { CreateableDocumentTypes, DocumentTypes } from "../../../config";
    import { Delay, SendEvent, SetDropdown, ShowSuccessModal } from "../../../utils/Utils";
    import { PlayerData, CurrentDocument, LoaderModal, DocumentIsDrop } from "../phone.stores";
    import { onDestroy, onMount } from "svelte";

    import * as DOCS from "./_documents";
    import Button from '../../../components/Button/Button.svelte';
    import DocumentsSignature from './components/DocumentsSignature.svelte';

    const _SelectDocumentTypes = DocumentTypes.map((Text, Index) => ({ Value: Index, Text: Text }));

    let Documents = [];
    let FilteredDocuments = [];
    let CurrentDocumentType = 0;
    let ShowingSignatures = false;
    let CreatingDocument = false;
    let DocumentsEditor;

    const OpenDocument = async (Document) => {
        if ($CurrentDocument.id) {
            CloseDocument();
        };

        LoaderModal.set(true);
        CurrentDocument.set(Document);
        LoadDocumentEditor();
    };

    const CloseDocument = () => {
        CurrentDocument.set({});
        DocumentIsDrop.set(false);
        CreatingDocument = false;
        ShowingSignatures = false;
    };

    const LoadDocumentEditor = async () => {
        while (!DocumentsEditor) {
            await Delay(0.25)
        };

        BalloonEditor.create(DocumentsEditor, {
            supportAllValues: true,
            toolbar: {
                items: [ 'heading', '|', 'bold', 'italic', '|', 'blockQuote', '|', 'undo', 'redo', '|', 'numberedList', 'bulletedList', '|', 'insertTable' ],
                shouldNotGroupWhenFull: true,
            },
            placeholder: "Begin met typen...",
        }).then(Editor => {
            window.editor = Editor;
            LoaderModal.set(false);
            if ($CurrentDocument.content) {
                window.editor.setData($CurrentDocument.content);
            } else {
                window.editor.setData("");
            };

            if (!$CurrentDocument.Editing && !CreatingDocument) window.editor.enableReadOnlyMode("suck dick ok?");
        }).catch(Error => {
            console.error(Error);
            CloseDocument();
            LoaderModal.set(false);
        });
    };

    const FilterDocuments = (Value) => {
        const Query = Value.toLowerCase();
        FilteredDocuments = Documents.filter((Val) => {
            return Val.title.toLowerCase().includes(Query)
        });
    };

    const FetchDocuments = (_) => {
        SendEvent("Documents/GetDocuments", {Type: CurrentDocumentType}, (Success, Data) => {
            if (!Success) return;
            Documents = Data;
            FilteredDocuments = Data;
        });
    };

    const GetOptionsDropdown = () => {
        let Options = [];

        if ($CurrentDocument.type == 0) {
            Options.push({
                Icon: "qrcode",
                Text: "Drop QR Code",
                Cb: DOCS.DropQRCode,
            })
        };

        Options.push({
            Icon: "share-alt",
            Text: "Delen (Lokaal)",
            Cb: DOCS.SessionShareDocument,
        })

        Options.push({
            Icon: "share",
            Text: "Delen (Permanent)",
            Cb: DOCS.PermanentShareDocument,
        })

        if ($CurrentDocument.finalized) {
            Options.push({
                Icon: "pen-nib",
                Text: "Handtekeningen",
                Cb: () => {
                    ShowingSignatures = true;
                },
            })
        } else if ($CurrentDocument.type == 5 && !$CurrentDocument.finalized) {
            Options.push({
                Icon: "stamp",
                Text: "Afronden",
                Cb: DOCS.FinalizeDocument,
            })
        };

        if ($CurrentDocument.citizenid == $PlayerData.Cid) {
            Options.push({
                Icon: "trash",
                Text: "Verwijderen",
                Cb: DOCS.DeleteDocument,
            })
        }

        return Options;
    };

    const SaveDocument = () => {
        DOCS.EditMode(false);
        window.editor.enableReadOnlyMode("suck dick ok?");

        LoaderModal.set(true);
        SendEvent("Documents/SaveDocument", {
            Id: $CurrentDocument.id,
            Title: $CurrentDocument.title,
            Type: CurrentDocumentType,
            Content: window.editor.getData()
        }, (Success, Data) => {
            LoaderModal.set(false);
            if (!Success) return;

            if (CreatingDocument) {
                ShowSuccessModal();
                CurrentDocument.set({});
                CreatingDocument = false;
            };
        });
    };

    onMount(() => {
        FetchDocuments();
        if ($CurrentDocument.id) LoadDocumentEditor();
    });

    onDestroy(() => {
        if (window.editor) window.editor.destroy();
        window.editor = null;
    });
</script>

<AppWrapper>
    {#if !$CurrentDocument.id && !CreatingDocument}
        {#if CreateableDocumentTypes.includes(CurrentDocumentType)}
            <div class="phone-misc-icons">
                <i
                    data-tooltip="Nieuw Document"
                    data-position="left"
                    class="fas fa-edit"
                    on:keyup
                    on:click={() => {
                        LoaderModal.set(true);
                        CreatingDocument = true;
                        LoadDocumentEditor();
                    }}
                />
            </div>
        {/if}

        <TextField
            Title="Zoeken"
            Icon="search"
            SubSet={FilterDocuments}
            class="phone-misc-input"
        />

        <TextField
            Title="Type"
            Select={_SelectDocumentTypes}
            SubSet={FetchDocuments}
            bind:Value={CurrentDocumentType}
            RealValue={DocumentTypes[0]}
            class="phone-misc-input"
            style="margin-top: 1.4vh;"
        />

        <PaperList style="top: 15.5vh; height: 40.5vh;">
            {#each FilteredDocuments as Data, Id}
                <div
                    class="phone-container-box-tiny"
                    on:keyup
                    on:click={() => { OpenDocument(Data) }}
                >
                    <p>{Data.title}</p>
                    <i class="fas fa-{Data.citizenid == $PlayerData.Cid && !Data.finalized ? "edit" : "eye"}"></i>
                </div>
            {/each}
        </PaperList>
    {:else if !ShowingSignatures}
        <div class="phone-misc-icons phone-misc-back">
            <i
                class="fas fa-chevron-left"
                on:keyup
                on:click={CloseDocument}
            />
        </div>

        <TextField
            Title="Titel"
            Icon="tags"
            bind:Value={$CurrentDocument.title}
            class="phone-misc-input phone-misc-input2"
            ReadOnly={!CreatingDocument && !$CurrentDocument.editing}
        />

        <div class="phone-misc-icons">
            {#if CreatingDocument}
                <i
                    data-tooltip="Opslaan"
                    data-position="left"
                    class="fas fa-cloud-upload"
                    on:keyup
                    on:click={SaveDocument}
                />
            {:else if !$DocumentIsDrop}
                {#if !$CurrentDocument.finalized}
                    {#if $CurrentDocument.citizenid == $PlayerData.Cid && !$CurrentDocument.editing}
                        <i
                            data-tooltip="Document Bewerken"
                            data-position="left"
                            class="fas fa-pencil"
                            on:keyup
                            on:click={(() => {
                                DOCS.EditMode(true)
                                window.editor.disableReadOnlyMode("suck dick ok?");
                            })}
                        />
                    {:else if $CurrentDocument.editing}
                        <i
                            data-tooltip="Opslaan"
                            data-position="left"
                            class="fas fa-cloud-upload"
                            on:keyup
                            on:click={SaveDocument}
                        />
                    {/if}
                {/if}

                <i
                    class="fas fa-ellipsis-v"
                    on:keyup
                    on:click={(event) => {
                        const IconPosition = event.target.getBoundingClientRect();
                        const Left = IconPosition.left;
                        const Top = IconPosition.bottom - 15;

                        console.log(GetOptionsDropdown());

                        SetDropdown(true, GetOptionsDropdown(), { Left, Top });
                    }}
                />
            {/if}
        </div>

        <div
            bind:this={DocumentsEditor}
            class="phone-document-editor"
        />
    {:else if ShowingSignatures}
        <div class="phone-misc-icons phone-misc-back">
            <i
                class="fas fa-chevron-left"
                on:keyup
                on:click={CloseDocument}
            />
        </div>

        <div class="phone-documents-signatures-buttons">
            {#if $CurrentDocument.signatures.some(Data => Data.Cid === $PlayerData.Cid && Data.Signed === false)}
                <Button on:click={DOCS.SignDocument} Color="success">Document Ondertekenen</Button>
            {/if}
            {#if $CurrentDocument.citizenid == $PlayerData.Cid}
                <Button on:click={DOCS.RequestSignature} Color="warning">Handtekening Aanvragen</Button>
            {/if}
        </div>

        <div class="phone-documents-signatures-list">
            <DocumentsSignature Index=1 {...$CurrentDocument.signatures[0]} />
            <DocumentsSignature Index=2 {...$CurrentDocument.signatures[1]} />
            <DocumentsSignature Index=3 {...$CurrentDocument.signatures[2]} />
            <DocumentsSignature Index=4 {...$CurrentDocument.signatures[3]} />
        </div>
    {/if}
</AppWrapper>

<style>
    .phone-container-box-tiny {
        display: flex;
        position: relative;
        cursor: pointer;
        justify-content: space-between;
        align-items: center;
        background-color: #30475e;
        height: max-content;
        padding: 0 1vh;
        font-size: 1.4vh;
        color: #e0e0e0;
        margin-bottom: 0.74vh;
        border-top-left-radius: 0.37vh;
        border-top-right-radius: 0.37vh;
        border-bottom: 0.15vh solid #c8c6ca
    }

    .phone-container-box-tiny > p {
        margin: 0;
        letter-spacing: -0.035vh;
        padding: 0.8vh 0;
    }

    .phone-document-editor {
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
        overflow-wrap: break-word;
    }

    :global(.phone-document-editor *) {
        user-select: text;
    }

    :global(.phone-document-editor ol) {
        padding: revert !important
    }

    :global(.phone-document-editor ul) {
        padding: revert !important
    }

    .phone-document-editor::-webkit-scrollbar {
        display: none
    }

    .phone-documents-signatures-buttons {
        display: flex;
        flex-direction: column;
        position: relative;
        top: 9vh;
        left: 0;
        right: 0;
        margin: 0 auto;
        height: max-content;
        width: max-content;
        align-items: center
    }

    .phone-documents-signatures-list {
        position: relative;
        left: 0;
        right: 0;
        margin: 0 auto;
        margin-top: 11.5vh;
        width: 89%;
        height: 33vh
    }

</style>