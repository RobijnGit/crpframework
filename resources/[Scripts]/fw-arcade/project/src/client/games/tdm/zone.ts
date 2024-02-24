import { Thread } from "../../../shared/classes/thread";
import { FW } from "../../client";

export const ZoneThread = new Thread("tick", 1);
export const TeamThread = new Thread("tick", 4);

let isOutsideZone: boolean = false;
let outsideTime: number = 0;

ZoneThread.addHook("active", (Data) => {
    if (IsPedDeadOrDying(PlayerPedId(), false)) return;

    const MyCoords = GetEntityCoords(PlayerPedId(), false);
    const Distance = Data.Center.getDistanceFromArray(MyCoords);
    const minDistance = Data.Radius - 10;
    const clampedDistance = Math.min(Math.max(Distance, minDistance), Data.Radius);
    const Alpha = lerp(0.0, 1.0, (clampedDistance - minDistance) / (Data.Radius - minDistance));

    DrawSphere(Data.Center.x, Data.Center.y, Data.Center.z, Data.Radius, 255, 0, 0, Math.min(0.5, Alpha));

    if (Distance > Data.Radius) {
        if (!isOutsideZone) {
            outsideTime = GetGameTimer() + 5000;
            isOutsideZone = true;
            FW.Functions.Notify("Ga terug in de zone, of je wordt over 5 seconden gekilled!", "error")
        };

        if (GetGameTimer() > outsideTime) {
            outsideTime = GetGameTimer() + 5000;
            if (Data.IsSpectator) {
                SetEntityCoords(PlayerPedId(), Data.Cam.x, Data.Cam.y, Data.Cam.z, false, false, false, false);
            } else {
                SetEntityHealth(PlayerPedId(), 0.0);
            }
        }
    } else if (isOutsideZone) {
        isOutsideZone = false;
        outsideTime = 0;
    }
});

TeamThread.addHook("active", (Data) => {
    for (let i = 0; i < Data.Players.length; i++) {
        const {Source, Team} = Data.Players[i];

        if (Source != GetPlayerServerId(PlayerId())) {
            const Ped = GetPlayerPed(GetPlayerFromServerId(Source));
            const [x, y, z] = GetPedBoneCoords(Ped, 0x796e, 0, 0, 0);
            const isFriendly = Data.Team == Team;
    
            let markerColor: [number, number, number] = [235, 47, 47];
            if (isFriendly) markerColor = [39, 84, 196];
    
            // @ts-ignore
            DrawMarker(
                20,
                x, y, z + 0.4,
                0, 0, 0,
                180.0, 0, 0,
                0.3, 0.3, 0.3,
                ...markerColor, 200,
                false, false, 2, true, false, false
            )
        };
    }
});

function lerp(min: number, max: number, t: number): number {
    return min + t * (max - min);
};