import { Thread } from "../../shared/classes/thread";
import { WeatherTypes } from "../../shared/config";
import type { Weather } from "../../shared/types.d";
import { Delay, exp } from "../../shared/utils";
import { FW } from "../server";

let CurrentTime: [number, number] = [10, 0];
let CurrentWeather: Weather = 'OVERCAST';
let PastWeatherStages: string[] = [];
let BlackoutActive = false;
let SnowActive = false;
let IsStageActive = false;

// Clock
const ClockThread = new Thread("tick", 2700);
ClockThread.addHook('active', () => {
    if (CurrentTime[1] + 1 >= 60) {
        CurrentTime[1] = 0;
        CurrentTime[0]++;
    } else {
        CurrentTime[1]++;
    }

    if (CurrentTime[0] >= 24) CurrentTime[0] = 1;

    emitNet("fw-sync:Client:SetTime", -1, CurrentTime);
});

on("fw-sync:Server:SetWeatherTime", (Hours: number) => {
    CurrentTime = [Hours, 0];
    emitNet("fw-sync:Client:SetTime", -1, CurrentTime);
});

// Weather
// const Types: Weather[] = [ "EXTRASUNNY" ,"CLEAR", "CLOUDS" ]
// const WeatherStages: {Id: string, Stages: Weather[], Timers: number[]}[] = [
//     { Id: "Default", Stages: [ "EXTRASUNNY" ], Timers: [ 45 ] },
//     { Id: "Foggy", Stages: [ "OVERCAST", "FOGGY" ], Timers: [ 8, 13 ] },
//     { Id: "Rain", Stages: [ "CLEARING", "RAIN", "CLEARING" ], Timers: [ 3, 15, 5 ] },
//     { Id: "Thunder", Stages: [ "CLEARING", "RAIN", "THUNDER", "RAIN", "CLEARING" ], Timers: [ 3, 5, 12, 3, 2 ] },
//     // { Id: "Snow", Stages: [ "XMAS" ], Timers: [ 25 ] },
// ];

// const WeatherThread = new Thread("tick", (1000 * 60) * 5);
// WeatherThread.addHook("active", async () => {
//     if (IsStageActive) return;

//     let NewWeatherId: false | string = false;
//     if (Math.random() <= 0.015) NewWeatherId = "Snow";

//     const _WeatherStages = WeatherStages.filter(Val => Val.Id != "Snow" && !PastWeatherStages.includes(Val.Id));
//     if (!NewWeatherId && (Math.random() < 0.6 || WeatherStages.length == 0)) {
//         const RandomWeather = Types[Math.floor(Math.random() * Types.length)];
//         PastWeatherStages = [...PastWeatherStages.slice(-5), RandomWeather]
//         CurrentWeather = RandomWeather;

//         emitNet("fw-sync:Client:SetWeather", -1, CurrentWeather);
//         return;
//     };

//     NewWeatherId = NewWeatherId || _WeatherStages[Math.floor(Math.random() * _WeatherStages.length)].Id;
//     if (NewWeatherId == "Snow") console.info("Snow weather set!");

//     const WeatherData = WeatherStages.find(Val => Val.Id == NewWeatherId)
//     if (!WeatherData) return;

//     IsStageActive = true;
//     if (NewWeatherId != "Default") PastWeatherStages = [...PastWeatherStages.slice(-5), NewWeatherId];

//     for (let i = 0; i < WeatherData.Stages.length; i++) {
//         CurrentWeather = WeatherData.Stages[i];
//         emitNet("fw-sync:Client:SetWeather", -1, CurrentWeather);
//         await Delay(WeatherData.Timers[i] * (1000 * 60));
//     };

//     IsStageActive = false;

//     setTimeout(() => {
//         PastWeatherStages = PastWeatherStages.filter(Val => Val != WeatherData.Id);
//     }, 60000 * 120);
// });

on("fw-sync:Server:SetCurrentWeather", (Weather: Weather) => {
    SnowActive = Weather.toLowerCase() == "xmas";
    CurrentWeather = SnowActive ? "OVERCAST" : Weather;
    emitNet("fw-sync:Client:SetWeather", -1, CurrentWeather);
    emitNet("fw-sync:Client:SetSnow", -1, SnowActive);
});

on("fw-sync:Server:SetBlackout", (State: boolean) => {
    BlackoutActive = !BlackoutActive;
    emitNet("fw-sync:Client:SetBlackout", -1, BlackoutActive);
    emitNet('chatMessage', -1, "LS Water & Elektriciteit", "warning", "De stroom in de stad is momenteel uitgevallen. We zijn bezig om het te herstellen!")

    setTimeout(() => {
        BlackoutActive = false;
        emitNet('chatMessage', -1, "LS Water & Elektriciteit", "warning", "De stroom in de stad is hersteld!")
        emitNet("fw-sync:Client:SetBlackout", -1, BlackoutActive);
    }, (60 * 1000) * 10);
});

export default () => {
    ClockThread.start();
    // WeatherThread.start();

    FW.Commands.Add("blackout", "Toggle blackout.", [], false, (Source: number, Args: Array<string>) => {
        BlackoutActive = !BlackoutActive;
        emitNet("fw-sync:Client:SetBlackout", -1, BlackoutActive);
    }, "admin");

    FW.Functions.CreateCallback("fw-sync:Server:GetWeatherData", (Source: number, Cb: Function) => {
        Cb({
            Time: CurrentTime,
            Weather: CurrentWeather,
            Blackout: BlackoutActive,
            Snow: SnowActive
        })
    });

    // set weather from server console
    RegisterCommand("+setWeather", (Source: number, Args: string[]) => {
        if (Source != 0) return;
        emit("fw-sync:Server:SetCurrentWeather", Args[0])
    }, true);
};

exp("GetCurrentTime", () => {
    return { Hour: CurrentTime[0], Minute: CurrentTime[1] }
});

exp("GetCurrentWeather", () => {
    return CurrentWeather
});