import { Track } from "../shared/types";
import { FW } from "./server";

export const GetTrackById = async (TrackId: number) => {
    const Result = await global.exports['ghmattimysql'].executeSync("SELECT * FROM `racing_tracks` WHERE `id` = @Id", {
        '@Id': TrackId
    })

    let Retval: false | Track = false;
    if (Result[0]) {
        Retval = {
            Id: Result[0].id,
            Name: Result[0].name,
            Type: Result[0].type,
            MinLaps: Result[0].min_laps,
            Distance: 0,
            Checkpoints: JSON.parse(Result[0].checkpoints),
            IsGov: Result[0].is_gov,
        };
    }

    return Retval;
}

FW.Functions.CreateCallback("fw-racing:Server:GetTrackById", async (Source: number, Cb: Function, TrackId: number) => {
    const Result = await GetTrackById(TrackId);
    Cb(Result)
});