import { Vector3 } from "../shared/classes/math";
import { Thread } from "../shared/classes/thread";
import { Config } from "../shared/config";
import type { Race } from "../shared/types";
import { Delay } from "../shared/utils";
import { FW } from "./client";
import { PhasingThread, StartPhasing } from "./phasing";
import { AddCheckpointBlip, GetCheckpointPositions, HasHitCheckpoint, HasRacingUsb, IsGov } from "./utils";
export let CurrentRace: false | Race = false;

let StartTotalTime: number = 0;
let StartLapTime: number = 0;
let BestLapTime: number = Number.MAX_SAFE_INTEGER;
let AdditionalTotalTime: number = 0; // penalty time
let AdditionalLapTime: number = 0; // penalty time
let LastPositionRequest: number = 0;
let CurrentPosition = 1;
let CountdownActive = false;
let RaceStarted: boolean = false;
let CurrentCheckpoint: number = 0;
let CurrentLap: number = 0;
let Blips: Array<number> = [];
let Objects: Array<number> = [];
let IsDNFStarted: boolean = false;
let DidDNF: boolean = false;
let DNFEnd: number = 0;

onNet("fw-racing:Client:SetCurrentRace", (RaceData: Race) => {
    CurrentRace = RaceData;
    if (!CurrentRace) {
        emit("fw-racing:Client:EndRace");
        return;
    };

    for (let i = 0; i < CurrentRace.Checkpoints.length; i++) {
        const Checkpoint = CurrentRace.Checkpoints[i];
        const Blip = AddCheckpointBlip(Checkpoint, i, i == 0 || (CurrentRace.Type == "Sprint" && i == (CurrentRace.Checkpoints.length - 1)));
        Blips[i] = Blip;
    };
});

onNet("fw-racing:Client:StartRace", async () => {
    if (!CurrentRace) return;
    CountdownActive = true;

    for (let i = 0; i < Blips.length; i++) {
        RemoveBlip(Blips[i]);
    };
    Blips = [];

    let Countdown = CurrentRace.Settings.Countdown;

    StartLapTime = 0;
    BestLapTime = Number.MAX_SAFE_INTEGER;
    AdditionalTotalTime = 0;
    AdditionalLapTime = 0;
    CurrentCheckpoint = 0;
    CurrentLap = 1;
    RaceStarted = false;
    CurrentPosition = 1;
    IsDNFStarted = false;
    DidDNF = false;
    DNFEnd = 0;

    if (CurrentRace.Settings.FreezeStart) FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(), false), true);

    UpdateRaceObjects();
    FW.Functions.Notify(`Race start over ${Countdown} seconden!`, "primary", 1000);

    const StartTime = GetGameTimer() + (Countdown * 1000) - 3000;
    while (GetGameTimer() < StartTime) {
        if (!CountdownActive) return;
        await Delay(1);
    };

    global.exports['fw-ui'].SendUIMessage("Racing", "StartCountdown", {});
    PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", false);
    await Delay(1000);
    PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", false);
    await Delay(1000);
    PlaySoundFrontend(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", false);
    await Delay(1000);
    PlaySoundFrontend(-1, "Oneshot_Final", "MP_MISSION_COUNTDOWN_SOUNDSET", false);

    if (CurrentRace.Settings.FreezeStart) FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId(), false), false);

    RaceThread.start();
});

onNet("fw-racing:Client:EndRace", () => {
    CountdownActive = false;

    ClearRaceObjects();
    global.exports['fw-ui'].SendUIMessage("Racing", "StopTimer", "Current");
    global.exports['fw-ui'].SendUIMessage("Racing", "StopTimer", "Total");

    global.exports['fw-ui'].SendUIMessage("Racing", "SetDNF", {
        Active: false,
    });
    global.exports['fw-ui'].SendUIMessage("Racing", "SetHud", {
        Visible: false,
    });

    if (RaceThread.running) RaceThread.stop();
});

// Thread
const RaceThread = new Thread('tick', 1);

RaceThread.addHook('preStart', async () => {
    if (!CurrentRace) return RaceThread.stop();
    CurrentRace = await FW.SendCallback("fw-racing:Server:GetRaceData", CurrentRace.Id);

    RaceStarted = true;
    StartTotalTime = GetGameTimer();
    StartLapTime = GetGameTimer();

    StartPhasing();

    global.exports['fw-ui'].SendUIMessage("Racing", "StartTimer", "Current");
    global.exports['fw-ui'].SendUIMessage("Racing", "StartTimer", "Total");
    global.exports['fw-ui'].SendUIMessage("Racing", "SetDNF", {
        Active: false,
    });

    global.exports['fw-ui'].SendUIMessage("Racing", "SetBestLap", false);
    UpdateHud();
});

RaceThread.addHook('active', async () => {
    if (!CurrentRace) {
        console.log("RaceThread was started, but no active race was set!");
        RaceThread.stop();
        return;
    };

    if (!RaceStarted) return;
    if (!CurrentRace.Checkpoints[CurrentCheckpoint]) return;

    if (CurrentRace.Settings.ForceFPP) {
        DisableControlAction(0, 79, true)
        DisableControlAction(0, 0, true)
        if (GetFollowPedCamViewMode() != 0 || GetFollowVehicleCamViewMode() == 0) {
            SetFollowPedCamViewMode(4)
            SetFollowVehicleCamViewMode(4)
        } else {
            SetFollowPedCamViewMode(0)
            SetFollowVehicleCamViewMode(0)
        };
    };

    if (GetGameTimer() - LastPositionRequest > 1000) {
        LastPositionRequest = GetGameTimer();
        UpdateHudPosition();
    };

    if (IsDNFStarted && new Date().getTime() >= DNFEnd) {
        DidDNF = true;
        FW.TriggerServer("fw-racing:Server:Finished", CurrentRace.Id, BestLapTime, GetGameTimer() - StartTotalTime + AdditionalTotalTime, GetEntityModel(GetVehiclePedIsIn(PlayerPedId(), false)), true)
        RaceThread.stop();

        global.exports['fw-ui'].SendUIMessage("Racing", "SetDNF", {
            Active: false
        });
    };

    const Hit = HasHitCheckpoint(CurrentRace.Checkpoints[CurrentCheckpoint]);
    if (!Hit) return;

    if (CurrentCheckpoint + 1 == CurrentRace.Checkpoints.length) { // Finish
        const LapTime = GetGameTimer() - StartLapTime + AdditionalLapTime;
        if (LapTime < BestLapTime) {
            BestLapTime = LapTime;
            global.exports['fw-ui'].SendUIMessage("Racing", "SetBestLap", LapTime);
        };

        if (CurrentLap < CurrentRace.Laps) {
            CurrentCheckpoint = 0;
            CurrentLap++;
            StartLapTime = GetGameTimer();
            AdditionalLapTime = 0;
            global.exports['fw-ui'].SendUIMessage("Racing", "ResetTimer", "Current");
        } else {
            FW.TriggerServer("fw-racing:Server:Finished", CurrentRace.Id, BestLapTime, GetGameTimer() - StartTotalTime + AdditionalTotalTime, GetEntityModel(GetVehiclePedIsIn(PlayerPedId(), false)), false)
            RaceThread.stop();
            CurrentCheckpoint++;
        };
        PlaySoundFrontend(-1, "CHECKPOINT_MISSED", "HUD_MINI_GAME_SOUNDSET", false)
    } else {
        CurrentCheckpoint++;
    };

    FW.TriggerServer("fw-racing:Server:UpdatePosition", CurrentRace.Id, CurrentLap, CurrentCheckpoint);

    UpdateRaceObjects();
    UpdateHud();
});

RaceThread.addHook('afterStop', () => {
    if (PhasingThread.running) PhasingThread.stop();
    setTimeout(() => {
        UpdateHud();
        ClearRaceObjects();
        global.exports['fw-ui'].SendUIMessage("Racing", "StopTimer", "Current");
        global.exports['fw-ui'].SendUIMessage("Racing", "StopTimer", "Total");
    }, 10);
});

const UpdateRaceObjects = async () => {
    ClearRaceObjects();
    if (!CurrentRace || !CurrentRace.Checkpoints) return;

    StartGpsMultiRoute(142, true, false);

    for (let i = -1; i < Config.LookAheadCheckpoints; i++) {
        let CheckpointId = CurrentCheckpoint + i
        let RenderingNextLap = false;
        if (i >= 0 && !CurrentRace.Checkpoints[CheckpointId] && CurrentLap != CurrentRace.Laps) {
            CheckpointId = CheckpointId % CurrentRace.Checkpoints.length;
            RenderingNextLap = true;
        };

        const Checkpoint = CurrentRace.Checkpoints[CheckpointId];
        if (Checkpoint) {
            const [LeftPos, RightPos] = GetCheckpointPositions(new Vector3().setFromObject(Checkpoint.Pos), Checkpoint.Radius, new Vector3().setFromObject(Checkpoint.Rotation));

            if (i < Config.LookAheadCheckpoints - 1) {
                const Model = !RenderingNextLap && ((CheckpointId == 0 && CurrentLap == 1) || (CheckpointId == CurrentRace.Checkpoints.length - 1 && CurrentLap == CurrentRace.Laps)) ? "prop_beachflag_01" : "prop_offroad_tyres02";
                RequestModel(Model);
                while (!HasModelLoaded(Model)) {
                    await Delay(10);
                };

                const LeftObject = CreateObjectNoOffset(Model, LeftPos.x, LeftPos.y, LeftPos.z, false, false, false);
                const RightObject = CreateObjectNoOffset(Model, RightPos.x, RightPos.y, RightPos.z, false, false, false);

                PlaceObjectOnGroundProperly(LeftObject);
                PlaceObjectOnGroundProperly(RightObject);

                if (Config.DisableCurrentCheckpointCollision && i == -1) {
                    SetEntityCollision(LeftObject, false, false)
                    SetEntityCollision(LeftObject, false, false)
                };

                Objects.push(LeftObject);
                Objects.push(RightObject);
            };

            if (i >= 0) {
                let IsFinish = false;
                if (!RenderingNextLap && CheckpointId == 0 && CurrentLap == 1) IsFinish = true;
                if (!RenderingNextLap && CheckpointId == (CurrentRace.Checkpoints.length - 1) && CurrentLap == CurrentRace.Laps) IsFinish = true;

                const Blip = AddCheckpointBlip(Checkpoint, CheckpointId + 1, IsFinish);
                AddPointToGpsMultiRoute(Checkpoint.Pos.x, Checkpoint.Pos.y, Checkpoint.Pos.z);
                Blips.push(Blip);
            }
        };
    };

    SetGpsMultiRouteRender(true);
};

const ClearRaceObjects = () => {
    for (let i = 0; i < Blips.length; i++) {
        RemoveBlip(Blips[i]);
    };
    Blips = [];

    for (let i = 0; i < Objects.length; i++) {
        DeleteEntity(Objects[i]);
    };
    Objects = [];

    SetWaypointOff();
    ClearGpsMultiRoute();
};

const UpdateHudPosition = async () => {
    if (!CurrentRace) return;
    const Result = await FW.SendCallback("fw-racing:Server:GetPosition", CurrentRace.Id);
    CurrentPosition = Result;
    UpdateHud();
}

const UpdateHud = () => {
    if (!CurrentRace) return;

    global.exports['fw-ui'].SendUIMessage("Racing", "SetHud", {
        Visible: true,
        ShowPos: IsGov() || CurrentRace.Settings.ShowPosition,
        Finished: DidDNF || CurrentLap == CurrentRace.Laps && CurrentCheckpoint == CurrentRace.Checkpoints.length,
        DidDNF: DidDNF,
        Checkpoint: CurrentCheckpoint,
        Position: CurrentPosition,
        Lap: CurrentLap,
        TotalPlayers: CurrentRace.Racers.length,
        TotalLaps: CurrentRace.Laps,
        TotalCheckpoints: CurrentRace.Checkpoints.length,
    });
};

on("onResourceStop", ClearRaceObjects);

on("DamageEvents:VehicleDamaged", (Vehicle: number, Attacker: number, Weapon: number, IsMelee: boolean, DamageTypeFlag: any) => {
    if (!CurrentRace || CurrentRace.Settings.CheckpointPenalty <= 0.0 || GetEntityModel(Attacker) != GetHashKey("prop_offroad_tyres02" || Vehicle != GetVehiclePedIsIn(PlayerPedId(), false))) return;
    AdditionalTotalTime += CurrentRace.Settings.CheckpointPenalty * 1000;
    AdditionalLapTime += CurrentRace.Settings.CheckpointPenalty * 1000;
    PlaySoundFrontend(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", false)

    global.exports['fw-ui'].SendUIMessage("Racing", "SetAdditionalTime", {
        Penalty: CurrentRace.Settings.CheckpointPenalty * 1000,
    });
});

onNet("fw-racing:Client:NewRace", () => {
    const [ RacingUsb, PDRacingUsb, RacingAlias ] = HasRacingUsb();
    if (!RacingUsb || !RacingAlias) return;

    emit("fw-phone:Client:Notification", "racing-new-event", "fas fa-flag-checkered", [ "white", "#039380" ], 'Racing', "Nieuwe race beschikbaar.")
});

onNet("fw-racing:Client:StartDNFTimer", (EndTime: number) => {
    if (!CurrentRace) return;

    IsDNFStarted = true;
    DidDNF = false;
    DNFEnd = EndTime;

    global.exports['fw-ui'].SendUIMessage("Racing", "SetDNF", {
        Active: IsDNFStarted,
        Timestamp: EndTime
    });
})