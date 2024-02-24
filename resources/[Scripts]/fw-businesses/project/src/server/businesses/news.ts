import { FW } from "../server";

onNet("fw-businesses:Server:News:PurchaseCamera", () => {
    const Source: number = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (Player.PlayerData.job.name != 'news') return Player.Functions.Notify("Geen toegang..", "error");
    if (!Player.Functions.RemoveMoney('cash', 85, 'Purchase News Item')) {
        return Player.Functions.Notify("Niet genoeg cash..", "error")
    };

    Player.Functions.AddItem('newscamera', 1, false, undefined, true);
});

onNet("fw-businesses:Server:News:PurchaseMic", () => {
    const Source: number = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (Player.PlayerData.job.name != 'news') return Player.Functions.Notify("Geen toegang..", "error");
    if (!Player.Functions.RemoveMoney('cash', 85, 'Purchase News Item')) {
        return Player.Functions.Notify("Niet genoeg cash..", "error")
    };

    Player.Functions.AddItem('newsmic', 1, false, undefined, true);
});