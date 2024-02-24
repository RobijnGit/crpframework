import { FW } from "./server";
import { GetRaceById } from "./race";
import { DateTime } from "luxon";
import { GetTrackById } from "./tracks";
import { Config } from "../shared/config";

export const UpdateTrackLeaderboard = async (Source: number, RaceId: number, LapTime: number, VehicleHash: number) => {
    const Race = GetRaceById(RaceId);
    if (!Race) return;

    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const RacerInfo = Race.Racers[Race.Racers.findIndex(Val => Val.Cid == Player.PlayerData.citizenid)];
    if (!RacerInfo) return;

    const VehicleData = FW.Shared.HashVehicles[VehicleHash]
    if (!VehicleData) return;

    // Is the Alias already on this race's leaderboard with the current car class?
    const Result = await global.exports['ghmattimysql'].executeSync(`SELECT id, time FROM racing_leaderboard WHERE track_id = ? AND alias = ? AND class = ? LIMIT 1`, [
        Race.TrackId,
        RacerInfo.Alias,
        VehicleData.Class,
    ]);

    // By default assume we don't have a record.
    let Query = "INSERT INTO `racing_leaderboard` (`track_id`, `class`, `alias`, `vehicle`, `time`) VALUES (?, ?, ?, ?, ?)";
    let Parameters: Array<string | number> = [
        Race.TrackId,
        VehicleData.Class,
        RacerInfo.Alias,
        VehicleData.Name,
        LapTime
    ];

    // If there is a record, compare the record time and current best lap time
    // If the record time is faster do not update, if otherwise change the query to update the record.
    if (Result.length > 0) {
        if (Result[0].time < LapTime) return;
        Query = `UPDATE racing_leaderboard SET time = ?, vehicle = ? WHERE id = ?`;
        Parameters = [ LapTime, VehicleData.Name, Result[0].id ];

        // Inform the player that they have broken their PB.
        if (Config.BrokenPBRecord) {
            const Lap1 = DateTime.fromMillis(Result[0].time);
            const Lap2 = DateTime.fromMillis(LapTime);
            Player.Functions.Notify(`Je hebt je persoonlijk record verbroken met ${Lap1.diff(Lap2).toFormat('mm:ss.SSS')}!`, "success")
        }
    };

    global.exports['ghmattimysql'].executeSync(Query, Parameters);
};

const GetTrackLeaderboard = async (TrackId: number) => {
    // Get the leaderboard
    const Result = await global.exports['ghmattimysql'].executeSync(`SELECT * FROM racing_leaderboard WHERE track_id = ? ORDER BY time ASC`, [
        TrackId,
    ]);

    // Re-format the leaderboard
    const Leaderboard = Result.map((Row: any, Index: number) => ({
        Position: Index + 1,
        Alias: Row.alias,
        Class: Row.class,
        Vehicle: Row.vehicle,
        Time: DateTime.fromMillis(Row.time).toFormat('mm:ss.SSS'),
    }));

    return Leaderboard;
};

FW.Functions.CreateCallback("fw-racing:Server:GetTrackLeaderboard", async (Source: number, Cb: Function, Id: number) => {
    const Leaderboard = await GetTrackLeaderboard(Id);
    const Track = await GetTrackById(Id);
    if (!Track) return Cb(false);

    Cb({
        Track: Track.Name,
        Players: Leaderboard
    });
})