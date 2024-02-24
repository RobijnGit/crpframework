import { Vector3 } from "../../../shared/classes/math";
import { Thread } from "../../../shared/classes/thread";
import { Delay } from "../../../shared/utils";
import { FW } from "../../client";
import { currentLobby } from "../../lobby/utils";
import { MyTeam, currentHolder, currentMap } from "./base";

export const ZoneThread = new Thread("tick", 4);
export const TeamThread = new Thread("tick", 4);

let isOutsideZone: boolean = false;
let outsideTime: number = 0;
let lastRepair: number = 0;
let Respawning: boolean = false;

ZoneThread.addHook("preStart", () => {
    lastRepair = GetGameTimer() + 3000;
})

ZoneThread.addHook("active", async (Data) => {
    if (Respawning) return;

    const Vehicle = GetVehiclePedIsIn(PlayerPedId(), false);
    const MyCoords = GetEntityCoords(Vehicle || PlayerPedId(), false);
    const Distance = Data.Center.getDistanceFromArray(MyCoords);
    const minDistance = Data.Radius - 30;
    const clampedDistance = Math.min(Math.max(Distance, minDistance), Data.Radius);
    const Alpha = lerp(0.0, 1.0, (clampedDistance - minDistance) / (Data.Radius - minDistance));

    DrawSphere(Data.Center.x, Data.Center.y, Data.Center.z, Data.Radius, 255, 0, 0, Math.min(0.5, Alpha));

    if (GetGameTimer() > lastRepair) {
        SetVehicleFixed(Vehicle);
        lastRepair = GetGameTimer() + 3000;
    }

    if (Distance > Data.Radius || MyCoords[2] <= 0.0) {
        if (!isOutsideZone) {
            outsideTime = GetGameTimer() + 10000;
            isOutsideZone = true;
            FW.Functions.Notify("Ga terug in de zone!", "error")
        };

        if (GetGameTimer() > outsideTime || MyCoords[2] <= 0.0) {
            Respawning = true;
            outsideTime = GetGameTimer() + 8000;
            DoScreenFadeOut(500);
            await Delay(600);
            
            if (Data.IsSpectator) {
                SetEntityCoords(PlayerPedId(), Data.Center.x, Data.Center.y, Data.Center.z + 50.0, false, false, false, false);
            } else {
                const Lobby = await FW.SendCallback("fw-arcade:Server:GetLobby", 'vehicleTag', currentLobby);
                if (!Lobby) return;
    
                const {citizenid} = FW.Functions.GetPlayerData();
                const TeamPlayers = Lobby.Players.filter((Val: {Team: number}) => Val.Team == MyTeam);
                const TeamIndex = TeamPlayers.findIndex((Val: {Cid: string}) => Val.Cid == citizenid);
                const Spawns = currentMap.Spawners;
                const Location = Spawns[MyTeam - 1][TeamIndex];
                SetEntityCoords(Vehicle, Location.x, Location.y, Location.z, false, false, false, false);
                SetEntityHeading(Vehicle, Location.w);

                if (currentHolder[0] == MyTeam && currentHolder[1] == Lobby.Players.findIndex((Val: {Cid: string}) => Val.Cid == citizenid)) {
                    FW.TriggerServer("fw-arcade:Server:VTag:RouletteTag", currentLobby);
                };
            };

            await Delay(500);
            DoScreenFadeIn(1000);
            Respawning = false;
        }
    } else if (isOutsideZone) {
        isOutsideZone = false;
        outsideTime = 0;
    };
});

TeamThread.addHook("active", async (Data) => {
    const [x, y, z] = GetEntityCoords(Data.Vehicle, false);
    const isFriendly = Data.Holder == Data.MyTeam;

    let markerColor: [number, number, number] = [235, 47, 47];
    if (isFriendly) markerColor = [47, 255, 47];

    // @ts-ignore
    DrawMarker(
        20,
        x, y, z + 1.5,
        0, 0, 0,
        180.0, 0, 0,
        1.0, 1.0, 1.0,
        ...markerColor, 200,
        false, false, 2, false, false, false
    );

    if (IsControlJustPressed(0, 86) && !FW.Throttled("arcadevTag-take-tag", 100)) {
        const Vehicle = GetVehiclePedIsIn(PlayerPedId(), false);
        if (Data.Vehicle == Vehicle) return;

        const Distance = new Vector3().setFromArray(GetEntityCoords(Vehicle, false)).getDistanceFromArray([x,y,z]);
        if (Distance <= 5.0) {
            const Succeeded = await FW.SendCallback("fw-arcade:Server:VTag:StealTag", currentLobby);
            if (Succeeded) {
                SetEntityAlpha(Vehicle, 150, true);
                setTimeout(() => {
                    ResetEntityAlpha(Vehicle);
                }, 5000);
            };
        };
    };
});

function lerp(min: number, max: number, t: number): number {
    return min + t * (max - min);
};