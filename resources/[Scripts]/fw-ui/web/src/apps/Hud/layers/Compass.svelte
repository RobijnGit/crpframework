<script>
    import { OnEvent } from "../../../utils/Utils";
    import { MyPreferences } from "../../Preferences/preferences.store.js";

    var CompassVisible = false;
    var CompassArea = false;
    var CompassStreet = false;
    var CompassDirection = false;

    OnEvent("Hud", "SetCompassVisibility", (Data) => {
        CompassVisible = Data.Visible;
    });

    OnEvent("Hud", "SetCompassDirection", (Data) => {
        CompassArea = Data.Area;
        CompassStreet = Data.Street;
        CompassDirection = Data.Direction + 100;
    });
</script>

{#if CompassVisible && $MyPreferences["Compass.Show"] && !$MyPreferences['BlackBars.Show']}
    <div class="hud-compass-wrapper">
        <div class="hud-compass">
            <div class="hud-compass-inside">
                <div class="hud-compass-area"><p>{CompassArea}</p></div>
                <div
                    style="background-position-x: -{(100 * CompassDirection) / 1080}vh"
                    class="hud-compass-image"
                >
                    <img
                        src="./images/compass-marker.png"
                        alt=""
                        class="hud-compass-current"
                    />
                </div>
                <div class="hud-compass-street"><p>{CompassStreet}</p></div>
            </div>
        </div>
    </div>
{/if}

<style>
    .hud-compass-wrapper {
        position: absolute;
        display: flex;

        top: 0;
        left: 0;

        width: 100vw;
        height: 2.96vh;

        pointer-events: none;
        place-content: center;

        color: white;
    }

    .hud-compass {
        display: flex;

        width: 100vw;
        height: 2.96vh;

        justify-content: center;
    }

    .hud-compass-inside {
        display: flex;

        width: 100vw;
        height: 2.96vh;

        justify-content: center;
    }

    .hud-compass-area {
        display: flex;

        flex: 1 1 0%;
        justify-content: center;

        margin: 0 1.48vh;
        align-items: center;
        text-align: right;
    }

    .hud-compass-area > p {
        text-shadow: rgb(55, 71, 79) -0.1vh 0.1vh 0, rgb(55, 71, 79) 0.1vh 0.1vh 0, rgb(55, 71, 79) 0.1vh -0.1vh 0, rgb(55, 71, 79) -0.1vh -0.1vh 0;
        letter-spacing: 0;
        text-decoration: none;
        text-transform: none;

        font-family: Arial, Helvetica, sans-serif;
        font-weight: 600;
        font-style: normal;
        font-variant: small-caps;

        width: 100%;
    }

    .hud-compass-image {
        display: flex;
        position: relative;

        width: 9.375vw;

        overflow: hidden;
        background-image: url("./../images/compass.png");
        background-repeat: repeat;
        background-size: 18.75vw 2.96vh;

        justify-content: center;
    }

    .hud-compass-current {
        height: 1.11vh;
    }

    .hud-compass-street {
        display: flex;

        flex: 1 1 0%;
        justify-content: center;

        margin: 0 1.48vh;

        text-align: left;
        align-items: center;
    }

    .hud-compass-street > p {
        text-shadow: rgb(55, 71, 79) -0.1vh 0.1vh 0,
            rgb(55, 71, 79) 0.1vh 0.1vh 0, rgb(55, 71, 79) 0.1vh -0.1vh 0,
            rgb(55, 71, 79) -0.1vh -0.1vh 0;
        letter-spacing: 0;
        text-transform: none;

        font-family: Arial, Helvetica, sans-serif;
        font-weight: 600;
        text-decoration: none;
        font-style: normal;
        font-variant: small-caps;

        width: 100%;
    }
</style>
