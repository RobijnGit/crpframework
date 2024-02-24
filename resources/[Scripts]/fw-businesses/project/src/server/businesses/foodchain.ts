import { DishTypes } from "../../shared/types";
import { GetRandom, NumberWithCommas, exp } from "../../shared/utils";
import { FW } from "../server";
import { GetBusinessAccount, GetBusinessOwner, HasPlayerBusinessPermission, IsClockedIn } from "../utils";

let DishesCache: {
    [key: string]: { // Business Name
        [key: string]: Array<{ // Dish Type
            foodchain: string;
            type: string;
            dish_id: string;
            item: string;
            ingredients: Array<string>;
        }>
    }
} = {};

let RegistersCache: {
    [key: string]: Array<false | {
        Order: string;
        Costs: number;
        CostsWithoutTax: number;
        Employee: {
            Name: string;
            Cid: string;
            Source: number;
        }
    }>
} = {};

// Registers
FW.RegisterServer("fw-businesses:Server:Foodchain:SetPaymentData", async (Source: number, Business: string, RegisterId: number, Order: string, Costs: number) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (!await HasPlayerBusinessPermission(Business, Source, "ChargeExternal")) {
        return Player.Functions.Notify("Geen toegang..", "error")
    };

    if (!RegistersCache[Business]) RegistersCache[Business] = [];

    RegistersCache[Business][RegisterId - 1] = {
        Order,
        Costs: FW.Shared.CalculateTax("Services", Costs),
        CostsWithoutTax: Costs,
        Employee: {
            Name: `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}`,
            Cid: Player.PlayerData.citizenid,
            Source
        }
    };
});

FW.Functions.CreateCallback("fw-businesses:Server:Foodchain:GetPaymentData", (Source: number, Cb: Function, Business: string, RegisterId: number) => {
    if (!RegistersCache[Business]) return Cb(false);
    if (!RegistersCache[Business][RegisterId - 1]) return Cb(false);

    Cb(RegistersCache[Business][RegisterId - 1]);
});

onNet("fw-businesses:Server:Foodchain:PayRegister", async (Data: {
    Business: string;
    RegisterId: number;
    PaymentType: "Cash" | "Bank";
}) => {
    const Player = FW.Functions.GetPlayer(source);
    if (!Player) return;

    if (!RegistersCache[Data.Business]) return;

    const PaymentData = RegistersCache[Data.Business][Data.RegisterId - 1];
    if (!PaymentData) return;

    const BusinessAccount = await GetBusinessAccount(Data.Business);

    if (
        (Data.PaymentType == 'Cash' && Player.Functions.RemoveMoney("cash", PaymentData.Costs)) ||
        (Data.PaymentType == "Bank") && exp['fw-financials'].RemoveMoneyFromAccount(PaymentData.Employee.Cid, BusinessAccount, Player.PlayerData.charinfo.account, PaymentData.Costs, 'PURCHASE', `Betaling zakelijke dienstverlening: ${PaymentData.Order}`, false)
    ) {
        if (Data.PaymentType == "Bank") {
            emitNet('fw-phone:Client:Notification', Player.PlayerData.source, `business-pay-${Data.Business}-${Data.RegisterId}`, "fas fa-home", [ "white" , "rgb(38, 50, 56)" ], Data.Business, `${NumberWithCommas(PaymentData.Costs)} afgeschreven van je bankrekening.`);
        };

        emitNet('fw-phone:Client:Notification', PaymentData.Employee.Source, `business-payment-${Data.Business}-${Data.RegisterId}`, "fas fa-home", [ "white" , "rgb(38, 50, 56)" ], Data.Business, `${NumberWithCommas(PaymentData.Costs)} is succesvol afgeschreven.`);
        exp['fw-financials'].AddMoneyToAccount(Player.PlayerData.citizenid, Player.PlayerData.charinfo.account, BusinessAccount, PaymentData.CostsWithoutTax, "PURCHASE", `Betaling zakelijke dienstverlening: ${PaymentData.Order}`, false)
        exp['fw-financials'].AddMoneyToAccount('1001', '1', '1', PaymentData.Costs - PaymentData.CostsWithoutTax, "TAX", `Services Tax. (${Data.Business}: ${NumberWithCommas(PaymentData.Costs)})`, false)

        RegistersCache[Data.Business][Data.RegisterId - 1] = false;
        emitNet("fw-businesses:Client:Foodchain:RecieveReceipt", -1, Data.Business, {Check: "Penis Twister 9000"});
    } else {
        Player.Functions.Notify("Je hebt niet genoeg geld..", "error")
    };
});

onNet("fw-businesses:Server:ReceiveReceipt", (Data: {
    Check: string;
}) => {
    if (Data.Check != "Penis Twister 9000") return;

    const Player = FW.Functions.GetPlayer(source);
    if (!Player) return;

    Player.Functions.AddItem("business-ticket", 1, false, false, true);
});

onNet("fw-businesses:Server:SellReceipts", async () => {
    const Player = FW.Functions.GetPlayer(source)
    if (!Player) return;

    const Items = await exp['ghmattimysql'].executeSync("SELECT item_name, custom_type, slot, createdate FROM `player_inventories` WHERE `inventory` = ?", [`ply-${Player.PlayerData.citizenid}`]);

    let TotalReceive = 0;
    for (let i = 0; i < Items.length; i++) {
        const Item = Items[i];
        if (Item.item_name == "business-ticket") {
            Player.Functions.RemoveItemByName("business-ticket", 1, false);
            TotalReceive += GetRandom(55, 75);
        };
    };

    if (TotalReceive > 0) {
        Player.Functions.Notify("Balans is toegevoegd op je bank.");
        exp['fw-financials'].AddMoneyToAccount('1001', '1', Player.PlayerData.charinfo.account, TotalReceive, 'DEPOSIT', 'Baan: Bonnetjes verkoop');
    };
});

// Food Preperation
FW.RegisterServer("fw-businesses:Server:Foodchain:FinishMeal", async (Source: number, Business: string, Dish: {
    foodchain: string;
    type: string;
    dish_id: string;
    item: string;
    ingredients: Array<string>;
}) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;
    
    const {ingredientCategories, foodchainBuffs} = await exp['fw-config'].GetModuleConfig("bus-foodchains");

    for (let i = 0; i < Dish.ingredients.length; i++) {
        const IngredientType = Dish.ingredients[i];

        for (let j = 0; j < ingredientCategories[IngredientType].length; j++) {
            if (Player.Functions.RemoveItemByName("ingredient", 1, true, ingredientCategories[IngredientType][j])) {
                break; // go to next ingredient.
            }
        };
    };

    const BusinessBuffs = foodchainBuffs[Business];
    Player.Functions.AddItem(Dish.item, 1, false, {
        Buff: BusinessBuffs ? BusinessBuffs[Math.floor(Math.random() * BusinessBuffs.length)] : undefined,
        BuffPercentage: GetRandom(10, 25)
    }, true, Dish.dish_id);
});

FW.Functions.CreateCallback("fw-businesses:Server:Foodchain:GetDishes", (Source: number, Cb: Function, Business: string, DishType: DishTypes) => {
    if (!DishesCache[Business] || !DishesCache[Business][DishType]) return Cb([]);
    Cb(DishesCache[Business][DishType]);
});

// Menu Management
const ImgurRegex = /https:\/\/i\.imgur\.com\/[a-zA-Z0-9]+\.png$/i;
FW.RegisterServer("fw-businesses:Server:Foodchain:CreateItem", async (Source: number, Business: string, Dish: DishTypes, Data: any) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (Data.Business != "Prison" && await GetBusinessOwner(Business) != Player.PlayerData.citizenid) {
        return;
    };

    const {foodchainIds, ingredientsPerDish, dishItems} = await exp['fw-config'].GetModuleConfig("bus-foodchains");
    const DishId = `${foodchainIds[Business]}-${Data.Name.toLowerCase().replaceAll(' ', '-')}`;

    const Result = await exp['ghmattimysql'].executeSync("SELECT COUNT(*) as Amount FROM `server_customtypes` WHERE `type_id` = ?", [DishId])
    if (Result[0].Amount != 0) {
        return Player.Functions.Notify("Dish bestaat al!", "error")
    }

    if (!ImgurRegex.test(Data.Image)) {
        return Player.Functions.Notify("Icoon moet een imgur PNG image zijn! (bv. https://i.imgur.com/SteKs2I.png", "error");
    };

    let Ingredients = [];
    for (let i = 0; i < ingredientsPerDish[Dish]; i++) {
        Ingredients.push(Data[`Ingredient${i+1}`])
    };

    exp['ghmattimysql'].executeSync("INSERT INTO `businesses_dishes` (`foodchain`, `type`, `dish_id`, `ingredients`) VALUES (?, ?, ?, ?)", [
        Business,
        Dish,
        DishId,
        JSON.stringify(Ingredients)
    ])

    exp['ghmattimysql'].executeSync("INSERT INTO `server_customtypes` (`item_id`, `type_id`, `label`, `description`, `image`, `craft`, `isExternImage`) VALUES (?, ?, ?, ?, ?, '[]', 1)", [
        dishItems[Dish],
        DishId,
        Data.Name,
        Data.Description,
        Data.Image
    ])

    Player.Functions.Notify("Gerecht toegevoegd!")
    TriggerEvent('fw-logs:Server:Log', 'menuManagement', 'Dish Created', `User: [${Player.PlayerData.source}] - ${Player.PlayerData.citizenid} - ${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}\nFoodchain: ${Business}\nDish Type: ${Dish}\nData: \`\`\`json\n${JSON.stringify(Data, undefined, 2)}\`\`\``, 'green')
});

FW.Functions.CreateCallback("fw-businesses:Server:Foodchain:GetItem", async (Source: number, Cb: Function, ItemId: string, TypeId: string) => {
    const Result = exp['ghmattimysql'].executeSync("SELECT `label` AS Label, `description` AS Description FROM `server_customtypes` WHERE `item_id` = ? AND `type_id` = ?", [ItemId, TypeId]);
    Cb(Result[0])
})

FW.Functions.CreateCallback("fw-businesses:Server:Foodchain:GetDBDishes", async (Source: number, Cb: Function, Foodchain: string, DishType: DishTypes) => {
    const Result = await exp['ghmattimysql'].executeSync("SELECT * FROM `businesses_dishes` WHERE `foodchain` = ? AND `type` = ?", [Foodchain, DishType])
    const {dishItems} = await exp['fw-config'].GetModuleConfig("bus-foodchains");

    for (let i = 0; i < Result.length; i++) {
        const Dish = Result[i];
        Result[i].item = dishItems[DishType];
        Result[i].ingredients = JSON.parse(Dish.ingredients);
    };

    Cb(Result)
});

onNet("fw-businesses:Server:Foodchain:DeleteItem", async (Data: {
    Foodchain: string;
    DishId: number
}) => {
    console.log("Hi?");
    const Player = FW.Functions.GetPlayer(source)
    if (!Player) return;

    if (Data.Foodchain != "Prison" && await GetBusinessOwner(Data.Foodchain) != Player.PlayerData.citizenid) {
        return Player.Functions.Notify("Geen toegang..", "error")
    }

    await exp['ghmattimysql'].executeSync("DELETE FROM `businesses_dishes` WHERE `id` = ?" , [ Data.DishId ])
    Player.Functions.Notify("Gerecht verwijderd!")
});

// Misc
onNet("fw-businesses:Server:Foodchain:GrabBusinessBag", async (Data: {
    Business: string;
    Type: string;
}) => {
    const Player = FW.Functions.GetPlayer(source);
    if (!Player) return;

    if (!await HasPlayerBusinessPermission(Data.Business, Player.PlayerData.source, "ChargeExternal")) {
        return Player.Functions.Notify("Geen toegang..", "error")
    };

    const BagId = `bag-${new Date().getTime()}${GetRandom(1, 999999)}`;
    Player.Functions.AddItem('business-bag', 1, false, {BagId}, true, Data.Type);
});

onNet("fw-businesses:Server:Foodchain:GrabBusinessGift", async (Data: {
    Business: string;
    Type: string;
}) => {
    const Player = FW.Functions.GetPlayer(source);
    if (!Player) return;

    if (!IsClockedIn(Player.PlayerData.source, Data.Business)) {
        return Player.Functions.Notify("Geen toegang..", "error")
    };

    if (Data.Type == "uwucafe") {
        Player.Functions.AddItem('uwu-mystery-box', 1, false, undefined, true);
    };
});

setImmediate(async () => {
    const Result = await exp['ghmattimysql'].executeSync("SELECT * FROM `businesses_dishes`");

    const {dishItems} = await exp['fw-config'].GetModuleConfig("bus-foodchains");

    for (let i = 0; i < Result.length; i++) {
        const Dish = Result[i];

        if (!DishesCache[Dish.foodchain]) DishesCache[Dish.foodchain] = {};
        if (!DishesCache[Dish.foodchain][Dish.type]) DishesCache[Dish.foodchain][Dish.type] = [];

        DishesCache[Dish.foodchain][Dish.type].push({
            foodchain: Dish.foodchain,
            type: Dish.type,
            dish_id: Dish.dish_id,
            item: dishItems[Dish.type],
            ingredients: JSON.parse(Dish.ingredients),
        });
    };

    console.log(`[FOODCHAIN] Loaded a total of ${Result.length} dishes.`)
});

onNet("fw-businesses:Server:Foodchain:OpenMystery", (Item: any) => {
    const Player = FW.Functions.GetPlayer(source)
    if (!Player) return;

    const Toys = [
        "uwu-toy-biker", "uwu-toy-business", "uwu-toy-burglar",
        "uwu-toy-doctor", "uwu-toy-fisher", "uwu-toy-maid",
        "uwu-toy-officer", "uwu-toy-wizard", "uwu-toy-worker"
    ]

    if (Player.Functions.RemoveItem('uwu-mystery-box', 1, Item.Slot)) {
        Player.Functions.AddItem(Toys[Math.floor(Math.random() * Toys.length)], 1, false, false, true)
    }
})

// RegisterCommand("getIngredients", function(Source: number) {
//     const Player = FW.Functions.GetPlayer(Source)

//     Player.Functions.AddItem('ingredient', 10, false, false, true, "Cream")
//     Player.Functions.AddItem('ingredient', 10, false, false, true, "Beans")
//     Player.Functions.AddItem('ingredient', 10, false, false, true, "Beef")
//     Player.Functions.AddItem('ingredient', 10, false, false, true, "Dairy")
//     Player.Functions.AddItem('ingredient', 10, false, false, true, "Cabbage")
//     Player.Functions.AddItem('ingredient', 10, false, false, true, "Carrot")
//     Player.Functions.AddItem('ingredient', 10, false, false, true, "Cucumber")
//     Player.Functions.AddItem('ingredient', 10, false, false, true, "Onion")
//     Player.Functions.AddItem('ingredient', 10, false, false, true, "Potato")
//     Player.Functions.AddItem('ingredient', 10, false, false, true, "Radish")
//     Player.Functions.AddItem('ingredient', 10, false, false, true, "RedBeet")
//     Player.Functions.AddItem('ingredient', 10, false, false, true, "Tomato")
//     Player.Functions.AddItem('ingredient', 10, false, false, true, "Corn")
//     Player.Functions.AddItem('ingredient', 10, false, false, true, "Wheat")
//     Player.Functions.AddItem('ingredient', 10, false, false, true, "Garlic")
//     Player.Functions.AddItem('ingredient', 10, false, false, true, "Pumpkin")
//     Player.Functions.AddItem('ingredient', 10, false, false, true, "Watermelon")
//     Player.Functions.AddItem('ingredient', 10, false, false, true, "Sunflower")
// }, false)