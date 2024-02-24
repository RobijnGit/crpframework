<script>
    import { OnEvent, SendEvent as _SendEvent, SetExitHandler } from "../../utils/Utils";
    import AppWrapper from "../../components/AppWrapper.svelte";

    const SendEvent = (Event, Parameters, Callback) => {
        _SendEvent(Event, Parameters, Callback, "fw-radio")
    }

    let AppVisible = false;
    let IsRadioOn = false;
    let RadioChannel = 1;

    OnEvent("Radio", "SetVisibility", (Data) => {
        AppVisible = Data.Visible;
        RadioChannel = Data.Channel;
    });

    const ToggleRadio = () => {
        IsRadioOn = !IsRadioOn;
        SendEvent("Radio/Toggle", {Channel: RadioChannel, State: IsRadioOn})
    };

    const ChannelOnKeyup = (Event) => {
        switch (Event.key) {
            case "Enter":
                ConnectToFrequency();
                break;
        }
    };

    const ConnectToFrequency = () => {
        SendEvent("Radio/Connect", {RadioChannel: Number(RadioChannel).toFixed(2)})
    };

    const Disconnect = () => {
        SendEvent("Radio/Disconnect", {})
    };

    SetExitHandler("", "Radio/Close", () => AppVisible, {__resource: "fw-radio"})
</script>

<AppWrapper AppName="Radio" Focused={AppVisible}>
    <div class="radio-wrapper" class:in={AppVisible}>
        <img src="./images/radio.png" alt="" />
    
        <div
            data-tooltip="Aan- / Uitschakelen"
            class="radio-toggle"
            on:keyup on:click={ToggleRadio}
        />
    
        <div
            data-tooltip="Verbinden"
            class="radio-connect"
            on:keyup on:click={ConnectToFrequency}
        />
    
        <div
            data-tooltip="Loskoppelen"
            class="radio-disconnect"
            on:keyup on:click={Disconnect}
        />
    
        <div class="radio-channel">
            {#if IsRadioOn}
                <input
                    bind:value={RadioChannel}
                    placeholder="100-999"
                    min="1"
                    max="999"
                    disabled={!AppVisible || !IsRadioOn}
                    on:keyup={ChannelOnKeyup}
                />
            {:else}
                <input
                    value="Uit"
                    disabled={!IsRadioOn}
                />
            {/if}
        </div>
    </div>
</AppWrapper>

<style>
    .radio-wrapper {
        position: absolute;
        bottom: -60vh;
        right: 2vh;

        width: auto;
        height: 60vh;

        transition: bottom ease 500ms;
    }

    .radio-wrapper.in {
        bottom: 3vh;
    }

    .radio-wrapper > img {
        width: 100%;
        height: 100%;
    }

    .radio-channel {
        display: flex;
        justify-content: center;
        align-items: center;

        position: absolute;
        bottom: 12.8vh;
        right: 3vh;

        width: 7.7vh;
        height: 7.7vh;

        border-radius: 0.3vh;

        background-color: #222833;
    }

    .radio-channel > input {
        border: none;
        outline: none;

        width: 7.7vh;
        text-align: center;

        font-size: 2.5vh;

        background-color: transparent;
        color: rgb(220, 220, 220);
    }

    .radio-channel > input::placeholder {
        font-size: 1.8vh;
    }

    .radio-toggle {
        position: absolute;

        bottom: 23vh;
        right: 1.8vh;

        width: 4.5vh;
        height: 4.5vh;
    }

    .radio-connect {
        position: absolute;

        bottom: 9.5vh;
        right: 5.3vh;

        width: 3vh;
        height: 2.3vh;
    }

    .radio-disconnect {
        position: absolute;

        bottom: 5vh;
        right: 2.5vh;

        width: 3vh;
        height: 2.3vh;
    }
</style>
