import { Vector4Format } from "../../shared/classes/math";
import { Delay, exp } from "../../shared/utils";
import { FW } from "../client";

// { x: -1507.61, y: -3005.03, z: -81.56, w: 358.62 }

const VehicleLocations: Vector4Format[] = [
    { x: -1498.82, y: -2989.57, z: -82.88, w: 1.61 },
    { x: -1502.53, y: -2989.7, z: -82.88, w: 0.31 },
    { x: -1506.4, y: -2989.71, z: -82.88, w: 359.65 },
    { x: -1510.3, y: -2989.61, z: -82.88, w: 0.36 },
    { x: -1514.64, y: -2989.37, z: -82.88, w: 1.39 },
    { x: -1514.26, y: -2996.61, z: -82.88, w: 1.05 },
    { x: -1510.14, y: -2996.8, z: -82.88, w: 1.5 },
    { x: -1506.48, y: -2996.46, z: -82.89, w: 2.41 },
    { x: -1502.58, y: -2996.37, z: -82.88, w: 1.9 },
    { x: -1499.02, y: -2995.93, z: -82.79, w: 357.48 }
];

let vehicleCache: Array<{
    Vehicle: number;
}> = [];

const LoadGarage = async () => {
    while (!exp['fw-config'].IsConfigReady()) {
        await Delay(100);
    };

    const {specialModels} = await exp['fw-config'].GetModuleConfig("boosting");
    if (!specialModels || specialModels.length == 0) return;

    console.log(specialModels);

    // Spawn the fake models.
    for (let i = 0; i < specialModels.length; i++) {
        const ModelName = specialModels[i];
        await exp['fw-assets'].RequestModelHash(ModelName);

        const Vehicle = CreateVehicle(ModelName, VehicleLocations[i].x, VehicleLocations[i].y, VehicleLocations[i].z, VehicleLocations[i].w, false, true);
        SetEntityHeading(Vehicle, VehicleLocations[i].w);
        PlaceObjectOnGroundProperly(Vehicle);
        FreezeEntityPosition(Vehicle, true);
        SetVehicleUndriveable(Vehicle, true);
        SetVehicleDoorsLocked(Vehicle, 2);
        
        vehicleCache.push({
            Vehicle: Vehicle
        })
    };

    vehicleCache = [];

    // specialModels

};

const UnloadGarage = () => {
    for (let i = 0; i < vehicleCache.length; i++) {
        const {Vehicle} = vehicleCache[i];
        DeleteVehicle(Vehicle);
    }
};

on("onResourceStop", UnloadGarage);

onNet("fw-boosting:Client:OpenContractSales", async () => {
    const Result = await FW.SendCallback("fw-boosting:Server:GetContractsPool");

    const ContextItems = [
        {
            Icon: "exclemation-cricle",
            Title: "Contracten die tekoop zijn",
            Desc: "Kom later terug voor andere opties.."
        }
    ];

    for (let i = 0; i < Result.length; i++) {
        const {Model, IsPurchased} = Result[i];
        
        const SharedData = FW.Shared.HashVehicles[GetHashKey(Model)]
        ContextItems.push({
            Icon: "car",
            Title: `<div></div>`,
            Desc: `Klasse: ${Model.Class}`
        });
    };

});

setImmediate(() => {
    exp['PolyZone'].CreateBox({
        center: {x: -1507.69, y: -3010.94, z: -79.25},
        length: 72.2,
        width: 30.2,
    }, {
        name: "boosting-garage",
        heading: 0,
        minZ: -85.05,
        maxZ: -75.05,
    }, (IsInside: boolean, Zone: any, Points: any) => {
        if (!IsInside) {
            UnloadGarage()
            return;
        };

        LoadGarage();
    })

    exp['fw-ui'].AddEyeEntry(`boosting_special_contracts_buyer`, {
        Type: 'Entity',
        EntityType: 'Ped',
        SpriteDistance: 10.0,
        Position: { x: -1507.61, y: -3005.03, z: -82.56, w: 358.62 },
        Model: "mp_m_weapwork_01",
        Options: [
            {
                Name: 'talk',
                Icon: 'fas fa-comment',
                Label: 'Praten',
                EventType: 'Client',
                EventName: 'fw-boosting:Client:OpenContractSales',
                EventParams: {},
                Enabled: () => true,
            }
        ]
    })
});