import { ClearPlayerBucket, GetLobby, sourceToLobby } from "../../lobby/main";
import { Maps } from "../../../shared/games/vehicle-tag/maps";
import { FW } from "../../server";
import { Vector3, Vector4Format } from "../../../shared/classes/math";
import { Delay } from "../../../shared/utils";
import { SendLobbyNotify } from "../../lobby/utils";

const activeTags: {[key: number]: any} = {};
const tagVehicles: {[key: number]: Array<{Source: number, NetId: number}>} = {};

export default () => {
    FW.Functions.CreateCallback("fw-arcade:Server:VTag:StealTag", (Source: number, Cb: Function, LobbyId: number) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return Cb(false);

        const {Game, Id} = sourceToLobby[Source];
        if (Game != 'vehicleTag' || Id != LobbyId || activeTags[Id].TagCooldown) return Cb(false);

        const Lobby = GetLobby(Game, Id);
        if (!Lobby) return Cb(false);

        // @ts-ignore
        const ClaimerVehicle = GetVehiclePedIsIn(GetPlayerPed(Source.toString()), false);
        // @ts-ignore
        const ClaimerCoords = GetEntityCoords(ClaimerVehicle);
        // @ts-ignore
        const TagCoords = GetEntityCoords(GetVehiclePedIsIn(GetPlayerPed(Lobby.Players[activeTags[LobbyId].TagHolder[1]].Source.toString()), false));

        const Distance = new Vector3().setFromArray(ClaimerCoords).getDistanceFromArray(TagCoords);
        if (Distance > 5.0) return Cb(false);

        const PlayerIndex = Lobby.Players.findIndex(Val => Val.Cid == Player.PlayerData.citizenid);
        if (PlayerIndex == -1) return Cb(false);

        activeTags[Id].TagCooldown = true;
        activeTags[Id].TagHolder = [Lobby.Players[PlayerIndex].Team, PlayerIndex];

        Cb(true);

        SendLobbyNotify(Game, Id, `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname} heeft de tag overgenomen!`);
        setTimeout(() => {
            activeTags[Id].TagCooldown = false;
        }, 5000)
    });

    FW.Functions.CreateCallback("fw-arcade:Server:VTag:SpawnVehicle", async (Source: number, Cb: Function, Model: string, Coords: Vector4Format, Plate: string) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return Cb(false);

        const {Game, Id} = sourceToLobby[Source];
        const Lobby = GetLobby(Game, Id);
        if (!Lobby) return Cb(false);

        const NetId = await FW.Functions.SpawnVehicle(Source, Model, {
            x: Coords.x,
            y: Coords.y,
            z: Coords.z,
            a: Coords.w,
        }, false, Plate);

        const Vehicle = NetworkGetEntityFromNetworkId(NetId);
        while (!DoesEntityExist(Vehicle)) {
            await Delay(25);
        };

        if (!tagVehicles[Lobby.Id]) tagVehicles[Lobby.Id] = [];
        tagVehicles[Lobby.Id].push({Source, NetId});

        const TeamPlayer = Lobby.Players.find(Val => Val.Source == Source);
        if (!TeamPlayer) return Cb(false);

        SetVehicleColours(Vehicle, TeamPlayer.Team == 1 ? 0 : 135, TeamPlayer.Team == 1 ? 0 : 135);
        SetVehicleNumberPlateText(Vehicle, Plate);

        if (tagVehicles[Lobby.Id].length == Lobby.Players.length) {
            Lobby.TriggerEvent("fw-arcade:Client:VTag:Ready");
        };

        Cb(NetId)
    });

    FW.RegisterServer("fw-arcade:Server:VTag:RouletteTag", (Source: number, LobbyId: number) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;

        VehicleTag.RouletteTag(LobbyId);
    });
}

export const VehicleTag = {
    SetupGame: (LobbyId: number) => {
        const Lobby = GetLobby('vehicleTag', LobbyId);
        if (!Lobby) return;

        Lobby.TriggerEvent("fw-arcade:Client:VTag:LoadGame", {
            Map: Lobby.Settings.Map,
            Vehicles: Lobby.Settings.Vehicles,
        });

        const Map = Maps.find(Val => Val.Name == Lobby.Settings.Map) || Maps[0];

        const Interval = setInterval(() => {
            const TagHolder = activeTags[LobbyId].TagHolder[0] - 1;
            if (!Lobby.Players[activeTags[LobbyId].TagHolder[1]]) return;

            // @ts-ignore
            const TagCoords = GetEntityCoords(GetPlayerPed(Lobby.Players[activeTags[LobbyId].TagHolder[1]].Source.toString()));

            if (Map.Coords.getDistanceFromArray(TagCoords) < Map.Radius) {
                activeTags[LobbyId].Points[TagHolder] += 1;
            } else if (activeTags[LobbyId].Points[TagHolder] > 0) {
                activeTags[LobbyId].Points[TagHolder] -= 1;
            };

            Lobby.TriggerEvent("fw-arcade:Client:VTag:UpdateInfo", {
                Timer: activeTags[LobbyId].Timer,
                Points: activeTags[LobbyId].Points,
                TagHolder: activeTags[LobbyId].TagHolder,
                PointsGoal: Lobby.Settings.Points,
            });

            activeTags[LobbyId].Timer -= 1;

            if (activeTags[LobbyId].Timer <= 0) {
                VehicleTag.UnloadGame(LobbyId, 0);
            } else if (activeTags[LobbyId].Points[TagHolder] >= Lobby.Settings.Points) {
                VehicleTag.UnloadGame(LobbyId, TagHolder + 1);
            };
        }, 1000);

        activeTags[LobbyId] = {
            Points: [0, 0],
            Timer: Lobby.Settings.Time * 60,
            TagHolder: [2, Lobby.Players.findIndex(Val => Val.Team == 2)],
            TagCooldown: false,
            TimerInterval: Interval,
        };
    },
    UnloadGame: (LobbyId: number, WinningTeam: false | number) => {
        const Lobby = GetLobby('vehicleTag', LobbyId);
        if (!Lobby) return;

        for (let i = 0; i < tagVehicles[LobbyId].length; i++) {
            const {NetId} = tagVehicles[LobbyId][i];
            DeleteEntity(NetworkGetEntityFromNetworkId(NetId));
        };

        tagVehicles[LobbyId] = [];
        clearInterval(activeTags[LobbyId].TimerInterval);
        delete activeTags[LobbyId]

        Lobby.InMatch = false;
        Lobby.TriggerEvent("fw-arcade:Client:SetGameActive", {State: false});
        Lobby.TriggerEvent("fw-arcade:Client:VTag:UnloadGame");

        setTimeout(() => {
            for (let i = 0; i < Lobby.Spectators.length; i++) {
                const {Source} = Lobby.Spectators[i];
                ClearPlayerBucket(Source);
            };

            for (let i = 0; i < Lobby.Players.length; i++) {
                const {Source, Team} = Lobby.Players[i];
                ClearPlayerBucket(Source);

                if (WinningTeam != false) {
                    emitNet("FW:Notify", Source, Team == WinningTeam ? "Je team heeft gewonnen! Gefeliciteerd!" : "Je team heeft verloren.. Volgende keer beter!", Team == WinningTeam ? "success" : "error")
                };
            };
        }, 750);
    },
    RouletteTag: (LobbyId: number) => {
        const Lobby = GetLobby('vehicleTag', LobbyId);
        if (!Lobby) return;

        let [Team, Index] = activeTags[LobbyId].TagHolder;
        Team = Team == 1 ? 2 : 1;

        const TeamPlayers = Lobby.Players.filter(Val => Val.Team == Team);
        const NewHolder = Lobby.Players.findIndex(Val => Val.Team == Team && (TeamPlayers.length == 1 || Val.Source != (Lobby.Players[Index]?.Source || 0)));

        activeTags[LobbyId].TagHolder = [Team, NewHolder];
    },
    DeleteVehicle: (LobbyId: number, Source: number) => {
        const {NetId} = tagVehicles[LobbyId].find(Val => Val.Source == Source) || {NetId: 0};
        if (NetId == 0) return;

        DeleteEntity(NetworkGetEntityFromNetworkId(NetId));
    }
};