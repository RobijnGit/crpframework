import { DishTypes } from "../../shared/types";
import { Delay, exp } from "../../shared/utils";
import { CurrentClock, FW } from "../client";
import { HasRolePermission, IsBusinessOnLockdown, IsBusinessOwner } from "../utils";

const DishSkillChecks: {[key: string]: number} = {
    Main: 1, // 3,
    Side: 1, // 2,
    Dessert: 1, // 1,
    Drink: 1 // 1
}

const HasAllIngredients = async (Ingredients: string[]): Promise<boolean> => {
    const {ingredientCategories} = await exp['fw-config'].GetModuleConfig("bus-foodchains");

    let ItemsChecked = 0;

    for (let i = 0; i < Ingredients.length; i++) {
        for (let j = 0; j < ingredientCategories[Ingredients[i]].length; j++) {
            if (exp['fw-inventory'].HasEnoughOfItem("ingredient", 1, ingredientCategories[Ingredients[i]][j])) {
                ItemsChecked += 1
            };
        };
    };

    return ItemsChecked >= Ingredients.length;
};

const PrepareFood = async (Data: {
    Business: undefined | string;
    Dish: {
        ingredients: string[]
    }
}) => {
    if (!await HasAllIngredients(Data.Dish.ingredients)) {
        return FW.Functions.Notify("You don't have enough ingredients..", "error")
    };

    exp["fw-inventory"].SetBusyState(true);

    setTimeout(async () => {
        TriggerEvent('fw-emotes:Client:PlayEmote', "cut", undefined, true)
        const Finished = await FW.Functions.CompactProgressbar(5000, "Preparing Food..", false, true, {disableMovement: true, disableCarMovement: true, disableMouse: false, disableCombat: true}, {}, {}, {}, false)
        TriggerEvent("fw-emotes:Client:CancelEmote", true)
        exp["fw-inventory"].SetBusyState(false);

        if (!Finished) return;
        FW.TriggerServer("fw-businesses:Server:Foodchain:FinishMeal", Data.Business || CurrentClock.Business, Data.Dish);

        await Delay(100);
        PrepareFood(Data);
    }, 250);
};

on("fw-businesses:Client:Foodchain:CreateMeal", async (Data: {
    Business: undefined | string;
    DishType: DishTypes;
    Dish: {
        ingredients: string[]
    }
}) => {
    const Tests = DishSkillChecks[Data.DishType];
    const Result = await exp['fw-ui'].StartSkillTest(Tests, [ 20, 30 ], [ 1000, 1500 ], false);
    if (!Result) return FW.Functions.Notify("Failed..", "error");

    PrepareFood(Data);
});

on("fw-businesses:Client:Foodchain:PrepareFood", async (Data: {
    Business: undefined | string;
    DishType: string;
}) => {
    if (!Data.Business) Data.Business = CurrentClock.Business;
    if (await IsBusinessOnLockdown(Data.Business)) {
        return FW.Functions.Notify("Business is in lockdown..", "error");
    };

    if (!await HasRolePermission(Data.Business, "CraftAccess")) return FW.Functions.Notify("No Access..", "error");

    const {categoryLabels} = await exp['fw-config'].GetModuleConfig("bus-foodchains");

    const FoodItems = await FW.SendCallback("fw-businesses:Server:Foodchain:GetDishes", Data.Business, Data.DishType);
    const ContextItems = [];

    for (let i = 0; i < FoodItems.length; i++) {
        const Dish = FoodItems[i];
        const SharedData = exp['fw-inventory'].GetItemData(Dish.item, Dish.dish_id);
        if (!SharedData) continue;

        let ItemRequirements = "";
        for (let j = 0; j < Dish.ingredients.length; j++) {
            const Ingredient = Dish.ingredients[j];

            ItemRequirements += ` ${categoryLabels[Ingredient]}`
            if (j != Dish.ingredients.length - 1) {
                ItemRequirements += ","
            };
        };

        ContextItems.push({
            Title: SharedData.Label,
            Desc: ItemRequirements,
            Disabled: !await HasAllIngredients(Dish.ingredients),
            Data: {
                Event: "fw-businesses:Client:Foodchain:CreateMeal",
                Type: "Client",
                DishType: Data.DishType,
                Dish,
                Business: Data.Business,
            }
        })
    };

    FW.Functions.OpenMenu({
        MainMenuItems: ContextItems
    });
});

on("fw-businesses:Client:Foodchain:ManageMenu", async (Data: {
    Business: string;
}) => {
    if (!Data.Business) Data.Business = CurrentClock.Business;
    if (await IsBusinessOnLockdown(Data.Business)) return FW.Functions.Notify("Business is in lockdown..", "error");

    FW.Functions.OpenMenu({
        MainMenuItems: [
            {
                Icon: 'hamburger',
                Title: "Manage Menu"
            },
            {
                Icon: 'file',
                Title: 'Create new Item',
                SecondMenu: [
                    {
                        Icon: 'hamburger',
                        Title: 'Main Dish',
                        CloseMenu: true,
                        Data: { Event: 'fw-businesses:Client:Foodchain:CreateNewItem', Dish: "Main", Business: Data.Business },
                    },
                    {
                        Icon: 'bacon',
                        Title: 'Side Dish',
                        CloseMenu: true,
                        Data: { Event: 'fw-businesses:Client:Foodchain:CreateNewItem', Dish: "Side", Business: Data.Business },
                    },
                    {
                        Icon: 'ice-cream',
                        Title: 'Dessert',
                        CloseMenu: true,
                        Data: { Event: 'fw-businesses:Client:Foodchain:CreateNewItem', Dish: "Dessert", Business: Data.Business },
                    },
                    {
                        Icon: 'coffee',
                        Title: 'Drink',
                        CloseMenu: true,
                        Data: { Event: 'fw-businesses:Client:Foodchain:CreateNewItem', Dish: "Drink", Business: Data.Business },
                    }
                ]
            },
            {
                Icon: 'utensils',
                Title: 'Dishes',
                CloseMenu: true,
                Data: {
                    Event: 'fw-businesses:Client:Foodchain:OpenDishesMenu',
                    Business: Data.Business
                },
            }
        ]
    });
});

on("fw-businesses:Client:Foodchain:OpenDishesMenu", async (Data: {
    Business: string;
}) => {
    if (Data.Business !== "Prison" && !IsBusinessOwner(Data.Business)) return FW.Functions.Notify("No Access..", "error");
    await Delay(200);

    FW.Functions.OpenMenu({
        MainMenuItems: [
            {
                Icon: 'tasks',
                Title: 'Manage Main Dishes',
                Data: {
                    Event: 'fw-businesses:Client:Foodchain:ManageDishes',
                    Dish: "Main",
                    Business: Data.Business
                },
            },
            {
                Icon: 'tasks',
                Title: 'Manage Side Dishes',
                Data: {
                    Event: 'fw-businesses:Client:Foodchain:ManageDishes',
                    Dish: "Side",
                    Business: Data.Business
                },
            },
            {
                Icon: 'tasks',
                Title: 'Manage Desserts',
                Data: {
                    Event: 'fw-businesses:Client:Foodchain:ManageDishes',
                    Dish: "Dessert",
                    Business: Data.Business
                },
            },
            {
                Icon: 'tasks',
                Title: 'Manage Drinks',
                Data: {
                    Event: 'fw-businesses:Client:Foodchain:ManageDishes',
                    Dish: "Drink",
                    Business: Data.Business
                },
            },
        ]
    })
});

on("fw-businesses:Client:Foodchain:ManageDishes", async (Data: {
    Business: string;
    Dish: DishTypes
}) => {
    if (Data.Business !== "Prison" && !IsBusinessOwner(Data.Business)) return FW.Functions.Notify("No Access..", "error");
    await Delay(200);

    const ContextItems: Array<{}> = [
        {
            Title: "Back",
            Data: {
                Event: 'fw-businesses:Client:Foodchain:OpenDishesMenu',
                Business: Data.Business
            }
        }
    ];

    const FoodItems = await FW.SendCallback("fw-businesses:Server:Foodchain:GetDBDishes", Data.Business, Data.Dish)
    const {categoryLabels} = await exp['fw-config'].GetModuleConfig("bus-foodchains");

    for (let i = 0; i < FoodItems.length; i++) {
        const Dish = FoodItems[i];
        let SharedData = exp['fw-inventory'].GetItemData(Dish.item, Dish.dish_id);
        if (!SharedData) {
            SharedData = await FW.SendCallback("fw-businesses:Server:Foodchain:GetItem", Dish.item, Dish.dish_id)
        }

        let ItemRequirements = "";
        for (let j = 0; j < Dish.ingredients.length; j++) {
            const Ingredient = Dish.ingredients[j];

            ItemRequirements += ` ${categoryLabels[Ingredient]}`
            if (j != Dish.ingredients.length - 1) {
                ItemRequirements += ","
            };
        };

        ContextItems.push({
            Title: SharedData?.Label || Dish.dish_id,
            Desc: SharedData?.Description || `No data found! (${Dish.dish_id})`,
            SecondMenu: [
                {
                    Title: "Delete Items",
                    Icon: "trash",
                    Data: {
                        Event: "fw-businesses:Server:Foodchain:DeleteItem",
                        Foodchain: Data.Business,
                        DishId: Dish.id
                    }
                }
            ]
        })
    }

    FW.Functions.OpenMenu({MainMenuItems: ContextItems, WIdth: "50vh"});
});

on("fw-businesses:Client:Foodchain:CreateNewItem", async (Data: {
    Business: string;
    Dish: DishTypes
}) => {
    if (Data.Business !== "Prison" && !IsBusinessOwner(Data.Business)) return FW.Functions.Notify("No Access..", "error");
    if (await IsBusinessOnLockdown(Data.Business)) return FW.Functions.Notify("Business is in lockdown..", "error");
    await Delay(200);

    if (!DishSkillChecks[Data.Dish]) {
        return FW.Function.Notify("Invalid Dish Type..", "error");
    };

    const {categoryLabels, ingredientsPerDish} = await exp['fw-config'].GetModuleConfig("bus-foodchains");
    const Ingredients = Object.entries(categoryLabels).map(([Key, Val]) => {
        return {
            Text: Val,
            Value: Key
        }
    });

    const Result = await exp['fw-ui'].CreateInput([
        { Label: "Dish Name", Icon: "circle", Name: "Name" },
        { Label: "Description", Icon: "circle", Name: "Description" },
        { Label: "Image URL (100x100)", Icon: "circle", Name: "Image" },
        ...Array.from({ length: ingredientsPerDish[Data.Dish] }, (_, index) => ({
            Label: `Ingredient Type ${index + 1}`,
            Name: `Ingredient${index + 1}`,
            Choices: Ingredients
        }))
    ]);

    if (!Result) return;

    for (let i = 0; i < ingredientsPerDish[Data.Dish]; i++) {
        if (Result[`Ingredient${i+1}`].trim().length == 0) {
            FW.Functions.Notify("You need to fill in all ingredient fields!")
            return;
        };
    };

    if (Result.Name.trim().length == 0 || Result.Description.trim().length == 0 || Result.Image.trim().length == 0) {
        return;
    };

    FW.TriggerServer("fw-businesses:Server:Foodchain:CreateItem", Data.Business, Data.Dish, Result);
});