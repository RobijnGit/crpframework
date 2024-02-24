<script>
    import { onMount } from "svelte";

    export let Title = "No Title";
    export let Placeholder = "";
    export let MaxLength = 255;
    export let Value = "";
    export let Rows = 1;

    let TextArea;
    let Focused = false;

    function updateTextareaHeight(event) {
        Value = TextArea.value;
        TextArea.style.height = "auto"; // reset the height to auto to avoid a scrollbar
        TextArea.style.height = TextArea.scrollHeight + 10 + "px"; // set the height to the scroll height
    }

    onMount(() => {
        TextArea.style.height = TextArea.scrollHeight + 10 + 'px';
    });
</script>

<div class="textarea-component-container">
    <p>{Title}</p>
    <textarea
        bind:this={TextArea}
        on:focusin={() => {
            Focused = true;
        }}
        on:focusout={() => {
            Focused = false;
        }}
        on:input={updateTextareaHeight}
        rows={Rows}
        placeholder={Placeholder}
        maxlength={MaxLength}>{Value}</textarea
    >

    <div class="textarea-underline" style="height: 0.1vh">
        <div
            class="textarea-underline-fill"
            style="width: {Focused ? 100 : 0}%"
        />
    </div>

    <p class="subtext">{Value.length}/{MaxLength}</p>
</div>

<style>
    .textarea-component-container {
        position: relative;
        width: 100%;
        height: max-content;
        margin-bottom: 1.25vh;
        color: rgb(200, 200, 200);
        font-family: "Roboto";
        font-size: 1.2vh;
        font-weight: 500;
    }

    .textarea-component-container > p {
        margin: 0;
        font-size: 1.2vh;
        width: 100%;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .textarea-component-container > p.subtext {
        font-size: 1.1vh;
        margin-top: 0.5vh;
        opacity: 0.8;
        width: 100%;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .textarea-component-container > textarea {
        margin: 0;
        border: none;
        outline: none;
        background-color: transparent;
        font-family: "Roboto";
        font-size: 1.5vh;
        color: rgba(200, 200, 200);
        margin-top: 0.3vh;
        resize: none;
        width: 100%;
    }

    .textarea-component-container > .textarea-underline {
        position: absolute;
        width: 100%;
        height: 0.1vh;
        background-color: rgb(180, 180, 180);
    }

    .textarea-component-container > .textarea-underline > .textarea-underline-fill {
        position: absolute;
        left: 50%;
        transform: translateX(-50%);

        height: 0.2vh;
        width: 100%;
        transition: width ease 250ms;

        background-color: white;
    }

    .textarea-component-container > textarea::-webkit-scrollbar {
        display: none;
    }
</style>
