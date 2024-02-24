<script lang="ts">
    import { OnEvent } from "../../utils/Utils";
    import AppWrapper from "../../components/AppWrapper.svelte";

    let ShowDeathText: boolean = false;
    let DeathText: string = 'HOUDT ~r~E~w~ (5) INGEDRUKT OM TE ~r~RESPAWNEN~w~ OF WACHT OP ~r~EMS~w~'.replaceAll('~r~', "<span style='color: red'>").replaceAll("~w~", "</span>");

    OnEvent("DeathText", "Set", (Data: { Visible: boolean, Text?: string }) => {
        ShowDeathText = Data.Visible;
        DeathText = Data.Text.replaceAll('~r~', "<span style='color: #df3232'>").replaceAll("~w~", "</span>");
    });
</script>

<AppWrapper AppName="DeathText" Focused={false}>
    {#if ShowDeathText}
        <p class="death-text">{@html DeathText}</p>
    {/if}
</AppWrapper>

<style>
    .death-text {
        position: absolute;
        left: 50%;
        bottom: 3vh;

        transform: translateX(-50%);

        font-family: ChaletLondon;
        font-size: 2.5vh;
        font-weight: 600;
        color: #e8e8e8;

        -webkit-font-smoothing: antialiased;
        text-shadow: #000 0 0 .2vh,   #000 0 0 .2vh,   #000 0 0 .2vh,
                     #000 0 0 .2vh,   #000 0 0 .2vh,   #000 0 0 .2vh,
                     #000 0 0 .2vh,   #000 0 0 .2vh,   #000 0 0 .2vh,
                     #000 0 0 .2vh,   #000 0 0 .2vh,   #000 0 0 .2vh,
                     #000 0 0 .2vh,   #000 0 0 .2vh,   #000 0 0 .2vh;

        margin: 0 auto;
    }
</style>
