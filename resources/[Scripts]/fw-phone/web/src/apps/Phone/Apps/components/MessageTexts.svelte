<script>
    import { GetLongTimeLabel, GetTimeLabel } from "../../../../utils/Utils";
    import ImageContainer from "../../components/ImageContainer.svelte";
    import { IsMessageSender } from "../_messages";
    export let Texts = [];
</script>

<div {...$$restProps} class="phone-messages-texts {$$restProps?.class}">
    {#each Texts as Data, Key}
        <div class="phone-messages-text" class:text-out={IsMessageSender(Data)}>
            {#if Data.Message != ''}
                <div class="inner" class:text-out={IsMessageSender(Data)}>
                    <p>{Data.Message}</p>
                </div>
            {/if}

            {#if Data.Attachments.length > 0}
                <ImageContainer Attachments={Data.Attachments} />
            {/if}

            <div data-tooltip={GetLongTimeLabel(Data.Timestamp)} class="timestamp">
                {#if Data.TimestampLabel}
                    <p>{Data.TimestampLabel} - {GetTimeLabel(Data.Timestamp)}</p>
                {:else}
                    <p>{GetTimeLabel(Data.Timestamp)}</p>
                {/if}
            </div>
        </div>
    {/each}
</div>

<style>
    .phone-messages-texts {
        position: absolute;
        left: 0;
        right: 0;
        top: 13vh;
        margin: 0 auto;
        width: 89%;
        height: 38vh;
        overflow: hidden;
        overflow-y: auto;
        display: flex;
        flex-direction: column-reverse
    }

    .phone-messages-texts::-webkit-scrollbar {
        display: none
    }

    .phone-messages-texts > .phone-messages-text {
        width: 100%;
        display: flex;
        flex-direction: column;
        align-items: flex-start
    }

    .phone-messages-texts > .phone-messages-text.text-out {
        align-items: flex-end
    }

    .phone-messages-texts > .phone-messages-text > .timestamp {
        display: flex;
        margin-top: 0.18vh;
        padding: 0 0.2vh
    }

    .phone-messages-texts > .phone-messages-text > .timestamp > p {
        color: #9e9e9e;
        text-align: right;
        font-size: 1.1vh;
        margin: 0
    }

    .phone-messages-texts > .phone-messages-text > .inner {
        width: max-content;
        max-width: 90%;
        border-radius: 1.1vh;
        padding: 0.7vh;
        margin: 2vh 0 0;
        background-color: #37474f
    }

    .phone-messages-texts > .phone-messages-text > .inner.text-out {
        background-color: #147efb;
        text-align: right
    }

    .phone-messages-texts > .phone-messages-text > .inner > p {
        font-size: 1.35vh;
        margin: 0.2vh;
        overflow-wrap: anywhere;
        user-select: text;
    }
</style>