<script>
    import { OnEvent } from "../../utils/Utils";
    import AppWrapper from "../../components/AppWrapper.svelte";

    let Visible = false;
    let StreetName = 'Pillbox Hill - Alta Street';
    let CurrentPlate = 'GEEN KENTEKENPLAAT GESCAND!';

    OnEvent("Helicam", "SetVisibility", (Data) => {
        Visible = Data.Show
    });

    OnEvent("Helicam", "SetStreetName", (Data) => {
        StreetName = `${Data.Zone} - ${Data.Street}`
    });

    OnEvent("Helicam", "SetPlate", (Data) => {
        if (Data.Cancel) {
            CurrentPlate = 'GEEN KENTEKENPLAAT GESCAND!';
            return;
        };

        CurrentPlate = `Kenteken: ${Data.Plate}`;
    });
</script>

<AppWrapper AppName="Helicam" Focused={false}>
    {#if Visible}
        <div class="helicam-wrapper">
            <div class="helicam-streetname">{StreetName}</div>
            <div class="helicam-scan">{CurrentPlate}</div>
        </div>
    {/if}
</AppWrapper>

<style>
    .helicam-wrapper {
        position: absolute;
        top: 0;
        right: 0;
        
        width: 100vw;
        height: 100vh;
    }

    .helicam-streetname {
        position: absolute;
        top: 6.5vh;
        left: 0;
        right: 0;

        text-shadow: 0 0 0.1vh black;

        font-size: 2vh;
        font-family: 'Roboto';
        font-weight: bolder;

        color: white;
        text-align: center;
        
        width: max-content;
        margin: 0 auto;
    }

    .helicam-scan {
        position: absolute;
        bottom: 4vh;    
        left: 0;
        right: 0;

        text-shadow: 0 0 0.1vh black;

        font-size: 2vh;
        font-family: 'Roboto';
        font-weight: bolder;

        color: white;
        text-align: center;
        
        width: max-content;
        margin: 0 auto;
    }
</style>