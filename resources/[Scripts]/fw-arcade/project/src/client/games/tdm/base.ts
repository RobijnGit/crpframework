import { Vector3, Vector4 } from "../../../shared/classes/math"
import { Delay, GetRandom, exp } from "../../../shared/utils"
import { FW } from "../../client";
import { IsSpectator, ToggleFreecam } from "../../lobby/spectate";
import { IsInLobby, currentLobby } from "../../lobby/utils";
import { DestroyLoadoutCam, OpenLoadoutMenu } from "./loadout";
import { TeamThread, ZoneThread } from "./zone";

export const Maps = [
    {
        Name: "Legion Square",
        Coords: new Vector3(195.29, -933.83, 30.69),
        Spawns: [new Vector4(231.74, -861.89, 29.93, 157.18), new Vector4(161.01, -995.96, 29.35, 341.21)],
        Cam: new Vector4(173.83, -933.1, 49.15, 290.0),
        Radius: 90,
    },
    {
        Name: "Alta Construction",
        Coords: new Vector3(75.31, -413.3, 37.55),
        Spawns: [new Vector4(134.32, -417.03, 41.11, 70.56), new Vector4(8.09, -398.76, 39.46, 247.65)],
        Cam: new Vector4(99.87, -451.64, 80.6, 31.6),
        Radius: 90,
    },
    {
        Name: "Cayo Perico",
        Coords: new Vector3(5010.77, -5750.07, 16.57),
        Spawns: [new Vector4(5064.62, -5779.41, 16.28, 40.72), new Vector4(4991.27, -5718.95, 19.88, 219.85)],
        Cam: new Vector4(5063.94, -5702.84, 49.98, 142.31),
        Radius: 70,
    },
    {
        Name: "De Bario",
        Coords: new Vector3(338.84, -2043.97, 21.26),
        Spawns: [new Vector4(392.41, -2010.62, 23.48, 141.37), new Vector4(309.84, -2102.66, 17.75, 332.08)],
        Cam: new Vector4(298.34, -2010.15, 64.81, 227.67),
        Radius: 80,
    },
];

export let currentMap = Maps[0];
let tdmMatchActive: boolean = false;

onNet("fw-arcade:Client:TDM:LoadGame", async (Data: {
    Game: string;
    Id: number;
    Map: string;
}) => {
    exp['fw-sync'].SetClientSync(false, {Time: 12, Weather: "SMOG"})
    exp['fw-assets'].SetDensity("Vehicle", 0.0);
    exp['fw-assets'].SetDensity("Parked", 0.0);
    exp['fw-assets'].SetDensity("Peds", 0.0);
    exp['fw-assets'].SetDensity("Scenarios", 0.0);

    const Map = Maps.find((Val: {Name: string}) => Val.Name == Data.Map) || Maps[0];
    currentMap = Map;

    SetEntityCoords(PlayerPedId(), Map.Coords.x - GetRandom(-2, 2), Map.Coords.y - GetRandom(-2, 2), Map.Coords.z - 5.0, false, false, false, false);
    FreezeEntityPosition(PlayerPedId(), true);

    const Lobby = await FW.SendCallback("fw-arcade:Server:GetLobby", 'tdm', Data.Id);
    if (!Lobby) return;

    const Spectator = IsSpectator(Lobby);
    if (Spectator) {
        ToggleFreecam(true);
        SetEntityCoords(PlayerPedId(), Map.Cam.x, Map.Cam.y, Map.Cam.z, false, false, false, false);
        SetEntityInvincible(PlayerPedId(), true);
    } else {
        OpenLoadoutMenu(true)

        const {citizenid} = FW.Functions.GetPlayerData();
        const MyTeam = Lobby.Players.find((Val: {Cid: string}) => Val.Cid == citizenid)?.Team || 1;
        TeamThread.data.Players = Lobby.Players;
        TeamThread.data.Team = MyTeam;
        TeamThread.start();
    }

    DoScreenFadeIn(1000);

    tdmMatchActive = true;
    ZoneThread.data.Center = Map.Coords;
    ZoneThread.data.Radius = Map.Radius;
    ZoneThread.data.Cam = Map.Cam;
    ZoneThread.data.IsSpectator = Spectator;
    ZoneThread.start();
});

onNet("fw-arcade:Client:TDM:UnloadGame", async () => {
    tdmMatchActive = false;
    ToggleFreecam(false);

    exp['fw-sync'].SetClientSync(true)
    exp['fw-assets'].ResetDensity();

    ZoneThread.stop();
    TeamThread.stop();

    DestroyLoadoutCam();
    SetEntityCoords(PlayerPedId(), -1658.98, -1069.02, 11.5, false, false, false, false);
    SetEntityHeading(PlayerPedId(), 318.17);
    FreezeEntityPosition(PlayerPedId(), false);
    SetEntityInvincible(PlayerPedId(), false);

    emit("fw-medical:Client:Revive");
    emitNet('fw-ui:Server:remove:stress', 100);
    await Delay(1000);
    DoScreenFadeIn(500);

    RemoveAllPedWeapons(PlayerPedId(), true);
    SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true);

    exp['fw-ui'].RemoveInfo();
});

onNet("fw-arcade:Client:KillFeed", async (Id: number) => {
    if (!IsInLobby(Id)) return;

    PlaySoundFrontend(-1, "CHECKPOINT_AHEAD", "HUD_MINI_GAME_SOUNDSET", false);

    const Lobby = await FW.SendCallback("fw-arcade:Server:GetLobby", 'tdm', Id);
    if (!Lobby) return;

    if (Lobby.Settings.KillHeal) {
        SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) + 50);
    };
})

onNet("fw-medical:Client:PlayerDied", async (KillerSource: number) => {
    if (!tdmMatchActive) return;

    emitNet("fw-arcade:Server:TDM:UpdateKillCounters", KillerSource);
    await Delay(1500);
    emit("fw-arcade:Client:TDM:Spawn", {Respawn: true});
    emitNet("fw-arcade:Server:TDM:RestockAmmo");
})

onNet("fw-arcade:Client:TDM:Spawn", async ({Respawn}: {Respawn: boolean}) => {
    if (!Respawn) {
        return
    };

    DoScreenFadeOut(500);
    while (!IsScreenFadedOut()) {
        await Delay(10);
    };

    emit("fw-medical:Client:Revive");
    emitNet('fw-ui:Server:remove:stress', 100);
    setTimeout(() => {
        DoScreenFadeIn(500);
    }, 100);
    
    if (!tdmMatchActive) return;

    const Lobby = await FW.SendCallback("fw-arcade:Server:GetLobby", 'tdm', currentLobby);
    if (!Lobby) return;

    if (parseInt(Lobby.Settings.SpawnTime) > 0) {
        SetEntityInvincible(PlayerPedId(), true);
        setTimeout(() => {
            SetEntityInvincible(PlayerPedId(), false);
        }, Math.min(20, parseInt(Lobby.Settings.SpawnTime)) * 1000);
    };

    const {citizenid} = FW.Functions.GetPlayerData();
    const MyTeam = Lobby.Players.find((Val: {Cid: string}) => Val.Cid == citizenid)?.Team || 1;

    const SpawnCoords = currentMap.Spawns[MyTeam - 1];
    SetEntityCoords(PlayerPedId(), SpawnCoords.x, SpawnCoords.y, SpawnCoords.z, false, false, false, false);
    SetEntityHeading(PlayerPedId(), SpawnCoords.w);
    FreezeEntityPosition(PlayerPedId(), false);
    ClearPedTasksImmediately(PlayerPedId());

    DestroyLoadoutCam();
});

onNet("fw-arcade:Client:TDM:UpdateCounter", async (Counter: {
    TeamOnePoints: string;
    TeamTwoPoints: string;
}) => {
    const Lobby = await FW.SendCallback("fw-arcade:Server:GetLobby", 'tdm', currentLobby);
    if (!Lobby) return;

    const {citizenid} = FW.Functions.GetPlayerData();
    const MyTeam = Lobby.Players.find((Val: {Cid: string}) => Val.Cid == citizenid)?.Team || 1;
    const Spectator = IsSpectator(Lobby);

    exp['fw-ui'].ShowInfo({
        Title: "TDM",
        Items: [
            {Text: `${Spectator ? "Team 1 punten" : "Jouw teampunten"}: ${MyTeam == 1 ? Counter.TeamOnePoints : Counter.TeamTwoPoints} / ${Lobby.Settings.Points}`},
            {Text: `${Spectator ? "Team 2 punten" : "Enemy teampunten"}: ${MyTeam == 1 ? Counter.TeamTwoPoints : Counter.TeamOnePoints} / ${Lobby.Settings.Points}`},
        ]
    });
});

export default () => {
    exp['fw-ui'].AddEyeEntry("arcade-tdm", {
        Type: 'Zone',
        SpriteDistance: 7.0,
        Distance: 3.5,
        ZoneData: {
            Center: new Vector3(-1660.24, -1070.61, 12.16),
            Length: 0.8,
            Width: 1.0,
            Data: {
                heading: 50,
                minZ: 11.16,
                maxZ: 13.06
            },
        },
        Options: [
            {
                Name: 'vehicletag',
                Icon: 'fas fa-chess',
                Label: 'Airsoft TDM spelen',
                EventType: 'Client',
                EventName: 'fw-arcade:Client:OpenLobbyMenu',
                EventParams: { Game: "tdm" },
                Enabled: () => true,
            },
            {
                Name: 'repair',
                Icon: 'fas fa-hammer',
                Label: 'Arcadekast beheren',
                EventType: 'Client',
                EventName: 'fw-arcade:Client:OpenArcadeManagement',
                EventParams: { Game: "tdm" },
                Enabled: async () => await exp['fw-businesses'].HasRolePermission("Coopers Arcade", "CraftAccess"),
            },
        ]
    });

    exp("IsInTDM", () => tdmMatchActive);
};

export const TDM = {
    CreateLobby: async (): Promise<any> => {
        const Result = await exp['fw-ui'].CreateInput([
            {
                Icon: 'file-signature',
                Label: 'Lobby naam',
                Name: 'Name'
            },
            {
                Icon: 'user-lock',
                Label: 'Wachtwoord',
                Name: 'Password',
                Type: "password"
            },
            {
                Icon: 'tag',
                Label: 'Te behalen punten',
                Name: 'Points',
                Type: "number"
            },
            {
                Icon: 'tag',
                Label: 'Aantal seconden spawn protection ',
                Name: 'SpawnTime',
                Type: "number"
            },
            {
                Label: 'Siphoning',
                Name: 'KillHeal',
                _Type: "Checkbox"
            },
            {
                Label: 'Map',
                Name: 'Map',
                Choices: [
                    { Text: "Random Map" },
                    ...Maps.map((Val: {Name: string}) => {
                        return { Text: Val.Name }
                    })
                ]
            },
        ]);

        if (!Result ||
            Result.Name.trim().length == 0 ||
            Result.Password.trim().length == 0 ||
            Result.Points.trim().length == 0 || Result.Points <= 0 ||
            Result.SpawnTime.trim().length == 0 || Result.SpawnTime <= 0 ||
            Result.Map.trim().length == 0
        ) {
            FW.Functions.Notify("Vul alle velden in!", "error");
            return false;
        }

        return Result;
    },
    OpenSettings: async (lobbySettings: any) => {
        const Result = await exp['fw-ui'].CreateInput([
            {
                Icon: 'tag',
                Label: 'Te behalen punten',
                Name: 'Points',
                Type: "number",
                Value: lobbySettings.Points || 350,
            },
            {
                Icon: 'tag',
                Label: 'Aantal seconden spawn protection ',
                Name: 'SpawnTime',
                Type: "number",
                Value: lobbySettings.SpawnTime || 3
            },
            {
                Label: 'Siphoning',
                Name: 'KillHeal',
                _Type: "Checkbox",
                Value: lobbySettings.KillHeal || false
            },
            {
                Label: 'Map',
                Name: 'Map',
                Value: lobbySettings.Map,
                Choices: [
                    { Text: "Random Map" },
                    ...Maps.map((Val: {Name: string}) => {
                        return { Text: Val.Name }
                    })
                ]
            },
        ]);

        if (!Result ||
            Result.Points.toString().trim().length == 0 || Result.Points <= 0 ||
            Result.Map.toString().trim().length == 0
        ) {
            FW.Functions.Notify("Vul alle velden in!", "error");
            return false;
        }

        return Result;
    }
};