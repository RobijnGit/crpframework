import { exp } from "../../shared/utils";
import { FW } from "../client";

export const ToggleFreecam = (Bool: boolean) => {
    // exp['fw-admin'].ToggleNoclip(Bool);
};

export const IsSpectator = (Lobby: {
    Spectators: Array<{ Cid: string }>
}) => {
    const {citizenid} = FW.Functions.GetPlayerData();
    return Lobby.Spectators.findIndex((Val) => Val.Cid == citizenid) != -1;
}