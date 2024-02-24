import { Vector3 } from "../shared/classes/math";
import { Config } from "../shared/config";
import type { CreateRaceData, Race, RaceMessage, Racer, RacerPosition, Track } from "../shared/types";
import { CalculateDistance } from "../shared/utils";
import { UpdateTrackLeaderboard } from "./leaderboard";
import { FW } from "./server";
import { GetTrackById } from "./tracks";

let Races: Race[] = [];
let RaceChats: { [key: number]: RaceMessage[] } = {};
let RacesPositions: { [key: number]: Array<RacerPosition> } = {};

FW.Functions.CreateCallback("fw-racing:Server:GetRaces", async (Source: number, Cb: Function, IsGov: boolean) => {
    const FilteredRaces = Races.filter(Val => Val.IsGov == IsGov);
    const Result = FilteredRaces.map(({
        Name, Id, TrackId, Creator, Racers, State, Type, Laps, Distance, IsGov, Settings
    }) => ({
        Name, Id, TrackId, Creator, Racers, State, Type, Laps, Distance, IsGov, Settings
    }));

    Cb(Result);
});

FW.Functions.CreateCallback("fw-racing:Server:GetRaceData", async (Source: number, Cb: Function, RaceId: number) => {
    Cb(GetRaceById(RaceId) || false);
});

FW.Functions.CreateCallback("fw-racing:Server:CreateRace", async (Source: number, Cb: Function, Data: CreateRaceData, IsGov: boolean) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return Cb({ Success: false, Msg: "Ongeldige Speler!" })

    const Track: false | Track = await GetTrackById(Data.TrackId);
    if (!Track) return Cb({ Success: false, Msg: "Ongeldige Track" })
    if (!Data.Name) return Cb({ Success: false, Msg: "Event Naam is vereist!" })

    // Validate data:
    if (Data.Reverse) Track.Checkpoints = Track.Checkpoints.reverse();
    if (!Data.CheckpointPenalty || Data.CheckpointPenalty < 0 || typeof Data.CheckpointPenalty != "number") Data.CheckpointPenalty = Number(Data.CheckpointPenalty || 0);
    if (!Data.Countdown || Data.Countdown < 3) Data.Countdown = 5;
    if (Data.Type == "Laps" && Data.Laps <= 0) Data.Laps = 1;
    if (!Data.Class) Data.Class = "Open";
    if (Data.Amount < 0) Data.Amount = 0;
    if (!Data.DNFPosition || Data.DNFPosition <= 0 || typeof Data.DNFPosition != "number") Data.DNFPosition = Number(Data.DNFPosition || 10);
    if (!Data.DNFCountdown || Data.DNFCountdown <= 0 || typeof Data.DNFCountdown != "number") Data.DNFCountdown = Number(Data.DNFCountdown || 180);
    if (!Data.Phasing) Data.Phasing = "None";
    if (!Data.Password || Data.Password.length == 0) Data.Password = false;

    // @ts-ignore
    // const Coords = new Vector3().setFromArray(GetEntityCoords(GetPlayerPed(Source), false))
    // if (Coords.getDistance(Track.Checkpoints[0].Pos) > 50.0) {
    //     return Cb({ Success: false, Msg: "Je bent te ver van het startpunt vandaan." })
    // }

    let PlayerAlias = `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}`
    if (!IsGov) {
        const Item = Player.Functions.GetItemByName('racing-usb')
        if (!Item) return;
        if (!Item.Info.Alias || Item.Info?._Owner != Player.PlayerData.citizenid) return;
        PlayerAlias = Item.Info.Alias;
    };

    const RaceId = Races.length;
    const RaceData: Race = {
        Id: RaceId,
        TrackId: Data.TrackId,
        Name: Data.Name,
        Type: Data.Type || "Sprint",
        Laps: Data.Type == "Laps" ? Data.Laps : 1,
        Class: Data.Class || "Open",
        Distance: CalculateDistance(Track.Checkpoints) / 1000,
        State: "Pending",
        Creator: Player.PlayerData.citizenid,
        Racers: [
            {
                Source: Player.PlayerData.source,
                Cid: Player.PlayerData.citizenid,
                Alias: PlayerAlias,
                Finished: false
            },
        ],
        IsGov: IsGov,
        DNFStarted: false,
        Settings: Data,
        Checkpoints: Track.Checkpoints
    }

    Races = [RaceData, ...Races];

    emitNet("fw-racing:Client:SetCurrentRace", Source, RaceData);
    if (Data.SendNotification) emitNet("fw-racing:Client:NewRace", -1);

    Cb({ Success: true })
})

FW.Functions.CreateCallback("fw-racing:Server:StartRace", async (Source: number, Cb: Function, RaceId: number) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return Cb({ Success: false, Msg: "Ongeldige Speler!" })

    const Race: Race = GetRaceById(RaceId);
    if (!Race) return Cb({Success: false, Msg: "Ongeldige Race!"});

    if (Race.Creator != Player.PlayerData.citizenid) return Cb({Success: false, Msg: "Alleen de raceorganisator kan de race starten!"});
    Race.State = "Active";

    for (let i = 0; i < Race.Racers.length; i++) {
        const Target = FW.Functions.GetPlayerByCitizenId(Race.Racers[i].Cid);
        if (Target) {
            // @ts-ignore
            const PlayerCoords = new Vector3().setFromArray(GetEntityCoords(GetPlayerPed(Target.PlayerData.source)));
            const Dist = PlayerCoords.getDistance(Race.Checkpoints[0].Pos);
            if (Dist > 50.0) {
                RemoveCidFromRace(RaceId, Race.Racers[i].Cid, 'is gekicked omdat hij te ver van het startpunt was.');
            };

            emitNet("fw-racing:Client:StartRace", Target.PlayerData.source);
        } else {
            RemoveCidFromRace(RaceId, Race.Racers[i].Cid);
        };
    };

    // Are all racers kicked, set the race to completed
    if (Race.Racers.length == 0) Race.State = "Completed";

    Cb({ Success: true })
});

FW.Functions.CreateCallback("fw-racing:Server:GetPosition", async (Source: number, Cb: Function, RaceId: number) => {
    if (!RacesPositions[RaceId]) return Cb(1);

    const RacerIndex = RacesPositions[RaceId].findIndex((Val: RacerPosition) => Val.Source === Source);
    Cb(RacerIndex === -1 ? 1 : RacerIndex + 1)
});

FW.Functions.CreateCallback("fw-racing:Server:JoinRace", async (Source: number, Cb: Function, RaceId: number, Password: string) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return Cb({ Success: false, Msg: "Ongeldige Speler!" })

    const Race: Race = GetRaceById(RaceId);
    if (!Race) return Cb({Success: false, Msg: "Ongeldige Race!"});

    if (Race.State != "Pending") return Cb({Success: false, Msg: "Race is al gestart of afgerond!"})

    if (Race.Settings.Password && Race.Settings.Password.length > 0 && Race.Settings.Password != Password) return Cb({Success: false, Msg: "Incorrect Wachtwoord"})

    let PlayerAlias = `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}`
    if (!Race.IsGov) {
        const Item = Player.Functions.GetItemByName('racing-usb')
        if (!Item) return;
        if (!Item.Info.Alias || Item.Info?._Owner != Player.PlayerData.citizenid) return;
        PlayerAlias = Item.Info.Alias;
    };

    if (Race.Racers.findIndex(Val => Val.Cid == Player.PlayerData.citizenid) > -1) {
        RemoveCidFromRace(RaceId, Player.PlayerData.citizenid);
        return Cb({Success: true})
    };

    Race.Racers.push({
        Source: Player.PlayerData.source,
        Cid: Player.PlayerData.citizenid,
        Alias: PlayerAlias,
        Finished: false,
    });

    emitNet("fw-racing:Client:SetCurrentRace", Source, Race);

    const Creator = FW.Functions.GetPlayerByCitizenId(Race.Creator);
    if (Creator) {
        emitNet("fw-phone:Client:Notification", Creator.PlayerData.source, `racing-join-${Player.PlayerData.citizenid}`, "fas fa-flag-checkered", [ "white", "#039380" ], "Race Join", `${PlayerAlias} is je race gejoined.`)
    };

    Cb({Success: true})
});

FW.Functions.CreateCallback("fw-racing:Server:LeaveRace", async (Source: number, Cb: Function, RaceId: number) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return Cb({ Success: false, Msg: "Ongeldige Speler!" })

    const Race: Race = GetRaceById(RaceId);
    if (!Race) return Cb({Success: false, Msg: "Ongeldige Race!"});

    if (Race.Racers.findIndex(Val => Val.Cid == Player.PlayerData.citizenid) == -1) {
        return Cb({Success: false, Msg: "Je zit niet in deze race!"})
    };

    RemoveCidFromRace(RaceId, Player.PlayerData.citizenid);

    Cb({Success: true})
});

FW.Functions.CreateCallback("fw-racing:Server:GetRacingTexts", (Source: number, Cb: Function, RaceId: number) => {
    const Race: Race = GetRaceById(RaceId);
    if (!Race) return Cb({Success: false})

    if (!RaceChats[RaceId]) {
        RaceChats[RaceId] = [];
    };

    Cb({ Success: true, Texts: RaceChats[RaceId] });
});

FW.RegisterServer("fw-racing:Server:UpdatePosition", (Source: number, RaceId: number, Lap: number, Checkpoint: number) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    // No array for positions? Create it.
    if (!RacesPositions[RaceId]) RacesPositions[RaceId] = [];

    // Get the racer
    const RacerIndex = RacesPositions[RaceId].findIndex((Val: RacerPosition) => Val.Source === Source);

    // Create or update the racers info
    if (RacerIndex === -1) {
        RacesPositions[RaceId].push({ Source, Cid: Player.PlayerData.citizenid, Lap, Checkpoint });
    } else {
        RacesPositions[RaceId][RacerIndex].Lap = Lap;
        RacesPositions[RaceId][RacerIndex].Checkpoint = Checkpoint;
    };

    // Sort the positions by lap and checkpoint
    RacesPositions[RaceId].sort((a, b) => {
        if (a.Lap !== b.Lap) {
            return b.Lap - a.Lap; // Sort by lap in descending order
        } else if (a.Checkpoint !== b.Checkpoint) {
            return b.Checkpoint - a.Checkpoint; // Sort by checkpoint in descending order if lap is the same
        } else {
            return 0; // If both lap and checkpoint are the same, maintain the current order
        }
    });

    const Race = GetRaceById(RaceId);
    if (!Race) return;

    if (Race.Laps == Lap && Race.Checkpoints.length == Checkpoint) {
        Race.Racers[Race.Racers.findIndex(Val => Val.Cid == Player.PlayerData.citizenid)].Finished = true;
    };

    const FinishedRacers = Race.Racers.filter(Val => Val.Finished).length;
    if (FinishedRacers == Race.Racers.length) {
        Race.State = "Completed";
        PayoutRacers(Race.Id);

        setTimeout(() => {
            for (let i = 0; i < Race.Racers.length; i++) {
                const Target = FW.Functions.GetPlayerByCitizenId(Race.Racers[i].Cid);
                if (Target) emitNet("fw-racing:Client:SetCurrentRace", Target.PlayerData.source, false);
            };
        }, 30000);
        return;
    };

    if (FinishedRacers >= Race.Settings.DNFPosition && !Race.DNFStarted) {
        Race.DNFStarted = true;
        const DNFTimestamp: number = new Date().getTime() + (Race.Settings.DNFCountdown * 1000);
        for (let i = 0; i < Race.Racers.length; i++) {
            const Target = FW.Functions.GetPlayerByCitizenId(Race.Racers[i].Cid);
            if (Target) emitNet("fw-racing:Client:StartDNFTimer", Target.PlayerData.source, DNFTimestamp);
        };

        setTimeout(() => {
            Race.State = "Completed";
            PayoutRacers(Race.Id);
        }, Race.Settings.DNFCountdown * 1000);
    }
});

FW.RegisterServer("fw-racing:Server:Finished", (Source: number, RaceId: number, LapTime: number, TotalTime: number, VehicleHash: number, IsDNF: boolean) => {
    if (!IsDNF) UpdateTrackLeaderboard(Source, RaceId, LapTime, VehicleHash);

    const Index = RacesPositions[RaceId].findIndex(Val => Val.Source == Source);
    if (Index == -1) return;

    RacesPositions[RaceId][Index].Total = TotalTime;
    RacesPositions[RaceId][Index].Best = LapTime;
    RacesPositions[RaceId][Index].DNF = IsDNF;
});

FW.RegisterServer("fw-racing:Server:SendRacingMessage", (Source: number, {RaceId, Attachments, Message}: {
    RaceId: number,
    Attachments: string[],
    Message: string
}) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Race: Race = GetRaceById(RaceId);
    if (!Race) return;

    let PlayerAlias = `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}`
    if (!Race.IsGov) {
        const Item = Player.Functions.GetItemByName('racing-usb')
        if (!Item) return;
        if (!Item.Info.Alias || Item.Info?._Owner != Player.PlayerData.citizenid) return;
        PlayerAlias = Item.Info.Alias;
    };

    if (Race.Racers.findIndex(Val => Val.Cid == Player.PlayerData.citizenid) == -1) {
        return
    };

    if (!RaceChats[RaceId]) {
        RaceChats[RaceId] = [];
    };

    RaceChats[RaceId] = [
        {
            Sender: Player.PlayerData.charinfo.phone,
            Timestamp: new Date().getTime(),
            TimestampLabel: PlayerAlias,
            Message,
            Attachments
        },
        ...RaceChats[RaceId]
    ];

    for (let i = 0; i < Race.Racers.length; i++) {
        const { Source } = Race.Racers[i];
        emitNet("fw-phone:Client:UpdateRacingTexts", Source, {RaceId, Texts: RaceChats[RaceId]});
    };
});

onNet("fw-racing:Server:EndRace", (RaceId: number) => {
    const Source = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Race = GetRaceById(RaceId);
    if (Race.Creator != Player.PlayerData.citizenid) return FW.Functions.Notify("Alleen de raceorganisator kan de race stoppen!", "error");

    Race.State = "Completed";
    for (let i = 0; i < Race.Racers.length; i++) {
        const Target = FW.Functions.GetPlayerByCitizenId(Race.Racers[i].Cid);
        if (Target) {
            emitNet("fw-racing:Client:EndRace", Target.PlayerData.source)
            emitNet("fw-racing:Client:SetCurrentRace", Target.PlayerData.source, false);
        };
    };

    PayoutRacers(RaceId, true)
});

export const GetRaceById = (RaceId: number) => {
    return Races[Races.findIndex(Val => Val.Id == RaceId)];
}

const RemoveCidFromRace = (RaceId: number, Cid: string, Reason: string = "is je race verlaten") => {
    const Race = GetRaceById(RaceId);
    if (!Race) return;

    const RacerIndex = Race.Racers.findIndex(Val => Val.Cid == Cid);
    if (RacerIndex == -1) return;

    const Racer = Race.Racers[RacerIndex];
    Race.Racers.splice(RacerIndex, 1);

    const RacerPly = FW.Functions.GetPlayerByCitizenId(Racer.Cid);
    if (RacerPly) emitNet("fw-racing:Client:SetCurrentRace", RacerPly.PlayerData.source, false);

    const Creator = FW.Functions.GetPlayerByCitizenId(Race.Creator);
    if (!Creator) return;
    emitNet("fw-phone:Client:Notification", Creator.PlayerData.source, `racing-left-${Racer.Cid}`, "fas fa-flag-checkered", [ "white", "#039380" ], "Race Verlaten", `${Racer.Alias} ${Reason}`)
};

const GenerateDistribution = (Players: number): number[] => {
    const Retval: number[] = [];

    const FirstPlacePercentage: number = 40;
    const SecondPlacePercentage: number = 30;
    const ThirdPlacePercentage: number = 20;
    const RemainingPercentage: number = 100;

    Retval.push(FirstPlacePercentage, SecondPlacePercentage, ThirdPlacePercentage);

    const remainingPlayers = Players;
    if (remainingPlayers > 0) {
        const equalPercentage = RemainingPercentage / remainingPlayers;
        for (let i: number = 0; i < remainingPlayers; i++) {
            Retval.push(Math.min(equalPercentage, 20));
        };
    };

    return Retval;
};

const PayoutRacers = (RaceId: number, ForceEnd: boolean = false) => {
    const Race: Race = GetRaceById(RaceId);
    if (!Race) return console.log(`Failed to do payout for ${RaceId}, no race existed with defined id.`);
    if (!RacesPositions[RaceId]) return console.log(`Failed to do payout for ${RaceId}, no race positions where cached.`);

    let SortedRacers: Racer[] = [];
    for (let i = 0; i < RacesPositions[RaceId].length; i++) {
        const Racer = RacesPositions[RaceId][i];
        const OrgRacer = Race.Racers.find(Val => Val.Cid == Racer.Cid);
        if (OrgRacer) {
            SortedRacers.push({
                Source: OrgRacer.Source,
                Cid: OrgRacer.Cid,
                Alias: OrgRacer.Alias,
                Finished: !Racer.DNF,
                BestTime: Racer.Best,
                TotalTime: Racer.Total,
                GNEReward: 0,
                MoneyReward: 0,
            });
        }
    };

    SortedRacers.sort((a: Racer, b: Racer) => {
        if (!a.TotalTime || !b.TotalTime) return 0;
        return a.TotalTime - b.TotalTime;
    });

    if (!Race.IsGov) {
        const {Hour} = global.exports['fw-sync'].GetCurrentTime();
        const SumDistribution = [0.5, 0.3, 0.2];
        const TotalSum = Race.Settings.Amount * Race.Racers.length;
        const TotalGNE = (Hour > 18 && Hour < 6 ? Config.CryptoRewardNight : Config.CryptoReward) * Race.Racers.length;

        for (let i = 0; i < 3; i++) {
            if (SortedRacers[i]) SortedRacers[i].MoneyReward = TotalSum * SumDistribution[i];
        };

        if (SortedRacers.length >= 5) {
            const Distribution: number[] = GenerateDistribution(SortedRacers.filter(Val => Val.Finished == true).length);
            const GNERewards: number[] = Distribution.map(Percentage => Math.floor(TotalGNE * (Percentage / 100)));

            for (let i = 0; i < SortedRacers.length; i++) {
                if (!GNERewards[i] || !SortedRacers[i].Finished || ForceEnd) {
                    SortedRacers[i].GNEReward = 0;
                } else {
                    SortedRacers[i].GNEReward = GNERewards[i] + 2;
                    const Target = FW.Functions.GetPlayerByCitizenId(SortedRacers[i].Cid);
                    if (Target) {
                        Target.Functions.AddCrypto('GNE', SortedRacers[i].GNEReward);
                    };
                };
            };
        };
    };

    Races[Races.findIndex(Val => Val.Id == RaceId)].Racers = SortedRacers;
};

on("playerDropped", (Reason: string) => {
    const Source = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const ActiveRaces = Races.filter(Val => Val.State == "Pending" || Val.State == "Active");

    const EndRace = (RaceId: number) => {
        const Race = GetRaceById(RaceId)
        Race.State = "Completed";

        for (let i = 0; i < Race.Racers.length; i++) {
            const Target = FW.Functions.GetPlayerByCitizenId(Race.Racers[i].Cid);
            if (Target) {
                emitNet("fw-racing:Client:EndRace", Target.PlayerData.source)
                emitNet("fw-racing:Client:SetCurrentRace", Target.PlayerData.source, false);
            };
        };

        PayoutRacers(RaceId, true);
    };

    for (let i = 0; i < ActiveRaces.length; i++) {
        const Race = ActiveRaces[i];
        if (Race.Creator == Player.PlayerData.citizenid) {
            EndRace(Race.Id);
            break
        };

        for (let j = 0; j < Race.Racers.length; j++) {
            const Racer = Race.Racers[j];
            if (Racer.Cid == Player.PlayerData.citizenid) {
                RemoveCidFromRace(Race.Id, Racer.Cid);
            };
        };
    };
});
