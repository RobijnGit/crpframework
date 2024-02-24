import { Delay, exp } from "../../shared/utils";
import { HasRolePermission, IsBusinessOnLockdown } from "../utils";
import { FW } from "../client";

onNet("fw-businesses:Client:OnFlightschoolStore", () => {
    if (!exp['fw-inventory'].CanOpenInventory()) return;
    FW.TriggerServer("fw-inventory:Server:OpenInventory", "Store", "Flightschool")
});

export const HasPilotLicense = (): boolean => {
    return FW.Functions.GetPlayerData().metadata.licenses.flying
};
exp("HasPilotLicense", HasPilotLicense)

setImmediate(async () => {
    while (!exp['fw-config'].IsConfigReady()) {
        await Delay(100)
    };

    const FlightschoolData = await exp['fw-config'].GetModuleConfig("bus-flightschool");
    exp['fw-ui'].AddEyeEntry("flightschool-highcommand-cabinet", {
        Type: 'Zone',
        SpriteDistance: 7.0,
        Distance: 1.2,
        ZoneData: {
            Center: FlightschoolData.hc_cabinet.center,
            Length: FlightschoolData.hc_cabinet.length,
            Width: FlightschoolData.hc_cabinet.width,
            Data: {
                heading: FlightschoolData.hc_cabinet.heading,
                minZ: FlightschoolData.hc_cabinet.minZ,
                maxZ: FlightschoolData.hc_cabinet.maxZ,
            },
        },
        Options: [
            {
                Name: 'highcommand_badge',
                Icon: 'fas fa-id-badge',
                Label: 'Vliegbrevet Maken',
                EventType: 'Client',
                EventName: 'fw-ui:Client:CreateBadge',
                EventParams: { Badge: 'flightschool' },
                Enabled: async () => {
                    if (await IsBusinessOnLockdown("Los Santos Vliegschool")) return false;
                    return await HasRolePermission("Los Santos Vliegschool", "ChargeExternal");
                }
            },
            {
                Name: 'stash',
                Icon: 'fas fa-box-open',
                Label: 'Open',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:OnFlightschoolStore',
                EventParams: {},
                Enabled: async () => {
                    if (await IsBusinessOnLockdown("Los Santos Vliegschool")) return false;
                    return await HasRolePermission("Los Santos Vliegschool", "ChargeExternal");
                }
            },
        ]
    });
});