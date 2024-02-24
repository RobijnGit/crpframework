import { FW } from "../server"

FW.Commands.Add(["hud", "binds"], "HUD instellingen", [], false, (Source: number, Args: Array<string>) => {
    const Player = FW.Functions.GetPlayer(Source)
    if (!Player) return;

    emitNet('fw-hud:Client:TogglePreferences', Source, true);
});