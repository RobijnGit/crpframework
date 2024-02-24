<script>
    import Ripple from '@smui/ripple';

    import { HasVpn } from "../phone.stores";
    import { SendEvent } from "../../../utils/Utils";

    import TextField from "../../../components/TextField/TextField.svelte";
    import AppWrapper from "../components/AppWrapper.svelte";

    let TargetId;

    const SendPing = (Event, IsAnon) => {
        SendEvent("Pinger/SendPing", {
            IsAnon,
            Id: Number(TargetId),
        })
    };

    const SendAnonPing = () => {
        SendPing(undefined, true)
    };
</script>


<AppWrapper style="background: url('./images/pingerbg.png') 0% 0% / cover;">
    <div class="phone-ping-banner">🍆 eRPinger 🍑</div>

    <TextField Icon="id-card-alt" Title="BSN" bind:RealValue={TargetId} Type="number" style="width: 55%; margin: 3vh auto 0" />

    <div class="phone-ping-buttons">
        <div use:Ripple={{ surface: true, active: true }} class="phone-ping-buttons-item" on:keyup on:click={SendPing}>
            <i class="fas fa-map-pin" />
            <h6>Verstuur Ping</h6>
        </div>

        {#if $HasVpn}
            <div use:Ripple={{ surface: true, active: true }} class="phone-ping-buttons-item" on:keyup on:click={SendAnonPing}>
                <i class="fas fa-user-secret" />
                <h6>Anon Ping</h6>
            </div>
        {/if}
    </div>
</AppWrapper>

<style>
    .phone-ping-banner {
        position: relative;
        margin-top: 3vh;
        height: 5.2vh;
        width: 100%;
        line-height: 5.2vh;
        text-align: center;
        text-shadow: 0.15vh 0.15vh 0.2vh black;
        font-size: 2.3vh;
        background: linear-gradient(135deg, rgba(238, 167, 165, 1) 0%, rgba(124, 29, 80, 1) 100%)
    }

    .phone-ping-buttons {
        position: relative;
        left: 0;
        right: 0;
        margin: 0 auto;
        margin-top: 1.5vh;
        display: flex;
        flex-direction: column;
        flex: 1 1 0%;
        width: 87%;
        padding: 1.48vh 1.6vw;
        align-items: center;
        box-sizing: border-box
    }

    .phone-ping-buttons-item {
        display: flex;
        width: 100%;
        padding: 0.74vh 0.83vw;
        cursor: pointer;
        align-items: center;
        text-transform: uppercase;
        border-radius: 0.37vh;
        margin-bottom: 1.4vh;
        background-color: rgb(48, 71, 94)
    }

    .phone-ping-buttons-item i {
        display: inline-block;
        height: 2.8vh;
        width: 1.85vh;
        overflow: visible;
        vertical-align: -0.185vh;
        font-size: 2.96vh
    }

    .phone-ping-buttons-item h6 {
        width: 100%;
        margin: 0;
        font-size: 1.85vh;
        font-weight: 500;
        line-height: 1.6;
        text-align: center;
        word-break: break-word;
        letter-spacing: 0.00625vw
    }
</style>