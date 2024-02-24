import { FW } from "./server";
import { Config } from "../shared/config"

FW.Functions.CreateCallback("fw-racing:Server:IsRacingCreator", (Source: number, Cb: Function) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return Cb(false);

    if (Config.PermissionBasedCreators && (FW.Functions.HasPermission(Source, "admin") || FW.Functions.HasPermission(Source, "god"))) {
        return Cb(true);
    };

    Cb(Config.Creators.includes(Player.PlayerData.citizenid));
})

export const IsRacingCreator = (Cid: string) => {
    const Player = FW.Functions.GetPlayerByCitizenId(Cid);
    if (Player && FW.Functions.HasPermission(Player.PlayerData.source, "admin") || FW.Functions.HasPermission(Player.PlayerData.source, "god")) return true;

    return Config.Creators.includes(Cid)
};