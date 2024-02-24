import { Delay, GetRandom, exp } from "../../shared/utils";
import { HasPlayerBusinessPermission } from "../utils";
import { IsItemScrappable } from "./electronics";
import { FW } from "../server";

FW.Functions.CreateCallback("fw-businesses:Server:PawnHub:GetScrapItems", async (Source: number, Cb: Function) => {
    if (!exp['fw-config'].IsConfigReady()) return Cb([]);

    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (!await HasPlayerBusinessPermission("PawnNGo", Source, "CraftAccess")) return Cb([]);

    const PlyItems = await exp['ghmattimysql'].executeSync("SELECT * FROM `player_inventories` WHERE `inventory` = ?", [`ply-${Player.PlayerData.citizenid}`]);

    const Retval: Array<{
        Label: string;
        Slot: number;
        Parts: number;
        Materials: number;
    }> = [];

    const {allowDecayedScrap, scrapItems: ScrappableItems} = exp['fw-config'].GetModuleConfig("bus-pawnhub", {});
    if (!ScrappableItems || ScrappableItems.length == 0) return Cb([]);

    for (let i = 0; i < PlyItems.length; i++) {
        const ItemData = PlyItems[i];
        if (!ItemData) continue;

        const ScrapInfo = IsItemScrappable(ScrappableItems, ItemData.item_name);
        if (!ScrapInfo) continue;

        const ItemQuality = exp['fw-inventory'].CalculateQuality(ItemData.item_name, ItemData.createdate);
        if (!allowDecayedScrap && ItemQuality <= 5) continue;

        const ItemInfo = exp['fw-inventory'].GetItemData(ItemData.item_name, ItemData.customtype)

        Retval.push({
            Label: ItemInfo.Label,
            Slot: ItemData.slot,
            Parts: 4 - Math.floor((100 - ItemQuality) / 33),
            Materials: Math.floor(75 * ((100 - ItemQuality) / 100))
        });
    }

    Cb(Retval);
});

onNet("fw-businesses:Server:PawnHub:ScrapElectronic", async (Data: {
    Parts: number;
    Slot: number;
}) => {
    if (!exp['fw-config'].IsConfigReady()) return;

    const Source = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (!await HasPlayerBusinessPermission("PawnNGo", Source, "CraftAccess")) return;
    
    const {scrapItems: ScrappableItems} = exp['fw-config'].GetModuleConfig("bus-pawnhub");
    const Item = await exp['fw-inventory'].GetInventoryItemBySlot(`ply-${Player.PlayerData.citizenid}`, Data.Slot);
    if (!Item) return;

    const ScrapInfo = IsItemScrappable(ScrappableItems, Item.Item);
    if (!ScrapInfo) return;

    const Reward = GetRandom(ScrapInfo.Rewards[0], ScrapInfo.Rewards[1]);
    const MaterialTypes = [ 'metalscrap', 'plastic', 'aluminum', 'copper' ];

    if (await Player.Functions.RemoveItem(Item.Item, 1, Data.Slot, true)) {
        for (let i = 0; i < 3; i++) {
            await Delay(50);
            Player.Functions.AddItem(MaterialTypes[Math.floor(Math.random() * MaterialTypes.length)], Math.ceil((Reward * Data.Parts) * 0.33), false, false, true, false)
        }
    };
});