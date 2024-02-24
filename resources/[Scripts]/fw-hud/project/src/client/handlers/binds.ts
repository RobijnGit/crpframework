import { Config } from "../../shared/config";
import { FW, LoggedIn } from "../client";

const Keys = [ 'F2', 'F3', 'F5', 'F5', 'F6', 'F7', 'F9', 'F10' ];

for (let i = 0; i < Keys.length; i++) {
    const Key = Keys[i];

    FW.AddKeybind(`bind_${Key}`, 'Algemeen', `Emote Bind ${Key}`, Key, (IsPressed: boolean) => {
        if (!LoggedIn || !IsPressed || !GetLastInputMethod(0)) return;

        const EmoteName = Config.MyPreferences[`Binds.${Key}`];
        if (!EmoteName || EmoteName.trim().length == 0) return;

        emit("fw-emotes:Client:PlayEmote", EmoteName);
    })
};
