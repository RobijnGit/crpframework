import { Vector4Format } from "../../shared/classes/math";
import { Delay, exp } from "../../shared/utils";
import { FW } from "../client";
import { ResetTaskData } from "../tasks/main";
import { EscapeThread } from "./prison-break";

export let InJail: boolean = false;

const PrisonSpawns: Vector4Format[] = [
    {x: 1745.78, y: 2489.61, z: 50.42, w: 212.02},
    {x: 1751.85, y: 2492.73, z: 50.42, w: 213.78},
    {x: 1760.81, y: 2498.14, z: 50.43, w: 208.27},
    {x: 1754.86, y: 2494.59, z: 45.82, w: 212.48},
    {x: 1748.83, y: 2491.35, z: 45.82, w: 203.42}
];

export const ResetJail = () => {
    InJail = false;
    exp['fw-ui'].HideInteraction();
    ResetTaskData();
}

export const SetInJail = (State: boolean) => {
    InJail = State;
}

onNet("fw-prison:Client:SetJail", async (PlaySound: boolean) => {
    if (PlaySound) emit('fw-misc:Client:PlaySound', 'state.jailCell');

    InJail = true;
    const RandomIndex = Math.floor(Math.random() * PrisonSpawns.length);
    const SpawnCoords = PrisonSpawns[RandomIndex]
    SetEntityCoords(PlayerPedId(), SpawnCoords.x, SpawnCoords.y, SpawnCoords.z, false, false, false, false);
    SetEntityHeading(PlayerPedId(), SpawnCoords.w);

    await Delay(2000);
    DoScreenFadeIn(1000);

    if (!FW.Functions.GetPlayerData().metadata.islifer) {
        if (!EscapeThread.running) EscapeThread.start();
        emit('chatMessage', "DOJ", "warning", `Je moet nog ${FW.Functions.GetPlayerData().metadata.jailtime} maand(en) zitten.`);
    };
});

onNet("fw-prison:Client:ReleaseJail", async () => {
    if (FW.Functions.GetPlayerData().metadata.jailtime > 1) {
        return FW.Functions.Notify("Je staf is nog niet over.. Ik denk dat je nog even moet zitten..", "error")
    };

    ResetJail();
    EscapeThread.stop();

    DoScreenFadeOut(1000);
    while (!IsScreenFadedOut()) await Delay(100);

    SetEntityCoords(PlayerPedId(), 1841.69, 2590.94, 46.01, false, false, false, false);
    SetEntityHeading(PlayerPedId(), 189.05);

    await Delay(2000);
    DoScreenFadeIn(1000);

    FW.TriggerServer("fw-prison:Server:ResetJailTime")
});

onNet("fw-prison:Client:CheckPrisonTime", () => {
    emit('chatMessage', "DOJ", "warning", `Je moet nog ${FW.Functions.GetPlayerData().metadata.jailtime} maand(en) zitten.`);
});

onNet("fw-prison:Client:OpenSeizedPossessions", () => {
    if (exp['fw-inventory'].CanOpenInventory()) {
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `jail-seize-${FW.Functions.GetPlayerData().citizenid}`, 40, 250)
    };
});

onNet("fw-prison:Client:OpenJailCraft", () => {
    if (exp['fw-inventory'].CanOpenInventory()) {
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Crafting', 'Prison')
    };
});

exp("IsInJail", () => InJail);