import { Config } from "../../shared/config";
import { Delay, exp } from "../../shared/utils";
import { FW } from "../client";
import { Bleeding, ClearBoneDamage, HealBoneDamage, ResetBleeding } from "./wounds";

export let OnOxy = false;
export let OnAdrenaline = false;
export let OnIbuprofen = false;
export let OnPainkillers = false;
export let OnKetamine = false;
export let OnMorphine = false;
export let OnMelatonin = false;

onNet("fw-medical:Client:UsedHeal", async (ItemName: string) => {
    if (exp['fw-progressbar'].GetTaskBarStatus()) return;
    exp['fw-inventory'].SetBusyState(true)

    exp['fw-assets'].AddProp("HealthPack")
    
    const Finished = await FW.Functions.CompactProgressbar(3000, ItemName == "ifak" ? "IFAK gebruiken" : "Verbandje omdoen...", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {
        animDict: "amb@world_human_clipboard@male@idle_a", anim: "idle_c", flags: 49
    }, {}, {}, false)

    exp['fw-assets'].RemoveProp()
    exp['fw-inventory'].SetBusyState(false)

    if (!Finished) return;

    const DidRemove = await FW.SendCallback("FW:RemoveItem", ItemName, 1);
    if (!DidRemove) return;

    await Delay(1500);

    if (ItemName == 'ifak') {
        ClearBoneDamage();
    } else {
        HealBoneDamage();
    };

    if (Bleeding) ResetBleeding();

    for (let i = 0; i < 6; i++) {
        await Delay(3500)
        const CurrentHealth = GetEntityHealth(PlayerPedId())
        SetEntityHealth(PlayerPedId(), CurrentHealth + 4 > 200 ? 200 : CurrentHealth + 4)
    };
});

onNet("fw-medical:Client:UsedOxy", async () => {
    if (OnOxy) return FW.Functions.Notify("Je wilt geen overdose toch?", "error");

    if (exp['fw-progressbar'].GetTaskBarStatus()) return;
    exp['fw-inventory'].SetBusyState(true)
    
    const Finished = await FW.Functions.CompactProgressbar(3000, "Pilletje slikken", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {
        animDict: "mp_suicide", anim: "pill", flags: 49
    }, {}, {}, false)

    StopAnimTask(PlayerPedId(), "mp_suicide", "pill", 8.0);

    exp['fw-inventory'].SetBusyState(false)
    if (!Finished) return;

    const DidRemove = await FW.SendCallback("FW:RemoveItem", "oxy", 1);
    if (!DidRemove) return;

    await Delay(1500);

    // heal bone damage 3 times
    for (let i = 0; i < 3; i++) {
        HealBoneDamage();
    };

    OnOxy = true;

    setTimeout(() => {
        OnOxy = false;
    }, 90000)
});

onNet("fw-medical:Client:UsedAdrenaline", async () => {
    if (OnAdrenaline) return FW.Functions.Notify("Je zit al aardig aan de adrenaline..", "error");

    const Finished = await FW.Functions.CompactProgressbar(3000, "Injecteren", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {
        animDict: "clear@custom_anim", anim: "adrenaline_clip", flags: 49
    }, {}, {}, false)

    if (!Finished) return;

    const DidRemove = await FW.SendCallback("FW:RemoveItem", "adrenaline", 1);
    if (!DidRemove) return;

    OnAdrenaline = true;

    SetRunSprintMultiplierForPlayer(PlayerId(), 1.2);
    ResetPlayerStamina(PlayerId())
    await Delay((Config.AdrenalineTimer - 2) * 1000)
    FW.Functions.Notify("Je voelt de adrenaline kick langzaam wegzakken..", "error")
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.1);
    await Delay(2000);
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0);
    OnAdrenaline = false;
});

onNet("fw-medical:Client:UsedIbuprofen", async () => {
    if (OnIbuprofen) return FW.Functions.Notify("Je zit al aardig aan de ibuprofen..", "error");

    const Finished = await FW.Functions.CompactProgressbar(3000, "Pilletje slikken", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {
        animDict: "mp_suicide", anim: "pill", flags: 49
    }, {}, {}, false)

    StopAnimTask(PlayerPedId(), "mp_suicide", "pill", 8.0);

    if (!Finished) return;

    const DidRemove = await FW.SendCallback("FW:RemoveItem", "ibuprofen", 1);
    if (!DidRemove) return;

    OnIbuprofen = true;

    for (let i = 0; i < 5; i++) {
        HealBoneDamage();
    };

    setTimeout(() => {
        OnIbuprofen = false;
    }, 15000);
});

onNet("fw-medical:Client:UsedKetamine", async () => {
    if (OnKetamine) return FW.Functions.Notify("Je zit al aardig aan de ketamine..", "error");

    const Finished = await FW.Functions.CompactProgressbar(3000, "Pilletje slikken", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {
        animDict: "mp_suicide", anim: "pill", flags: 49
    }, {}, {}, false)

    StopAnimTask(PlayerPedId(), "mp_suicide", "pill", 8.0);

    if (!Finished) return;

    const DidRemove = await FW.SendCallback("FW:RemoveItem", "ketamine", 1);
    if (!DidRemove) return;

    OnKetamine = true;

    SetPedMotionBlur(PlayerPedId(), true);
    SetPedIsDrunk(PlayerPedId(), true);
    TriggerScreenblurFadeIn(500.0);

    AnimpostfxPlay("DMT_flight", 60000, true);
    ShakeGameplayCam('DRUNK_SHAKE', 5.0);
    await Delay(30000);
    StopGameplayCamShaking(true);
    AnimpostfxStop("DMT_flight");
    SetPedMotionBlur(PlayerPedId(), false);
    ClearTimecycleModifier();
    AnimpostfxPlay("DrugsDrivingOut", 3000, false);

    setTimeout(() => {
        TriggerScreenblurFadeOut(10000.0);
        OnKetamine = false;
    }, 1000);
});

onNet("fw-medical:Client:UsedMelatonin", async () => {
    if (OnMelatonin) return FW.Functions.Notify("Je zit al aardig aan de melatonine..", "error");

    const Finished = await FW.Functions.CompactProgressbar(3000, "Pilletje slikken", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {
        animDict: "mp_suicide", anim: "pill", flags: 49
    }, {}, {}, false)

    StopAnimTask(PlayerPedId(), "mp_suicide", "pill", 8.0);

    if (!Finished) return;

    const DidRemove = await FW.SendCallback("FW:RemoveItem", "melatonin", 1);
    if (!DidRemove) return;

    OnMelatonin = true;

    let Interval = 5000;
    for (let i = 0; i < 5; i++) {
        DoScreenFadeOut(500);
        await Delay(300);
        DoScreenFadeIn(500);
        Interval -= 1000;
        await Delay(Interval);
    };

    DoScreenFadeOut(1000);
    emit('fw-emotes:Client:PlayEmote', "sleep", null, true)
    FW.Functions.Notify("Je bent in slaap gevallen...", "error");
    await Delay(5000);
    DoScreenFadeIn(15000);

    await Delay(15000);
    emit('fw-emotes:Client:PlayEmote', "sleep", null, false)

    OnMelatonin = false;
});

onNet("fw-medical:Client:UsedMorphine", async () => {
    if (OnMorphine) return FW.Functions.Notify("Je zit al aardig aan de morfine..", "error");

    const Finished = await FW.Functions.CompactProgressbar(3000, "Pilletje slikken", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {
        animDict: "mp_suicide", anim: "pill", flags: 49
    }, {}, {}, false)

    StopAnimTask(PlayerPedId(), "mp_suicide", "pill", 8.0);

    if (!Finished) return;

    const DidRemove = await FW.SendCallback("FW:RemoveItem", "morphine", 1);
    if (!DidRemove) return;

    OnMorphine = true;
    ClearBoneDamage();

    setTimeout(() => {
        OnMorphine = false;
    }, 90000);
});

onNet("fw-medical:Client:UsedPainkillers", async () => {
    if (OnPainkillers) return FW.Functions.Notify("Je zit al aardig aan de paracetamol..", "error");

    const Finished = await FW.Functions.CompactProgressbar(3000, "Pilletje slikken", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {
        animDict: "mp_suicide", anim: "pill", flags: 49
    }, {}, {}, false)

    StopAnimTask(PlayerPedId(), "mp_suicide", "pill", 8.0);

    if (!Finished) return;

    const DidRemove = await FW.SendCallback("FW:RemoveItem", "painkillers", 1);
    if (!DidRemove) return;

    OnPainkillers = true;

    for (let i = 0; i < 3; i++) {
        HealBoneDamage();
    };

    setTimeout(() => {
        OnPainkillers = false;
    }, 15000);
});