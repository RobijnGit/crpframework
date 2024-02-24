<script>
    import { fade } from "svelte/transition";
    import { Iframes } from "./config";
    import { OnEvent, SetExitHandler } from "../../utils/Utils";
    import AppWrapper from "../../components/AppWrapper.svelte";

    let CurrentIframe = "default";
    let ShowIframe = false;

    SetExitHandler("", "Tablet/Close", () => ShowIframe, {});

    OnEvent("Tablet", "SetIframe", (Data) => {
        ShowIframe = true;
        CurrentIframe = Data.Iframe;
    });
    
    OnEvent("Tablet", "HideIframe", () => {
        ShowIframe = false;
        CurrentIframe = "default";
    });
</script>

<AppWrapper AppName="Tablet" Focused={ShowIframe}>
    {#if ShowIframe}
        <div
            class="tablet-wrapper"
            transition:fade={{duration: 250}}
        >
            <div class="tablet-bg"></div>
            <iframe src={Iframes[CurrentIframe]} title="" frameborder="0" class="tablet-iframe"></iframe>
            <img src="./images/tablet-frame.png" class="tablet-frame" alt=""/>
        </div>
    {/if}
</AppWrapper>

<style>
    .tablet-bg {
        position: absolute;
        top: 12.3vh; 
        left: 0; 
        right: 0; 
        margin: 0 auto; 
        width: 128vh;
        height: 75vh;
        background-color: black;
    }

    .tablet-iframe {
        position: absolute; 
        top: 12.3vh; 
        left: 0; 
        right: 0; 
        width: 128vh;
        height: 75vh;
        margin: 0 auto; 
    }

    .tablet-frame {
        position: absolute; 
        top: 5.5vh; 
        left: 0; 
        right: 0; 
        margin: 0 auto; 
        pointer-events: none; 
        width: 142.22vh;
        height: 89vh;
    }
</style>