import type { HospitalBed } from "../shared/types";
import { Delay, exp } from "../shared/utils"
export const FW = exp['fw-core'].GetCoreObject();

import './zones';
import './handlers/wounds';
import './handlers/interactions';
import './handlers/medic';
import './handlers/garage';

import { Dead, IsMinor, RevivePlayer } from "./handlers/death";
import { LoadAnimDict } from "./utils";
import { Thread } from "../shared/classes/thread";

const HealthThread = new Thread("tick", 3000)

onNet("FW:Client:OnPlayerLoaded", () => {
    const PlayerData = FW.Functions.GetPlayerData();
    if (PlayerData.metadata.isdead) SetEntityHealth(PlayerPedId(), 0);
})

export const DrawTxt = (Visible: boolean, Text?: string) => {
    exp['fw-ui'].SendUIMessage("DeathText", "Set", { Visible, Text })
};

export let InBed = false;

export const SaveHealth = () => {
    const Health = GetEntityHealth(PlayerPedId());
    const Armor = GetPedArmour(PlayerPedId());
    FW.TriggerServer("fw-medical:Server:SaveHealth", Health, Armor)
}
HealthThread.addHook("active", SaveHealth);

export const GetHospitalBed = async (Pay: boolean = false) => {
    const Result: HospitalBed = await FW.SendCallback("fw-medical:Server:GetHospitalBed")
    InBed = true;

    DoScreenFadeOut(100);
    while (!IsScreenFadedOut()) {
        await Delay(10);
    };

    RequestCollisionAtCoord(Result.Coords.x, Result.Coords.y, Result.Coords.z);
    while (!HasCollisionLoadedAroundEntity(PlayerPedId())) {
        SetEntityCoords(PlayerPedId(), Result.Coords.x, Result.Coords.y, Result.Coords.z - 20.0, false, false, false, false);
        await Delay(10);
    };

    SetEntityCoords(PlayerPedId(), Result.Coords.x, Result.Coords.y, Result.Coords.z, false, false, false, false);

    const BedObject = GetClosestObjectOfType(Result.Coords.x, Result.Coords.y, Result.Coords.z, 5.0, Result.Model, false, false, false);
    const Heading = GetEntityHeading(BedObject);
    SetEntityHeading(PlayerPedId(), Heading);

    DoScreenFadeIn(100);

    FW.TriggerServer("fw-medical:Server:PayMedicalFee", Dead)

    if (!Dead) {
        await LoadAnimDict('dead');
        TaskPlayAnim(PlayerPedId(), 'dead', 'dead_c', 8, -8, -1, 1, 0, false, false, false);
    };

    setTimeout(async () => {
        await LoadAnimDict('switch@franklin@bed');
        InBed = false;
        RevivePlayer();

        SetEntityHeading(PlayerPedId(), Heading - 90.0);
        TaskPlayAnim(PlayerPedId(), 'switch@franklin@bed', 'sleep_getup_rubeyes', 100.0, 1.0, -1, 8, -1, false, false, false);
        await Delay(5000)
        StopAnimTask(PlayerPedId(), 'switch@franklin@bed', 'sleep_getup_rubeyes', 99.0)
    }, 10000);
};
onNet("fw-medical:Client:CheckIn", GetHospitalBed);

on("onResourceStart", (ResourceName: string) => {
    if (ResourceName != "fw-medical") return;
    console.info("medical initialized, resetting health and invincibility.")
    SetEntityInvincible(PlayerPedId(), false);
    SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()));
});

on("fw-medical:Client:LayBed", (Data: any, Entity: number) => {
    const [x, y, z] = GetEntityCoords(Entity, false);
    const Heading = GetEntityHeading(Entity) + (Data.Heading || 0);

    SetEntityCoordsNoOffset(PlayerPedId(), x, y, z + 1.0, false, false, false);
    SetEntityHeading(PlayerPedId(), (Dead && !IsMinor) ? Heading : Heading + 180);

    TriggerEvent("fw-emotes:Client:PlayEmote", "passout4")
});