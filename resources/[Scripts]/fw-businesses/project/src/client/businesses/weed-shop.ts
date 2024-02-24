import { Delay, exp } from "../../shared/utils";
import { FW, GetCurrentClock } from "../client";
import { HasRolePermission, IsBusinessOnLockdown, IsPlayerInBusiness } from "../utils";

onNet("fw-businesses:Client:WhiteWidow:Counter", (Data: {Type: string}) => {
    if (exp['fw-inventory'].CanOpenInventory()) {
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `${Data.Type}_counter`, 10, 200)
    }
});

onNet("fw-businesses:Client:WhiteWidow:Storage", async (Data: {
    Business: string;
    Type: string;
}) => {
    if (!await HasRolePermission(Data.Business, "StashAccess")) return;

    if (await IsBusinessOnLockdown(Data.Business)) {
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error");
    };

    if (exp['fw-inventory'].CanOpenInventory()) {
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `${Data.Type}_storage`, 40, 2000)
    }
});

onNet("fw-businesses:Client:WhiteWidow:Craft", async (Data: {
    Business: string;
}) => {
    if (!await HasRolePermission(Data.Business, "CraftAccess")) return;

    if (await IsBusinessOnLockdown(Data.Business)) {
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error");
    };

    if (exp['fw-inventory'].CanOpenInventory()) {
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Crafting', 'WhiteWidow')
    };
});

// zones
onNet("fw-config:configLoaded", (pConfig: string) => {
    if (!exp['fw-config'].IsConfigReady() || pConfig != "bus-whitewidow") return;
    loadWeedshopZones();
});

onNet("fw-config:configReady", () => {
    loadWeedshopZones();
});

const loadWeedshopZones = async () => {
    while (!exp['fw-config'].IsConfigReady()) {
        await Delay(100);
    };

    const {zones} = await exp['fw-config'].GetModuleConfig("bus-whitewidow");

    for (let i = 0; i < zones.length; i++) {
        const ZoneData = zones[i];
        let options: any[] = [];

        if (ZoneData.options.includes("stash")) {
            options.push({
                Name: 'stash',
                Icon: 'fas fa-box-open',
                Label: 'Stash',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:WhiteWidow:Storage',
                EventParams: ZoneData.data,
                Enabled: () => {
                    const {Business, ClockedIn} = GetCurrentClock();
                    return ClockedIn && Business === ZoneData.data.Business;
                },
            })
        };

        if (ZoneData.options.includes("craft")) {
            options.push({
                Name: 'craft',
                Icon: 'fas fa-tools',
                Label: 'Craften',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:WhiteWidow:Craft',
                EventParams: ZoneData.data,
                Enabled: () => {
                    const {Business, ClockedIn} = GetCurrentClock();
                    return ClockedIn && Business === ZoneData.data.Business;
                },
            })
        };

        if (ZoneData.options.includes("tray")) {
            options.push({
                Name: 'stash',
                Icon: 'fas fa-box-open',
                Label: 'Toonbank',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:WhiteWidow:Counter',
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
