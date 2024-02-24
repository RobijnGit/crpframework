// leave this here pls.
// @ts-nocheck
import { BuffMessages, Hud } from "../../shared/config";
import { Delay, exp } from "../../shared/utils";
import { FW } from "../client";
import { GetHudId, SetHudBuffed, SetHudValue } from "./hud";

export let CurrentBuffs: any = {};

onNet("fw-hud:Client:SetCurrentBuff", async (
    BuffId: string,
    BuffData: {
        Value: number,
        HudId: string
    }
) => {
    const HasBuff = await FW.SendCallback("fw-hud:Server:DoesPlayerHaveBuff", BuffId);
    if (!HasBuff) return;

    if (CurrentBuffs[BuffId]) {
        const NewBuffValue = Math.min(CurrentBuffs[BuffId].Value + BuffData.Value, 100);
        const BuffDuration = ((60 * 60000) * 3) * (NewBuffValue / 100);

        CurrentBuffs[BuffId].Value = Math.min(CurrentBuffs[BuffId].Value + BuffData.Value, 100)
        CurrentBuffs[BuffId].EndTime = GetGameTimer() + BuffDuration
    };

    const ThreeHoursMS = ((60 * 60000) * 3)
    const BuffDuration = ThreeHoursMS * (BuffData.Value / 100)

    let Alerted = false;

    const HudIndex = GetHudId(BuffData.HudId);
    SetHudBuffed(HudIndex, true);

    const BuffTick = setTick(async () => {
        if (!CurrentBuffs[BuffId] || GetGameTimer() > CurrentBuffs[BuffId].EndTime) {
            clearTick(CurrentBuffs[BuffId] ? CurrentBuffs[BuffId].Tick : BuffTick);
            RemoveBuff(BuffId, HudIndex);
            return;
        };

        const Percentage = ((CurrentBuffs[BuffId].EndTime - GetGameTimer()) / ThreeHoursMS) * 100;
        CurrentBuffs[BuffId].Value = Percentage;

        if (Hud[HudIndex].IsEnhancement) SetHudValue(HudIndex, Percentage);

        if (Percentage < 2.0 && !Alerted && BuffMessages[BuffId]) {
            FW.Functions.Notify(BuffMessages[BuffId], "error");
            Alerted = true;
        };

        await Delay(2500);
    });

    CurrentBuffs[BuffId] = {
        ...BuffData,
        EndTime: GetGameTimer() + BuffDuration,
        Tick: BuffTick
    };
});

const RemoveBuff = (BuffId: string, HudIndex: number) => {
    CurrentBuffs[BuffId] = undefined;
    if (Hud[HudIndex].IsEnhancement) SetHudValue(HudIndex, 0);
    SetHudBuffed(HudIndex, false);
    FW.TriggerServer("fw-hud:Server:RemoveBuff", BuffId)
};

const HasBuff = (BuffId: string) => {
    return CurrentBuffs[BuffId] != undefined
};
exp("HasBuff", HasBuff);