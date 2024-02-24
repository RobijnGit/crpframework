import { Delay, exp } from "../../shared/utils";
import { FW, GetCurrentClock } from "../client";
import { HasRolePermission, IsBusinessOnLockdown, IsPlayerInBusiness } from "../utils";

onNet("fw-businesses:Client:PawnHub:Tray", async (Data: {
    name: string;
}) => {
    if (await IsBusinessOnLockdown("PawnNGo")) {
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error")
    };

    if (exp['fw-inventory'].CanOpenInventory()) {
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', Data.name, 10, 200);
    };
});

onNet("fw-businesses:Client:PawnHub:Stash", async () => {
    if (!await HasRolePermission("PawnNGo", 'StashAccess')) {
        return FW.Functions.Notify("Geen toegang..", "error")
    }

    if (await IsBusinessOnLockdown("PawnNGo")) {
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error")
    };

    if (exp['fw-inventory'].CanOpenInventory()) {
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `PawnNGO_storage`, 70, 2000);
    };
});

onNet("fw-businesses:Client:PawnHub:Craft", async () => {
    if (!await HasRolePermission("PawnNGo", 'CraftAccess')) {
        return FW.Functions.Notify("Geen toegang..", "error")
    }

    if (await IsBusinessOnLockdown("PawnNGo")) {
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error")
    };

    if (exp['fw-inventory'].CanOpenInventory()) {
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Crafting', `PawnNGo`);
    };
});

onNet("fw-businesses:Client:PawnHub:Scrap", async () => {
    if (!exp['fw-inventory'].CanOpenInventory()) return;
    if (!await HasRolePermission("PawnNGo", "CraftAccess")) return;

    if (await IsBusinessOnLockdown("PawnNGo")) {
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error");
    };

    const Result = await FW.SendCallback("fw-businesses:Server:PawnHub:GetScrapItems");
    if (!Result || Result.length == 0) return FW.Functions.Notify("Je hebt niks opzak om te scrappen..", "error");

    let ContextItems = [];
    for (let i = 0; i < Result.length; i++) {
        const {Label, Slot, Parts} = Result[i];

        ContextItems.push({
            Title: Label,
            Desc: `Slot ${Slot}`,
            SecondMenu: [
                {
                    Title: `<div style="display: flex; justify-content: space-between"><span>Scrappen</span><span>▨ ${Parts}</span></div>`,
                    Icon: "hammer",
                    Data: {
                        Event: "fw-businesses:Server:PawnHub:ScrapElectronic",
                        Type: "Server",
                        Parts, Slot
                    }
                }
            ]
        })
    };

    FW.Functions.OpenMenu({MainMenuItems: ContextItems})
});

// zones
onNet("fw-config:configLoaded", (pConfig: string) => {
    if (!exp['fw-config'].IsConfigReady() || pConfig != "bus-pawnhub") return;
    loadPawnhubZones();
});

onNet("fw-config:configReady", () => {
    loadPawnhubZones();
});

const loadPawnhubZones = async () => {
    while (!exp['fw-config'].IsConfigReady()) {
        await Delay(100);
    };

    const {zones} = await exp['fw-config'].GetModuleConfig("bus-pawnhub");

    for (let i = 0; i < zones.length; i++) {
        const ZoneData = zones[i];
        let options: any[] = [];

        if (ZoneData.options.includes("stash")) {
            options.push({
                Name: 'stash',
                Icon: 'fas fa-box-open',
                Label: 'Stash',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:PawnHub:Stash',
                EventParams: ZoneData.data,
                Enabled: () => {
                    const {Business, ClockedIn} = GetCurrentClock();
                    return ClockedIn && Business === "PawnNGo";
                },
            })
        };

        if (ZoneData.options.includes("craft")) {
            options.push({
                Name: 'craft',
                Icon: 'fas fa-wrench',
                Label: 'Craften',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:PawnHub:Craft',
                EventParams: ZoneData.data,
                Enabled: () => {
                    const {Business, ClockedIn} = GetCurrentClock();
                    return ClockedIn && Business === "PawnNGo";
                },
            })
        };

        if (ZoneData.options.includes("scrap")) {
            options.push({
                Name: 'scrap',
                Icon: 'fas fa-hammer',
                Label: 'Scrappen',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:PawnHub:Scrap',
                EventParams: ZoneData.data,
                Enabled: () => {
                    const {Business, ClockedIn} = GetCurrentClock();
                    return ClockedIn && Business === "PawnNGo";
                },
            })
        };

        if (ZoneData.options.includes("tray")) {
            options.push({
                Name: 'stash',
                Icon: 'fas fa-box-open',
                Label: 'Toonbank',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:PawnHub:Tray',
                EventParams: ZoneData.data,
                Enabled: () => true,
            })
        };

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
                EventParams: { Business: "PawnNGo", ClockedIn: true },
                Enabled: async () => {
                    const {ClockedIn} = GetCurrentClock();
                    if (ClockedIn) return false;
                    return await IsPlayerInBusiness("PawnNGo")
                },
            })

            options.push({
                Name: 'clock_out',
                Icon: 'fas fa-clock',
                Label: 'Uitklokken',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:SetClock',
                EventParams: { Business: "PawnNGo", ClockedIn: false },
                Enabled: async () => {
                    const {ClockedIn} = GetCurrentClock();
                    if (!ClockedIn) return false;
                    return await IsPlayerInBusiness("PawnNGo")
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
                    maxZ: ZoneData.maxZ,
                },
            },
            Options: options
        })
    };
};

setImmediate(() => {
    loadPawnhubZones();
})