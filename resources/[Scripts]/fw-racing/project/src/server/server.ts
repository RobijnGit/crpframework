export const FW = global.exports['fw-core'].GetCoreObject();

import './creation';
import './phone';
import './tracks';
import './race';

FW.Functions.CreateUsableItem("racing-usb", async (Source: number, Item: any) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (!await Player.Functions.GetItemBySlot(Item.Slot)) return;

    if (Item.Info._Owner && Item.Info._Owner != Player.PlayerData.citizenid) {
        return Player.Functions.Notify("Dit is niet jouw USB!", "error")
    };

    if (Item.Info.Alias) {
        return Player.Functions.Notify("Alias kan niet veranderd worden voor deze USB..", "error")
    };

    emitNet("fw-racing:Client:OpenAliasTextbox", Source, Item.Slot);
})

FW.Functions.CreateCallback("fw-racing:Server:SetAlias", async (Source: number, Cb: Function, Slot: number, Alias: string) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return Cb({Success: false});

    const Item = await Player.Functions.GetItemBySlot(Slot);
    if (Item.Item != "racing-usb") return Cb({Success: false});

    const Result = await global.exports['ghmattimysql'].executeSync("SELECT `info` FROM `player_inventories` WHERE `info` LIKE ?", [
        `%"Alias":"${Alias}"%`
    ]);

    if (Result.length > 0) return Cb({Success: false, Msg: "Alias is al bezet!"});

    await Player.Functions.SetItemKV('racing-usb', Slot, "_Owner", Player.PlayerData.citizenid);
    await Player.Functions.SetItemKV('racing-usb', Slot, "Alias", Alias);

    Cb({Success: true})
});