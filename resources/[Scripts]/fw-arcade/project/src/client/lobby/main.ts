// Events
import { Delay, exp } from "../../shared/utils";
import { FW } from "../client";
import { TDM } from "../games/tdm";
import { VehicleTag } from "../games/vehicle-tag";
import { IsInAnyLobby, IsInLobby, currentGame, currentLobby } from "./utils";
import './spectate'

onNet("fw-arcade:Client:OpenLobbyMenu", async ({Game}: {Game: string}) => {
    let lobbyContext: any = [];

    const Lobbys = await FW.SendCallback("fw-arcade:Server:GetGameLobbys", Game)
    for (let i = 0; i < Lobbys.length; i++) {
        const {Id, Name, InMatch} = Lobbys[i];

        lobbyContext.push({
            Icon: 'users',
            Title: Name,
            Desc: IsInLobby(Id) ? "Lobby bekijken" : "Lobby joinen",
            Data: { Event: "fw-arcade:Client:ViewLobby", Game, Id },
            Disabled: InMatch
        });
    };

    FW.Functions.OpenMenu({
        MainMenuItems: [
            {
                Icon: "user-plus",
                Title: "Nieuwe lobby aanmaken",
                Desc: "Maak je eigen lobby aan!",
                Data: { Event: "fw-arcade:Client:CreateLobby", Game },
                Disabled: IsInAnyLobby()
            },
            ...lobbyContext
        ],
        Width: "35vh"
    })
});

onNet("fw-arcade:Client:CreateLobby", async ({Game}: {Game: string}) => {
    await Delay(10);

    let Result;
    if (Game == 'vehicleTag') {
        Result = await VehicleTag.CreateLobby();
    } else if (Game == 'tdm') {
        Result = await TDM.CreateLobby();
    };

    if (!Result) return;
    FW.TriggerServer("fw-arcade:Server:CreateLobby", Game, Result);
});

// Lobby Stuff
onNet("fw-arcade:Client:ViewLobby", async ({Game, Id}: {Game: string, Id: number}) => {
    // await Delay(10);

    const Result = await FW.SendCallback("fw-arcade:Server:GetLobby", Game, Id);
    if (!Result) return FW.Functions.Notify("Lobby bestaat niet..", "error");

    if (!IsInLobby(Id)) {
        const Result = await exp['fw-ui'].CreateInput([
            {
                Icon: 'user-lock',
                Label: 'Wachtwoord',
                Name: 'Password',
                Type: "password"
            },
        ]);

        if (!Result || Result.Password.trim().length == 0) return;
        FW.TriggerServer("fw-arcade:Server:JoinLobby", Game, Id, Result.Password);

        return;
    };

    let lobbyContext: any = [];

    const Cid = FW.Functions.GetPlayerData().citizenid
    if (Result.Matchmaker == Cid) {
        lobbyContext = [
            {
                Icon: "cogs",
                Title: "Verander lobby instellingen",
                Desc: "Verander alles wat je wilt dud",
                Data: { Event: "fw-arcade:Client:AdjustLobbySettings", Game, Id }
            },
            {
                Icon: "play",
                Title: "Start",
                Desc: "Start de lobby",
                Data: {Event: "fw-arcade:Client:TryStartGame", Game, Id}
            },
            {
                Icon: "trash",
                Title: "Annuleren",
                Desc: "Verwijder de lobby",
                Data: {Event: "fw-arcade:Server:LeaveLobby", Game, Id }
            },
        ]
    } else {
        lobbyContext = [
            {
                Icon: " ",
                Title: "Verlaten",
                Desc: `Lobby verlaten`,
                Data: {Event: "fw-arcade:Server:LeaveLobby", Game, Id }
            },
        ]
    }

    FW.Functions.OpenMenu({
        MainMenuItems: [
            {
                Title: Result.Name
            },
            {
                Icon: "users",
                Title: "Spelers",
                Desc: `${Result.Players.length}/${Result.MaxPlayers}`
            },
            {
                Icon: "user-plus",
                Title: "Invite Spelers",
                Desc: `Nodig nog wat spelers uit om je lobby op gang te brengen!`,
                Disabled: Result.Players.length == Result.MaxPlayers,
                Data: {Event: "fw-arcade:Client:InviteToLobby", Game, Id }
            },
            {
                Icon: "users-cog",
                Title: "Team 1",
                Desc: `${Result.Players.filter((Val: {Team: number}) => Val.Team == 1).length}/${Result.MaxPlayers / 2}`,
                Data: {Event: "fw-arcade:Client:ViewLobbyTeam", Game, Id, TeamId: 1}
            },
            {
                Icon: "users-cog",
                Title: "Team 2",
                Desc: `${Result.Players.filter((Val: {Team: number}) => Val.Team == 2).length}/${Result.MaxPlayers / 2}`,
                Data: {Event: "fw-arcade:Client:ViewLobbyTeam", Game, Id, TeamId: 2}
            },
            ...lobbyContext,
            {
                Icon: "box",
                Title: "Open Token Inventory",
                Desc: `Doe je Arcade Token hier in om te spelen!`,
                Data: {Event: "fw-arcade:Client:LobbyInventory", Game, Id}
            },
            {
                Icon: "backward",
                Title: "Terug",
                Desc: `Terug naar de lobby lijst`,
                Data: {Event: "fw-arcade:Client:OpenLobbyMenu", Game}
            },
        ],
        Width: "35vh"
    })
})

on("fw-arcade:Client:InviteToLobby", async ({Game, Id}: {Game: string, Id: number}) => {
    await Delay(10);
    if (!IsInLobby(Id)) return;

    const Result = await exp['fw-ui'].CreateInput([
        {
            Icon: 'id-card',
            Label: 'BSN',
            Name: 'Cid',
            Type: "number"
        },
    ]);

    if (!Result || Result.Cid.trim().length == 0) return;

    FW.TriggerServer("fw-arcade:Server:SendInvitation", Game, Id, Result.Cid)
});

onNet("fw-arcade:Client:ViewLobbyTeam", async ({Game, Id, TeamId}: {Game: string, Id: number, TeamId: number}) => {
    // await Delay(10);
    if (!IsInLobby(Id)) return;

    const Result = await FW.SendCallback("fw-arcade:Server:GetLobby", Game, Id);
    if (!Result) return FW.Functions.Notify("Lobby bestaat niet..", "error");
    
    const TeamPlayers = Result.Players.filter((Val: {Team: number}) => Val.Team == TeamId);
    const MyCid = FW.Functions.GetPlayerData().citizenid;

    const lobbyContext = [];

    if (TeamPlayers.findIndex((Val: {Cid: string}) => Val.Cid == MyCid) == -1) {
        lobbyContext.push({
            Icon: "user-plus",
            Title: "Join Team",
            Desc: "Join dit team",
            Data: {Event: "fw-arcade:Server:SwapTeam", Game, Id, TeamId}
        })
    }

    for (let i = 0; i < TeamPlayers.length; i++) {
        const {Cid, Name} = TeamPlayers[i];
        
        lobbyContext.push({
            Icon: "arrow-right",
            Title: `${Name} ${MyCid == Cid ? "(Jij)" : ""}`,
            Desc: Result.Matchmaker == MyCid ? "Verplaats de speler naar het andere team door te klikken." : "",
            Data: Result.Matchmaker == MyCid ? {Event: "fw-arcade:Server:SwapTeam", Game, Id, TeamId, Cid } : undefined,
        })
    }

    FW.Functions.OpenMenu({
        MainMenuItems: [
            {
                Icon: "user-friends",
                Title: `Team ${TeamId}`
            },
            ...lobbyContext,
            {
                Icon: "backward",
                Title: "Terug",
                Data: { Event: "fw-arcade:Client:ViewLobby", Game, Id }
            },
        ],
        Width: "35vh"
    })
});

on("fw-arcade:Client:AdjustLobbySettings", async ({Game, Id}: {Game: string, Id: number}) => {
    if (!IsInLobby(Id)) return;

    const Result = await FW.SendCallback("fw-arcade:Server:GetLobby", Game, Id);
    if (!Result) return FW.Functions.Notify("Lobby bestaat niet..", "error");

    const MyCid = FW.Functions.GetPlayerData().citizenid;
    if (Result.Matchmaker != MyCid) return;

    let Settings;
    if (Game == 'vehicleTag') {
        Settings = await VehicleTag.OpenSettings(Result.Settings);
    } else if (Game == 'tdm') {
        Settings = await TDM.OpenSettings(Result.Settings);
    }

    if (!Settings) return;
    FW.TriggerServer('fw-arcade:Server:SaveLobbySettings', Game, Id, Settings);
});

on("fw-arcade:Client:LobbyInventory", async ({Game, Id}: {Game: string, Id: number}) => {
    if (!IsInLobby(Id)) return;

    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Arcade Inventory', `arcade-tokens-${Game}-${Id}`, 40, 250);
});

on("fw-arcade:Client:TryStartGame", async ({Game, Id}: {Game: string, Id: number}) => {
    if (!IsInLobby(Id)) return;

    const Result = await FW.SendCallback("fw-arcade:Server:GetLobby", Game, Id);
    if (!Result) return FW.Functions.Notify("Lobby bestaat niet..", "error");

    if (Result.Players.filter((Val: {Team: number}) => Val.Team == 1).length <= 0 || Result.Players.filter((Val: {Team: number}) => Val.Team == 2).length <= 0) {
        return FW.Functions.Notify("Er moet minimaal 1 persoon in elk team zitten!", "error");
    };

    const {Success, Msg} = await FW.SendCallback("fw-arcade:Server:CanLobbyStart", Game, Id);
    if (!Success) return FW.Functions.Notify(Msg, "error");
});

onNet("fw-arcade:Client:StartLobby", async ({Game, Id}: {Game: string, Id: number}) => {
    if (!IsInLobby(Id)) return;
    FW.Functions.Notify("Het spel start in 5 seconden!");

    setTimeout(() => {
        DoScreenFadeOut(1000);
    }, 3500);
});

onNet("fw-arcade:Client:EndGame", async () => {
    if (currentGame == 'none' || !currentLobby) return;
    FW.TriggerServer("fw-arcade:Server:EndGame", currentGame, currentLobby);
})

// setImmediate(async () => {
//     SetEntityCoords(PlayerPedId(), -1658.95, -1069.02, 12.16, false, false, false, false);

//     if (GetPlayerFromServerId(2) != PlayerId()) {
//         await Delay(200);
//         FW.TriggerServer("fw-arcade:Server:JoinSpectator", 'vehicleTag', 1);
//         return
//     };

//     FW.TriggerServer("fw-arcade:Server:CreateLobby", 'vehicleTag', {
//         Name: "Arcade Test",
//         Password: "123",
//         Time: 15,
//         Points: 350,
//         Vehicles: "Sports",
//         Map: "The Docks"
//     });

//     await Delay(500);
//     emit("fw-arcade:Client:TryStartGame", {Game: "vehicleTag", Id: "1"})
// })