import { FW } from "../server"

const Tasks: {[key: string]: string} = {};

export default () => {
    FW.RegisterServer("fw-prison:Server:SetCurrentTask", (Source: number, Task: string) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;

        Tasks[Player.PlayerData.citizenid] = Task;
    })

    FW.Functions.CreateCallback("fw-prison:Server:GetInmateData", (Source: number, Cb: Function, PlayerId: number) => {
        const Player = FW.Functions.GetPlayer(PlayerId);
        Cb({
            ...Player.PlayerData,
            CurrentTask: Tasks[Player.PlayerData.citizenid]
        });
    });
}