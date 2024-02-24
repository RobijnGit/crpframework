import { Vector3 } from "../shared/classes/math";
import { Config } from "../shared/config";
import { exp } from "../shared/utils";
import { FW } from "./client";
import { Dead } from "./handlers/death";

const BedProps = [ "v_med_bed1", "v_med_bed2", "gn_med_bed_prop", "gn_med_ope_table_prop", "gn_med_irm_3_prop", "gn_med_xray_3_prop", ];
let NearCheckin: boolean = false;

setImmediate(() => {
    for (let i = 0; i < BedProps.length; i++) {
        const Prop = BedProps[i];
        exp['fw-ui'].AddEyeEntry(GetHashKey(Prop), {
            Type: 'Model',
            Model: Prop,
            Distance: 2.5,
            Options: [
                {
                    Name: 'lay_down',
                    Icon: 'fas fa-bed',
                    Label: 'Liggen',
                    EventType: 'Client',
                    EventName: 'fw-medical:Client:LayBed',
                    EventParams: Prop == "gn_med_xray_3_prop" ? { Heading: -90 } : {},
                    Enabled: () => true,
                }
            ]
        })
    };

    exp['fw-ui'].AddEyeEntry("ems-highcommand-cabinet", {
        Type: 'Zone',
        SpriteDistance: 7.0,
        Distance: 1.2,
        ZoneData: {
            Center: new Vector3(380.97, -1409.93, 36.52),
            Length: 2.45,
            Width: 0.4,
            Data: {
                heading: 320,
                minZ: 35.52,
                maxZ: 37.52
            },
        },
        Options: [
            {
                Name: 'cabin',
                Icon: 'fas fa-archive',
                Label: 'HC Stash',
                EventType: 'Client',
                EventName: 'fw-police:Client:OpenHCStash',
                EventParams: { Department: "CRUSADE" },
                Enabled: (Entity: number) => {
                    const PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'ems' && PlayerData.metadata.ishighcommand
                },
            },
            {
                Name: 'highcommand_badge',
                Icon: 'fas fa-id-badge',
                Label: 'Medicus Pas Maken',
                EventType: 'Client',
                EventName: 'fw-ui:Client:CreateBadge',
                EventParams: { Badge: 'ems', Job: 'ems', Department: "Los Santos Medical Group" },
                Enabled: (Entity: number) => {
                    const PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'ems' && PlayerData.metadata.ishighcommand
                },
            },
            {
                Name: 'highcommand_employees',
                Icon: 'fas fa-users',
                Label: 'EMS Medewerkerslijst',
                EventType: 'Client',
                EventName: 'fw-police:Client:OpenEmployeelist',
                EventParams: { Job: 'ems' },
                Enabled: (Entity: number) => {
                    const PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'ems' && PlayerData.metadata.ishighcommand
                },
            },
            {
                Name:'usb',
                Icon:'fas fa-road',
                Label:'Time Trial USB Pakken',
                EventType:'Client',
                EventName:'fw-police:Client:GrabTimeTrialUSB',
                EventParams:{ Job:'police' },
                Enabled: (Entity: number) => {
                    const PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'ems' && PlayerData.metadata.ishighcommand
                },
            },
        ]
    })

    exp['PolyZone'].CreateBox({
        center: new Vector3(354.88, -1397.16, 32.5),
        length: 3.0,
        width: 4.4,
    }, {
        name: 'crusade-medical-check-in',
        heading: 320,
        minZ: 31.5,
        maxZ: 33.7
    });
    
    exp['PolyZone'].CreateBox({
        center: new Vector3(-817.64, -1236.55, 7.34),
        length: 3.0,
        width: 4.4,
    }, {
        name: "viceroy-medical-check-in",
        heading: 50,
        minZ: 6.34,
        maxZ: 9.14
    });
    
    exp['PolyZone'].CreateBox({
        center: new Vector3(1674.38, 3666.2, 35.34),
        length: 3.0,
        width: 4.4,
    }, {
        name: "sandy-medical-check-in",
        heading: 30,
        minZ: 34.34,
        maxZ: 36.74
    });
    
    exp['PolyZone'].CreateBox({
        center: new Vector3(-250.68, 6335.59, 32.45),
        length: 3.0,
        width: 4.4,
    }, {
        name: "paleto-medical-check-in",
        heading: 45,
        minZ: 31.45,
        maxZ: 34.25
    });
});

on("PolyZone:OnEnter", async (Poly: any) => {
    if (Poly.name != "crusade-medical-check-in" && Poly.name != "viceroy-medical-check-in" && Poly.name != "sandy-medical-check-in" && Poly.name != "paleto-medical-check-in") return;
    NearCheckin = await FW.SendCallback("fw-medical:Server:CanCheckIn");
    exp['fw-ui'].ShowInteraction(`[F1] Checkin (€${Dead ? Config.MedicalFee * Config.FeeMultiplier : Config.MedicalFee})`);
});

on("PolyZone:OnExit", () => {
    NearCheckin = false;
    exp['fw-ui'].HideInteraction();
});

exp("NearCheckin", () => NearCheckin);