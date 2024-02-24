import { Delay, exp } from "../shared/utils"
export const FW = exp['fw-core'].GetCoreObject();

import { BoostLocations, DropoffLocations, ScratchLocations } from "../shared/locations";
import './handlers/laptop'
import { CurrentContract, CurrentTaskId } from "./handlers/boost";
import './handlers/garage';

onNet("fw-boosting:Client:CreateGroup", async () => {
    const MyJob = exp["fw-jobmanager"].GetMyJob()
    if (!MyJob || !MyJob.CurrentJob) return;
    if (MyJob.CurrentJob != "boosting") return;

    await FW.SendCallback("fw-jobmanager:Server:CreateGroup", "boosting");
    await Delay(100);
    FW.SendCallback("fw-jobmanager:Server:Ready", "boosting", exp["fw-jobmanager"].GetMyJob().CurrentGroup.Id)
});

setImmediate(() => {
    for (let i = 0; i < ScratchLocations.length; i++) {
        const Data = ScratchLocations[i];
        exp['fw-ui'].AddEyeEntry(`boosting-vin-laptop-${i}`, {
            Type: "Zone",
            SpriteDistance: 10.0,
            Distance: 2.5,
            ZoneData: {
                Center: Data.Laptop.Coords,
                Length: 0.3,
                Width: 0.3,
                Data: {
                    heading: Data.Laptop.Coords.w,
                    minZ: Data.Laptop.Coords.z - 0.1,
                    maxZ: Data.Laptop.Coords.z + 0.3
                },
            },
            Options: [
                {
                    Name: "boosting-vin-laptop",
                    Icon: "fas fa-laptop",
                    Label: "Bereid Vin Scratch voor",
                    EventType: "client",
                    EventName: "fw-boosting:Client:PrepareVIN",
                    EventParams: {},
                    Enabled: (Entity: number) => {
                        if (!CurrentContract) return false;
                        return CurrentContract.Vin && CurrentTaskId == 4
                    },
                },
            ],
        });

        if (Data.Laptop.Create) {
            exp['fw-assets'].RequestModelHash(Data.Laptop.Create);
            const Object = CreateObject(Data.Laptop.Create, Data.Laptop.Coords.x, Data.Laptop.Coords.y, Data.Laptop.Coords.z, true, false, false);
            FreezeEntityPosition(Object, true);
            SetEntityHeading(Object, Data.Laptop.Coords.w);
            SetEntityCollision(Object, false, false);
        };
    };

    // for (let i = 0; i < DropoffLocations.length; i++) {
    //     const {x, y, z} = DropoffLocations[i];

    //     const AreaBlip = AddBlipForRadius(x, y, z, 20.0);
    //     const BlipCoords = AddBlipForCoord(x, y, z);
    //     SetBlipSprite(BlipCoords, 227);
    //     SetBlipColour(BlipCoords, 3)
    //     SetBlipScale(BlipCoords, 0.5)
    //     BeginTextCommandSetBlipName("STRING");
    //     AddTextComponentString(`${i}`);
    //     EndTextCommandSetBlipName(BlipCoords);

    //     SetBlipHighDetail(AreaBlip, true);
    //     SetBlipColour(AreaBlip, 1)
    //     SetBlipAsShortRange(AreaBlip, true)
    //     SetBlipAlpha(AreaBlip, 255)
    // }
});