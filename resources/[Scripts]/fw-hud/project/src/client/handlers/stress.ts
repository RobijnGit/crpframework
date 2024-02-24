import { FW, LoggedIn } from "../client";
import { Thread } from "../../shared/classes/thread";
import { Delay, GetRandom, exp } from "../../shared/utils";
import { GetHudId, SetHudData, SetHudValue } from "./hud";
import { GetPreferenceById } from "./preferences";

const StressThread = new Thread("tick", 700);
const GainThread = new Thread("tick", 50);

let CurrentStressLevel: number = 0;
let BlurTimeout: number = GetGameTimer();
let GainGunshotStress: boolean = true;

export const InitiateStress = () => {
    CurrentStressLevel = FW.Functions.GetPlayerData().metadata.stress;
    StressThread.start();
    GainThread.start();
};

StressThread.addHook("active", async () => {
    // Is the player logged in?
    if (!LoggedIn) return StressThread.stop();

    // Is the player stressed enough?
    if (CurrentStressLevel < 10) return;

    // Has it been x time since the last blur?
    if (BlurTimeout != 0 && BlurTimeout - GetGameTimer() > 0) return;

    // Get the blur timeout
    let WaitTime = 120;
    if (CurrentStressLevel > 75) {
        WaitTime = 10
    } else if (CurrentStressLevel > 45) {
        WaitTime = 30
    } else if (CurrentStressLevel > 20) {
        WaitTime = 60
    };

    BlurTimeout = GetGameTimer() + (WaitTime * 1000)

    TriggerScreenblurFadeIn(1000.0);
    await Delay(1500);
    TriggerScreenblurFadeOut(1000.0);
});

StressThread.addHook("afterStop", () => {
    TriggerScreenblurFadeOut(0.0)
});

GainThread.addHook("active", () => {
    if (!LoggedIn) return GainThread.stop();
    if (CurrentStressLevel >= 100) return;

    if (!IsPedShooting(PlayerPedId()) || !GainGunshotStress) {
        return;
    };

    const PlayerJob = FW.Functions.GetPlayerData().job;
    if (PlayerJob.name == "police" && PlayerJob.onduty) return;

    const Weapon: number = GetSelectedPedWeapon(PlayerPedId());
    if (exp['fw-police'].IgnoreWeapon(Weapon)) return;

    GainGunshotStress = false;
    emitNet("fw-ui:Server:gain:stress", GetRandom(1, 3));
    setTimeout(() => {
        GainGunshotStress = true;
    }, 20000)
});

onNet("fw-hud:Client:UpdateStress", (NewValue: number) => {
    if (CurrentStressLevel <= 0 && GetPreferenceById('Status.ShowStress') && NewValue > 0) SetHudData(GetHudId('Stress'), 'Show', true);

    CurrentStressLevel = NewValue;
    SetHudValue(GetHudId('Stress'), NewValue);
})