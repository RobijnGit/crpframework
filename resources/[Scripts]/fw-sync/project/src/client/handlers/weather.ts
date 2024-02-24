import { Thread } from "../../shared/classes/thread";
import { WeatherTypes } from "../../shared/config";
import { Delay, exp } from "../../shared/utils";
import { FW } from "../client";

const SyncOverride = new Thread("tick", 1000);
let ServerTime: [number, number] = [10, 0];
let ServerWeather: string = "XMAS";
let ServerBlackout: boolean = false;
let ServerSnow: boolean = false;
let CurrentWeather: string = "";
let BlackoutActive: boolean = false;

onNet("fw-sync:Client:SetTime", (Time: [number, number]) => {
    ServerTime = Time;
    if (SyncOverride.running) return;
    NetworkOverrideClockTime(ServerTime[0], ServerTime[1], 0);
});

onNet("fw-sync:Client:SetWeather", (Weather: string) => {
    ServerWeather = Weather;
    if (SyncOverride.running) return;

    SetWeatherTypeOvertimePersist(ServerWeather, 15.0);
    CurrentWeather = ServerWeather;
});

onNet("fw-sync:Client:SetBlackout", (State: boolean) => {
    ServerBlackout = State;
    if (SyncOverride.running) return;

    SetArtificialLightsState(ServerBlackout);
    SetArtificialLightsStateAffectsVehicles(false);
    BlackoutActive = ServerBlackout;
});

onNet("fw-sync:Client:SetSnow", async (State: boolean) => {
    ServerSnow = State;
    if (SyncOverride.running) return;

    if (ServerSnow) {
        WaterOverrideSetStrength(1.0);
    } else {
        WaterOverrideSetStrength(0.0);
    };

    ForceSnowPass(ServerSnow);
    SetForceVehicleTrails(ServerSnow);
    SetForcePedFootstepsTracks(ServerSnow);
});

export default async () => {
    const { Time, Weather, Blackout, Snow } = await FW.SendCallback("fw-sync:Server:GetWeatherData")

    emit("fw-sync:Client:SetTime", Time);
    emit("fw-sync:Client:SetWeather", Weather);
    emit("fw-sync:Client:SetBlackout", Blackout);
    emit("fw-sync:Client:SetSnow", Snow);
    SetWind(0.5);

    SyncOverride.addHook("preStart", () => {
        NetworkClearClockTimeOverride();
    });

    SyncOverride.addHook("active", ({overrideData}) => {
        NetworkOverrideClockTime(overrideData.Time, 0, 0);

        if (CurrentWeather != overrideData.Weather) {
            SetWeatherTypeOvertimePersist(overrideData.Weather, 15.0);
            CurrentWeather = overrideData.Weather

            const isXMAS = overrideData.Weather == "XMAS";
            SetForceVehicleTrails(isXMAS);
            SetForcePedFootstepsTracks(isXMAS);
        };

        if (BlackoutActive != overrideData.Blackout) {
            SetArtificialLightsState(overrideData.Blackout);
            SetArtificialLightsStateAffectsVehicles(false);
            BlackoutActive = overrideData.Blackout;
        }
    });

    SyncOverride.addHook("afterStop", () => {
        NetworkOverrideClockTime(ServerTime[0], ServerTime[1], 0);

        if (CurrentWeather != ServerWeather) {
            SetWeatherTypeOvertimePersist(ServerWeather, 15.0);
            CurrentWeather = ServerWeather

            const isXMAS = ServerWeather == "XMAS";
            SetForceVehicleTrails(isXMAS);
            SetForcePedFootstepsTracks(isXMAS);
        };

        if (BlackoutActive != ServerBlackout) {
            SetArtificialLightsState(ServerBlackout);
            SetArtificialLightsStateAffectsVehicles(false);
            BlackoutActive = ServerBlackout;
        }
    });

    // SyncOverride.data.overrideData = { Time: 12, Weather: "SNOW" }
    // SyncOverride.start();
};

exp("GetWeatherTypes", () => {
    return WeatherTypes
});

exp("GetCurrentTime", () => {
    return { Hour: ServerTime[0], Minute: ServerTime[1] }
});

exp("GetCurrentWeather", () => {
    return ServerWeather
});

exp("SetClientSync", (State: boolean, Override: { Time: number, Weather: string }) => {
    if (!State) {
        SyncOverride.data.overrideData = Override;
        SyncOverride.start();
        return
    }

    SyncOverride.data.overrideData = false;
    SyncOverride.stop();
});

exp("BlackoutActive", () => BlackoutActive);
exp("SnowActive", () => ServerSnow);