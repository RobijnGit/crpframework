import { DateTime } from 'luxon';
import { exp } from "../../shared/utils";
import { FW } from "../server";
import { DiscordWebhook } from '../token';

FW.RegisterServer("fw-polaroid:Server:RechargeCamera", (Source: number, CameraSlot: number) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    exp['fw-inventory'].IncreaseQualityItemFromInventory(`ply-${Player.PlayerData.citizenid}`, 'polaroid-camera', CameraSlot, 100.0);
    Player.Functions.Notify("Je Polaroid Camera is volledig opgeladen!", "success");
});

FW.RegisterServer("fw-polaroid:Server:ReceivePhoto", (Source: number, Url: string) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    Player.Functions.AddItem("polaroid-photo", 1, false, {
        Image: Url,
        Date: DateTime.now().toFormat('MM/dd/yyyy'),
    }, true);
});

FW.Functions.CreateUsableItem("polaroid-camera", async (Source: number, Item: any) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (!await Player.Functions.GetItemBySlot(Item.Slot)) return;

    emitNet("fw-polaroid:Client:OpenCamera", Source);
});

FW.Functions.CreateCallback("fw-polaroid:Server:GetWebhook", (Source: number, Cb: Function) => {
    Cb(DiscordWebhook)
});