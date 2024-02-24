import { Vector3, Vector4Format } from "../../shared/classes/math";
import { Delay, NumberWithCommas, exp } from "../../shared/utils"
import { FW } from "../client";

onNet("fw-businesses:Client:BicycleShop:OpenMenu", async ({isRental, spawn}: {isRental: boolean, spawn: Vector4Format}) => {
    const {bicycles} = await exp['fw-config'].GetModuleConfig("bus-bicycle-shop");
    const MenuItems = [];

    for (let i = 0; i < bicycles.length; i++) {
        const bicycle = bicycles[i];
        const price = isRental ? bicycle.price * 0.1 : bicycle.price;

        MenuItems.push({
            Icon: 'bicycle',
            Title: bicycle.label,
            Desc: NumberWithCommas(FW.Shared.CalculateTax('Vehicle Registration Tax', price)),
            SecondMenu: [
                {
                    Title: 'Bevestig aankoop',
                    GoBack: false,
                    CloseMenu: true,
                    DoCloseEvent: false,
                    Data: {
                        Event: 'fw-businesses:Client:BicycleShop:PurchaseBike',
                        Type: "Client",
                        Model: bicycle.model,
                        Price: FW.Shared.CalculateTax('Vehicle Registration Tax', price),
                        Spawn: spawn,
                        IsRental: isRental
                    }
                }
            ]
        });
    };

    FW.Functions.OpenMenu({ MainMenuItems: MenuItems })
});

onNet("fw-businesses:Client:BicycleShop:PurchaseBike", async (Data: {
    Model: string;
    Price: number;
    IsRental: boolean;
    Spawn: Vector4Format
}) => {
    if (!FW.Functions.IsSpawnPointClear(Data.Spawn, 1.85)) {
        return FW.Functions.Notify("Er staat iets in de weg..", "error")
    }

    const [startX, startY, startZ] = GetEntityCoords(PlayerPedId(), false);
    const Finished = await FW.Functions.CompactProgressbar(15000, "Aanschaffen, niet bewegen...", false, true, {disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: false}, {}, {}, {}, false)
    if (!Finished) return;

    const [endX, endY, endZ] = GetEntityCoords(PlayerPedId(), false);

    if (new Vector3().setFromArray([endX, endY, endZ]).getDistanceFromArray([startX, startY, startZ]) > 2.0) {
        return FW.Functions.Notify("Idioot, je bent te ver weg gegaan..", "error")
    };

    const Result = await FW.SendCallback("fw-businesses:Server:BicycleShop:Purchase", Data.Model, Data.Price, Data.IsRental, Data.Spawn);
    if (!Result.Success) return FW.Functions.Notify("Niet genoeg cash..", "error");

    while (!NetworkDoesEntityExistWithNetworkId(Result.NetId)) await Delay(100);
    const Vehicle = NetworkGetEntityFromNetworkId(Result.NetId);

    setTimeout(() => {
        exp['fw-vehicles'].SetVehicleKeys(Result.Plate, true, false);
        exp['fw-vehicles'].SetFuelLevel(Vehicle, 100.0);
        exp['fw-vehicles'].LoadVehicleMeta(Vehicle);
        NetworkRegisterEntityAsNetworked(Vehicle);
        FW.Functions.SetVehiclePlate(Vehicle, Result.Plate);
        SetVehicleDirtLevel(Vehicle, 0.0);
    }, 500);
});

setImmediate(async () => {
    while (!exp['fw-config'].IsConfigReady()) {
        await Delay(100);
    };

    const {npcs} = await exp['fw-config'].GetModuleConfig("bus-bicycle-shop");
    if (!npcs || npcs.length == 0) return;

    for (let i = 0; i < npcs.length; i++) {
        const {id, isRental, ped, spawn} = npcs[i];

        exp['fw-ui'].AddEyeEntry(`bicycle_rental-${id}`, {
            Type: 'Entity',
            EntityType: 'Ped',
            SpriteDistance: 10.0,
            Distance: 1.5,
            Position: {x: ped.x, y: ped.y, z: ped.z, w: ped.w},
            Model: 'u_m_m_bikehire_01',
            Options: [
                {
                    Name: 'purchase',
                    Icon: 'fas fa-circle',
                    Label: `Fiets ${isRental ? "huren" : "kopen"}`,
                    EventType: 'Client',
                    EventName: 'fw-businesses:Client:BicycleShop:OpenMenu',
                    EventParams: { isRental, spawn },
                    Enabled: (Entity: number) => {
                        return true
                    },
                },
            ]
        });
    };
})