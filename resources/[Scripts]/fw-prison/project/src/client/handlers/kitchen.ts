import { FW } from "../client";

on("fw-prison:Client:KitchenStash", () => {
    const PlayerData = FW.Functions.GetPlayerData();
    if (!PlayerData.metadata.islifer && PlayerData.job.name != "doc" && PlayerData.job.name != "police") return FW.Functions.Notify("Geen toegang..");

    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `prison-kitchen`, 25, 1250)
});

on("fw-prison:Client:Tray", () => {
    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `prison-kitchen-tray`, 10, 200)
});

onNet("fw-prison:Client:TapJailSlushy", async () => {
    const Finished = await FW.Functions.CompactProgressbar(5000, "Slushy tappen", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {
        animDict: "amb@world_human_hang_out_street@female_hold_arm@idle_a", anim: "idle_a", flags: 8
    }, {}, {}, false);

    StopAnimTask(PlayerPedId(), "amb@world_human_hang_out_street@female_hold_arm@idle_a", "idle_a", 1.0)
    if (!Finished) return;

    FW.TriggerServer("fw-prison:Server:ReceiveJailItem", 'slushy');
});

onNet("fw-prison:Client:GetJailFood", async () => {
    const Finished = await FW.Functions.CompactProgressbar(5000, "Eten voorbereiden", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {
        animDict: "amb@world_human_hang_out_street@female_hold_arm@idle_a", anim: "idle_a", flags: 8
    }, {}, {}, false);

    StopAnimTask(PlayerPedId(), "amb@world_human_hang_out_street@female_hold_arm@idle_a", "idle_a", 1.0)
    if (!Finished) return;

    FW.TriggerServer("fw-prison:Server:ReceiveJailItem", 'jail-food');
});