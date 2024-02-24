import { Vector3, Vector4 } from "../../../shared/classes/math/vector3"
import { Delay, GetRandom, exp } from "../../../shared/utils"
import { FW } from "../../client";
import { Maps } from "../../../shared/games/vehicle-tag/maps";
import { TeamThread, ZoneThread } from "./zone";
import { currentLobby } from "../../lobby/utils";
import { IsSpectator, ToggleFreecam } from "../../lobby/spectate";

export const Vehicles = [
    {Name: "Off Road voertuigen", Models: [ "yosemite3", "brawler", "kamacho", "caracara2", "hellion", "everon", "freecrawler" ] },
    {Name: "Sports", Models: [ "seven70", "coquette4", "italigto", "neo", "pariah", "corsita", "tenf2", "comet5", "sentinel4" ] },
    {Name: "Caddy", Models: [ "caddy" ] },
    {Name: "Motoren", Models: [ "esskey", "nemesis", "pcj", "vader" ] },
];

export let currentMap = Maps[0];
export let MyTeam: number = 1;
export let currentHolder: number[] = [2, 0];
let VehicleTagMatchActive = false;
let TagVehicle: number = 0;
let HolderBlip: number;

onNet("fw-arcade:Client:VTag:LoadGame", async (Data: {
    Game: string;
    Id: number;
    Map: string;
    Vehicles: string;
}) => {
    exp['fw-sync'].SetClientSync(false, {Time: 12, Weather: "SMOG"});
    exp['fw-assets'].SetDensity("Vehicle", 0.0);
    exp['fw-assets'].SetDensity("Parked", 0.0);
    exp['fw-assets'].SetDensity("Peds", 0.0);
    exp['fw-assets'].SetDensity("Scenarios", 0.0);

    VehicleTagMatchActive = true;
    currentMap = Maps.find((Val: {Name: string}) => Val.Name == Data.Map) || Maps[0];

    const Models = Vehicles.find((Val: {Name: string}) => Val.Name == Data.Vehicles)?.Models || Vehicles[0].Models;
    const Spawns = currentMap.Spawners;

    const Lobby = await FW.SendCallback("fw-arcade:Server:GetLobby", 'vehicleTag', Data.Id);
    if (!Lobby) return;

    const Spectator = IsSpectator(Lobby);
    if (Spectator) {
        MyTeam = 0;
        ToggleFreecam(true);
        SetEntityCoords(PlayerPedId(), currentMap.Coords.x, currentMap.Coords.y, currentMap.Coords.z + 50.0, false, false, false, false);
    } else {
        const {citizenid} = FW.Functions.GetPlayerData();
        MyTeam = Lobby.Players.find((Val: {Cid: string}) => Val.Cid == citizenid)?.Team || 1;
        const TeamPlayers = Lobby.Players.filter((Val: {Team: number}) => Val.Team == MyTeam);
        const TeamIndex = TeamPlayers.findIndex((Val: {Cid: string}) => Val.Cid == citizenid);
    
        const VehicleModel = Models[GetRandom(1, Models.length) - 1];
        const Location = Spawns[MyTeam - 1][TeamIndex];
    
        SetEntityCoords(PlayerPedId(), Location.x, Location.y, Location.z - 1.5, false, false, false, false);
        FreezeEntityPosition(PlayerPedId(), true);
        SetEntityInvincible(PlayerPedId(), true);
    
        const Plate = `VTAG${GetRandom(1000, 9999)}`;
        const NetId: number = await FW.SendCallback("fw-arcade:Server:VTag:SpawnVehicle", VehicleModel, Location, Plate);
    
        while (!NetworkDoesEntityExistWithNetworkId(NetId)) await Delay(100);
    
        TagVehicle = NetToVeh(NetId);
        while (!DoesEntityExist(TagVehicle)) await Delay(100);
    
        NetworkRequestControlOfEntity(TagVehicle);

        setTimeout(() => {
            FW.Functions.SetVehiclePlate(TagVehicle, Plate);
            NetworkRegisterEntityAsNetworked(TagVehicle);
            SetEntityHeading(TagVehicle, Location.w);
            SetEntityInvincible(TagVehicle, true);
    
            exp['fw-vehicles'].SetVehicleKeys(Plate, true, false);
            exp['fw-vehicles'].SetFuelLevel(TagVehicle, 100.0);
    
            SetVehicleModKit(TagVehicle, 0);
            SetVehicleColours(TagVehicle, MyTeam == 1 ? 0 : 135, MyTeam == 1 ? 0 : 135);
            SetVehicleExtraColours(TagVehicle, 0, 0)
            SetVehicleLivery(TagVehicle, 0);
    
            FreezeEntityPosition(PlayerPedId(), false);
            TaskWarpPedIntoVehicle(PlayerPedId(), TagVehicle, -1);
        }, 1000);
    }

    ZoneThread.data.Center = currentMap.Coords;
    ZoneThread.data.Radius = currentMap.Radius;
    ZoneThread.data.IsSpectator = Spectator;
    ZoneThread.start();
});

onNet("fw-arcade:Client:VTag:Ready", () => {
    setTimeout(() => {
        DoScreenFadeIn(1000);
    }, 2000);
})

onNet("fw-arcade:Client:VTag:UnloadGame", async () => {
    VehicleTagMatchActive = false;

    exp['fw-sync'].SetClientSync(true)
    exp['fw-assets'].ResetDensity();
    ToggleFreecam(false);

    ZoneThread.stop();
    TeamThread.stop();

    SetEntityCoords(PlayerPedId(), -1656.82, -1069.83, 12.16, false, false, false, false);
    SetEntityHeading(PlayerPedId(), 141.9);
    FreezeEntityPosition(PlayerPedId(), false);
    SetEntityInvincible(PlayerPedId(), false);

    emit("fw-medical:Client:Revive");
    emitNet('fw-ui:Server:remove:stress', 100);

    await Delay(1000);

    DoScreenFadeIn(500);
    exp['fw-ui'].RemoveInfo();
})

onNet("fw-arcade:Client:VTag:UpdateInfo", async (Data: {
    PointsGoal: number;
    Timer: number;
    Points: number[];
    TagHolder: number[];
}) => {
    if (!VehicleTagMatchActive) return;
    
    if (Data.TagHolder[0] != currentHolder[0] || Data.TagHolder[1] != currentHolder[1] || !TeamThread.data.Vehicle) {
        currentHolder = Data.TagHolder;
        
        const Lobby = await FW.SendCallback("fw-arcade:Server:GetLobby", 'vehicleTag', currentLobby);
        if (!Lobby) return;

        const HolderPed = GetPlayerPed(GetPlayerFromServerId(Lobby.Players[currentHolder[1]].Source))
        TeamThread.data.Vehicle = GetVehiclePedIsIn(HolderPed, false);
        TeamThread.data.Holder = currentHolder[0];
        TeamThread.data.MyTeam = MyTeam;

        if (HolderBlip) RemoveBlip(HolderBlip);
        if (TeamThread.data.Vehicle) {
            HolderBlip = AddBlipForEntity(TeamThread.data.Vehicle);
            SetBlipSprite(HolderBlip, 439);
            SetBlipColour(HolderBlip, 1);
            SetBlipScale(HolderBlip, 1.0);
        }

        if (!TeamThread.running) {
            TeamThread.start();
        };
    };

    let ExtraItems: Array<{Text: string}> = [];
    if (MyTeam == currentHolder[0]) {
        ExtraItems.push({
            Text: "Jouw team heeft momenteel de tag vast!"
        })
    }

    exp['fw-ui'].ShowInfo({
        Title: "Vehicle Tag",
        Items: [
            { Text: `Resterende tijd: ${FormatTime(Data.Timer)}` },
            { Text: `Eerste die ${Data.PointsGoal} punten behaald wint!` },
            { Text: `Team 1: ${Data.Points[0]} punten` },
            { Text: `Team 2: ${Data.Points[1]} punten` },
            ...ExtraItems
        ]
    })
});

const FormatTime = (Seconds: number): string => {
    const Minutes: number = Math.floor(Seconds / 60);
    const RemainingSeconds: number = Seconds % 60;

    const MinutesString: string = Minutes < 10 ? `0${Minutes}` : `${Minutes}`;
    const SecondsString: string = RemainingSeconds < 10 ? `0${RemainingSeconds}` : `${RemainingSeconds}`;

    return `${MinutesString}:${SecondsString}`;
};

export default () => {
    exp['fw-ui'].AddEyeEntry("arcade-vehicle-tag", {
        Type: 'Zone',
        SpriteDistance: 7.0,
        Distance: 3.5,
        ZoneData: {
            Center: new Vector3(-1658.54, -1071.99, 12.16),
            Length: 2.6,
            Width: 1.0,
            Data: {
                heading: 50,
                minZ: 11.16,
                maxZ: 13.36,
            },
        },
        Options: [
            {
                Name: 'vehicletag',
                Icon: 'fas fa-chess',
                Label: 'Vehicle Tag spelen',
                EventType: 'Client',
                EventName: 'fw-arcade:Client:OpenLobbyMenu',
                EventParams: { Game: "vehicleTag" },
                Enabled: (Entity: number) => {
                    return true
                },
            },
            {
                Name: 'repair',
                Icon: 'fas fa-hammer',
                Label: 'Arcadekast beheren',
                EventType: 'Client',
                EventName: 'fw-arcade:Client:OpenArcadeManagement',
                EventParams: { Game: "vehicleTag" },
                Enabled: async () => await exp['fw-businesses'].HasRolePermission("Coopers Arcade", "CraftAccess"),
            },
        ]
    });
};

export const VehicleTag = {
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
                Label: 'Tijd in minuten',
                Name: 'Time',
                Type: "number",
            },
            {
                Icon: 'tag',
                Label: 'Te behalen punten',
                Name: 'Points',
                Type: "number"
            },
            {
                Label: 'Voertuig groep',
                Name: 'Vehicles',
                Choices: Vehicles.map((Val) => {
                    return { Text: Val.Name }
                })
            },
            {
                Label: 'Map',
                Name: 'Map',
                Choices: Maps.map((Val: {Name: string}) => {
                    return { Text: Val.Name }
                })
            },
        ]);

        if (!Result ||
            Result.Name.trim().length == 0 ||
            Result.Password.trim().length == 0 ||
            Result.Time.trim().length == 0 || Result.Time <= 0 ||
            Result.Points.trim().length == 0 || Result.Points <= 0 ||
            Result.Vehicles.trim().length == 0 ||
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
                Label: 'Tijd in minuten',
                Name: 'Time',
                Type: "number",
                Value: lobbySettings.Time || 15,
            },
            {
                Icon: 'tag',
                Label: 'Te behalen punten',
                Name: 'Points',
                Type: "number",
                Value: lobbySettings.Points || 350,
            },
            {
                Label: 'Voertuig groep',
                Name: 'Vehicles',
                Value: lobbySettings.Vehicles,
                Choices: Vehicles.map((Val) => {
                    return { Text: Val.Name }
                })
            },
            {
                Label: 'Map',
                Name: 'Map',
                Value: lobbySettings.Map,
                Choices: Maps.map((Val: {Name: string}) => {
                    return { Text: Val.Name }
                })
            },
        ]);

        if (!Result ||
            Result.Time.toString().trim().length == 0 || Result.Time <= 0 ||
            Result.Points.toString().trim().length == 0 || Result.Points <= 0 ||
            Result.Vehicles.toString().trim().length == 0 ||
            Result.Map.toString().trim().length == 0
        ) {
            FW.Functions.Notify("Vul alle velden in!", "error");
            return false;
        }

        return Result;
    }
}