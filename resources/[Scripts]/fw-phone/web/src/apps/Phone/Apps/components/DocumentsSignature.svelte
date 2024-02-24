<script>
    import { GetLongTimeLabel, GetTimeLabel } from "../../../../utils/Utils";

    export let Index = 1;
    export let Name = 'Niet Ondertekend';
    export let Signed = false;
    export let Timestamp = 0;
</script>

<div class="phone-signature-box">
    <div class="phone-signature-box-number">{Index}</div>
    <div class="phone-signature-box-details">
        <p>{Name}</p>
        {#if Signed}
            <p data-tooltip={GetLongTimeLabel(Timestamp)} data-position="bottom">{GetTimeLabel(Timestamp)}</p>
        {:else if Timestamp && !Signed}
            <p>Aangevraagd</p>
        {/if}
    </div>
</div>

<style>
    .phone-signature-box {
        position: relative;
        display: flex;
        padding-bottom: .6vh;
        border-bottom: 0.15vh solid white;
        margin-bottom: 2.4vh
    }

    .phone-signature-box > .phone-signature-box-number {
        width: 5.5vh;
        height: 5.5vh;
        border-radius: 50%;
        background-color: #30475e;
        text-align: center;
        line-height: 5.5vh;
        font-family: 'Roboto';
        font-weight: bolder;
        font-size: 2vh;
        margin-right: 1.7vh
    }

    .phone-signature-box > .phone-signature-box-details {
        position: relative;
        top: 0;
        bottom: 0;
        margin: auto 0;
        width: 65%;
        height: max-content;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        font-style: italic;
        text-transform: capitalize
    }

    .phone-signature-box > .phone-signature-box-details>p {
        margin: 0;
        font-size: 1.5vh;
        font-family: "Roboto";
        font-weight: 400;
        line-height: 1.43;
        letter-spacing: 0.005vh;
        width: max-content
    }
</style>