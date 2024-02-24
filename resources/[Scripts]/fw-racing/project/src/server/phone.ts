import { FW } from "./server";
import type { Checkpoint, Track } from "../shared/types";
import { CalculateDistance } from "../shared/utils";
import { IsRacingCreator } from "./creation";

FW.Functions.CreateCallback("fw-racing:Server:GetTracks", async (Source: number, Cb: Function, IsGov: boolean) => {
    const Result = await global.exports['ghmattimysql'].executeSync("SELECT * FROM `racing_tracks` WHERE `is_gov` = @IsGov", {
        '@IsGov': IsGov ? 1 : 0
    });

    let ParsedTracks: Track[] = [];
    
    for (let i = 0; i < Result.length; i++) {
        const Data = Result[i];
        ParsedTracks.push({
            Id: Data.id,
            Name: Data.name,
            Type: Data.type,
            IsGov: IsGov,
            Distance: CalculateDistance(JSON.parse(Data.checkpoints)) / 1000,
            MinLaps: 0,
            Checkpoints: [],
        });
    };

    Cb(ParsedTracks);
});

FW.Functions.CreateCallback("fw-racing:Server:SaveRaceTrack", async (Source: number, Cb: Function, Data: { Name: string, Type: string, MinLaps: number }, Checkpoints: Checkpoint[], IsGov: boolean) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return Cb({ Success: false, Msg: "Ongeldige Speler." });

    if (!IsRacingCreator(Player.PlayerData.citizenid)) {
        Cb({ Success: false, Msg: "Geen toegang om race tracks te maken." });
        return;
    };

    if (Checkpoints.length < 3) {
        Cb({ Success: false, Msg: "Een race track moet minimaal 3 checkpoints hebben." });
        return;
    };

    const Result = await global.exports['ghmattimysql'].executeSync("INSERT INTO `racing_tracks` (`name`, `type`, `checkpoints`, `min_laps`, `is_gov`) VALUES (@Name, @Type, @Checkpoints, @MinLaps, @IsGov)", {
        '@Name': Data.Name,
        '@Type': Data.Type,
        '@Checkpoints': JSON.stringify(Checkpoints),
        '@MinLaps': Data.MinLaps,
        '@IsGov': IsGov ? 1 : 0
    });

    if (Result.affectedRows >= 1) {
        Cb({ Success: true })
    } else {
        Cb({ Success: false, Msg: "Database fout opgetreden." })
    };
});