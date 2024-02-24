import { Thread } from "../../shared/classes/thread";
import { Delay, Round, exp } from "../../shared/utils";
import { FW, GetCurrentClock } from "../client";
import { HasRolePermission, IsBusinessOnLockdown, IsPlayerInBusiness } from "../utils";

const TotalPartsHealth = 600;
const PartsThread = new Thread("tick", 5000);

let VehicleEffects: {[key: string]: {
    hasAdjustedBrakes?: boolean;
    originalBrakeForce?: number;
    hasClutchOverwrite?: boolean;
    originalSteeringLock?: number;
    hasAdjustedAxle?: boolean;
}} = {};

let VehicleParts: {
    [key: string]: {
        Engine: number;
        Axle: number;
        Transmission: number;
        FuelInjectors: number;
        Clutch: number;
        Brakes: number;
    }
} = {};

export const IsAutocare = async (): Promise<boolean> => {
    if (await IsPlayerInBusiness("Bennys Motorworks")) return true;
    if (await IsPlayerInBusiness("Hayes Repairs")) return true;
    if (await IsPlayerInBusiness("Harmony Repairs")) return true;

    return false;
};
exp("IsAutocare", IsAutocare);

const GetTotalPercentage = (Parts: number[]): number => {
    let Retval = 0
    for (let i = 0; i < Parts.length; i++) {
        Retval += Parts[i];
    };
    return (Retval / TotalPartsHealth) * 100
};

// vehicle damage stuff
onNet("baseevents:enteredVehicle", (vehicle: number, seatIndex: number, displayName: string, netId: number) => {
    const Plate = GetVehicleNumberPlateText(vehicle);
    if (!VehicleParts[Plate]) return;

    PartsThread.data = { vehicle, seatIndex, displayName, netId };
    PartsThread.start();
});

onNet("baseevents:leftVehicle", () => {
    PartsThread.stop();
});

onNet("fw-businesses:Client:AutoCare:SyncVehicleParts", (Plate: string, Parts: {
    Engine: number;
    Axle: number;
    Transmission: number;
    FuelInjectors: number;
    Clutch: number;
    Brakes: number;
}) => {
    VehicleParts[Plate] = Parts;
});

const GetEngineTimeoutLength = (percentage: number): number => {
    const maxTimeout = 12000;
    const minTimeout = 2000;
    const timeoutRange = maxTimeout - minTimeout;

    const calculatedTimeout = maxTimeout - (percentage / 25) * timeoutRange;
    return calculatedTimeout - (Math.random() * 1000 - 500);
};

const AdjustedBrakeForce = (brakeHealth: number, originalBrakeForce: number): number => {
    if (brakeHealth <= 7) {
        return 0;
    } else if (brakeHealth <= 50) {
        const maxReductionPercentage = 95;
        const reductionPercentage = maxReductionPercentage - ((brakeHealth - 10) / 42) * maxReductionPercentage;
        return originalBrakeForce * (1 - reductionPercentage / 100);
    } else {
        return originalBrakeForce;
    }
};

PartsThread.addHook("active", ({vehicle, seatIndex, displayName, netId}) => {
    const SeatPed = GetPedInVehicleSeat(vehicle, -1);
    if (SeatPed != PlayerPedId()) return;
    
    const Speed = GetEntitySpeed(vehicle);
    if (Speed < 5) return;
    
    const Plate = GetVehicleNumberPlateText(vehicle);
    const Class = GetVehicleClass(vehicle);
    if (!VehicleParts[Plate]) return;

    // Disable the vehicle for x seconds based on engine part %
    // Note: if you change the threshold, change the GetEngineTimeoutLength function too.
    if (VehicleParts[Plate].Engine < 25.0 && IsVehicleEngineOn(vehicle)) {
        if (Math.random() < 0.12) {
            SetVehicleEngineOn(vehicle, false, true, true);
            FW.Functions.Notify("Voertuig is afgeslagen..", "error");
        };
    };

    // Decrease brake force based on brakes part % :)
    if (VehicleParts[Plate].Brakes < 50.0) {
        const CurrentBrakes = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fBrakeForce');
        if (!VehicleEffects[Plate]) VehicleEffects[Plate] = {};
        if (VehicleEffects[Plate].originalBrakeForce === undefined) {
            VehicleEffects[Plate].originalBrakeForce = CurrentBrakes;
        };

        const newBrakeForce = AdjustedBrakeForce(VehicleParts[Plate].Brakes, VehicleEffects[Plate].originalBrakeForce!);
        if (newBrakeForce != CurrentBrakes) {
            SetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeForce", newBrakeForce)
            VehicleEffects[Plate].hasAdjustedBrakes = true;
        };
    } else if (VehicleEffects[Plate] && VehicleEffects[Plate].hasAdjustedBrakes && VehicleEffects[Plate].originalBrakeForce) {
        // Reset it to default if the brakeForce was adjusted.
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeForce", VehicleEffects[Plate].originalBrakeForce!)
        VehicleEffects[Plate].hasAdjustedBrakes = false;
    };

    // Clutch
    if (VehicleParts[Plate].Clutch <= 15.0 && (!VehicleEffects[Plate]?.hasClutchOverwrite || GetEntitySpeed(vehicle) > 20.0)) {
        if (!VehicleEffects[Plate]) VehicleEffects[Plate] = {}
        VehicleEffects[Plate].hasClutchOverwrite = true;
        SetEntityMaxSpeed(vehicle, 20.0);
    } else {
        SetEntityMaxSpeed(vehicle, exp['fw-assets'].GetSpeedLimit());
        if (!VehicleEffects[Plate]) VehicleEffects[Plate] = {};
        VehicleEffects[Plate].hasClutchOverwrite = false;
    };

    // Axle
    if (VehicleParts[Plate].Axle <= 15.0) {
        const CurrentSteer = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fSteeringLock');
        if (!VehicleEffects[Plate]) VehicleEffects[Plate] = {};
        if (VehicleEffects[Plate].originalSteeringLock === undefined) {
            VehicleEffects[Plate].originalSteeringLock = CurrentSteer;
        };
        
        if (CurrentSteer == VehicleEffects[Plate].originalSteeringLock) {
            SetVehicleHandlingFloat(vehicle, "CHandlingData", "fSteeringLock", 20.0)
            VehicleEffects[Plate].hasAdjustedAxle = true;
        };
    } else if (VehicleEffects[Plate] && VehicleEffects[Plate].hasAdjustedAxle && VehicleEffects[Plate].originalSteeringLock) {
        SetVehicleHandlingFloat(vehicle, "CHandlingData", "fSteeringLock", VehicleEffects[Plate].originalSteeringLock!)
        VehicleEffects[Plate].hasAdjustedAxle = false;
    }

    // Fuel Injectors
    if (VehicleParts[Plate].FuelInjectors < 15.0) {
        exp['fw-vehicles'].SetFuelRateOnVehicle(Plate, 5.0)
    } else if (exp['fw-vehicles'].GetFuelRate(Plate) > 1.0 && Class != 8 && GetEntityModel(vehicle) != GetHashKey("airone")) {
        exp['fw-vehicles'].SetFuelRateOnVehicle(Plate, 1.0)
    };

    if (GetVehicleDirtLevel(vehicle) > 1.0) {
        const Waxed = exp['fw-vehicles'].GetVehicleMeta(vehicle, "Waxed")
        if (Waxed && Waxed > 0.0) {
            SetVehicleDirtLevel(vehicle, 0.0)
            exp['fw-vehicles'].SetVehicleMeta(vehicle, "Waxed", Waxed - 0.15)
        };
    };
});

// job stuff
onNet("fw-businesses:Client:AutoCare:CheckVehicle", async (Data: any, Entity: number) => {
    const Plate = GetVehicleNumberPlateText(Entity)
    if (!VehicleParts[Plate]) {
        return FW.Functions.Notify("Je ziet weinig schroefjes en bent verbaasd dat dit voertuig vooruit komt..", "error")
    };

    const VehicleData = FW.Shared.HashVehicles[GetEntityModel(Entity)]
    if (!VehicleData) {
        return FW.Functions.Notify("Dit voertuig kan niet gecontroleerd worden..", "error")
    };

    const ContextItems: any = [];
    ContextItems.push({
        Icon: 'car',
        CloseMenu: false,
        Title: `${VehicleData.Name} | ${Plate}`,
        Desc: `Klasse: ${VehicleData.Class} | Totale percentage: ${Round(GetTotalPercentage(Object.values(VehicleParts[Plate])), 2)}%`,
        Data: { Event: '', Type: 'Client'},
    });

    ContextItems.push({
        Icon: 'wrench',
        Title: "Voertuig Diagnostiek",
        Desc: "Bekijk de staat van de onderdelen.",
        Data: { Event: '', Type: 'Client'},
        SecondMenu: []
    });

    if (await IsPlayerInBusiness("Bennys Motorworks") && !exp['fw-vehicles'].IsGovVehicle(Entity)) {
        ContextItems.push({
            Icon: 'meteor',
            Title: "Voertuig Opties",
            Desc: "Monteer een raceharnas of nitrofles.",
            Data: { Event: '', Type: 'Client'},
            SecondMenu: [
                {
                    Icon: 'user-slash',
                    CloseMenu: true,
                    Disabled: false,
                    Title: 'Raceharnas',
                    Desc: `Huidige staat: ${Round(exp['fw-vehicles'].GetVehicleMeta(Entity, 'Harness'), 2)}%`,
                    Data: { Event: "fw-businesses:Client:AutoCare:MountMisc", Type: "Client", Misc: "Harness", Vehicle: Entity },
                },
                {
                    Icon: 'bolt',
                    CloseMenu: true,
                    Disabled: !IsToggleModOn(Entity, 18),
                    Title: 'Nitrofles',
                    Desc: `Huidige staat: ${Round(exp['fw-vehicles'].GetVehicleMeta(Entity, 'Nitrous'), 2)}%`,
                    Data: { Event: "fw-businesses:Client:AutoCare:MountMisc", Type: "Client", Misc: "Nitrous", Vehicle: Entity },
                },
            ]
        });
    };

    const {partLabels} = await exp['fw-config'].GetModuleConfig("bus-autocare");

    for (const [Key, Value] of Object.entries(VehicleParts[Plate])) {
        ContextItems[1].SecondMenu.push({
            Icon: 'info-circle',
            CloseMenu: false,
            Title: `Voertuig ${partLabels[Key]}`,
            Desc: `Huidige staat: ${Round(Value, 2)}%`,
        })
    };

    const Waxed = exp['fw-vehicles'].GetVehicleMeta(Entity, "Waxed");
    ContextItems[1].SecondMenu.push({
        Icon: 'sparkles',
        CloseMenu: false,
        Title: `Voertuig Wax`,
        Desc: `Huidige staat: ${(Waxed && Waxed > 0.0 ? `${Round(Waxed, 2)}%` : "Geen wax")}`,
    })

    FW.Functions.OpenMenu({
        MainMenuItems: ContextItems,
    })
});

onNet("fw-businesses:Client:AutoCare:MountPart", (Item: string, Type: string, Class: string) => {
    if (IsPedInAnyVehicle(PlayerPedId(), false)) {
        return FW.Functions.Notify("Je kan vanaf hier geen voertuigonderdeel monteren..", "error")
    };

    const RayResult = exp['fw-ui'].GetEntityPlayerIsLookingAt(4.0, 0.2, 286, PlayerPedId());
    if (!RayResult) return;

    const [Entity, EntityType] = RayResult;
    if (Entity <= 0 || EntityType != 2) return;

    const Model = GetEntityModel(Entity);
    const VehicleData = FW.Shared.HashVehicles[Model];
    if (!VehicleData) return;

    if (VehicleData.Class != Class) {
        return FW.Functions.Notify("Het lijkt erop dat dit onderdeel niet in dit voertuig past..", "error")
    }

    let Animation: {
        animDict?: string;
        anim?: string;
        flags?: number;
    } = {};
    if (Type != 'Brakes' && Type != 'Axle') {
        Animation = {
            animDict: "mini@repair",
            anim: "fixing_a_player",
            flags: 16,
        }
    } else {
        TriggerEvent('fw-emotes:Client:PlayEmote', "welding", undefined, true)
    }

    exp["fw-inventory"].SetBusyState(true)
    FW.Functions.Progressbar("mounting_part", "Repareren...", 12500, false, true, {
        disableMovement: true,
        disableCarMovement: true,
        disableMouse: false,
        disableCombat: true,
    }, Animation, {}, {}, async () => {
        TriggerEvent("fw-emotes:Client:CancelEmote", true)
        if (Animation.animDict && Animation.anim) StopAnimTask(PlayerPedId(), Animation.animDict, Animation.anim, 1.0);

        const DidRemove = await FW.SendCallback("FW:RemoveItem", Item, 1, false, Class);
        if (!DidRemove) {
            return FW.Functions.Notify("Waar is het voertuigonderdeel gebleven dan?", "error")
        };

        const Plate = GetVehicleNumberPlateText(Entity)
        TriggerServerEvent("fw-businesses:Server:AutoCare:RepairPart", Plate, Type)

        exp["fw-inventory"].SetBusyState(false)
    }, () => {
        TriggerEvent("fw-emotes:Client:CancelEmote", true)
        if (Animation.animDict && Animation.anim) StopAnimTask(PlayerPedId(), Animation.animDict, Animation.anim, 1.0);

        exp["fw-inventory"].SetBusyState(false)
    })
});

onNet("fw-businesses:Client:AutoCare:MountMisc", (Data: {
    Misc: string;
    Vehicle: number;
}) => {
    const Item = exp['fw-inventory'].GetItemByName(Data.Misc.toLowerCase());
    if (!Item) return FW.Functions.Notify("Je mist een item..", "error");

    if (Data.Misc == "Nitrous" && !IsToggleModOn(Data.Vehicle, 18)) {
        return FW.Functions.Notify("Dit voertuig heeft geen Turbo om de nitrofles op te installeren..", "error")
    };

    TriggerEvent('fw-emotes:Client:PlayEmote', "welding", undefined, true);
    exp["fw-inventory"].SetBusyState(true);
    FW.Functions.Progressbar("mounting_part", "Repareren...", 12500, false, true, {
        disableMovement: true,
        disableCarMovement: true,
        disableMouse: false,
        disableCombat: true,
    }, {}, {}, {}, async () => {
        TriggerEvent("fw-emotes:Client:CancelEmote", true)
        const NewPercentage = await FW.SendCallback("fw-businesses:Server:AutoCare:GetNewPercentage", Data.Misc, Item.CreateDate, Item.Slot, NetworkGetNetworkIdFromEntity(Data.Vehicle))
        FW.Functions.Notify(`Harness gerepareerd naar ${Round(NewPercentage, 2)}%`)
        exp["fw-inventory"].SetBusyState(false);
    }, () => {
        TriggerEvent("fw-emotes:Client:CancelEmote", true)
        exp["fw-inventory"].SetBusyState(false);
    });
});

onNet("fw-businesses:Client:AutoCare:Stash", async (Data: {
    Business: string;
    Name: string;
}) => {
    if (!await HasRolePermission(Data.Business, 'StashAccess')) {
        return FW.Functions.Notify("Geen toegang..", "error")
    }

    if (await IsBusinessOnLockdown(Data.Business)) {
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error")
    };

    if (exp['fw-inventory'].CanOpenInventory()) {
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `${Data.Name}_stash`, 70, 2000)
    };
});

onNet("fw-businesses:Client:AutoCare:Craft", async (Data: {
    Business: string;
}) => {
    if (!await HasRolePermission(Data.Business, 'CraftAccess')) {
        return FW.Functions.Notify("Geen toegang..", "error")
    }

    if (await IsBusinessOnLockdown(Data.Business)) {
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error")
    };

    if (exp['fw-inventory'].CanOpenInventory()) {
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Crafting', Data.Business == 'Bennys Motorworks' ? 'Bennys' : 'Autocare')
    };
});

onNet("fw-businesses:Client:AutoCare:Tray", async (Data: {
    Name: string;
}) => {
    if (exp['fw-inventory'].CanOpenInventory()) {
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `autocare_${Data.Name}_counter`, 10, 200)
    };
});

onNet("fw-businesses:Client:AutoCare:ApplyWax", async () => {
    const RayResult = exp['fw-ui'].GetEntityPlayerIsLookingAt(4.0, 0.2, 286, PlayerPedId());
    if (!RayResult) return;

    const [Entity, EntityType] = RayResult;
    if (Entity <= 0 || EntityType != 2) return;

    const Model = GetEntityModel(Entity);
    const VehicleData = FW.Shared.HashVehicles[Model];
    if (!VehicleData) return;

    const Plate = GetVehicleNumberPlateText(Entity)
    if (!VehicleParts[Plate]) {
        return FW.Functions.Notify("Je kan dit voertuig niet waxen..")
    }
    
    if (GetVehicleDirtLevel(Entity) > 1.0) {
        return FW.Functions.Notify("De auto is vies.. Misschien eerst maar eens schoonpoetsen?")
    }

    const WaxPercentage = exp['fw-vehicles'].GetVehicleMeta(Entity, "Waxed")
    if (WaxPercentage && WaxPercentage > 25.0) {
        return FW.Functions.Notify("De auto is nog gewaxt.. Probeer het later nog eens!")
    }

	TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_MAID_CLEAN", 0, true)
    const Outcome = await exp['fw-ui'].StartSkillTest(1, [ 5, 8 ], [ 10000, 20000 ], false);
    ClearPedTasks(PlayerPedId())

    if (!Outcome) {
        TriggerServerEvent('fw-inventory:Server:DecayItem', 'carwax', undefined, 33.0)
        return
    }

    const DidRemove = await FW.SendCallback("FW:RemoveItem", "carwax", 1)
    if (!DidRemove) return;
    exp['fw-vehicles'].SetVehicleMeta(Entity, "Waxed", 100.0);
    SetVehicleDirtLevel(Entity, 0.0);
});


// zones stuff
onNet("fw-config:configLoaded", (pConfig: string) => {
    if (!exp['fw-config'].IsConfigReady() || pConfig != "bus-autocare") return;
    loadAutocareZones();
});

onNet("fw-config:configReady", () => {
    loadAutocareZones();
});

const loadAutocareZones = async () => {
    while (!exp['fw-config'].IsConfigReady()) {
        await Delay(100);
    };

    const {zones} = await exp['fw-config'].GetModuleConfig("bus-autocare");

    for (let i = 0; i < zones.length; i++) {
        const ZoneData = zones[i];
        let options: any[] = [];

        if (ZoneData.options.includes("stash")) {
            options.push({
                Name: 'stash',
                Icon: 'fas fa-box-open',
                Label: 'Stash',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:AutoCare:Stash',
                EventParams: ZoneData.data,
                Enabled: () => true,
            })
        };

        if (ZoneData.options.includes("craft")) {
            options.push({
                Name: 'craft',
                Icon: 'fas fa-wrench',
                Label: 'Craften',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:AutoCare:Craft',
                EventParams: ZoneData.data,
                Enabled: () => true,
            })
        };

        if (ZoneData.options.includes("tray")) {
            options.push({
                Name: 'tray',
                Icon: 'fas fa-box-open',
                Label: 'Toonbank',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:AutoCare:Tray',
                EventParams: ZoneData.data,
                Enabled: () => true,
            })
        };

        exp['fw-ui'].AddEyeEntry(ZoneData.name, {
            Type: 'Zone',
            SpriteDistance: 10.0,
            Distance: 1.5,
            ZoneData: {
                Center: ZoneData.center,
                Length: ZoneData.length,
                Width: ZoneData.width,
                Data: {
                    heading: ZoneData.heading,
                    minZ: ZoneData.minZ,
                    maxZ: ZoneData.maxZ
                },
            },
            Options: options
        })
    };
};

setImmediate(async () => {
    const Result = await FW.SendCallback("fw-businesses:Server:AutoCare:GetAllParts");
    VehicleParts = Result;
})