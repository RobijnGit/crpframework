import { Hud } from "../../shared/config";
import { exp, SendUIMessage } from "../../shared/utils";
import { FW } from "../client";
import { CurrentBuffs } from "./buffs";

export const SetHudVisibleState = (Visible: boolean) => {
    SendUIMessage("Hud", "SetVisibility", Visible)
};

export const GetHudId = (Id: string): number => {
    return Hud.findIndex(Val => Val.Id == Id);
};

export const SetHudBuffed = (HudId: number, Buffed: boolean) => {
    if (!Hud[HudId]) return;
    Hud[HudId].Buffed = Buffed;
    SendUIMessage("Hud", "SetHudData", Hud[HudId]);
};

export const SetHudValue = (HudId: number, Value: number) => {
    if (!Hud[HudId]) return;

    if (Value < 0) Value = 0;
    if (Value > 100) Value = 100;
    if (Hud[HudId].Value == Value) return;

    Hud[HudId].Value = Value;
    if (Hud[HudId].AutoShow && Value > 0) Hud[HudId].Show = true;
    if (Hud[HudId].AutoHide && Value <= 0) Hud[HudId].Show = false;

    SendUIMessage("Hud", "SetHudData", Hud[HudId]);
};

export const SetHudIcon = (HudId: number, Icon: string) => {
    if (!Hud[HudId]) return;
    Hud[HudId].Icon = Icon;
    SendUIMessage("Hud", "SetHudData", Hud[HudId]);
};

export const SetHudData = (HudId: number, Key: string, Value: any) => {
    if (!Hud[HudId]) return;
    if (Key == 'Value') return SetHudValue(HudId, Value);

    // @ts-expect-error
    Hud[HudId][Key] = Value;
    SendUIMessage("Hud", "SetHudData", Hud[HudId]);
};

export const InitiateHud = () => {
    const MetaData = FW.Functions.GetPlayerData().metadata;
    SendUIMessage("Hud", "SetHudComponents", Hud);

    for (let i = 0; i < Hud.length; i++) {
        const HudElement = Hud[i];
        const BuffData = Object.values(CurrentBuffs).find((Val: any) => Val && Val.HudId == HudElement.Id);
        HudElement.Buffed = BuffData != undefined;
    };

    const IsDead: boolean = exp['fw-medical'].GetDeathStatus();
    SetHudValue(GetHudId("Health"), IsDead ? 0 : GetEntityHealth(PlayerPedId()) - 100);
    SetHudValue(GetHudId("Armor"), GetPedArmour(PlayerPedId()));
    SetHudValue(GetHudId("Food"), MetaData.hunger);
    SetHudValue(GetHudId("Water"), MetaData.thirst);
    SetHudValue(GetHudId("Stress"), MetaData.stress);
    SetHudValue(GetHudId("Oxygen"), GetPlayerUnderwaterTimeRemaining(PlayerId()));
};

exp("SetHudVisibleState", SetHudVisibleState)
exp("GetHudId", GetHudId)
exp("SetHudBuffed", SetHudBuffed)
exp("SetHudValue", SetHudValue)
exp("SetHudIcon", SetHudIcon)
exp("SetHudData", SetHudData)

onNet("fw-hud:Client:GetHudId", GetHudId)
onNet("fw-hud:Client:SetHudBuffed", SetHudBuffed)
onNet("fw-hud:Client:SetHudValue", SetHudValue)
onNet("fw-hud:Client:SetHudIcon", SetHudIcon)
onNet("fw-hud:Client:SetHudData", SetHudData)

// Updaters

onNet("FW:Client:OnMetaDataUpdate", (TableName: boolean | string, Key: string, Value: any) => {
    switch (Key) {
        case "hunger":
            SetHudValue(GetHudId("Food"), Value);
            break;
        case "thirst":
            SetHudValue(GetHudId("Water"), Value);
            break;
    }
})

onNet("FW:Health:OnThreadChange", (Value: number) => {
    const IsDead: boolean = exp['fw-medical'].GetDeathStatus();
    SetHudValue(GetHudId("Health"), IsDead ? 0 : Value - 100);
});

onNet("fw-medical:Client:PlayerDied", () => {
    SetHudValue(GetHudId("Health"), 0);
});

onNet("fw-medical:Client:PlayerRevived", () => {
    SetHudValue(GetHudId("Health"), GetEntityHealth(PlayerPedId()) - 100);
});

onNet("FW:Armour:OnThreadChange", (Value: number) => {
    SetHudValue(GetHudId("Armor"), Value);
});

onNet("fw-ui:Client:Set:Voice:Range", (Range: number) => {
    const RangeToValue = [33.0, 66.0, 100.0 ];
    SetHudValue(GetHudId("Voice"), RangeToValue[Range - 1]);
});

onNet("FW:Talking:OnThreadChange", (Value: number) => {
    if (exp['fw-voice'].TalkingOnRadio()) return;
    SetHudData(GetHudId('Voice'), 'Color', Value ? '#EBD334' : '#fff');
});