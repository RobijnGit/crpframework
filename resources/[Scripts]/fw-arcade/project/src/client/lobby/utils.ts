import { exp } from "../../shared/utils";
import { FW } from "../client";

export let currentGame: string = 'none'
export let currentLobby: number = 0;
export let isGameActive: boolean = false;

// Is the player in ANY lobby?
export const IsInAnyLobby = (): boolean => {
    return !!currentLobby;
}

// Is the player in 'lobbyId' lobby?
export const IsInLobby = (lobbyId: number): boolean => {
    return currentLobby == lobbyId;
}

export const IsGameActive = () => isGameActive;
exp("IsGameActive", IsGameActive);

export const IsMatchmaker = async () => {
    if (currentGame == 'none' || !currentLobby) return;
    return await FW.SendCallback("fw-arcade:Server:IsMatchmaker", currentGame, currentLobby)
};
exp("IsMatchmaker", IsMatchmaker);

onNet("fw-arcade:Client:SetGameActive", ({State}: {State: boolean}) => {
    isGameActive = State;
});

onNet("fw-arcade:Client:SetCurrentLobby", (Game: string, LobbyId: number) => {
    currentGame = Game;
    currentLobby = LobbyId;

    // console.log(`Arcade Data set to ${Game}:${LobbyId}`)
});