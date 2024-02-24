import { exp } from "../../shared/utils";
import { FW } from "../server";
import { GetLobby, sourceToLobby } from "./main";

export const IsCidInAnyLobby = (Cid: string): boolean => {
    const Player = FW.Functions.GetPlayerByCitizenId(Cid);
    if (!Player) return true;
    if (!sourceToLobby[Player.PlayerData.source]) return false;
    return true;
};

export const IsCidInLobby = (Game: string, Id: number, Cid: string): boolean => {
    const Result = GetLobby(Game, Id);
    if (!Result) return false;
    return (Result.Players.findIndex(Val => Val.Cid == Cid) != -1 || Result.Spectators.findIndex(Val => Val.Cid == Cid) != -1);
};

export const SendLobbyNotify = (Game: string, Id: number, Message: string) => {
    const Lobby = GetLobby(Game, Id);
    if (!Lobby) return;

    const Players = [...Lobby.Players, ...Lobby.Spectators];
    for (let i = 0; i < Players.length; i++) {
        const {Source, Cid} = Players[i];
        emitNet('FW:Notify', Source, Message)
    };
};

export const TriggerLobbyEvent = (Game: string, Id: number, Event: string, Payload: any) => {
    const Lobby = GetLobby(Game, Id);
    if (!Lobby) return;

    const Players = [...Lobby.Players, ...Lobby.Spectators];
    for (let i = 0; i < Players.length; i++) {
        const {Source, Cid} = Players[i];
        emitNet(Event, Source, {Game, Id, ...Payload});
    };
};

export const DegradeArcadeMachine = async (Game: string, Degradation: number) => {
    const { arcadeMachines } = await exp['fw-config'].GetModuleConfig("bus-arcade", {arcadeMachines: {}});
    if (arcadeMachines[Game] == undefined) return console.log(`[ARCADE]: Degradation failed on game '${Game}'! No arcade machine found!`);

    arcadeMachines[Game] -= Degradation;
    if (arcadeMachines[Game] <= 0.0) arcadeMachines[Game] = 0.0;

    exp['fw-config'].SetConfigValue("bus-arcade", "arcadeMachines", arcadeMachines);
}