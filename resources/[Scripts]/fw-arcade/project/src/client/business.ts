// all the code for the business itself.

import { Vector3 } from "../shared/classes/math/vector3";
import { Delay, exp } from "../shared/utils";
import { FW } from "./client";
import { DateTime } from "luxon";

onNet("fw-arcade:Client:OpenArcadeInventory", () => {
    const {citizenid} = FW.Functions.GetPlayerData();
    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Arcade Inventory', `arcade-inventory-${citizenid}`, 40, 250)
});

onNet("fw-arcade:Client:OpenTokenMenu", async () => {
    await Delay(10);

    const {ticketPrice} = await exp['fw-config'].GetModuleConfig("bus-arcade", { ticketPrice: 299});

    FW.Functions.OpenMenu({
        MainMenuItems: [
            {
                Title: "Purchase Tokens",
                Desc: "You need tokens to play games on the arcades.",
                SecondMenu: [
                    {
                        Icon: "dollar-sign",
                        Title: "Pay with Cash",
                        Desc: `$${ticketPrice}`,
                        Data: { Event: "fw-arcade:Client:PurchaseToken", Payment: "Cash" }
                    },
                    {
                        Icon: "credit-card",
                        Title: "Pay with Card",
                        Desc: `$${ticketPrice}`,
                        Data: { Event: "fw-arcade:Client:PurchaseToken", Payment: "Card" }
                    },
                ]
            }
        ],
        Width: "32vh"
    })

});

onNet("fw-arcade:Client:PurchaseToken", async (Data: {
    Payment: "Cash" | "Card"
}) => {
    await Delay(10);

    const Result = await exp['fw-ui'].CreateInput([
        {
            Icon: 'coins',
            Label: 'Amount of tokens',
            Name: 'Amount',
            Type: "number"
        },
    ]);

    if (!Result || Result.Amount.trim().length == 0) return;
    emitNet("fw-arcade:Server:PurchaseToken", {
        Payment: Data.Payment,
        Amount: parseInt(Result.Amount)
    })
});

onNet("fw-arcade:Client:OpenArcadeManagement", async (Data: {
    Game: string
}) => {
    if (!await exp['fw-businesses'].HasRolePermission("Coopers Arcade", "CraftAccess")) return;

    const { ticketTypes, arcadeMachines, arcadeStats } = await exp['fw-config'].GetModuleConfig("bus-arcade", {
        ticketTypes: [],
        arcadeMachines: {},
        arcadeStats: {},
    })

    if (ticketTypes == undefined || ticketTypes.length == 0) {
        return FW.Functions.Notify("This arcade can not be opened..", "error");
    };

    const ContextItems = [
        {
            Icon: "joystick",
            Title: ticketTypes.find((Val: string[]) => Val[0] == Data.Game)[1]
        },
        {
            Icon: "heart",
            Title: `Arcade status: ${Math.floor(arcadeMachines[Data.Game])}%`,
            Desc: `Click to repair (${Math.ceil((1200 - (1200 * (Math.floor(arcadeMachines[Data.Game]) / 100))) * 2)}x)`,
            Data: { Event: "fw-arcade:Client:RepairArcadeMachine", Game: Data.Game, Health: arcadeMachines[Data.Game] }
        },
        {
            Icon: "clock",
            Title: `Last repair`,
            Desc: DateTime.fromMillis(arcadeStats[Data.Game].lastRepair).toFormat("dd MMM yyyy HH:mm")
        },
        {
            Icon: "chart-line",
            Title: `Times played`,
            Desc: `${Math.floor(arcadeStats[Data.Game].totalPlays).toLocaleString('en-US')} times`
        },
        // {
        //     Icon: "chart-line",
        //     Title: `Times played today`,
        //     Desc: `0 keer`
        // },
        {
            Icon: "medal",
            Title: `Popularity rank`,
            Desc: Object.keys(arcadeStats).sort((a, b) => arcadeStats[b].totalPlays - arcadeStats[a].totalPlays).findIndex((Val) => Val == Data.Game) + 1
        },
    ];

    FW.Functions.OpenMenu({
        MainMenuItems: ContextItems
    });
});

on("fw-arcade:Client:RepairArcadeMachine", async (Data: {
    Game: string;
    Health: number
}) => {
    if (!await exp['fw-businesses'].HasRolePermission("Coopers Arcade", "CraftAccess")) return;

    if (Data.Health >= 95) {
        return FW.Functions.Notify("The arcade looks fine!")
    };

    const RequiredMaterials = Math.floor(1200 - (1200 * (Math.floor(Data.Health) / 100)));
    if (RequiredMaterials <= 0) return FW.Functions.Notify("The arcade looks fine!");

    if (!exp['fw-inventory'].HasEnoughOfItem("electronics", RequiredMaterials) || !exp['fw-inventory'].HasEnoughOfItem("plastic", RequiredMaterials)) {
        return FW.Functions.Notify("You don't have enough materials..", "error")
    };

    const Finished = await FW.Functions.CompactProgressbar(500 * (100 - Data.Health), "Repairing arcade..", false, true, {
        disableMovement: true,
        disableCarMovement: true,
        disableMouse: false,
        disableCombat: true
    }, {
        animDict: "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
        anim: "machinic_loop_mechandplayer",
        flags: 1,
    }, {}, {}, false);

    StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0);

    if (!Finished) return;
    FW.TriggerServer("fw-arcade:Server:RepairArcadeMachine", Data.Game)
});

on("fw-arcade:Client:OpenMembershipMenu", async () => {
    if (!await exp['fw-businesses'].HasRolePermission("Coopers Arcade", "ChargeCustomer")) return;

    const ContextItems: any = [];
    const {subscriptions} = await exp['fw-config'].GetModuleConfig("arcade-memberships", {subscriptions: []})

    for (let i = 0; i < subscriptions.length; i++) {
        const { Cid, FirstPayment, Type } = subscriptions[i];
        const Name = await FW.SendCallback("fw-arcade:Server:GetPlayerCharName", Cid);
        if (!Name) continue;

        const OverdueDebts = await FW.SendCallback("fw-misc:Server:GetOverdueDebtsByCid", "Memberships", "Coopers Arcade Membership", Cid);

        ContextItems.push({
            Title: `(#${Cid}) ${Name}`,
            Desc: `${OverdueDebts.length} overdue ${OverdueDebts.length == 1 ? "invoice" : "invoices"}`,
            SecondMenu: [
                {
                    Icon: "user",
                    Title: `(#${Cid}) ${Name}`,
                    Desc: `Membership since: ${DateTime.fromMillis(FirstPayment).toFormat("dd MMM yyyy")}`
                },
                {
                    Title: `Membership Type: ${Type}`,
                },
                {
                    Title: `Membership Status: ${OverdueDebts.length < 1 ? "Active" : "Inactive"}`,
                },
                {
                    Title: `Revoke Membership`,
                    Data: {
                        Event: "fw-arcade:Server:RevokeMembership",
                        Cid
                    }
                },
            ]
        })
    };

    FW.Functions.OpenMenu({
        MainMenuItems: [
            {
                Title: "Add Member",
                Desc: "Register a new GameNerd membership"
            },
            ...ContextItems
        ]
    })
});

export default () => {
    exp['fw-ui'].AddEyeEntry("arcade-inventory", {
        Type: 'Zone',
        SpriteDistance: 7.0,
        Distance: 2.0,
        ZoneData: {
            Center: new Vector3(-1658.92, -1063.72, 12.16),
            Length: 0.8,
            Width: 1.2,
            Data: {
                heading: 50,
                minZ: 12.16,
                maxZ: 12.56,
            },
        },
        Options: [
            {
                Name: 'stash',
                Icon: 'fas fa-box-open',
                Label: 'Stash',
                EventType: 'Client',
                EventName: 'fw-arcade:Client:OpenArcadeInventory',
                EventParams: {},
                Enabled: (Entity: number) => {
                    return true
                },
            },
        ]
    })

    exp['fw-ui'].AddEyeEntry("arcade-token-machine", {
        Type: 'Zone',
        SpriteDistance: 7.0,
        Distance: 2.0,
        ZoneData: {
            Center: new Vector3(-1648.95, -1062.51, 12.16),
            Length: 1.0,
            Width: 0.3,
            Data: {
                heading: 50,
                minZ: 12.11,
                maxZ: 12.81
            },
        },
        Options: [
            {
                Name: 'token',
                Icon: 'fas fa-cash-register',
                Label: 'Purchase Tokens',
                EventType: 'Client',
                EventName: 'fw-arcade:Client:OpenTokenMenu',
                EventParams: {},
                Enabled: (Entity: number) => {
                    return true
                },
            },
        ]
    })

    // exp['fw-ui'].AddEyeEntry("arcade-management", {
    //     Type: 'Zone',
    //     SpriteDistance: 7.0,
    //     Distance: 2.0,
    //     ZoneData: {
    //         Center: new Vector3(-1648.58, -1069.89, 13.76),
    //         Length: 0.5,
    //         Width: 0.45,
    //         Data: {
    //             heading: 326,
    //             minZ: 13.51,
    //             maxZ: 13.86
    //         },
    //     },
    //     Options: [
    //         {
    //             Name: 'subscriptions',
    //             Icon: 'fas fa-address-card',
    //             Label: 'Memberships beheren',
    //             EventType: 'Client',
    //             EventName: 'fw-arcade:Client:OpenMembershipMenu',
    //             EventParams: {},
    //             Enabled: async (Entity: number) => {
    //                 return await exp['fw-businesses'].HasRolePermission("Coopers Arcade", "ChargeCustomer")
    //             },
    //         },
    //     ]
    // })
}