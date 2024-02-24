import { Vector4Format } from "../../shared/classes/math";
import { Delay, NumberWithCommas } from "../../shared/utils";
import { FW } from "../server";
import { VehicleRegistration } from "./vehicle-shop";

FW.Functions.CreateCallback("fw-businesses:Server:BicycleShop:Purchase", async (Source: number, Cb: Function, Model: string, Price: number, IsRental: boolean, Spawn: Vector4Format) => {
    const Player = FW.Functions.GetPlayer(Source)
    if (!Player) return;

    if (!Player.Functions.RemoveMoney("cash", FW.Shared.CalculateTax("Vehicle Registration Tax", Price), "Purchased Bicycle")) {
        Cb({Success: false})
        return;
    };

    const Plate = await FW.Functions.GeneratePlate();
    
    const NetId = FW.Functions.SpawnVehicle(Source, Model, {
        x: Spawn.x,
        y: Spawn.y,
        z: Spawn.z + 1.5,
        a: Spawn.w,
    }, false, Plate);

    const Vehicle = NetworkGetEntityFromNetworkId(NetId);

    while (!DoesEntityExist(Vehicle)) {
        await Delay(25);
    };

    SetEntityHeading(Vehicle, Spawn.w + 0.0);

    if (!IsRental) {
        const SharedData = FW.Shared.HashVehicles[GetHashKey(Model)];
        const VIN = await FW.Functions.GenerateVin();

        const _Date = new Date();
        const Year = _Date.getFullYear();
        const Month = _Date.getMonth();
        const Day = _Date.getDate();
        const Hour = _Date.getHours();
        const Minutes = _Date.getMinutes();

        let TemplateData: string[] = [
            SharedData.Name,
            Model,
            Plate,
            VIN,
            `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}`,
            `Skelet Spoke`,
            `${Day}/${Month}/${Year} ${Hour}:${Minutes}`,
            NumberWithCommas(Price)
        ];
        emit('fw-phone:Server:Documents:AddDocument', '1001', {
            Type: 3,
            Title: `${SharedData.Name} - ${Plate}`,
            Content: VehicleRegistration.replace(/%s/g, () => TemplateData.shift() || ''),
            Signatures: [
                { Signed: true, Name: 'De Staat', Timestamp: _Date.getTime(), Cid: '1001' },
                { Signed: true, Name: `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}`, Timestamp: _Date.getTime(), Cid: Player.PlayerData.citizenid },
            ],
            Sharees: [ Player.PlayerData.citizenid ],
            Finalized: 1,
        });
    };

    Cb({Success: true, Plate, NetId})
});