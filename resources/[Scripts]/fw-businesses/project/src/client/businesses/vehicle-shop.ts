import { Vector4Format } from "../../shared/classes/math";
import { Thread } from "../../shared/classes/thread";
import type { VehicleShops } from "../../shared/types";
import { Delay, exp } from "../../shared/utils";
import { FW } from "../client";

let PreviewVehicles: number[] = [];
let CurrentShop: false | VehicleShops = false;
const QuicksellThread = new Thread("tick", 4);

const LoadStore = async (StoreName: VehicleShops) => {
    CurrentShop = StoreName;

    const Placements = await FW.SendCallback("fw-businesses:Server:GetVehicleShopPlacements", CurrentShop);
    if (!Placements) return;

    for (let i = 0; i < PreviewVehicles.length; i++) {
        FW.VSync.DeleteVehicle(PreviewVehicles[i]);
    };

    for (let j = 0; j < Placements.length; j++) {
        const {Coords, Vehicle} = Placements[j];
        if (!Vehicle) continue;

        PreviewVehicles[j] = await CreateDisplayVehicle(Vehicle, Coords);
    };
};

const UnloadStore = () => {
    CurrentShop = false;

    for (let i = 0; i < PreviewVehicles.length; i++) {
        FW.VSync.DeleteVehicle(PreviewVehicles[i]);
    };
};

const CreateDisplayVehicle = async (ModelName: string, Coords: Vector4Format): Promise<number> => {
    RequestModel(ModelName);
    while (!HasModelLoaded(ModelName)) await Delay(100);

    const Vehicle = CreateVehicle(ModelName, Coords.x, Coords.y, Coords.z, Coords.w, false, true);
    SetEntityHeading(Vehicle, Coords.w);
    FreezeEntityPosition(Vehicle, true);
    SetEntityInvincible(Vehicle, true);
    SetVehicleDoorsLocked(Vehicle, 3);
    SetVehicleModKit(Vehicle, 0);

    const Preset = await FW.SendCallback("fw-businesses:Server:VehicleShop:GetPreset", CurrentShop, Vehicle);
    if (Preset && Object.keys(Preset).length !== 0) {
        FW.VSync.ApplyVehicleMods(Vehicle, Preset);
    };

    return Vehicle;
};

onNet("fw-businesses:Client:VehicleShop:SetVehicle", async (ShopName: VehicleShops, Spot: number, ModelName: string) => {
    if (ShopName != CurrentShop) return;

    if (PreviewVehicles[Spot]) {
        FW.VSync.DeleteVehicle(PreviewVehicles[Spot])
    };

    const Placements = await FW.SendCallback("fw-businesses:Server:GetVehicleShopPlacements", CurrentShop);
    if (!Placements) return;

    PreviewVehicles[Spot] = await CreateDisplayVehicle(ModelName, Placements[Spot].Coords);
});

onNet("fw-businesses:Client:VehicleShop:LoadVehicle", async (NetId: number, Plate: string) => {
    while (!NetworkDoesEntityExistWithNetworkId(NetId)) await Delay(100);
    const Vehicle = NetworkGetEntityFromNetworkId(NetId);

    SetVehicleModKit(Vehicle, 0)
    for (let i = 0; i <= 49; i++) {
        SetVehicleMod(Vehicle, i, -1, false)
    };

    exp['fw-vehicles'].SetVehicleKeys(Plate, true, false);
    exp['fw-vehicles'].SetFuelLevel(Vehicle, 100.0);

    setTimeout(() => {
        NetworkRegisterEntityAsNetworked(Vehicle)
        FW.Functions.SetVehiclePlate(Vehicle, Plate)
        emitNet("fw-businesses:Server:AutoCare:LoadParts", Plate, { Engine: 100, Axle: 100, Transmission: 100, FuelInjectors: 100, Clutch: 100, Brakes: 100 })
        emitNet("fw-vehicles:Server:LoadVehicleMeta", NetId, null)
    }, 1000);
});

QuicksellThread.addHook("preStart", () => {
    exp['fw-ui'].ShowInteraction("[Y] Quick-Sell Voertuig", "error")
});

QuicksellThread.addHook("active", () => {
    if (IsControlJustReleased(0, 246)) {
        const Vehicle = GetVehiclePedIsIn(PlayerPedId(), false);
        if (!Vehicle) return FW.Functions.Notify("Je zit niet in een voertuig..", "error");
        FW.TriggerServer("fw-businesses:Server:QuicksellVehicle", NetworkGetNetworkIdFromEntity(Vehicle), GetVehicleNumberPlateText(Vehicle), GetEntityModel(Vehicle));
    }
});

QuicksellThread.addHook("afterStop", () => {
    exp['fw-ui'].HideInteraction();
});

setImmediate(async () => {
    while (!exp['fw-config'].IsConfigReady()) {
        await Delay(100)
    };

    const ShopZones: VehicleShops[] = [ "pdm", "bennys", "flightschool", "lostmc", "darkwolves", "losmuertos" ];
    const ShopData = await exp['fw-config'].GetModuleConfig("bus-vehicleshop");

    for (let i = 0; i < ShopZones.length; i++) {
        const Shop = ShopData[ShopZones[i]];
        if (!Shop) {
            console.error(`Failed to load shop '${ShopZones[i]}': no matching config found.`);
            continue;
        };

        if (Shop.area) {
            exp['PolyZone'].CreateBox({
                center: Shop.area.center,
                length: Shop.area.length,
                width: Shop.area.width,
            }, {
                name: `${ShopZones[i]}_area_zone`,
                heading: Shop.area.heading,
                minZ: Shop.area.minZ,
                maxZ: Shop.area.maxZ,
            }, (IsInside: boolean, Zone: any, Points: any) => {
                IsInside ? LoadStore(ShopZones[i]) : UnloadStore();
            })
        }
    }

    if (ShopData.pdm.quicksell) {
        exp['PolyZone'].CreateBox({
            center: ShopData.pdm.quicksell.center,
            length: ShopData.pdm.quicksell.length,
            width: ShopData.pdm.quicksell.width,
        }, {
            name: `pdm_quicksell`,
            heading: ShopData.pdm.quicksell.heading,
            minZ: ShopData.pdm.quicksell.minZ,
            maxZ: ShopData.pdm.quicksell.maxZ,
        }, (IsInside: boolean, Zone: any, Points: any) => {
            IsInside ? QuicksellThread.start() : QuicksellThread.stop();
        });
    };
});