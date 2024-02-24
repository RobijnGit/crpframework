<script>
    import { fade } from "svelte/transition";
    import { OnEvent } from "../../../utils/Utils";
    import { MyPreferences } from "../../Preferences/preferences.store.js";

    let Visible = false;
    let KMHSpeed = 0;
    let CarRPM = 0;
    let FuelLevel = 0;

    let ShowAltitude = 0;
    let Altitude = 0;

    let HasBelt = false;
    let BrokenEngine = false;

    OnEvent("Hud", "SetVehicleVisibility", (Data) => {
        Visible = Data.Visible;
    });

    OnEvent("Hud", "SetVehicleData", (Data) => {
        KMHSpeed = Data.Speed;
        CarRPM = Data.RPM;
        ShowAltitude = Data.ShowAltitude;
        Altitude = Data.Altitude;
        HasBelt = Data.HasBelt;
        BrokenEngine = Data.BrokenEngine;
        FuelLevel = Data.FuelLevel;
    });
</script>

{#if Visible && !$MyPreferences['BlackBars.Show']}
    <div class="hud-car-wrapper">
        <div class="hud-car hud-speed">
            <p><span>{KMHSpeed}</span><br>KMH</p>
            <svg viewBox="0 0 62 62" style="width: 100%;">
                <circle id="hud-speed__bgCircle" stroke="#9E9E9E" stroke-width="6" fill="transparent" r="27" cx="31" cy="31" stroke-dasharray="169.0" stroke-dashoffset="56.54"></circle>
                <circle id="hud-speed__circle" stroke="white" stroke-width="6" fill="transparent" r="27" cx="31" cy="31" stroke-dasharray="169.0" stroke-dashoffset={169 * (1.0 - (CarRPM / 100 * 56.54))} style="transition: stroke-dashoffset 400ms linear 0s; will-change: transition;"></circle>
            </svg>
        </div>

        <div class="hud-car hud-fuel">
            <i class="fas fa-gas-pump"></i>
            <svg viewBox="0 0 32 32" style="width: 100%;">
                <circle id="hud-fuel__bgCircle" stroke="#9E9E9E" stroke-width="3" fill="transparent" r="13.5" cx="16" cy="16" stroke-dasharray="123" stroke-dashoffset="66.72"></circle>
                <circle id="hud-fuel__circle" stroke="white" stroke-width="3" fill="transparent" r="13.5" cx="16" cy="16" stroke-dasharray="123" stroke-dashoffset={123 - (FuelLevel / 100 * 56)} style="transition: stroke-dashoffset 400ms linear 0s; will-change: transition;"></circle>
            </svg>
        </div>

        {#if ShowAltitude}
            <div class="hud-car hud-alt" style="width: 5.8vh;">
                <p><span>{Altitude}</span><br>ALT</p>
                <svg viewBox="0 0 50 50" style="display: block; width: 100%;">
                    <circle id="hud-alt__bgCircle" stroke="#9E9E9E" stroke-width="4" fill="transparent" r="21" cx="25" cy="25" stroke-dasharray="169.0"  stroke-dashoffset="84.5"></circle>
                    <circle id="hud-alt__circle" stroke="white" stroke-width="4" fill="transparent" r="21" cx="25" cy="25" stroke-dasharray="169.0" stroke-dashoffset={169 * (13 - ((Altitude > 1300 && 1300 || Altitude) / 1300 / 100 * 50))} style="transition: stroke-dashoffset 400ms linear 0s; will-change: transition;"></circle>
                </svg>
            </div>
        {/if}

        {#if !HasBelt}
            <div in:fade={{duration: 250}} out:fade={{duration: 250}} class="hud-car hud-belt">
                <i class="fas fa-user-slash"></i>
            </div>
        {/if}

        {#if BrokenEngine}
            <div in:fade={{duration: 250}} out:fade={{duration: 250}} class="hud-car hud-broken">
                <i class="fas fa-oil-can"></i>
            </div>
        {/if}
    </div>

    {#if $MyPreferences['Vehicle.ShowMapOutline']}
        <div class="hud-car-border"></div>
    {/if}
{/if}

<style>
    .hud-car-wrapper {
        position: absolute;

        left: 29vh;
        bottom: 6vh;

        width: fit-content;
        height: fit-content;
    }

    .hud-car { float: left;}
    .hud-speed, .hud-alt {
        position: relative;

        width: 5.8vh;
        height: 5.8vh;
        
        margin-right: .7vw;
    }

    .hud-speed > svg { transform: rotate(120deg); }
    .hud-alt > svg { transform: rotate(150deg); }

    .hud-speed > p, .hud-alt > p {
        position: absolute;
        margin-top: 1.4vh;
        left: 47%;

        transform: translateX(-50%);

        font-size: 1vh;
        font-style: normal;
        font-family: Arial, Helvetica, sans-serif;
        font-weight: 600;
        font-variant: small-caps;

        color: white;
        line-height: 1.1;
        letter-spacing: 0;
        text-align: center;
        text-transform: none;
        text-decoration: none;

        text-shadow: rgb(55 71 79) -0.1vh 0.1vh 0, rgb(55 71 79) 0.1vh 0.1vh 0, rgb(55 71 79) 0.1vh -0.1vh 0, rgb(55 71 79) -0.1vh -0.1vh 0;
    }

    .hud-speed > p > span, .hud-alt > p > span {
        font-family: 'Arial Black' !important;
        font-size: 1.75vh;
    }

    .hud-fuel {
        position: absolute;
        top: 3.2vh;
        left: 4vh;

        width: 3vh;
        height: 3vh;
    }

    .hud-fuel > svg { transform: rotate(150deg); }

    .hud-fuel > i {
        position: absolute;
        top: 50%;
        left: 52%;

        transform: translate(-50%, -50%);

        color: white;

        font-size: 1vh;
    }

    .hud-belt,
    .hud-broken {
        margin-top: 2vh;
        margin-left: .3vh;
        margin-right: 1.5vh;
    }

    .hud-belt > i,
    .hud-broken > i {
        font-size: 2vh;
        color: rgb(216, 67, 21);
    }

    .hud-car-border {
        position: absolute;

        left: 1.5vw;
        bottom: 5.5vh;

        height: 15.5vh;
        width: 13.8vw;

        border-radius: .15vh;
        border: .3vh solid rgba(255, 255, 255, 0.7);
    }
</style>