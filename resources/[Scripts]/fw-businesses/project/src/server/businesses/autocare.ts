import { GetRandom, exp } from "../../shared/utils";
import { FW } from "../server";

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

const PartItems = [
    { Item: "vehicle-clutch", Type: "Clutch" },
    { Item: "vehicle-axle", Type: "Axle" },
    { Item: "vehicle-brakes", Type: "Brakes" },
    { Item: "vehicle-engine", Type: "Engine" },
    { Item: "vehicle-injectors", Type: "FuelInjectors" },
    { Item: "vehicle-transmission", Type: "Transmission" }
];

for (let i = 0; i < PartItems.length; i++) {
    const {Item: itemName, Type: partType} = PartItems[i];

    FW.Functions.CreateUsableItem(itemName, async (Source: number, Item: any) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!await Player.Functions.GetItemBySlot(Item.Slot)) return;
        emitNet("fw-businesses:Client:AutoCare:MountPart", Source, itemName, partType, Item.CustomType);
    });
}

const GetVehiclePartsByPlate = async (Plate: string): Promise<any> => {
    const Result = await exp['ghmattimysql'].executeSync("SELECT `parts` FROM `player_vehicles` WHERE `plate` = ? LIMIT 1", [Plate]);
    return Result[0] && Result[0].parts && JSON.parse(Result[0].parts) || undefined;
}

const SaveVehicleParts = async (Plate: string) => {
    const Parts = VehicleParts[Plate]
    if (!Parts) return;

    exp['ghmattimysql'].execute("UPDATE `player_vehicles` SET `parts` = ? WHERE `plate` = ? LIMIT 1", [ JSON.stringify(Parts), Plate ]);
    emitNet("fw-businesses:Client:AutoCare:SyncVehicleParts", -1, Plate, Parts);
};

FW.Functions.CreateCallback("fw-businesses:Server:AutoCare:GetAllParts", (Source: number, Cb: Function) => {
    Cb(VehicleParts);
});

FW.Functions.CreateCallback("fw-businesses:Server:AutoCare:GetNewPercentage", (Source: number, Cb: Function, Type: string, ItemCreateDate: number, ItemSlot: number, Vehicle: number) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    let NewPercentage = exp['fw-vehicles'].GetVehicleMeta(Vehicle, Type);
    let Quality = 0;
    
    switch (Type) {
        case "Harness":
            Quality = exp['fw-inventory'].CalculateQuality('harness', ItemCreateDate);
            NewPercentage = NewPercentage + Quality;
            exp['fw-vehicles'].SetVehicleMeta(Vehicle, "Harness", NewPercentage > 100 ? 100 : NewPercentage);
            Player.Functions.RemoveItem('harness', 1, ItemSlot, true);
            break;
        case "Nitrous":
            Quality = exp['fw-inventory'].CalculateQuality('nitrous', ItemCreateDate);
            NewPercentage = NewPercentage + Quality;
            exp['fw-vehicles'].SetVehicleMeta(Vehicle, "Nitrous", NewPercentage > 100 ? 100 : NewPercentage);
            Player.Functions.RemoveItem('nitrous', 1, ItemSlot, true);
            break;
    };

    Cb(NewPercentage > 100 ? 100 : NewPercentage);
});

onNet("fw-businesses:Server:AutoCare:LoadParts", async (Plate: string) => {
    const Parts = await GetVehiclePartsByPlate(Plate)
    if (!Parts) return;

    VehicleParts[Plate] = Parts
    emitNet("fw-businesses:Client:AutoCare:SyncVehicleParts", -1, Plate, Parts);
});

onNet("fw-businesses:Server:AutoCare:RepairPart", async (Plate: string, Part: 'Engine' | 'Axle' | 'Transmission' | 'FuelInjectors' | 'Clutch' | 'Brakes') => {
    if (VehicleParts[Plate] === undefined) return;
    VehicleParts[Plate][Part] = 100.0;
    SaveVehicleParts(Plate);
});

onNet("fw-businesses:Server:AutoCare:ApplyPartDamage", async (Plate: string, Model: string, Type: string) => {
    const VehicleData = FW.Shared.HashVehicles[Model]
    if (!VehicleData) return;

    let Multiplier = 1.0;
    const MinusAmount = 0.6;

    if (Type == 'Body') Multiplier = 1.6;
    if (VehicleData.Class == 'A') Multiplier = Multiplier + 0.2;
    if (VehicleData.Class == 'B') Multiplier = Multiplier + 0.4;
    if (VehicleData.Class == 'C') Multiplier = Multiplier + 0.6;
    if (VehicleData.Class == 'D') Multiplier = Multiplier + 0.8;
    if (VehicleData.Class == 'E') Multiplier = Multiplier + 1.0;
    if (VehicleData.Class == 'M') Multiplier = Multiplier + 1.2;

    if (!VehicleParts[Plate]) return;

    const PartsArray = Object.keys(VehicleParts[Plate]);
    for (let i = 0; i < PartsArray.length; i++) {
        const PartName = PartsArray[i];
        // @ts-ignore
        VehicleParts[Plate][PartName] -= (MinusAmount + Multiplier + (GetRandom(40, 130) / 100));
        
    };

    SaveVehicleParts(Plate);
});