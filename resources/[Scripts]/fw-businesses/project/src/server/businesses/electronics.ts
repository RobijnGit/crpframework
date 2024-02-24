import { Delay, GetRandom, exp } from "../../shared/utils";
import { FW } from "../server";
import { HasPlayerBusinessPermission } from "../utils";

export const IsItemScrappable = (ScrappableItems: Array<{
    Item: string;
    Label: string;
    Rewards: number[];
}>, ItemName: string) => {
    const Index = ScrappableItems.findIndex(Val => Val.Item == ItemName);
    return Index !== -1 ? ScrappableItems[Index] : false;
};

FW.Functions.CreateCallback("fw-businesses:Server:Electronics:GetScrapItems", async (Source: number, Cb: Function, Business: string) => {
    if (!exp['fw-config'].IsConfigReady()) return Cb([]);

    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (!await HasPlayerBusinessPermission(Business, Source, "CraftAccess")) return Cb([]);

    const PlyItems = await exp['ghmattimysql'].executeSync("SELECT * FROM `player_inventories` WHERE `inventory` = ?", [`ply-${Player.PlayerData.citizenid}`]);

    const Retval: Array<{
        Label: string;
        Slot: number;
        Parts: number;
        Materials: number;
    }> = [];

    const {allowDecayedScrap, scrapItems: ScrappableItems} = exp['fw-config'].GetModuleConfig("bus-electronics", {});
    if (!ScrappableItems || ScrappableItems.length == 0) return Cb([]);

    for (let i = 0; i < PlyItems.length; i++) {
        const ItemData = PlyItems[i];
        if (!ItemData) continue;

        const ScrapInfo = IsItemScrappable(ScrappableItems, ItemData.item_name);
        if (!ScrapInfo) continue;

        const ItemQuality = exp['fw-inventory'].CalculateQuality(ItemData.item_name, ItemData.createdate);
        if (!allowDecayedScrap && ItemQuality <= 5) continue;

        Retval.push({
            Label: ScrapInfo.Label,
            Slot: ItemData.slot,
            Parts: 4 - Math.floor((100 - ItemQuality) / 33),
            Materials: Math.floor(75 * ((100 - ItemQuality) / 100))
        });
    }

    Cb(Retval);
});

onNet("fw-businesses:Server:Electronics:ScrapElectronic", async (Data: {
    Business: string;
    Parts: number;
    Slot: number;
}) => {
    if (!exp['fw-config'].IsConfigReady()) return;

    const Source = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (!await HasPlayerBusinessPermission(Data.Business, Source, "CraftAccess")) return;
    
    const {scrapItems: ScrappableItems} = exp['fw-config'].GetModuleConfig("bus-electronics");
    const Item = await exp['fw-inventory'].GetInventoryItemBySlot(`ply-${Player.PlayerData.citizenid}`, Data.Slot);
    if (!Item) return;

    const ScrapInfo = IsItemScrappable(ScrappableItems, Item.Item);
    if (!ScrapInfo) return;

    const Reward = GetRandom(ScrapInfo.Rewards[0], ScrapInfo.Rewards[1]);

    if (await Player.Functions.RemoveItem(Item.Item, 1, Data.Slot, true)) {
        await Delay(10);
        Player.Functions.AddItem('electronics', Reward * Data.Parts, false, false, true, false)
    };
});

onNet("fw-businesses:Server:Electronics:RepairElectronic", async (Data: {
    Business: string;
    Materials: number;
    Slot: number;
}) => {
    if (!exp['fw-config'].IsConfigReady()) return;

    const Source = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (!await HasPlayerBusinessPermission(Data.Business, Source, "CraftAccess")) return;
    
    const {scrapItems: ScrappableItems} = exp['fw-config'].GetModuleConfig("bus-electronics");
    const Item = await exp['fw-inventory'].GetInventoryItemBySlot(`ply-${Player.PlayerData.citizenid}`, Data.Slot);
    if (!Item) return;

    const ScrapInfo = IsItemScrappable(ScrappableItems, Item.Item);
    if (!ScrapInfo) return;

    if (await Player.Functions.RemoveItemByName('electronics', Data.Materials, true)) {
        exp['fw-inventory'].IncreaseQualityItemFromInventory(`ply-${Player.PlayerData.citizenid}`, Item.Item, 100.0, Data.Slot);
        Player.Functions.Notify("Gerepareerd!")
    } else {
        Player.Functions.Notify("Je hebt niet genoeg eletronica..", "error")
    };
});

onNet("fw-businesses:Server:Electronics:RemoveMusicEntry", async (Data: {
    Business: string;
    TrackId: number;
}) => {
    const Source = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (!HasPlayerBusinessPermission(Data.Business, Source, "CraftAccess")) {
        return Player.Functions.Notify("Geen toegang.", "error")
    };

    await exp['ghmattimysql'].executeSync("DELETE FROM `musictapes` WHERE `id` = ?", [Data.TrackId]);
    Player.Functions.Notify("Track verwijderd!")

    setTimeout(() => {
        emitNet("fw-businesses:Client:Electronics:ManageMusicEntries", Source, {Business: Data.Business})
    }, 150)

    emit("fw-logs:Server:Log", "musictapes", "Track Entry Deleted", `User: [${Player.PlayerData.source}] - ${Player.PlayerData.citizenid} - ${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}\nEntry Id: ${Data.TrackId}`, "red");
});

FW.RegisterServer("fw-businesses:Server:Electronics:AddMusicEntry", async (Source: number, Data: {
    Business: string;
    TapeId: string;
    Artist: string;
    Title: string;
}) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;
    
    if (!HasPlayerBusinessPermission(Data.Business, Source, "CraftAccess")) {
        return Player.Functions.Notify("Geen toegang.", "error")
    };

    const Result = await exp['ghmattimysql'].executeSync('INSERT INTO `musictapes` (tape_id, tape_title, tape_artist) VALUES (?, ?, ?)', [
        Data.TapeId,
        Data.Title,
        Data.Artist
    ]);

    TriggerEvent("fw-logs:Server:Log", "musictapes", "Track Entry Added", `User: [${Player.PlayerData.source}] - ${Player.PlayerData.citizenid} - ${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}\nEntry ID: ${Result.insertId}\nSoundcloud Track Id: [${Data.TapeId}](https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/${Data.TapeId}&color=%232cffb8&auto_play=true&hide_related=true&show_comments=false&show_user=false&show_reposts=false&show_teaser=false)\nTape: ${Data.Artist} - ${Data.Title}`, "green");
});

FW.RegisterServer("fw-businesses:Server:Electronics:CreateCassetteTapes", async (Source: number, Data: {
    Business: string;
    TrackId: string;
    Copies: number;
}) => {
    const Player = FW.Functions.GetPlayer(Source)
    if (!Player) return;

    if (!HasPlayerBusinessPermission(Data.Business, Source, "CraftAccess")) {
        return Player.Functions.Notify("Geen toegang.", "error")
    };

    const Result = await exp['ghmattimysql'].executeSync('SELECT * FROM `musictapes` WHERE `id` = ?', [Data.TrackId]);
    if (!Result[0]) return Player.Functions.Notify("Track bestaat niet..");

    for (let i = 0; i < Data.Copies; i++) {
        Player.Functions.AddItem("musictape", 1, undefined, {
            Artist: Result[0].tape_artist,
            Title: Result[0].tape_title,
            _TrackId: Result[0].tape_id
        }, true)
    };
});

FW.Functions.CreateCallback("fw-businesses:Server:Electronics:GetMusicEntries", async (Source: number, Cb: Function) => {
    const Player = FW.Functions.GetPlayer(Source)
    if (!Player) return;

    const Result = await exp['ghmattimysql'].executeSync('SELECT * FROM `musictapes`')
    Cb(Result)
});