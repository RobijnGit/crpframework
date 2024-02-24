import { FW } from "../server";
import { DegradeArcadeMachine, IsCidInAnyLobby, IsCidInLobby, SendLobbyNotify, TriggerLobbyEvent } from "./utils";
import { Vector3, Vector3Format } from "../../shared/classes/math";
import { Delay, GetRandom, exp } from "../../shared/utils";
import { TDM } from "../games/tdm";
import { VehicleTag } from "../games/vehicle-tag";

type LobbyPlayer = {
    Cid: string;
    Source: number;
    Team: number;
    Name: string;
}

type LobbyGroup = {
    Id: number;
    Matchmaker: string;
    Players: LobbyPlayer[];
    Spectators: Array<{
        Cid: string;
        Source: number;
    }>;
    Password: string;
    Name: string;
    Sessions: number;
    Settings: {[key: string]: any};
    MaxPlayers: number;
    TriggerEvent: Function;
    InMatch: boolean;
}

// [game]: lobby data
let lobbyIds = 0;
export const sourceToLobby: {[key: number]: { Game: string, Id: number }} = {};
const activeLobbys: {
    [key: string]: Array<LobbyGroup>
} = {};

export default () => {
    FW.RegisterServer("fw-arcade:Server:CreateLobby", async (Source: number, Game: string, LobbySettings: any) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return Player.Functions.Notify("Lobby niet aangemaakt!", "error");

        const { arcadeMachines } = await exp['fw-config'].GetModuleConfig("bus-arcade", {arcadeMachines: {}});
        if (arcadeMachines[Game] == undefined || arcadeMachines[Game] <= GetRandom(1, 10) - 1.0) {
            return Player.Functions.Notify("Kan de lobby niet starten, de arcadekast is kapot..", "error");
        };

        if (activeLobbys[Game] == undefined) {
            activeLobbys[Game] = [];
            // console.log(`Created lobby array entry for ${Game}!`)
        };

        lobbyIds += 1;
        const LobbyData: LobbyGroup = {
            Id: lobbyIds,
            Matchmaker: Player.PlayerData.citizenid,
            Players: [
                {
                    Cid: Player.PlayerData.citizenid,
                    Source: Player.PlayerData.source,
                    Name: `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}`,
                    Team: 1
                }
            ],
            Spectators: [],
            Password: LobbySettings.Password,
            Name: LobbySettings.Name,
            Sessions: 3,
            Settings: LobbySettings,
            MaxPlayers: await exp['fw-businesses'].HasPlayerBusinessPermission("Coopers Arcade", Source, "VehicleSales") ? 36 : 12,
            InMatch: false,

            // Methods
            TriggerEvent: (Event: string, Payload: any) => {
                TriggerLobbyEvent(Game, LobbyData.Id, Event, Payload);
            }
        }

        activeLobbys[Game].push(LobbyData);
        sourceToLobby[Source] = { Game, Id: LobbyData.Id };

        // console.log(`Created lobby for ${Game}, lobby name: ${LobbySettings.Name}!`);

        Player.Functions.Notify("Lobby aangemaakt!");
        emitNet("fw-arcade:Client:SetCurrentLobby", Source, Game, LobbyData.Id);
        emitNet("fw-arcade:Client:OpenLobbyMenu", Source, {Game});
    });

    FW.RegisterServer("fw-arcade:Server:JoinLobby", (Source: number, Game: string, Id: number, Password: string) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;

        const Lobby = GetLobby(Game, Id);
        if (!Lobby) return Player.Functions.Notify("Lobby bestaat niet..", "error");
        if (Lobby.Password != Password) return Player.Functions.Notify("Wachtwoord klopt niet..", "error");

        const TeamId = GetTeamId(Lobby.Players);
        SendLobbyNotify(Game, Id, `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname} heeft de lobby gejoined!`)

        sourceToLobby[Source] = { Game, Id };
        Lobby.Players.push({
            Cid: Player.PlayerData.citizenid,
            Source: Player.PlayerData.source,
            Name: `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}`,
            Team: TeamId
        })

        Player.Functions.Notify("Je bent een lobby gejoined.");
        emitNet("fw-arcade:Client:SetCurrentLobby", Source, Game, Lobby.Id);
    });

    FW.RegisterServer("fw-arcade:Server:JoinSpectator", async (Source: number, Game: string, Id: number) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;

        const Lobby = GetLobby(Game, Id);
        if (!Lobby) return Player.Functions.Notify("Lobby bestaat niet..", "error");

        if (!await exp['fw-businesses'].HasPlayerBusinessPermission("Coopers Arcade", Source, "VehicleSales")) {
            return;
        };

        if (sourceToLobby[Source]) return Player.Functions.Notify("Je zit al in een lobby!");

        sourceToLobby[Source] = { Game, Id };
        Lobby.Spectators.push({
            Cid: Player.PlayerData.citizenid,
            Source: Player.PlayerData.source
        })

        Player.Functions.Notify("Je bent een lobby gejoined als spectator..");
        emitNet("fw-arcade:Client:SetCurrentLobby", Source, Game, Lobby.Id);
    });

    FW.RegisterServer("fw-arcade:Server:SendInvitation", (Source: number, Game: string, Id: number, TargetCid: string) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;

        const Lobby = GetLobby(Game, Id);
        if (!Lobby) return Player.Functions.Notify("Lobby bestaat niet..", "error");
        if (IsCidInAnyLobby(TargetCid)) return Player.Functions.Notify("Speler zit al in een lobby!");

        const Target = FW.Functions.GetPlayerByCitizenId(TargetCid);
        if (!Target) return;

        // @ts-ignore
        const TargetCoords: number[] = GetEntityCoords(GetPlayerPed(Target.PlayerData.source));
        const ArcadeCoords = new Vector3(-1654.12, -1070.66, 12.16);

        if (ArcadeCoords.getDistanceFromArray(TargetCoords) > 100.0) return Player.Functions.Notify("Speler is niet bij de arcade..", "error");

        emitNet("fw-phone:Client:Notification", Target.PlayerData.source, `arcade-invite-${Game}:${Id}`, "fas fa-gamepad", ["white", "rgb(38, 50, 56)"], "Arcade Invite", `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname} heeft je uitgenodigd voor een lobby.`, false, true, "fw-arcade:Server:AcceptInvitation", "fw-phone:Client:RemoveNotificationById", {Id: `arcade-invite-${Game}:${Id}`, Game, LobbyId: Id})
    });

    FW.RegisterServer("fw-arcade:Server:SaveLobbySettings", (Source: number, Game: string, Id: number, NewSettings: {[key: string]: any}) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;

        const Lobby = GetLobby(Game, Id);
        if (!Lobby) return Player.Functions.Notify("Lobby bestaat niet..", "error");

        if (Lobby.Matchmaker != Player.PlayerData.citizenid) return;
        Lobby.Settings = NewSettings;
    });

    FW.RegisterServer("fw-arcade:Server:EndGame", (Source: number, Game: string, Id: number) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;

        const Lobby = GetLobby(Game, Id);
        if (!Lobby) return Player.Functions.Notify("Lobby bestaat niet..", "error");

        if (Lobby.Matchmaker != Player.PlayerData.citizenid) return;

        Lobby.InMatch = false;
        Lobby.TriggerEvent("fw-arcade:Client:SetGameActive", {State: false});

        if (Game == 'tdm') {
            TDM.UnloadGame(Id, false);
        } else if (Game == 'vehicleTag') {
            VehicleTag.UnloadGame(Id, false);
        };
    });

    FW.Functions.CreateCallback("fw-arcade:Server:GetGameLobbys", (Source: number, Cb: Function, Game: string) => {
        if (activeLobbys[Game] == undefined) {
            return Cb([]);
        };

        Cb(activeLobbys[Game]);
    });

    FW.Functions.CreateCallback("fw-arcade:Server:GetLobby", (Source: number, Cb: Function, Game: string, Id: number) => {
        Cb(GetLobby(Game, Id))
    });

    FW.Functions.CreateCallback("fw-arcade:Server:IsMatchmaker", (Source: number, Cb: Function, Game: string, Id: number) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;

        const Lobby = GetLobby(Game, Id);
        if (!Lobby) return Cb(false);

        Cb(Lobby.Matchmaker == Player.PlayerData.citizenid);
    });

    FW.Functions.CreateCallback("fw-arcade:Server:CanLobbyStart", async (Source: number, Cb: Function, Game: string, Id: number) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return Cb({ Success: false, Msg: "Lobby kan niet gestart worden.." });

        const Lobby = GetLobby(Game, Id);
        if (!Lobby) return Cb({ Success: false, Msg: "Lobby bestaat niet.." });

        if (Lobby.Matchmaker != Player.PlayerData.citizenid) {
            return Cb({ Success: false, Msg: "Alleen de Matchmaker kan de lobby starten.." });
        };

        const { arcadeMachines, arcadeStats } = await exp['fw-config'].GetModuleConfig("bus-arcade", {arcadeMachines: {}});
        if (arcadeMachines[Game] == undefined || arcadeMachines[Game] <= GetRandom(1, 10) - 1.0) {
            return Cb({Success: false, Msg: "Kan de lobby niet starten, de arcadekast is kapot.."})
        };

        // Remove disconnected players and players that are not nearby Arcade Building..
        let disconnectedPlayers: number[] = [];
        const ArcadeCoords = new Vector3(-1654.12, -1070.66, 12.16);
        for (let i = 0; i < Lobby.Players.length; i++) {
            const {Name, Source: src} = Lobby.Players[i];

            // @ts-ignore
            const TargetCoords: number[] = GetEntityCoords(GetPlayerPed(src));

            // @ts-ignore
            if (!GetPlayerName(src) || ArcadeCoords.getDistanceFromArray(TargetCoords) > 35.0) {
                disconnectedPlayers.push(src);
                SendLobbyNotify(Game, Id, `${Name} is uit de lobby gekickt.`)
            };
        };

        Lobby.Players = Lobby.Players.filter((Val: LobbyPlayer) => !disconnectedPlayers.includes(Val.Source));

        // Check if both teams have 1 player.
        if (Lobby.Players.filter((Val: {Team: number}) => Val.Team == 1).length <= 0 || Lobby.Players.filter((Val: {Team: number}) => Val.Team == 2).length <= 0) {
            return Cb({Success: false, Msg: "Er moet minimaal 1 persoon in elk team zitten!"});
        };

        // Check if all players have disposited their arcade tokens.
        const Items = await exp['fw-inventory'].GetInventoryItemsUnproccessed(`arcade-tokens-${Game}-${Id}`);
        if (!Items) return Cb({Success: false, Msg: "Iemand heeft geen geldige Arcade Token ingeleverd.."});

        const FoundTokens = Lobby.Players.filter((Val: LobbyPlayer) => {
            return !Items.some(({info}: {
                info: string;
            }) => {
                const {purchaser, games} = JSON.parse(info);
                return purchaser == Val.Cid && games > 0
            })
        });

        if (FoundTokens.length != 0) {
            return Cb({Success: false, Msg: "Iemand heeft geen geldige Arcade Token ingeleverd.."})
        };

        for (let i = 0; i < Items.length; i++) {
            const Info = JSON.parse(Items[i].info)
            if (Info.games - 1 > 0) {
                exp['ghmattimysql'].executeSync("UPDATE `player_inventories` SET `info` = ? WHERE `id` = ?", [
                    JSON.stringify({ ...Info, games: Info.games - 1 }),
                    Items[i].id
                ]);
            } else {
                exp['ghmattimysql'].executeSync("DELETE FROM `player_inventories` WHERE `id` = ?", [
                    Items[i].id
                ]);
            };
        };

        // Let all players know the game is starting!
        Lobby.InMatch = true;
        Lobby.TriggerEvent("fw-arcade:Client:StartLobby", {Game, Id});

        setTimeout(() => {
            const Players = [...Lobby.Players, ...Lobby.Spectators];
            for (let i = 0; i < Players.length; i++) {
                const {Source: src} = Players[i];
                SetPlayerInLobbyBucket(src, Lobby.Id);
            };

            Lobby.TriggerEvent("fw-arcade:Client:SetGameActive", {State: true});
        }, 4000);

        setTimeout(() => {
            if (Game == 'vehicleTag') {
                VehicleTag.SetupGame(Id);
            } else if (Game == 'tdm') {
                TDM.SetupGame(Id);
            };
        }, 5000);

        arcadeStats[Game].totalPlays += 1;
        exp['fw-config'].SetConfigValue("bus-arcade", "arcadeStats", arcadeStats);
        await Delay(1);
        DegradeArcadeMachine(Game, 0.1 * Lobby.Players.length);

        Cb({Success: true})
    });
};

export const GetLobby = (Game: string, Id: number) => {
    if (activeLobbys[Game] == undefined) {
        return false;
    };

    return activeLobbys[Game].find(Val => Val.Id == Id) || false;
};

export const SetPlayerInLobbyBucket = (Source: number, Id: number) => {
    // console.log(`Source ${Source} has been set to bucket ${Id}`);
    // @ts-ignore
    SetRoutingBucketPopulationEnabled(Id, false);
    // @ts-ignore
    SetPlayerRoutingBucket(Source.toString(), Id);
};

export const ClearPlayerBucket = (Source: number) => {
    // console.log(`Source ${Source} has been reset to world.`);
    // @ts-ignore
    SetPlayerRoutingBucket(Source.toString(), 0);
};

const GetTeamId = (Players: Array<LobbyPlayer>) => {
    const Team1Count = Players.filter(Val => Val.Team === 1).length;
    const Team2Count = Players.filter(Val => Val.Team === 2).length;

    if (Team1Count === Team2Count || Team2Count < Team1Count) {
        return 2;
    } else {
        return 1;
    };
};

onNet("fw-arcade:Server:AcceptInvitation", async (Data: {
    Id: string;
    Game: string;
    LobbyId: number;
}) => {
    const Source = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return emitNet('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Ongeldige invite...", true);

    const Lobby = GetLobby(Data.Game, Data.LobbyId);
    if (!Lobby) return emitNet('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Ongeldige invite...", true);

    emitNet('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Invite geaccepteerd!", true)

    const TeamId = GetTeamId(Lobby.Players);
    SendLobbyNotify(Data.Game, Data.LobbyId, `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname} heeft de lobby gejoined!`);

    sourceToLobby[Source] = { Game: Data.Game, Id: Data.LobbyId };
    Lobby.Players.push({
        Cid: Player.PlayerData.citizenid,
        Source: Player.PlayerData.source,
        Name: `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}`,
        Team: TeamId
    });

    Player.Functions.Notify("Je bent een lobby gejoined.");
    emitNet("fw-arcade:Client:SetCurrentLobby", Source, Data.Game, Lobby.Id);
});

onNet("fw-arcade:Server:SwapTeam", async ({Game, Id, TeamId, Cid}: {Game: string, Id: number, TeamId: number, Cid: boolean | string}) => {
    const Source = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Lobby = GetLobby(Game, Id);
    if (!Lobby) return;

    const PlayerIndex = Lobby.Players.findIndex((Val: LobbyPlayer) => Val.Cid == (Cid || Player.PlayerData.citizenid));
    if (PlayerIndex == -1) return;

    Lobby.Players[PlayerIndex].Team = Cid ? (TeamId == 1 ? 2 : 1) : TeamId;

    emitNet("fw-arcade:Client:ViewLobbyTeam", Source, {Game, Id, TeamId })
});

onNet("fw-arcade:Server:LeaveLobby", async ({Game, Id}: {Game: string, Id: number}) => {
    const Source = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Lobby = GetLobby(Game, Id);
    if (!Lobby) return;

    if (Lobby.Matchmaker == Player.PlayerData.citizenid) {
        const Items = await exp['fw-inventory'].GetInventoryItemsUnproccessed(`arcade-tokens-${Game}-${Id}`);
        if (Items.length != 0) return Player.Functions.Notify("Er zitten nog arcade tokens in de kast!", "error");

        const LobbyIndex = activeLobbys[Game].findIndex(Val => Val.Id == Id);
        if (LobbyIndex == -1) return;
        SendLobbyNotify(Game, Id, `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname} heeft de lobby verwijderd!`)

        for (let i = 0; i < Lobby.Players.length; i++) {
            const {Source: src} = Lobby.Players[i];
            emitNet("fw-arcade:Client:SetCurrentLobby", src, false, 0);
            delete sourceToLobby[src]
        }

        activeLobbys[Game].splice(LobbyIndex, 1);
    } else {
        Lobby.Players = Lobby.Players.filter(Val => Val.Cid != Player.PlayerData.citizenid);
        SendLobbyNotify(Game, Id, `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname} heeft de lobby verlaten!`)
        emitNet("fw-arcade:Client:SetCurrentLobby", Source, false, 0);
    };

    delete sourceToLobby[Source];
})

on("playerDropped", async (Reason: string) => {
    const Source = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (!sourceToLobby[Source]) return;

    const {Game, Id} = sourceToLobby[Source];
    const Lobby = GetLobby(Game, Id);
    if (!Lobby) return;

    if (Game == 'tdm') {
        await exp['ghmattimysql'].executeSync("DELETE FROM `player_inventories` WHERE `inventory` = ? AND `info` LIKE ?", [
            `ply-${Player.PlayerData.citizenid}`,
            `%arcadetdm%`
        ]);

        await exp['ghmattimysql'].executeSync("DELETE FROM `player_inventories` WHERE `inventory` = ? AND `item_name` = 'ammo' AND `info` LIKE ?", [
            `ply-${Player.PlayerData.citizenid}`,
            `%arcadetdm%`
        ]);
    } else if (Game == 'vehicleTag') {
        VehicleTag.RouletteTag(Id);
        VehicleTag.DeleteVehicle(Id, Source);
    };

    delete sourceToLobby[Source];
    if (Lobby.Matchmaker == Player.PlayerData.citizenid) {
        const LobbyIndex = activeLobbys[Game].findIndex(Val => Val.Id == Id);
        if (LobbyIndex == -1) return;
        SendLobbyNotify(Game, Id, `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname} heeft de lobby verwijderd!`)

        for (let i = 0; i < Lobby.Players.length; i++) {
            const {Source: src} = Lobby.Players[i];
            emitNet("fw-arcade:Client:SetCurrentLobby", src, false, 0);
            delete sourceToLobby[src]
        };

        if (Game == 'tdm') {
            TDM.UnloadGame(Id, false);
        } else {
            VehicleTag.UnloadGame(Id, 0);
        };

        activeLobbys[Game].splice(LobbyIndex, 1);
    } else {
        Lobby.Players = Lobby.Players.filter(Val => Val.Cid != Player.PlayerData.citizenid);
        SendLobbyNotify(Game, Id, `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname} heeft de lobby verlaten!`)
    }
});