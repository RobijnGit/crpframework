import { Vector3 } from "../../shared/classes/math";
import { Thread } from "../../shared/classes/thread";
import { exp } from "../../shared/utils";
import { FW } from "../client";

const ActionsThread = new Thread("tick", 4);
ActionsThread.addHook("active", () => {
    if (IsControlJustReleased(0, 38)) {
        emit("fw-prison:Client:OpenDOCActions")
    };
});

export default () => {
    exp['PolyZone'].CreateBox({
        center: new Vector3(1844.33, 2574.39, 46.01),
        length: 1.05,
        width: 1.5,
    }, {
        name: "doc-prison-actions",
        heading: 0,
        minZ: 45.01,
        maxZ: 47.21
    });

    exp['fw-ui'].AddEyeEntry("doc-hc-cabin", {
        Type: 'Zone',
        SpriteDistance: 7.0,
        Distance: 2.0,
        ZoneData: {
            Center: new Vector3(1839.49, 2573.9, 46.01),
            Length: 0.65,
            Width: 1.2,
            Data: {
                heading: 0,
                minZ: 45.76,
                maxZ: 46.31
            },
        },
        Options: [
            {
                Name: 'cabin',
                Icon: 'fas fa-archive',
                Label: 'HC Stash',
                EventType: 'Client',
                EventName: 'fw-police:Client:OpenHCStash',
                EventParams: { Department: "DOC" },
                Enabled: (Entity: number) => {
                    const PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'doc' && PlayerData.metadata.ishighcommand
                },
            },
            {
                Name: 'highcommand_badge',
                Icon: 'fas fa-id-badge',
                Label: 'DOC Pas Maken',
                EventType: 'Client',
                EventName: 'fw-ui:Client:CreateBadge',
                EventParams: { Badge: 'doc', Job: 'doc', Department: "Department of Corrections" },
                Enabled: (Entity: number) => {
                    const PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'doc' && PlayerData.metadata.ishighcommand
                },
            },
            {
                Name: 'highcommand_employees',
                Icon: 'fas fa-users',
                Label: 'DOC Medewerkerslijst',
                EventType: 'Client',
                EventName: 'fw-police:Client:OpenEmployeelist',
                EventParams: { Job: 'doc' },
                Enabled: (Entity: number) => {
                    const PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'doc' && PlayerData.metadata.ishighcommand
                },
            },
        ]
    })
};

on("PolyZone:OnEnter", (Poly: any) => {
    if (Poly.name != "doc-prison-actions") return;

    const PlayerJob = FW.Functions.GetPlayerData().job;
    if (PlayerJob.name != "doc" || !PlayerJob.onduty) return;

    exp['fw-ui'].ShowInteraction('[E] DOC Acties');
    ActionsThread.start();
});

on("PolyZone:OnExit", (Poly: any) => {
    if (Poly.name != "doc-prison-actions") return;
    exp['fw-ui'].HideInteraction();
    if (ActionsThread.running) ActionsThread.stop();
});