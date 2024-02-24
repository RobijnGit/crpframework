import { DateTime } from "luxon";
import { FW, GetCurrentDocs } from "../server";

export default () => {
    FW.Commands.Add("jail", "Stuur een crimineel naar de gevangenis.", [
        { name: "id", help: "Speler ID" },
        { name: "tijd", help: "Hoelang de crimineel moet wegrotten" },
        { name: "voorwaardelijk", help: "Hoeveel maanden voorwaardelijk?" }
    ], true, (Source: number, Args: string[]) => {
        const Player = FW.Functions.GetPlayer(Source)
        if (!Player) return;

        if (Player.PlayerData.job.name == "police" && GetCurrentDocs() >= 2) {
            return Player.Functions.Notify("Department of Corrections is aanwezig..", "error");
        }

        if ((Player.PlayerData.job.name != "police" && Player.PlayerData.job.name != "doc") || !Player.PlayerData.job.onduty) {
            return Player.Functions.Notify("Dit kan jij niet..", "error");
        };
    
        const TPlayer = FW.Functions.GetPlayer(Number(Args[0]));
        if (!TPlayer) return;
    
        let Time: number = Math.min(Math.floor(Number(Args[1])), 99999); // 69 days
        if (!Time || Time <= 0) return Player.Functions.Notify("Minstens 0 maanden celstaf!", "error");
    
        if (TPlayer.PlayerData.metadata.paroletime > 0) Time += TPlayer.PlayerData.metadata.paroletime;
    
        const Parole: number = Number(Args[2])
        if (Parole == undefined || Parole == null || Parole < 0) return Player.Functions.Notify("Minstens 0 maanden voorwaardelijk!", "error");
    
        TPlayer.Functions.SetMetaData("paroletime", Parole)
        TPlayer.Functions.SetMetaData("jailtime", Time)
        emitNet("fw-assets:Client:JailMugshot", TPlayer.PlayerData.source, `${TPlayer.PlayerData.charinfo.firstname} ${TPlayer.PlayerData.charinfo.lastname}`, Time, TPlayer.PlayerData.citizenid, DateTime.local().toFormat('dd/MM/yyyy'));
    })
}