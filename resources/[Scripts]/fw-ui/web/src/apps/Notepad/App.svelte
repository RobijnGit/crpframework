<script>
    import AppWrapper from "../../components/AppWrapper.svelte";
    import Button from "../../lib/Button/Button.svelte";
    import { OnEvent, SetExitHandler, SendEvent as _SendEvent } from "../../utils/Utils";

    const SendEvent = (Event, Parameters, Callback) => {
        _SendEvent(Event, Parameters, Callback, "fw-misc")
    };

    let Visible = false;
    let IsCreatingNotepad = false;
    let NotepadText = "";

    OnEvent("Notepad", "OpenNotepad", (Data) => {
        Visible = true;
        IsCreatingNotepad = Data.Writing;
        NotepadText = Data.Note || "";
    });

    OnEvent("Notepad", "CloseNotepad", (Data) => {
        Visible = false;
    });

    SetExitHandler("", "Notepad/Close", () => Visible, {__resource: "fw-misc"});

    const SaveNote = () => {
        if (NotepadText.trim().length == 0) return;

        SendEvent("Notepad/Save", {
            Text: NotepadText
        });
    };
</script>

<AppWrapper AppName="Notepad" Focused={Visible}>
    {#if Visible}
        <div class="notepad-wrapper">
            <div class="notepad-container">
                {#if IsCreatingNotepad}
                    <div class="notepad-buttons">
                        <Button
                            Color={NotepadText.trim().length > 0 ? "success" : "disabled"}
                            on:click={() => SaveNote()}
                        >Opslaan</Button>
                    </div>
                {/if}

                <div class="notepad-letter">
                    <textarea bind:value={NotepadText} disabled={!IsCreatingNotepad} />
                </div>
            </div>
        </div>
    {/if}
</AppWrapper>

<style>
    .notepad-wrapper {
        width: 100vw;
        height: 100vh;

        display: flex;
        justify-content: center;
        align-items: center;
    }

    .notepad-container {
        width: 89vh;
        height: max-content;
    }

    .notepad-buttons {
        display: flex;
        align-items: center;
        padding: 0 2vh;

        height: 4.5vh;
        width: calc(100% - 4vh);

        background-color: rgb(34, 40, 49);
    }

    .notepad-letter {
        display: flex;
        justify-content: center;

        width: 100%;
        height: 35vh;

        background-image: url(../images/notepad.png);
    }

    .notepad-letter > textarea {
        background: transparent;
        border: none;
        outline: none;

        width: 85%;
        height: 90%;

        margin-top: 1vh;
        line-height: 4.5vh;

        font-size: 2vh;
        font-family: 'Roboto';
        resize: none;
    }

    .notepad-letter > textarea::-webkit-scrollbar {
        display: none;
    }
</style>