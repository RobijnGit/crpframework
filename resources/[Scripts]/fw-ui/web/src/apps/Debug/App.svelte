<script>
    import { DebugData } from "../../utils/DebugData.js";

    var Visible = false;
    var App = '';
    var Action = '';
    var Message = '{}';

    var Presets = [
        // {
        //     Label: "Open Phone",
        //     Action: "OpenPhone",
        //     Payload: {}
        // }
    ]

    var SendDebugEvent = (Element) => {
        if (!Message || Message.length == 0) Message = "{}";

        DebugData([
            {
                app: App,
                action: Action,
                payload: JSON.parse(Message),
            }
        ], 5);
    };

    var SetVisible = () => {
        Visible = !Visible;
    };
</script>

{#if Visible}
    <i on:click={SetVisible} on:keyup class="fas fa-chevron-left debug-focus"></i>
    <div class="debug-wrapper">
        <input bind:value={App} type="text" placeholder="App" class="debug-event-action">
        <input bind:value={Action} type="text" placeholder="NUI Event" class="debug-event-action">
        <textarea bind:value={Message} placeholder="(VALID) JSON Message example: {'{"Visible":true}'}" class="debug-event-json" cols="30" rows="10"></textarea>
        <button on:click={SendDebugEvent}>Send</button>
        
        <h1 style="font-size: 3vh; font-family: Roboto; color: white; margin-top: 3vh; width: 100%; border-bottom: 0.2vh solid white; padding-bottom: 1vh;">Quick Actions</h1>
        {#each Presets as Data, Id}
            <button style="margin-top: 0.5vh;" on:click={() => {
                DebugData([
                    {
                        app: Data.App,
                        action: Data.Action,
                        payload: Data.Payload
                    }
                ], 5)
            }}>{Data.Label}</button>
        {/each}
    </div>
{:else}
    <i on:click={SetVisible} on:keyup class="fas fa-chevron-right debug-focus"></i>
{/if}


<style>
    .debug-wrapper {
        display: flex;
        flex-direction: column;
    
        position: absolute;
        top: 0vh;
        left: 3.4vh;
    
        z-index: 999;
    }
    
    .debug-focus {
        position: absolute;
        top: 0;
        left: 0;
        z-index: 999;

        width: 3.4vh;
        height: 3.4vh;
    
        text-align: center;
        line-height: 3.4vh;
    
        color: white;
    
        font-size: 1.2vh;
    
        background-color: rgba(0, 0, 0, 0.5);
    }
    
    .debug-wrapper .debug-event-action,
    .debug-wrapper .debug-event-json {
        background-color: #30475e;
        border: none;
        outline: none;
    
        width: 30vh;
    
        font-size: 2.0vh;
    
        color: white;
        padding: 1vh;
    
        resize: none;
    
        margin: 0;
        margin-bottom: 1vh;
    }
    
    .debug-wrapper .debug-event-action:focus,
    .debug-wrapper .debug-event-json:focus {
        border-bottom: 0.2vh solid #ff4081;
    }
    
    button {
        background-color: #30475e;
        color: #c8c6ca;
        border: 0;
        outline: 0;
        padding: 1vh;
        font-size: 2.2vh;
    }
    
    button:active {
        background-color: #222831;
    }
</style>