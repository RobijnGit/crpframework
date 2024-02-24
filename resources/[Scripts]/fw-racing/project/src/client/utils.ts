import { Vector3, Radians, Vector3Format } from "../shared/classes/math"
import { Checkpoint } from "../shared/types";
import { Config } from "../shared/config";
import { FW } from "./client";

export const HasRacingUsb = () => {
    const Cid = FW.Functions.GetPlayerData().citizenid;
    const RacingUsbItem = global.exports['fw-inventory'].GetItemByName('racing-usb');
    const PdRacingUsbItem = global.exports['fw-inventory'].GetItemByName('racing-usb-pd');

    const HasRacingUsb = RacingUsbItem && RacingUsbItem.Info.Alias && RacingUsbItem.Info._Owner == Cid;
    const HasPdRacingUsb = PdRacingUsbItem && IsGov();

    return [
        HasRacingUsb,
        HasPdRacingUsb,
        RacingUsbItem?.Info?.Alias
    ];
};
global.exports("HasRacingUsb", HasRacingUsb);

export const CanJoinOrStartRace = async (Id: number): Promise<[boolean, string]> => {
    const Race = await FW.SendCallback("fw-racing:Server:GetRaceData", Id);
    if (!Race) return [false, "Ongeldige Race!"];

    const Vehicle = GetVehiclePedIsIn(PlayerPedId(), false);
    if (!Vehicle) return [false, "Je moet in een voertuig zitten!"];

    const Driver = GetPedInVehicleSeat(Vehicle, -1);
    if (Driver != PlayerPedId()) return [false, "Je moet in de bestuurdersstoel zitten!"];

    const Model = GetEntityModel(Vehicle);
    const VehicleData = FW.Shared.HashVehicles[Model];
    if (!VehicleData) return [false, "Dit voertuig kan niet gebruikt worden in een race!"];
    if (Race.Class != "Open" && VehicleData.Class != Race.Class) return [false, `Je moet in een ${Race.Class} klasse voertuig zitten!`]

    // const [x, y, z] = GetEntityCoords(PlayerPedId(), false);
    // const Distance = new Vector3(Race.Coords.x, Race.Coords.y, Race.Coords.z).getDistance({x, y, z});
    // if (Distance > 50.0) return [false, "Je bent te ver van de race vandaan."];

    return [true, ""];
};

export const IsGovWithUsb = () => {
    const [p0, HasPDRacingUsb, p2] = HasRacingUsb();
    return HasPDRacingUsb;
}
global.exports("IsGovWithUsb", IsGovWithUsb)

export const IsGov = () => {
    const PlayerData = FW.Functions.GetPlayerData();
    return (PlayerData.job.name == 'police' || PlayerData.job.name == 'ems') && PlayerData.job.onduty
};

export const RayCast = (Origin: Vector3Format, Destination: Vector3Format, Flags: number) => {
    const Ray = StartShapeTestRay(Origin.x, Origin.y, Origin.z, Destination.x, Destination.y, Destination.z, Flags, 0, 0)
    return GetShapeTestResult(Ray)
};

export const HasHitCheckpoint = (Checkpoint: Checkpoint) => {
    const CenterVector = new Vector3().setFromObject(Checkpoint.Pos);
    // Raycast is nice and all, but may sometimes not work
    // Recommend to use radius instead, its not nice or super accurate, but it will work better than raycast.
    // Issues where the raycast breaks:
    // - If going too fast, it may take too long to process.
    // - If vehicle is too close to the ground and race was setup in a SUV, the vehicle won't be high enough to hit raycast.
    // - If any NPC vehicle is on the line, it will target that instead of the player, and thus not counting the hit.
    if (Config.RaycastBasedCheckpoint) {
        const [LeftPos, RightPos] = GetCheckpointPositions(CenterVector, Checkpoint.Radius, new Vector3().setFromObject(Checkpoint.Rotation));
    
        if (Config.DrawCheckpointLine) {
            DrawLine(LeftPos.x, LeftPos.y, LeftPos.z, RightPos.x, RightPos.y, RightPos.z, 0, 255, 0, 255)
        }
    
        const [p1, Hit, HitPos, p4, HitEntity] = RayCast(LeftPos, RightPos, 2);
        if (Hit && HitEntity == GetVehiclePedIsIn(PlayerPedId(), false)) {
            return true
        }
    
        return false
    } else {
        const Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if (!Vehicle) return false;

        if (Config.DrawCheckpointLine) {
            DrawSphere(CenterVector.x, CenterVector.y, CenterVector.z, Checkpoint.Radius + Config.RadiusCheckpointBuffer, 0, 255, 0, 0.2)
        }

        return CenterVector.getDistance(new Vector3().setFromArray(GetEntityCoords(Vehicle, false))) < (Checkpoint.Radius + Config.RadiusCheckpointBuffer);
    }
};

export const GetCheckpointPositions = (Center: Vector3, Radius: number, Rotation: Vector3) => {
    const LeftPos = new Vector3(Center.x - Radius, Center.y, Center.z);
    const RightPos = new Vector3(Center.x + Radius, Center.y, Center.z);

    return [
        Rotate(Center, LeftPos, Rotation),
        Rotate(Center, RightPos, Rotation)
    ];
};

export const Rotate = (Origin: Vector3, Point: Vector3, Rotation: Vector3) => {
    const Diff = Point.sub(Origin);

    const CosY = Math.cos(Radians(Rotation.y));
    const SinY = Math.sin(Radians(Rotation.y));
    const CosZ = Math.cos(Radians(Rotation.z));
    const SinZ = Math.sin(Radians(Rotation.z));

    const RotatedX = Diff.x * CosZ - Diff.y * SinZ;
    const RotatedY = Diff.x * SinZ + Diff.y * CosZ;
    const RotatedZ = Diff.z;

    const FinalX = RotatedX * CosY + RotatedZ * SinY;
    const FinalY = RotatedY;
    const FinalZ = RotatedZ * CosY - RotatedX * SinY;

    return new Vector3(FinalX, FinalY, FinalZ).add(Origin);
};

export const AddCheckpointBlip = (Data: Checkpoint, Id: number, IsFinish: boolean = false) => {
    let Blip = AddBlipForCoord(Data.Pos.x, Data.Pos.y, Data.Pos.z)

    if (IsFinish) {
        SetBlipSprite(Blip, 38)
        SetBlipColour(Blip, 4)
    } else {
        ShowNumberOnBlip(Blip, Id)
        SetBlipColour(Blip, 7)
    };

    SetBlipDisplay(Blip, 8)
    SetBlipScale(Blip, 1.2)
    SetBlipAsShortRange(Blip, false)

    return Blip;
}