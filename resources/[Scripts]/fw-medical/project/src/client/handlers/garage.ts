import { Vector3 } from "../../shared/classes/math";
import { Thread } from "../../shared/classes/thread";
import { Config } from "../../shared/config";
import { Delay, exp } from "../../shared/utils";
import { FW } from "../client";

const HelipadThread = new Thread("tick", 4);
const Helipads = [
    {x: 313.45, y: -1465.2, z: 46.51, w: 153.1 },
    {x: 1637.23, y: 3654.64, z: 35.34, w: 52.31 },
    {x: -245.75, y: 6323.43, z: 37.62, w: 314.31 },
    {x: -789.86, y: -1192.4, z: 52.92, w: 48.1 }
];

const GetClosestSpot = () => {
    let SpotId: number = 0;
    let Distance: number = Number.MAX_SAFE_INTEGER;
    const [x, y, z]: Array<number> = GetEntityCoords(PlayerPedId(), false)

    for (let i = 0; i < Helipads.length; i++) {
        const Data = Helipads[i];
        const Dist = new Vector3().setFromObject(Data).getDistance({x, y, z});
        if (Distance > Dist) {
            SpotId = i;
            Distance = Dist;
        };
    };

    return Helipads[SpotId];
};

HelipadThread.addHook('preStart', () => {
    exp['fw-ui'].ShowInteraction(IsPedInAnyHeli(PlayerPedId()) ? "[E] Helikopter Inleveren" : "[E] Helikopter Pakken")
});

HelipadThread.addHook('active', async () => {
    if (!IsControlJustReleased(0, 38)) return;

    if (IsPedInAnyHeli(PlayerPedId())) {
        FW.VSync.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), false));
        return
    };

    const Spot = GetClosestSpot()
    const NetId: number = await FW.SendCallback("FW:server:spawn:vehicle", "emsaw139", { x: Spot.x, y: Spot.y, z: Spot.z, a: Spot.w });

    while (!NetworkDoesEntityExistWithNetworkId(NetId)) {
        await Delay(100)
    };
    
    const Vehicle = NetToVeh(NetId);
    while (!DoesEntityExist(Vehicle)) {
        await Delay(100)
    }

    SetEntityVisible(Vehicle, false, false);
    
    setTimeout(() => {
        const Plate: string = GetVehicleNumberPlateText(Vehicle);
        SetVehicleModKit(Vehicle, 0);
        NetworkRegisterEntityAsNetworked(Vehicle)
        exp['fw-vehicles'].SetVehicleKeys(Plate, true, false);
        exp['fw-vehicles'].SetFuelLevel(Vehicle, 100);
        SetEntityVisible(Vehicle, true, true);
    }, 750)

});

HelipadThread.addHook('afterStop', () => {
    exp['fw-ui'].HideInteraction()
});

on("fw-medical:Client:PurchaseVehicle", () => {
    if (FW.Functions.GetPlayerData().job.name != 'ems') {
        return FW.Functions.Notify("Geen toegang..", "error")
    }

    let BuyVehicles: Array<any> = [];
    const EMSVehicles = [ 'emsspeedo', 'emstau', 'emsmotor', 'emsexp' ]

    for (let i = 0; i < EMSVehicles.length; i++) {
        const Model = EMSVehicles[i];
        
        const SharedData = FW.Shared.HashVehicles[GetHashKey(Model)]
        BuyVehicles.push({
            Icon: 'car',
            Title: SharedData.Name,
            Desc: exp['fw-businesses'].NumberWithCommas(FW.Shared.CalculateTax("Vehicle Registration Tax", SharedData.Price)),
            Disabled: !CanUseVehicle(Model),
            SecondMenu: [
                {
                    Icon: 'user',
                    Title: 'Bevestig aankoop',
                    CloseMenu: true,
                    Data: { Event: 'fw-hospital:Server:PurchaseVehicle', Vehicle: Model }
                },
            ]
        })

        if (FW.Functions.GetPlayerData().metadata.ishighcommand) {
            BuyVehicles[BuyVehicles.length - 1].SecondMenu[1] = {
                Icon: 'people-arrows',
                Title: 'Bevestig aankoop (Gezamelijk)',
                CloseMenu: true,
                Data: { Event: 'fw-hospital:Server:PurchaseVehicle', Vehicle: Model, Shared: true }
            }
        }
    }

    FW.Functions.OpenMenu({
        MainMenuItems: BuyVehicles
    })
})

const CanUseVehicle = (Model: string): boolean => {
    const VehicleCerts = FW.Functions.GetPlayerData().metadata['ems-vehicle']
    return VehicleCerts[Config.VehicleCerts[Model].toUpperCase()]
}

const SpawnHelicopter = (IsInside: boolean) => {
    if (!IsInside) return HelipadThread.stop();

    const Job = FW.Functions.GetPlayerData().job.name
    if (Job != 'ems') return;

    HelipadThread.start();
};

setImmediate(() => {
    exp['PolyZone'].CreateBox({
        center: new Vector3(313.31, -1464.95, 46.51),
        length: 11.0,
        width: 11.0,
    }, {
        name: "ems-crusade-helipad",
        heading: 320,
        minZ: 45.51, maxZ: 49.51
    }, SpawnHelicopter)

    exp['PolyZone'].CreateBox({
        center: new Vector3(1636.53, 3655.24, 35.34),
        length: 9.4,
        width: 9.0,
    }, {
        name: "ems-sandy-helipad",
        heading: 355,
        minZ: 34.34, maxZ: 37.94
    }, SpawnHelicopter)

    exp['PolyZone'].CreateBox({
        center: new Vector3(-245.9, 6323.09, 37.62),
        length: 11.0,
        width: 11.0,
    }, {
        name: "ems-paleto-helipad",
        heading: 315,
        minZ: 36.62, maxZ: 40.62
    }, SpawnHelicopter)

    exp['PolyZone'].CreateBox({
        center: new Vector3(-791.06, -1191.4, 53.03),
        length: 8.0,
        width: 8.0,
    }, {
        name: "ems-viceroy-helipad",
        heading: 315,
        minZ: 52.03, maxZ: 56.03
    }, SpawnHelicopter)

    exp['fw-ui'].AddEyeEntry("crusade_purchase_vehicle", {
        Type: 'Entity',
        EntityType: 'Ped',
        SpriteDistance: 10.0,
        Distance: 1.5,
        Position: {x: 317.48, y: -1417.98, z: 28.92, w: 142.06},
        Model: 's_m_m_paramedic_01',
        Options: [
            {
                Name: "purchase",
                Icon: "fas fa-garage-car",
                Label: "Voertuig Aanschaffen",
                EventType: "Client",
                EventName: "fw-medical:Client:PurchaseVehicle",
                EventParams: {},
                Enabled: () => true,
            }
        ]
    })
})