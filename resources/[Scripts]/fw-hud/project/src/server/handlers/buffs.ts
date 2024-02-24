import { exp } from "../../shared/utils";
import { Buffs } from "../config";
import { FW } from "../server";
let BuffedPlayers: {[key: number]: Array<string>} = {};

FW.Functions.CreateCallback("fw-hud:Server:GetBuffs", (Source: number, Cb: Function) => {
    Cb(Buffs)
});

FW.Functions.CreateCallback("fw-hud:Server:DoesPlayerHaveBuff", (Source: number, Cb: Function, BuffId: string) => {
    Cb(DoesPlayerHaveBuff(Source, BuffId))
});

FW.RegisterServer("fw-hud:Server:ApplyBuff", (Source: number, BuffId: string, Percentage: number) => {
    if (!Buffs[BuffId]) return console.log(`Failed to add buff to player, invalid BuffId. | Source: ${Source}; BuffId: ${BuffId}; Percentage: ${Percentage}`);

    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (!BuffedPlayers[Source]) BuffedPlayers[Source] = [];
    BuffedPlayers[Source].push(BuffId);

    emitNet("fw-hud:Client:SetCurrentBuff", Source, BuffId, {
        HudId: Buffs[BuffId].HudId,
        Value: Percentage
    });

    emitNet("fw-hud:Client:ApplyBuff", Source, BuffId, Percentage);
});

FW.RegisterServer("fw-hud:Server:RemoveBuff", (Source: number, BuffId: string) => {
    emitNet("fw-hud:Client:RemoveBuff", Source, BuffId);
    if (!BuffedPlayers[Source] || !BuffedPlayers[Source].includes(BuffId)) {
        return console.warn(`A buff was removed from a player, but the server was unknown of this buff. | Source: ${Source}; BuffId: ${BuffId}`);
    };

    BuffedPlayers[Source].filter(Val => Val != BuffId);
});

const DoesPlayerHaveBuff = (Source: number, BuffId: string) => {
    if (!BuffedPlayers[Source]) return false;
    return BuffedPlayers[Source].includes(BuffId);
};
exp("DoesPlayerHaveBuff", DoesPlayerHaveBuff);