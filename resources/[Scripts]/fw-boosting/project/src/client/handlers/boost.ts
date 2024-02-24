import { Vector3, Vector3Format } from "../../shared/classes/math";
import { BoostingContract } from "../../shared/types";
import { Delay, GetRandom, exp } from "../../shared/utils";
import { HackSpeed, TierConfigs } from "../../shared/config";
import { FW } from "../client";
export let CurrentContract: false | BoostingContract = false;

let _IsLeader = false;
let AreaBlip: number = 0;
let DropoffBlip: number = 0;
export let CurrentTaskId: number = 0;
let IsPoliceAlertSent: boolean = false;
let AppliedRandomMods: boolean = false;
let ConfirmedVinOrder: boolean = false;
let isForceCanceled = false;

export const StartBoostContract = async (Data: {contract: BoostingContract}) => {
    if (CurrentContract) {
        return {
            success: false,
            message: "Je bent al met een contract bezig!"
        };
    };

    if (TierConfigs[Data.contract.Class].MinCops > exp['fw-police'].GetCurrentCops()) {
        return {
            success: false,
            message: "Dit contract kan momenteel niet worden gestart!"
        };
    };

    const Result = await FW.SendCallback("fw-boosting:Server:StartContract", Data.contract);
    return Result.data;
};

onNet("fw-inventory:Client:Cock", async () => {
    if (!CurrentContract) return;
    if (exp['fw-inventory'].HasEnoughOfItem("vpn", 1)) return;

    await FW.SendCallback("fw-boosting:Server:CancelContract", CurrentContract);
    if (_IsLeader && CurrentContract.Data) emitNet("fw-boosting:Server:CleanupBoosting", CurrentContract, false);

    CurrentContract = false;
    _IsLeader = false;

    RemoveBlip(AreaBlip);
    RemoveBlip(DropoffBlip);

    AreaBlip = 0;
    DropoffBlip = 0;
});

// for the Impound System :)
onNet("fw-boosting:Client:ForceCancel", async () => {
    if (!CurrentContract) return;
    isForceCanceled = true;

    await FW.SendCallback("fw-boosting:Server:CancelContract", CurrentContract, true);

    setTimeout(() => {
        isForceCanceled = false;
    }, 1000);
});

onNet('fw-jobmanager:Client:SetupJob', (IsLeader: boolean, Tasks: any, Data: BoostingContract) => {
    const MyJob = exp["fw-jobmanager"].GetMyJob()
    if (MyJob.CurrentJob != "boosting") return;

    CurrentContract = Data;

    CurrentTaskId = 1;
    _IsLeader = IsLeader;
    AppliedRandomMods = false;
    IsPoliceAlertSent = false;
    ConfirmedVinOrder = false;

    CreateVehicleAreaBlip();

    if (!IsLeader) return;

    const Location = new Vector3().setFromObject(CurrentContract.Location.Vehicle);

    const Tick = setTick(async () => {
        if (!CurrentContract || !CurrentContract.Data) {
            clearTick(Tick);
            return;
        };

        if (CurrentTaskId != 1) {
            clearTick(Tick);
            return;
        };

        const [x, y, z] = GetEntityCoords(PlayerPedId(), false);
        const Distance = Location.getDistance({x, y, z});

        if (!AppliedRandomMods && Distance <= 100) {
            const BoostVehicle = NetworkGetEntityFromNetworkId(CurrentContract.Data.NetId);
            RandomizeVehicleMods(BoostVehicle);
        };

        if (AppliedRandomMods) {
            clearTick(Tick);
            return;
        };

        await Delay(2000);
    });
});

onNet('fw-jobmanager:Client:OnNextTask', (IsLeader: boolean, TaskId: number) => {
    const MyJob = exp["fw-jobmanager"].GetMyJob()
    if (MyJob.CurrentJob != "boosting") return;

    if (!CurrentContract || !CurrentContract.Data) return;

    CurrentTaskId = TaskId;

    if (TaskId == 2) { // Hack the trackers
        RemoveBlip(AreaBlip); AreaBlip = 0;

        if (TierConfigs[CurrentContract.Class].Trackers == 0) {
            setTimeout(() => {
                AddTaskProgress(2);
            }, 500)
        }
    } else if (TaskId == 3) {  // Dropping of
        AddDropoffBlip();

        if (!IsLeader) return;
        const DropoffVector = new Vector3().setFromObject(CurrentContract.Data.Dropoff);
        const Tick = setTick(async () => {
            if (!CurrentContract || !CurrentContract.Data) {
                clearTick(Tick);
                return;
            };

            const [x, y, z] = GetEntityCoords(PlayerPedId(), false);
            const Distance = DropoffVector.getDistance({x, y, z});

            if (Distance < 10.0) {
                AddTaskProgress(3);
                clearTick(Tick);
            }

            await Delay(2000);
        });
    } else if (TaskId == 4) {
        if (!IsLeader) return;

        if (!CurrentContract.Vin) {
            const DropoffVector = new Vector3().setFromObject(CurrentContract.Data.Dropoff);
            const BoostingVehicle = NetworkGetEntityFromNetworkId(CurrentContract.Data.NetId)
            const Tick = setTick(async () => {
                if (!CurrentContract || !CurrentContract.Data) {
                    clearTick(Tick);
                    return;
                };

                const [plyX, plyY, plyZ] = GetEntityCoords(PlayerPedId(), false);
                const PlayerDistance = DropoffVector.getDistance({x: plyX, y: plyY, z: plyZ});
                
                const [vehX, vehY, vehZ] = GetEntityCoords(BoostingVehicle, false);
                const VehicleDistance = DropoffVector.getDistance({x: vehX, y: vehY, z: vehZ});

                if (PlayerDistance > 50.0 && VehicleDistance < 10.0) {
                    AddTaskProgress(4);
                    clearTick(Tick);
                };

                await Delay(2000);
            });
        }
    };
});

onNet('fw-jobmanager:Client:JobCleanup', (IsLeader: boolean, IsForced: boolean) => {
    const MyJob = exp["fw-jobmanager"].GetMyJob()
    if (MyJob.CurrentJob != "boosting") return;
    
    if (IsLeader && CurrentContract && CurrentContract.Data) {
        emitNet("fw-boosting:Server:CleanupBoosting", CurrentContract, !IsForced, isForceCanceled);
    }

    CurrentContract = false;
    _IsLeader = false;

    RemoveBlip(AreaBlip);
    RemoveBlip(DropoffBlip);

    AreaBlip = 0;
    DropoffBlip = 0;
});

onNet("fw-vehicles:Client:OnLockpickStart", (Entity: number) => {
    if (!CurrentContract || !CurrentContract.Data || IsPoliceAlertSent) return;

    const BoostVehicle = NetworkGetEntityFromNetworkId(CurrentContract.Data.NetId);
    if (BoostVehicle != Entity) return;

    emitNet("fw-boosting:Server:SetAlertSent");

    const [x, y, z] = GetEntityCoords(Entity, false);
    emitNet("fw-mdw:Server:SendAlert:CarBoosting",
        {x, y, z},
        FW.Functions.GetStreetLabel(),
        FW.Functions.GetCardinalDirection(),
        CurrentContract.VehicleLabel,
        CurrentContract.Data.Plate,
        FW.Functions.GetVehicleColorLabel(Entity),
        CurrentContract.Class
    );

    emitNet("fw-boosting:Server:StartTrackingVehicle", CurrentContract);

    // Is this a VIN scratch or a class where peds will spawn? Spawn them!
    if (CurrentContract.Vin || CurrentContract.AlwaysPeds) {
        SpawnAngryPeds(CurrentContract.Location.NPCs);
    };
});

onNet("fw-vehicles:Client:OnLockpickSuccess", (Entity: number, InVehicle: boolean) => {
    if (!CurrentContract || !CurrentContract.Data || CurrentTaskId != 1) return;
    const BoostVehicle = NetworkGetEntityFromNetworkId(CurrentContract.Data.NetId);
    if (BoostVehicle != Entity) return;
    AddTaskProgress(1); 
});

onNet("fw-boosting:Client:SetAlertSent", (Entity: number) => {
    IsPoliceAlertSent = true;
});

onNet("fw-boosting:Client:CreateTrackerBlip", ([x, y, z]: number[]) => {
    const PlayerData = FW.Functions.GetPlayerData()
    if (PlayerData && PlayerData.job && PlayerData.job.name == "police" && PlayerData.job.onduty) {
        const Blip = AddBlipForCoord(x, y, z);
        SetBlipSprite(Blip, 225);
        SetBlipColour(Blip, 1);
        SetBlipScale(Blip, 1.5);
        SetBlipAsShortRange(Blip, false);
        SetBlipDisplay(Blip, 2);
        SetBlipFlashes(Blip, true);
        BeginTextCommandSetBlipName("STRING");
        AddTextComponentString("10-99A - GPS-locatie");
        EndTextCommandSetBlipName(Blip);

        setTimeout(() => {
            RemoveBlip(Blip);
        }, 10000);
    };
});

onNet("fw-boosting:Client:TrackerSound", (NetId: number) => {
    if (!NetworkDoesEntityExistWithNetworkId(NetId)) return;

    const Vehicle = NetworkGetEntityFromNetworkId(NetId)
    if (DoesEntityExist(Vehicle)) {
        PlaySoundFromEntity(-1, "MP_5_SECOND_TIMER", Vehicle, "HUD_FRONTEND_DEFAULT_SOUNDSET", false, 0)
    };
});

onNet("fw-boosting:Client:UseHackingDevice", async (Item: any) => {
    if (!CurrentContract || !CurrentContract.Data) return;

    const Vehicle = GetVehiclePedIsIn(PlayerPedId(), false);
    if (!Vehicle || !DoesEntityExist(Vehicle)) return;

    const Speed = GetEntitySpeed(Vehicle) * 3.6;
    if (Speed < HackSpeed) {
        return FW.Functions.Notify("Het voertuig gaat niet snel genoeg..", "error");
    };

    const DriverPed = GetPedInVehicleSeat(Vehicle, -1);
    if (DriverPed == 0 || DriverPed == PlayerPedId()) {
        return FW.Functions.Notify("De bestuurder kan niet hacken!", "error");
    };

    const Plate = GetVehicleNumberPlateText(Vehicle);
    const Result = await FW.SendCallback("fw-boosting:Server:IsVehicleHackable", Plate);
    if (!Result.data.success) {
        return FW.Functions.Notify(Result.data.message, "error");
    };

    const Success = await exp['minigame-boostinghack'].StartHack(Result.data.HackTypes, Result.data.HackTime);

    if (!Success) {
        FW.Functions.Notify("Mislukt!", "error");
        emitNet("fw-boosting:Server:FailedHack", Plate);
        return;
    };

    FW.TriggerServer("fw-boosting:Server:AddHackProgress", Plate);
});

onNet("fw-boosting:Client:PrepareVIN", async () => {
    if (!CurrentContract) return;
    if (!_IsLeader) {
        return FW.Functions.Notify("Alleen de eigenaar van het contract kan de VIN-scratch doen..", "error")
    };

    const Finished = await FW.Functions.CompactProgressbar(3000, "Laptop openen..", false, false, {
        disableMovement: true,
        disableCarMovement: true,
        disableMouse: false,
        disableCombat: true
    }, {
        animDict: "anim@heists@prison_heiststation@cop_reactions",
        anim: "cop_b_idle",
        flags: 1,
    }, {}, {}, false)

    if (!Finished) return;

    emit("fw-phone:Client:Notification",
        `boosting-vin-order-${CurrentContract.Id}`,
        "fas fa-horse-head",
        [ "white", "transparent" ],
        "PM Boosting",
        `Prijs bestelling ${CurrentContract.ScratchPrice} ${CurrentContract.Crypto}`,
        false,
        true,
        "fw-boosting:Server:ConfirmVINOrder",
        "fw-phone:Client:RemoveNotificationById",
        {
            HideOnAction: false,
            Id: `boosting-vin-order-${CurrentContract.Id}`,
            Contract: CurrentContract
        }
    )
});

onNet("fw-boosting:Client:ConfirmOrder", async (State: boolean) => {
    if (!State) {
        ConfirmedVinOrder = false;
        StopAnimTask(PlayerPedId(), "anim@heists@prison_heiststation@cop_reactions", "cop_b_idle", 1.0);
        return;
    };

    await FW.Functions.CompactProgressbar(5000, "Met netwerk verbinden..", false, false, {
        disableMovement: true,
        disableCarMovement: true,
        disableMouse: false,
        disableCombat: true
    }, {
        animDict: "anim@heists@prison_heiststation@cop_reactions",
        anim: "cop_b_idle",
        flags: 1,
    }, {}, {}, false);

    await FW.Functions.CompactProgressbar(10000, "Papierwerk wissen..", false, false, {
        disableMovement: true,
        disableCarMovement: true,
        disableMouse: false,
        disableCombat: true
    }, {
        animDict: "anim@heists@prison_heiststation@cop_reactions",
        anim: "cop_b_idle",
        flags: 1,
    }, {}, {}, false);

    StopAnimTask(PlayerPedId(), "anim@heists@prison_heiststation@cop_reactions", "cop_b_idle", 1.0);

    AddTaskProgress(4);
    ConfirmedVinOrder = true;
});

onNet("fw-boosting:Client:ScratchVin", async (Entity: number) => {
    if (!CurrentContract || !CurrentContract.Data) return;
    if (!_IsLeader) {
        return FW.Functions.Notify("Alleen de eigenaar van het contract kan de VIN-scratch doen..", "error")
    };

    const Finished = await FW.Functions.CompactProgressbar(20000, "VIN wegkrassen..", false, false, {
        disableMovement: true,
        disableCarMovement: true,
        disableMouse: false,
        disableCombat: true
    }, {
        animDict: "amb@medic@standing@kneel@idle_a",
        anim: "idle_a",
        flags: 1,
    }, {}, {}, false);

    StopAnimTask(PlayerPedId(), "amb@medic@standing@kneel@idle_a", "idle_a", 1.0);
    if (!Finished) return;

    const Vehicle = NetworkGetEntityFromNetworkId(CurrentContract.Data.NetId);

    FW.TriggerServer("fw-boosting:Server:ScratchVin", CurrentContract, FW.VSync.GetVehicleMods(Vehicle));
});

const CreateVehicleAreaBlip = () => {
    if (!CurrentContract) return;
    const {x, y, z} = CurrentContract.Area;

    AreaBlip = AddBlipForRadius(x, y, z, 250.0);
    SetBlipHighDetail(AreaBlip, true);
    SetBlipColour(AreaBlip, 68)
    SetBlipAsShortRange(AreaBlip, true)
    SetBlipAlpha(AreaBlip, 128)
};

const AddDropoffBlip = () => {
    if (DropoffBlip) RemoveBlip(DropoffBlip);

    if (!CurrentContract) return;
    const {x, y, z} = CurrentContract.Data?.Dropoff;

    DropoffBlip = AddBlipForCoord(x, y, z);
    SetBlipSprite(DropoffBlip, 225);
    SetBlipColour(DropoffBlip, 43);
    SetBlipDisplay(DropoffBlip, 4);
    SetBlipAsShortRange(DropoffBlip, false);
    BeginTextCommandSetBlipName("STRING");
    AddTextComponentString("Dropoff Locatie");
    EndTextCommandSetBlipName(DropoffBlip);
};

const RandomizeVehicleMods = (Vehicle: number) => {
    if (!DoesEntityExist(Vehicle) || !IsEntityAVehicle(Vehicle)) {
        return;
    }

    AppliedRandomMods = true;

    SetVehicleModKit(Vehicle, 0);

    for (let i = 0; i <= 49; i++) {
        const NumOptions: number = GetNumVehicleMods(Vehicle, i);
        if (NumOptions > 0) {
            const RandomMod: number = Math.floor(Math.random() * NumOptions);
            SetVehicleMod(Vehicle, i, RandomMod, false);
        };
    };

    // Neon?
    if (Math.random() > 0.5) {
        const NeonColours: [number,number,number][] = [
            [ 222, 222, 255 ],
            [ 2, 21, 255 ],
            [ 3, 83, 255 ],
            [ 0, 255, 140 ],
            [ 94, 255, 1 ],
            [ 255, 255, 0 ],
            [ 255, 150, 0 ],
            [ 255, 62, 0 ],
            [ 255, 1, 1 ],
            [ 255, 50, 100 ],
            [ 255, 5, 190 ],
            [ 35, 1, 255 ],
            [ 15, 3, 255 ],
        ];

        const NeonColour = NeonColours[Math.floor(Math.random() * NeonColours.length)]
        SetVehicleNeonLightEnabled(Vehicle, 0, true);
        SetVehicleNeonLightEnabled(Vehicle, 1, true);
        SetVehicleNeonLightEnabled(Vehicle, 2, true);
        SetVehicleNeonLightEnabled(Vehicle, 3, true);
        SetVehicleNeonLightsColour(Vehicle, NeonColour[0], NeonColour[1], NeonColour[2]);
    };

    // Xenon?
    if (Math.random() > 0.5) {
        ToggleVehicleMod(Vehicle, 22, true);
        const LightColour = GetRandom(0, 13);
        SetVehicleXenonLightsColor(Vehicle, LightColour == 13 ? 255 : LightColour)
    } else {
        ToggleVehicleMod(Vehicle, 22, false);
    };

    // Turbo?
    ToggleVehicleMod(Vehicle, 18, Math.random() > 0.8);

    // Misc
    SetVehicleDoorsLocked(Vehicle, 2);
    if (CurrentContract && CurrentContract.Data) SetVehicleNumberPlateText(Vehicle, CurrentContract.Data.Plate);
};

const SpawnAngryPeds = async (Locations: Vector3Format[]) => {
    const Models = [
        "a_m_m_beach_01",
        "a_m_m_og_boss_01",
        "a_m_m_soucent_01",
    ];

    for (let i = 0; i < Locations.length; i++) {
        const {x, y, z} = Locations[i];
        const Model = Models[Math.floor(Math.random() * Models.length)];
        await exp['fw-assets'].RequestModelHash(Model);

        const Ped = CreatePed(1, Model, x, y, z, 0.0, true, true)
        SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(Ped), true);
        SetPedAccuracy(Ped, 70);
        SetPedRelationshipGroupHash(Ped, `HATES_PLAYER`);
        SetPedKeepTask(Ped, true);
        SetCanAttackFriendly(Ped, false, true);
        TaskCombatPed(Ped, PlayerPedId(), 0, 16);
        SetPedCombatAttributes(Ped, 46, true);
        SetPedCombatAbility(Ped, 1);
        SetPedCombatAttributes(Ped, 0, true);
        GiveWeaponToPed(Ped, "weapon_pistol_mk2", -1, false, true);
        SetPedDropsWeaponsWhenDead(Ped, false);
        SetPedCombatRange(Ped, 2);
        SetPedFleeAttributes(Ped, 0, false);
        SetPedConfigFlag(Ped, 58, true);
        SetPedConfigFlag(Ped, 75, true);
        SetBlockingOfNonTemporaryEvents(Ped, true);
        SetEntityAsNoLongerNeeded(Ped);
        SetPedArmour(Ped, 100);
        SetEntityMaxHealth(Ped, 350);
        SetEntityHealth(Ped, 350);
    };
};

const AddTaskProgress = (TaskId: number, Progress: number = 1) => {
    const MyJob = exp["fw-jobmanager"].GetMyJob()
    if (!MyJob || !MyJob.CurrentJob) return;
    if (MyJob.CurrentJob != "boosting") return;
    if (!CurrentContract || !CurrentContract.Data) return;
    
    FW.TriggerServer("fw-jobmanager:Server:AddTaskProgress", MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, TaskId, Progress)
};

exp("IsVehicleScratchable", (Entity: number) => {
    if (!CurrentContract) return false;
    if (!CurrentContract.Data) return false;

    const Vehicle = NetworkGetEntityFromNetworkId(CurrentContract.Data.NetId);
    return ConfirmedVinOrder && Vehicle == Entity;
});