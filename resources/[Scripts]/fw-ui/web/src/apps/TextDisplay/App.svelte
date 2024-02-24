<script>
    import { OnEvent, SetExitHandler } from "../../utils/Utils";
    import AppWrapper from "../../components/AppWrapper.svelte";

    let DisplayText = '';
    let ShowingDisplay = false;

    OnEvent("TextDisplay", "SetDisplay", (Text) => {
        DisplayText = Text;
        ShowingDisplay = true;
    });

    OnEvent("TextDisplay", "HideDisplay", () => {
        ShowingDisplay = false;
    });

    SetExitHandler("", "TextDisplay/Close", () => ShowingDisplay, {})
</script>

<AppWrapper AppName="TextDisplay" Focused={ShowingDisplay}>
    {#if ShowingDisplay}
        <div class="password-container">
            <p>{DisplayText}</p>
        </div>
    {/if}
</AppWrapper>

<style>
    .password-container {
        position: absolute;
        top: 50%;
        left: 50%;

        transform: translate(-50%, -50%);

        width: fit-content;
        height: max-content;

        padding: 2vh;

        user-select: none;

        background-color: #232832;
    }

    .password-container > p {
        font-family: Roboto;
        font-size: 3vh;
        color: white;
        margin: 1vh;
    }
</style>