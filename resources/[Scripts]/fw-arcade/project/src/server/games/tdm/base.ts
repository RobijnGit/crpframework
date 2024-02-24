import { Delay, GetRandom, exp } from "../../../shared/utils";
import { ClearPlayerBucket, GetLobby } from "../../lobby/main";
import { sourceToLobby } from "../../lobby/main";
import { IsCidInLobby } from "../../lobby/utils";
import { FW } from "../../server";

const activeMatches: {[key: number]: any} = {};
const playerLoadout: {[key: string]: Array<any>} = {};

export const Maps = [
    { Name: "Legion Square" },
    { Name: "Alta Construction" },
    { Name: "Cayo Perico" },
    { Name: "De Bario" },
];

onNet("fw-arcade:Server:TDM:GiveLoadout", async (Data: {
    Id: number;
    Weapon: string;
}) => {
    const Player = FW.Functions.GetPlayer(source);
    if (!Player) return;

    if (!IsCidInLobby("tdm", Data.Id, Player.PlayerData.citizenid)) {
        console.log(`USER TRIED TO GET TDM LOADOUT, BUT IS NOT IN A MATCH!`)
        return;
    };

    const {AmmoType} = exp['fw-weapons'].GetWeaponList(GetHashKey(Data.Weapon));
    if (!AmmoType) return;

    await Player.Functions.AddItem(Data.Weapon, 1, false, {
        Serial: `arcadetdm-${Data.Id}-${Player.PlayerData.citizenid}`,
        Ammo: AmmoType == 'AMMO_FIRE' ? 1 : 100
    }, true, false);

    let AmmoItem;
    switch (AmmoType) {
        case 'AMMO_RIFLE':
            AmmoItem = 'Rifle'
            break;
        case 'AMMO_PISTOL':
            AmmoItem = 'Pistol'
            break;
        case 'AMMO_SHOTGUN':
            AmmoItem = 'Shotgun'
            break;
        case 'AMMO_REVOLVER':
            AmmoItem = 'Revolver'
            break;
        case 'AMMO_SMG':
            AmmoItem = 'Smg'
            break;
    }

    if (!playerLoadout[Player.PlayerData.citizenid]) playerLoadout[Player.PlayerData.citizenid] = [];
    playerLoadout[Player.PlayerData.citizenid].push({
        Weapon: Data.Weapon,
        Ammo: AmmoItem
    })

    if (!AmmoItem) return;
    Player.Functions.AddItem("ammo", 5, false, {
        arcadeId: `arcadetdm-${Data.Id}`
    }, true, AmmoItem)
})

onNet("fw-arcade:Server:TDM:RemoveLoadout", async () => {
    const Player = FW.Functions.GetPlayer(source);
    if (!Player) return;
    
    const {Game, Id} = sourceToLobby[Player.PlayerData.source];
    const Lobby = GetLobby(Game, Id);
    if (!Lobby) return;

    playerLoadout[Player.PlayerData.citizenid] = [];

    await exp['ghmattimysql'].executeSync("DELETE FROM `player_inventories` WHERE `inventory` = ? AND `info` LIKE ?", [
        `ply-${Player.PlayerData.citizenid}`,
        `%arcadetdm-${Id}%`
    ]);

    await exp['ghmattimysql'].executeSync("DELETE FROM `player_inventories` WHERE `inventory` = ? AND `item_name` = 'ammo' AND `info` LIKE ?", [
        `ply-${Player.PlayerData.citizenid}`,
        `%arcadetdm-${Id}%`
    ]);

    await Delay(50);
    Player.Functions.RefreshInventory();

    Player.Functions.Notify("Loadout verwijderd.");
});

onNet("fw-arcade:Server:TDM:UpdateKillCounters", async (KillerSource: number) => {
    if (KillerSource == 0) return;

    const Player = FW.Functions.GetPlayer(source);
    if (!Player) return;

    const {Game, Id} = sourceToLobby[Player.PlayerData.source];
    const Lobby = GetLobby(Game, Id);
    if (!Lobby) return;

    const KillerTeam = Lobby.Players.find((Val: {Source: number}) => Val.Source == KillerSource)?.Team || 1;
    const KilledTeam = Lobby.Players.find((Val: {Source: number}) => Val.Source == Player.PlayerData.source)?.Team || 1;

    if (KillerTeam == KilledTeam) {
        if (KillerTeam == 1) {
            activeMatches[Lobby.Id].TeamOnePoints -= 2;
            if (activeMatches[Lobby.Id].TeamOnePoints <= 0) activeMatches[Lobby.Id].TeamOnePoints = 0;
        } else {
            activeMatches[Lobby.Id].TeamTwoPoints -= 2;
            if (activeMatches[Lobby.Id].TeamTwoPoints <= 0) activeMatches[Lobby.Id].TeamTwoPoints = 0;
        };
    } else {
        if (KillerTeam == 1) {
            activeMatches[Lobby.Id].TeamOnePoints += 1;
        } else {
            activeMatches[Lobby.Id].TeamTwoPoints += 1;
        };
    };

    emitNet("fw-arcade:Client:KillFeed", KillerSource, Lobby.Id)
    Lobby.TriggerEvent("fw-arcade:Client:TDM:UpdateCounter", activeMatches[Lobby.Id])

    await Delay(10);

    if (activeMatches[Lobby.Id].TeamOnePoints >= Lobby.Settings.Points) {
        TDM.UnloadGame(Id, 1)
    } else if (activeMatches[Lobby.Id].TeamTwoPoints >= Lobby.Settings.Points) {
        TDM.UnloadGame(Id, 2)
    };
});

onNet("fw-arcade:Server:TDM:RestockAmmo", async () => {
    const Player = FW.Functions.GetPlayer(source);
    if (!Player) return;

    const {Game, Id} = sourceToLobby[Player.PlayerData.source];
    const Lobby = GetLobby(Game, Id);
    if (!Lobby || !Lobby.InMatch) return;

    await exp['ghmattimysql'].executeSync("DELETE FROM `player_inventories` WHERE `inventory` = ? AND `info` LIKE ?", [
        `ply-${Player.PlayerData.citizenid}`,
        `%arcadetdm-${Id}%`
    ]);

    await exp['ghmattimysql'].executeSync("DELETE FROM `player_inventories` WHERE `inventory` = ? AND `item_name` = 'ammo' AND `info` LIKE ?", [
        `ply-${Player.PlayerData.citizenid}`,
        `%arcadetdm-${Id}%`
    ]);

    await Delay(100);
    Player.Functions.RefreshInventory();
    await Delay(100);

    for (let i = 0; i < playerLoadout[Player.PlayerData.citizenid].length; i++) {
        const {Weapon, Ammo} = playerLoadout[Player.PlayerData.citizenid][i];
        await Player.Functions.AddItem(Weapon, 1, false, {
            Serial: `arcadetdm-${Id}-${Player.PlayerData.citizenid}`,
            Ammo: Ammo ? 100 : 1
        }, true, false);

        await Delay(150);

        if (Ammo) {
            await Player.Functions.AddItem("ammo", 5, false, {
                arcadeId: `arcadetdm-${Id}`
            }, true, Ammo)
        };

        await Delay(150);
    }
});

export const TDM = {
    SetupGame: (LobbyId: number) => {
        const Lobby = GetLobby('tdm', LobbyId);
        if (!Lobby) return;

        activeMatches[LobbyId] = {
            TeamOnePoints: 0,
            TeamTwoPoints: 0
        };

        for (let i = 0; i < Lobby.Players.length; i++) {
            const {Source} = Lobby.Players[i];
            playerLoadout[Source] = [];
        }

        Lobby.TriggerEvent("fw-arcade:Client:TDM:LoadGame", {
            Map: Lobby.Settings.Map == 'Random Map' ? Maps[GetRandom(0, Maps.length - 1)].Name : Lobby.Settings.Map
        });

        Lobby.TriggerEvent("fw-arcade:Client:TDM:UpdateCounter", activeMatches[LobbyId])
    },
    UnloadGame: async (LobbyId: number, WinningTeam: false | number) => {
        const Lobby = GetLobby('tdm', LobbyId);
        if (!Lobby) return;

        Lobby.InMatch = false;
        Lobby.TriggerEvent("fw-arcade:Client:SetGameActive", {State: false});
        Lobby.TriggerEvent("fw-arcade:Client:TDM:UnloadGame");

        // Delete loadout!
        await exp['ghmattimysql'].executeSync("DELETE FROM `player_inventories` WHERE `info` LIKE ?", [
            `%arcadetdm-${LobbyId}-%`
        ]);
    
        await exp['ghmattimysql'].executeSync("DELETE FROM `player_inventories` WHERE `item_name` = 'ammo' AND `info` LIKE ?", [
            `%arcadetdm-${LobbyId}%`
        ]);

        await Delay(100);

        for (let i = 0; i < Lobby.Spectators.length; i++) {
            const {Source} = Lobby.Spectators[i];
            ClearPlayerBucket(Source);
        };

        for (let i = 0; i < Lobby.Players.length; i++) {
            const {Source, Team} = Lobby.Players[i];
            ClearPlayerBucket(Source);

            playerLoadout[Source] = [];

            const Player = FW.Functions.GetPlayer(Source);
            if (Player) Player.Functions.RefreshInventory();

            emitNet("fw-assets:Client:Toggle:Items", Source, false, false);
            setTimeout(() => {
                emitNet("fw-assets:Client:Toggle:Items", Source, true, false);
            }, 500);

            if (WinningTeam) {
                emitNet("FW:Notify", Source, Team == WinningTeam ? "Je team heeft gewonnen! Gefeliciteerd!" : "Je team heeft verloren.. Volgende keer beter!", Team == WinningTeam ? "success" : "error")
            };
        };
    },
};