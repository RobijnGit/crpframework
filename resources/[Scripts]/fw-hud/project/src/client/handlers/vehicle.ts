import { Thread } from "../../shared/classes/thread";
import { Config } from "../../shared/config";
import { Delay, SendUIMessage, exp } from "../../shared/utils";
import { FW } from "../client";
import { StartCompass, StopCompass } from "./compass";
import { GetHudId, SetHudValue, SetHudVisibleState } from "./hud";

const VehicleThread = new Thread("tick", 60);
const IgnoreBeltClasses: number[] = [8, 13]
const IgnoreBeltModels: number[] = [ GetHashKey("polmotor") ];

let VehicleHudState: boolean = false;
let LastFuelWarning: number = 0;
let CurrentNitrousValue: number = 0;
let CurrentHarnessValue: number = 0;

VehicleThread.addHook('active', () => {
    const Vehicle = GetVehiclePedIsIn(PlayerPedId(), false);

    if (!GetIsVehicleEngineRunning(Vehicle) || IsPauseMenuActive() || exp['fw-police'].IsInHeliCam()) {
        if (VehicleHudState) {
            VehicleHudState = false;
            DisplayRadar(false);
            StopCompass();
            SendUIMessage("Hud", "SetVehicleVisibility", {Visible: false});

            if (exp['fw-police'].IsInHeliCam()) SetHudVisibleState(false);
        };
        return;
    };

    if (!VehicleHudState) {
        VehicleHudState = true;
        SendUIMessage("Hud", "SetVehicleVisibility", {Visible: true});
        StartCompass();
        DisplayRadar(!Config.MyPreferences['BlackBars.Show']);
        SetHudVisibleState(true);
    };

    const FuelLevel = exp['fw-vehicles'].GetVehicleMeta(Vehicle, "Fuel");
    if (FuelLevel > 0 && FuelLevel < 10 && LastFuelWarning - GetGameTimer() < 0) {
        LastFuelWarning = GetGameTimer() + 15000;
        WarnFuellevel();
    };

    const VehicleClass = GetVehicleClass(Vehicle);
    const HasBelt = (IgnoreBeltClasses.includes(VehicleClass) || IgnoreBeltModels.includes(GetEntityModel(Vehicle))) || exp['fw-vehicles'].GetBeltStatus();
    const SpeedValue = GetEntitySpeed(Vehicle);
    let RPM = GetVehicleCurrentRpm(Vehicle);
    if (RPM - 0.2 > 0.0) RPM = RPM - 0.2;

    SendUIMessage("Hud", "SetVehicleData", {
        Speed: Math.ceil(SpeedValue * 3.6),
        RPM: RPM,
        ShowAltitude: IsPedInAnyHeli(PlayerPedId()) || IsPedInAnyPlane(PlayerPedId()),
        Altitude: Math.floor(GetEntityHeightAboveGround(Vehicle) * 3.28084) - 4,
        HasBelt: HasBelt,
        BrokenEngine: GetVehicleEngineHealth(Vehicle) < 400.0,
        FuelLevel: exp['fw-vehicles'].GetVehicleMeta(Vehicle, 'Fuel'),
    });

    const NitrousPercentage = exp['fw-vehicles'].GetVehicleMeta(Vehicle, 'Nitrous');
    const HarnessPercentage = exp['fw-vehicles'].GetVehicleMeta(Vehicle, 'Harness');

    if (NitrousPercentage != CurrentNitrousValue) {
        CurrentNitrousValue = NitrousPercentage
        SetHudValue(GetHudId('Nitrous'), CurrentNitrousValue);
    };

    if (HarnessPercentage != CurrentHarnessValue) {
        CurrentHarnessValue = HarnessPercentage
        SetHudValue(GetHudId('Harness'), CurrentHarnessValue);
    };
});

const WarnFuellevel = async () => {
    FW.Functions.Notify('Benzine niveau laag..', 'error')
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", true); await Delay(200);
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", true); await Delay(200);
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", true);
};

onNet("baseevents:enteredVehicle", (Vehicle: number, SeatIndex: number, DisplayName: string, NetId: number) => {
    VehicleThread.start();
});

onNet("baseevents:leftVehicle", (Vehicle: number, SeatIndex: number, DisplayName: string, NetId: number) => {
    if (VehicleThread.running) VehicleThread.stop();

    CurrentNitrousValue = 0;
    CurrentHarnessValue = 0;
    VehicleHudState = false;
    DisplayRadar(false);
    StopCompass();
    SendUIMessage("Hud", "SetVehicleVisibility", {Visible: false});
});