import { exp } from "../shared/utils";
export const FW = exp['fw-core'].GetCoreObject();

import { Hud } from "../shared/config";

import "./handlers/buffs";
import "./handlers/preferences";

const GetHudId = (Id: string): number => {
    return Hud.findIndex(Val => Val.Id == Id);
};
exp("GetHudId", GetHudId);

FW.Commands.Add("cash", "Hoeveel contant hebbie?", [], false, (Source: number, Args: Array<string>) => {
    const Player = FW.Functions.GetPlayer(Source)
    if (!Player) return;

    emitNet('fw-hud:Client:ShowCash', Source);
});