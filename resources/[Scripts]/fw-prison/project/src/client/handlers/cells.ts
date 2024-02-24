import { CellZones } from "../../shared/config";
import { exp } from "../../shared/utils";
import { FW } from "../client";

let currentCell: string = "";

setImmediate(() => {
    for (let i = 0; i < CellZones.length; i++) {
        const ZoneData = CellZones[i];
        exp['fw-ui'].AddEyeEntry(`prison_cell_${i}`, {
            Type: 'Zone',
            SpriteDistance: 10.0,
            Distance: 7.0,
            ZoneData: {
                Center: ZoneData.center,
                Length: ZoneData.length,
                Width: ZoneData.width,
                Data: {
                    debugPoly: false,
                    heading: ZoneData.heading,
                    minZ: ZoneData.minZ,
                    maxZ: ZoneData.maxZ,
                    data: {cellId: i}
                },
            },
            Options: [
                {
                    Name: 'claim',
                    Icon: 'fas fa-flag',
                    Label: 'Claim',
                    EventType: 'Server',
                    EventName: 'fw-prison:Server:ClaimCell',
                    EventParams: { CellId: i },
                    Enabled: async (Entity: number) => {
                        if (currentCell != `prison_cell_${i}`) return false;
                        const PlayerData = FW.Functions.GetPlayerData()
                        if (!PlayerData.metadata.islifer && PlayerData.metadata.jailtime <= 0) return false;

                        const isClaimed = await IsCellClaimed(i);
                        return !isClaimed;
                    },
                },
                {
                    Name: 'stash',
                    Icon: 'fas fa-box-open',
                    Label: 'Stash',
                    EventType: 'Client',
                    EventName: 'fw-prison:Client:OpenStash',
                    EventParams: { CellId: i },
                    Enabled: async (Entity: number) => {
                        if (currentCell != `prison_cell_${i}`) return false;

                        const IsClaimee = await IsCellClaimee(i);
                        return IsClaimee || FW.Functions.GetPlayerData().job.name == "doc";
                    },
                },
            ]
        });
    };
});

onNet("fw-prison:Client:OpenStash", ({CellId}: {CellId: number}) => {
    if (!exp['fw-inventory'].CanOpenInventory()) return;
    if (!IsCellClaimed(CellId)) return;

    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `prison-cell-${CellId}`, 10, 150);
    FW.TriggerServer("fw-prison:Server:SetLastUsed", CellId);
});

onNet("PolyZone:OnEnter", ({name}: {name: string}) => {
    currentCell = name
});

onNet("PolyZone:OnExit", () => {
    currentCell = ""
});

const IsCellClaimed = async (cellId: number): Promise<boolean> => {
    return await FW.SendCallback("fw-prison:Server:IsCellClaimed", cellId);
};

const IsCellClaimee = async (cellId: number): Promise<boolean> => {
    return await FW.SendCallback("fw-prison:Server:IsCellClaimee", cellId);
};