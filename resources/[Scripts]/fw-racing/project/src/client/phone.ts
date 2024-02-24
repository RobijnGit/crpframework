import type { CreateRaceData, RaceMessage } from "../shared/types";
import { GetRandom } from "../shared/utils";
import { FW } from "./client";
import { Checkpoints, IsCreating, StartCreation, StopCreation } from "./creation";
import { CurrentRace } from "./race";
import { AddCheckpointBlip, CanJoinOrStartRace, IsGovWithUsb } from "./utils";

let PreviewBlips: Array<number> = [];
let PreviewTimer: ReturnType<typeof setTimeout>;

export const CanCreateTracks = async (): Promise<boolean> => {
    const Result = await FW.SendCallback("fw-racing:Server:IsRacingCreator")
    return Result
};
global.exports("CanCreateTracks", CanCreateTracks)

export const IsCreatingTrack = () => {
    return IsCreating;
};
global.exports("IsCreatingTrack", IsCreatingTrack);

export const GetTracks = async () => {
    const Result = await FW.SendCallback("fw-racing:Server:GetTracks", IsGovWithUsb())
    return Result;
};
global.exports("GetTracks", GetTracks);

const CreateRaceTrack = () => {
    StartCreation();
    return "Ok";
};
global.exports("CreateRaceTrack", CreateRaceTrack)

const CancelCreation = () => {
    StopCreation();
    return "Ok";
};
global.exports("CancelCreation", CancelCreation)

const SaveRaceTrack = async (Data: { Name: string, Type: string, MinLaps: number }) => {
    const Result = await FW.SendCallback("fw-racing:Server:SaveRaceTrack", Data, Checkpoints, IsGovWithUsb());
    if (Result.Success) StopCreation();
    return Result;
};
global.exports("SaveRaceTrack", SaveRaceTrack)

const SetGPS = async (Data: {TrackId: number}) => {
    SetWaypointOff();

    const Result = await FW.SendCallback("fw-racing:Server:GetTrackById", Data.TrackId);
    if (!Result) return;

    SetNewWaypoint(Result.Checkpoints[0].Pos.x, Result.Checkpoints[0].Pos.y)
};
global.exports("SetGPS", SetGPS);

const Preview = async (Data: {TrackId: number}) => {
    if (PreviewBlips.length > 0) {
        for (let i = 0; i < PreviewBlips.length; i++) {
            RemoveBlip(PreviewBlips[i]);
        };

        PreviewBlips = [];
    };

    if (PreviewTimer) clearTimeout(PreviewTimer);

    const Result = await FW.SendCallback("fw-racing:Server:GetTrackById", Data.TrackId);
    if (!Result) return;

    for (let i = 0; i < Result.Checkpoints.length; i++) {
        const Checkpoint = Result.Checkpoints[i];
        const Blip = AddCheckpointBlip(Checkpoint, i, i == 0 || (Result.Type == "Sprint" && i == (Result.Checkpoints.length - 1)));
        PreviewBlips[i] = Blip;
    };

    PreviewTimer = setTimeout(() => {
        if (PreviewBlips.length > 0) {
            for (let i = 0; i < PreviewBlips.length; i++) {
                RemoveBlip(PreviewBlips[i]);
            };
    
            PreviewBlips = [];
        };    
    }, 15000);
};
global.exports("Preview", Preview);

const CreateRace = async (Data: CreateRaceData) => {
    if (CurrentRace) return { Success: false, Msg: "Je zit al in een race!" };

    const Result = await FW.SendCallback("fw-racing:Server:CreateRace", Data, IsGovWithUsb());
    return Result;
};
global.exports("CreateRace", CreateRace);

const StartRace = async () => {
    if (!CurrentRace) return;

    const [CanJoin, FailureMsg] = await CanJoinOrStartRace(CurrentRace.Id);
    if (!CanJoin) return FW.Functions.Notify(FailureMsg, "error");

    const Result = await FW.SendCallback("fw-racing:Server:StartRace", CurrentRace.Id);
    if (!Result.Success) return FW.Functions.Notify(Result.Msg, Result.Type || "error");

    if (!IsGovWithUsb() && GetRandom(1, 100) > 25) {
        emitNet("fw-mdw:Server:SendAlert:Racing", FW.Functions.GetStreetLabel(), FW.Functions.GetCardinalDirection())
    }

    return "Ok";
};
global.exports("StartRace", StartRace);

const EndRace = async () => {
    if (!CurrentRace) return;
    emitNet("fw-racing:Server:EndRace", CurrentRace.Id)
};
global.exports("EndRace", EndRace);

const LeaveRace = async (Data: {Id: number}) => {
    const Result = await FW.SendCallback("fw-racing:Server:LeaveRace", Data.Id);
    return Result;
};
global.exports("LeaveRace", LeaveRace);

const JoinRace = async (Data: {Id: number, Password: string}) => {
    const [CanJoin, FailureMsg] = await CanJoinOrStartRace(Data.Id);
    if (!CanJoin) return FW.Functions.Notify(FailureMsg, "error");
    
    const Result = await FW.SendCallback("fw-racing:Server:JoinRace", Data.Id, Data.Password);
    return Result;
};
global.exports("JoinRace", JoinRace);

const GetTrackLeaderboard = async (Id: number) => {
    const Result = await FW.SendCallback("fw-racing:Server:GetTrackLeaderboard", Id);
    return Result;
};
global.exports("GetTrackLeaderboard", GetTrackLeaderboard);

const GetRaceById = async (Id: number) => {
    const Result = await FW.SendCallback("fw-racing:Server:GetRaceData", Id);
    return Result;
};
global.exports("GetRaceById", GetRaceById);

const GetRaceTexts = async (Data: {Id: number}) => {
    const Result = await FW.SendCallback("fw-racing:Server:GetRacingTexts", Data.Id);
    return Result;
};
global.exports("GetRaceTexts", GetRaceTexts);

const SendTextMessage = (Data: {
    RaceId: number,
    Attachments: string[],
    Message: string
}) => {
    FW.TriggerServer("fw-racing:Server:SendRacingMessage", Data)
};
global.exports("SendTextMessage", SendTextMessage);

onNet("fw-phone:Client:UpdateRacingTexts", (Data: {
    RaceId: number;
    Texts: RaceMessage[]
}) => {
    global.exports['fw-phone'].UpdateRacingChat(Data);
});