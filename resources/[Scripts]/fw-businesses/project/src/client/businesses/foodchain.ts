import { Delay, exp } from "../../shared/utils";
import { FW, GetCurrentClock } from "../client";
import { HasRolePermission, IsBusinessOnLockdown, IsBusinessOwner, IsPlayerInBusiness } from "../utils";

const CanHandInReceipts = async (): Promise<boolean> => {
    const Businesses: string[] = [
        'Burger Shot',
        'UwU Café',
        'Digital Den',
        'PawnNGo',
        'Mattronics',
        'Dragons Den',
        'White Widow',
        'Puff Puff Pass',
        'Kebab King',
        'Bahama Mamas',
        'Digital Dean',
        'De petit croissant'
    ];

    for (let i = 0; i < Businesses.length; i++) {
        if (await IsPlayerInBusiness(Businesses[i])) {
            return true;
        };
    };

    return false;
};

setImmediate(() => {
    exp['fw-ui'].AddEyeEntry("bank_payment_ped", {
        Type: 'Entity',
        EntityType: 'Ped',
        SpriteDistance: 10.0,
        Distance: 5.0,
        Position: {x: 269.38, y: 217.22, z: 105.28, w: 68.01},
        Model: 'a_m_y_hasjew_01',
        Anim: {
            Dict: "missheistdockssetup1clipboard@base",
            Name: "base"
        },
        Props: [
            {
                Prop: 'prop_notepad_01',
                Bone: 18905,
                Placement: [0.1, 0.02, 0.05, 10.0, 0.0, 0.0],
            },
            {
                Prop: 'prop_pencil_01',
                Bone: 58866,
                Placement: [0.11, -0.02, 0.001, -120.0, 0.0, 0.0],
            },
        ],
        Options: [
            {
                Name: 'payment_interaction',
                Icon: 'fas fa-circle',
                Label: 'Salaris Ophalen',
                EventType: 'Server',
                EventName: 'fw-financials:Server:ReceivePaycheck',
                EventParams: {},
                Enabled: () => true
            },
            {
                Name: 'payment_ticket',
                Icon: 'fas fa-circle',
                Label: 'Bonnetjes inleveren',
                EventType: 'Server',
                EventName: 'fw-businesses:Server:SellReceipts',
                EventParams: {},
                Enabled: async () => await CanHandInReceipts(),
            }
        ]
    })
});

on("fw-businesses:Client:Foodchain:ShowEmployees", async (Data: {
    Business: string;
}) => {
    if (!await IsPlayerInBusiness(Data.Business)) return FW.Functions.Notify("Geen toegang..", "error");

    const Result = await FW.SendCallback("fw-businesses:Server:GetClockedInEmployees", Data.Business);
    const ContextItems: Array<{
        Icon: string;
        Title: string;
        Desc: string;
    }> = [];

    for (let i = 0; i < Result.length; i++) {
        const {Cid, Name, TimeClockedIn} = Result[i];
        const MinutesClockedIn = Math.floor((TimeClockedIn / 1000) / 60);

        ContextItems.push({
            Icon: 'user-headset',
            Title: `(#${Cid}) ${Name}`,
            Desc: `${MinutesClockedIn} ${MinutesClockedIn == 1 ? "minuut" : "minuten"} in dienst.`
        });
    };

    FW.Functions.OpenMenu({
        MainMenuItems: ContextItems
    });
});

on("fw-businesses:Client:Foodchain:Counter", async (Data: {
    Type: string;
}) => {
    if (!exp['fw-inventory'].CanOpenInventory()) return;

    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `business_tray_${Data.Type}`, 10, 200)
});

on("fw-businesses:Client:Foodchain:OpenStorage", async (Data: {
    Business: string;
    Type: string;
    Name: string;
}) => {
    if (!exp['fw-inventory'].CanOpenInventory()) return;
    if (!await HasRolePermission(Data.Business, "StashAccess")) return FW.Functions.Notify("Geen toegang..", "error");
    if (await IsBusinessOnLockdown(Data.Business)) return FW.Functions.Notify("Bedrijf is in lockdown..", "error");

    let Slots = 105;
    let Weight = 1600;
    if (Data.Name == "dragonsden" || Data.Name == "kebabking") {
        Slots = 145;
        Weight = 2000;
    };

    if (Data.Type == "Cold") {
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `${Data.Name}_storage_main`, Slots, Weight)
    } else {
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `${Data.Name}_storage_shelf`, 40, 750)
    }
});

onNet("fw-items:Client:Used:MysteryBox", async (Item: any) => {
    exp["fw-inventory"].SetBusyState(true)
    const Finished = await FW.Functions.CompactProgressbar(3000, "Uitpakken..", false, true, {disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: false}, {}, {}, {}, false)
    exp["fw-inventory"].SetBusyState(false);

    if (Finished) emitNet("fw-businesses:Server:Foodchain:OpenMystery", Item);
});

// zones
onNet("fw-config:configLoaded", (pConfig: string) => {
    if (!exp['fw-config'].IsConfigReady() || pConfig != "bus-foodchains") return;
    loadFoodchainZones();
});

onNet("fw-config:configReady", () => {
    loadFoodchainZones();
});

const loadFoodchainZones = async () => {
    while (!exp['fw-config'].IsConfigReady()) {
        await Delay(100);
    };

    const {zones} = await exp['fw-config'].GetModuleConfig("bus-foodchains");

    for (let i = 0; i < zones.length; i++) {
        const ZoneData = zones[i];
        let options: any[] = [];

        if (ZoneData.options.includes("payment")) {
            options.push({
                Name: 'pay_payment',
                Icon: 'fas fa-hand-holding-usd',
                Label: 'Betalen',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Foodchain:GetPayments',
                EventParams: ZoneData.data,
                Enabled: () => true,
            })

            options.push({
                Name: 'setup_payment',
                Icon: 'fas fa-cash-register',
                Label: 'Bestelling Openen',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Foodchain:SetupPayment',
                EventParams: { RegisterId: ZoneData.data.RegisterId },
                Enabled: async () => {
                    const {Business, ClockedIn} = GetCurrentClock();
                    if (Business !== ZoneData.data.Business || !ClockedIn) return;

                    return await HasRolePermission(ZoneData.data.Business, "ChargeExternal");
                },
            })
        };

        if (ZoneData.options.includes("clock")) {
            options.push({
                Name: 'clock_in',
                Icon: 'fas fa-clock',
                Label: 'Inklokken',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:SetClock',
                EventParams: { ...ZoneData.data, ClockedIn: true },
                Enabled: async () => {
                    const {ClockedIn} = GetCurrentClock();
                    if (ClockedIn) return false;
                    return await IsPlayerInBusiness(ZoneData.data.Business)
                },
            })

            options.push({
                Name: 'clock_out',
                Icon: 'fas fa-clock',
                Label: 'Uitklokken',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:SetClock',
                EventParams: { ...ZoneData.data, ClockedIn: false },
                Enabled: async () => {
                    const {ClockedIn} = GetCurrentClock();
                    if (!ClockedIn) return false;
                    return await IsPlayerInBusiness(ZoneData.data.Business)
                },
            })
        };

        if (ZoneData.options.includes("employees")) {
            options.push({
                Name: 'check_employees',
                Icon: 'fas fa-user-check',
                Label: 'Aanwezige Werknemers',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Foodchain:ShowEmployees',
                EventParams: ZoneData.data,
                Enabled: async () => {
                    const {ClockedIn} = GetCurrentClock();
                    if (!ClockedIn) return false;
                    return await IsPlayerInBusiness(ZoneData.data.Business)
                },
            })
        };

        if (ZoneData.options.includes("bag")) {
            options.push({
                Name: 'grab_bag',
                Icon: 'fas fa-box',
                Label: 'Bestelling Zak Pakken',
                EventType: 'Server',
                EventName: 'fw-businesses:Server:Foodchain:GrabBusinessBag',
                EventParams: ZoneData.data,
                Enabled: async () => {
                    const {ClockedIn} = GetCurrentClock();
                    if (!ClockedIn) return false;
                    return await IsPlayerInBusiness(ZoneData.data.Business)
                },
            })
        }

        if (ZoneData.options.includes("uwu_mystery")) {
            options.push({
                Name: 'grab_gift',
                Icon: 'fas fa-box',
                Label: 'Bestelling Cadeau Pakken',
                EventType: 'Server',
                EventName: 'fw-businesses:Server:Foodchain:GrabBusinessGift',
                EventParams: ZoneData.data,
                Enabled: async () => {
                    const {ClockedIn} = GetCurrentClock();
                    if (!ClockedIn) return false;
                    return await IsPlayerInBusiness(ZoneData.data.Business)
                },
            })
        }

        if (ZoneData.options.includes("tray")) {
            options.push({
                Name: 'stash',
                Icon: 'fas fa-box-open',
                Label: 'Toonbank',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Foodchain:Counter',
                EventParams: ZoneData.data,
                Enabled: () => true,
            })
        };

        if (ZoneData.options.includes("storageCold")) {
            options.push({
                Name: 'stash',
                Icon: 'fas fa-box-open',
                Label: 'Open',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Foodchain:OpenStorage',
                EventParams: {Type: "Cold", ...ZoneData.data},
                Enabled: async () => {
                    const {ClockedIn} = GetCurrentClock();
                    if (!ClockedIn) return false;
                    return await IsPlayerInBusiness(ZoneData.data.Business)
                },
            })
        };

        if (ZoneData.options.includes("storageShelf")) {
            options.push({
                Name: 'stash',
                Icon: 'fas fa-box-open',
                Label: 'Open',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Foodchain:OpenStorage',
                EventParams: {Type: "Shelf", ...ZoneData.data},
                Enabled: async () => {
                    const {ClockedIn} = GetCurrentClock();
                    if (!ClockedIn) return false;
                    return await IsPlayerInBusiness(ZoneData.data.Business)
                },
            })
        };

        if (ZoneData.options.includes("prepareFood")) {
            options.push({
                Name: 'prepareFood',
                Icon: 'fas fa-utensils',
                Label: `${ZoneData.data.DishType == "Drinks" ? "Drinken" : "Eten"} Voorbereiden`,
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Foodchain:PrepareFood',
                EventParams: ZoneData.data,
                Enabled: async () => {
                    const {ClockedIn} = GetCurrentClock();
                    if (!ClockedIn) return false;
                    return await IsPlayerInBusiness(ZoneData.data.Business)
                },
            })
        };

        if (ZoneData.options.includes("menuManagement")) {
            options.push({
                Name: 'menuManagement',
                Icon: 'fas fa-circle',
                Label: 'Menukaart Beheren',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Foodchain:ManageMenu',
                EventParams: ZoneData.data,
                Enabled: async () => {
                    const {ClockedIn} = GetCurrentClock();
                    if (!ClockedIn) return false;
                    return await IsBusinessOwner(ZoneData.data.Business)
                },
            })
        };

        exp['fw-ui'].AddEyeEntry(ZoneData.name, {
            Type: 'Zone',
            SpriteDistance: 10.0,
            Distance: 1.5,
            ZoneData: {
                Center: ZoneData.center,
                Length: ZoneData.length,
                Width: ZoneData.width,
                Data: {
                    heading: ZoneData.heading,
                    minZ: ZoneData.minZ,
                    maxZ: ZoneData.maxZ
                },
            },
            Options: options
        })
    };
};