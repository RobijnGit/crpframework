import { Config } from "../../shared/config";
import { Preferences } from "../../shared/types";
import { exp, RegisterNUICallback, SetUIFocus, SendUIMessage } from "../../shared/utils";
import { FW } from "../client";

let PreferencesLoaded: boolean = false;

export const LoadPreferences = () => {
    let Preferences: {[key: string]: any} = {};

    const KVPValue = GetResourceKvpString("fw-hud_preferences");
    if (KVPValue && KVPValue != '[]') Preferences = JSON.parse(KVPValue);

    for (const [Key, Value] of Object.entries(Config.PresetPreferences)) {
        if (Preferences[Key] == undefined || Preferences[Key] == null) Preferences[Key] = Value;
        Config.MyPreferences[Key] = Preferences[Key];
    };

    SetResourceKvp("fw-hud_preferences", JSON.stringify(Config.MyPreferences));
    emit('fw-hud:Client:OnPreferenceUpdate', Config.MyPreferences);

    PreferencesLoaded = true;

    return Config.MyPreferences;
}

export const GetPreferenceById = (Id: string) => Config.MyPreferences[Id];
export const GetPreferences = () => {
    if (PreferencesLoaded) return Config.MyPreferences;
    return LoadPreferences();
};

const SetPreferenceById = (Id: string, Value: any) => {
    if (Id == "Audio.RadioVolume" || "Audio.PhoneVolume") Value = Value.toFixed(1);
    Config.MyPreferences[Id] = Value;
    SetResourceKvp("fw-hud_preferences", JSON.stringify(Config.MyPreferences));
    emit("fw-hud:Client:OnPreferenceUpdate", Config.MyPreferences);
};

onNet("fw-ui:Ready", () => {
    const Preferences = GetPreferences()
    SendUIMessage("Preferences", "UpdatePreferences", {Preferences})
})

onNet("fw-hud:Client:TogglePreferences", () => {
    SetUIFocus(true, true);
    SendUIMessage("Preferences", "SetVisibility", {Visible: true})
});

onNet("fw-hud:Client:ReloadPreferences", () => {
    const Preferences = GetPreferences();
    emit('fw-hud:Client:OnPreferenceUpdate', Preferences);
});

onNet("fw-hud:Client:OnPreferenceUpdate", (newPreferences: Preferences) => {
    if (GetVehiclePedIsIn(PlayerPedId(), false) == 0) return;
    DisplayRadar(!newPreferences['BlackBars.Show']);
});

RegisterNUICallback("Preferences/Close", (Data: any, Cb: Function) => {
    SetUIFocus(false, false);
    SendUIMessage("Preferences", "SetVisibility", {Visible: false});

    const Preferences = GetPreferences()
    SendUIMessage("Preferences", "UpdatePreferences", {Preferences})

    Cb("Ok")
});

RegisterNUICallback("Preferences/Save", (Data: {Preferences: Preferences}, Cb: Function) => {
    Config.MyPreferences = Data.Preferences;
    SetResourceKvp("fw-hud_preferences", JSON.stringify(Config.MyPreferences));
    emit("fw-hud:Client:OnPreferenceUpdate", Config.MyPreferences);

    FW.Functions.Notify("Opgeslagen!")

    Cb("Ok")
});

exp("GetPreferences", GetPreferences);
exp("GetPreferenceById", GetPreferenceById);
exp("SetPreferenceById", SetPreferenceById);