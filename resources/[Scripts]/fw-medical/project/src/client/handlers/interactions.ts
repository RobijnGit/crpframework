import { Vector3 } from "../../shared/classes/math";
import { Thread } from "../../shared/classes/thread";
import { exp } from "../../shared/utils";
import { FW } from "../client";

const SharedStashes = ['crusade-medical-stash', 'viceroy-medical-stash', 'sandy-medical-stash', 'paleto-medical-stash'];
const PersonalStashes = ['crusade-medical-personal', 'viceroy-medical-personal', 'sandy-medical-personal', 'paleto-medical-personal'];
const Shops = ['crusade-medical-shop', 'viceroy-medical-shop', 'sandy-medical-shop', 'paleto-medical-shop'];

const StashThread = new Thread("tick", 4);
const PersonalStashThread = new Thread("tick", 4);
const ShopThread = new Thread("tick", 4);

StashThread.addHook('active', () => {
    if (!IsControlJustReleased(0, 38)) return;

    const PlayerData = FW.Functions.GetPlayerData();
    if (PlayerData.job.name != 'ems' || !PlayerData.job.onduty) return FW.Functions.Notify("Geen toegang..", "error");

    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', 'medical-storage-shared', 30, 300)
});

PersonalStashThread.addHook('active', () => {
    if (!IsControlJustReleased(0, 38)) return;

    const PlayerData = FW.Functions.GetPlayerData();
    if (PlayerData.job.name != 'ems' || !PlayerData.job.onduty) return FW.Functions.Notify("Geen toegang..", "error");

    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `medical-storage-${PlayerData.citizenid}`, 30, 300)
});

ShopThread.addHook('active', () => {
    if (IsControlJustReleased(0, 38)) {
        const PlayerData = FW.Functions.GetPlayerData();
        if (PlayerData.job.name != 'ems' || !PlayerData.job.onduty) return FW.Functions.Notify("Geen toegang..", "error");
    
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Store', 'Hospital')
    };

    if (IsControlJustReleased(0, 47)) {
        const PlayerData = FW.Functions.GetPlayerData();
        if (PlayerData.job.name != 'ems' || !PlayerData.job.onduty) return FW.Functions.Notify("Geen toegang..", "error");
    
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Store', 'Medicine')
    }
});

setImmediate(() => {
    // Crusade Medical Center
    exp['PolyZone'].CreateBox({
        center: new Vector3(357.32, -1400.78, 32.5),
        length: 0.8,
        width: 3.0,
    }, {
        name: "crusade-medical-stash",
        heading: 320,
        minZ: 31.5,
        maxZ: 33.85
    });

    exp['PolyZone'].CreateBox({
        center: new Vector3(390.93, -1408.79, 32.5),
        length: 1.0,
        width: 2.0,
    }, {
        name: "crusade-medical-shop",
        heading: 50,
        minZ: 31.5,
        maxZ: 33.7
    });

    exp['PolyZone'].CreateBox({
        center: new Vector3(355.62, -1413.27, 32.5),
        length: 2.6,
        width: 1.0,
    }, {
        name: "crusade-medical-personal",
        heading: 50,
        minZ: 31.5,
        maxZ: 33.4
    });

    // Viceroy Medical Center
    exp['PolyZone'].CreateBox({
        center: new Vector3(-804.48, -1206.68, 7.34),
        length: 1.0,
        width: 1.0,
    }, {
        name: "viceroy-medical-shop",
        heading: 320,
        minZ: 6.34,
        maxZ: 8.69
    });

    exp['PolyZone'].CreateBox({
        center: new Vector3(-820.0, -1242.97, 7.34),
        length: 1.0,
        width: 2.0,
    }, {
        name: "viceroy-medical-stash",
        heading: 320,
        minZ: 6.34,
        maxZ: 8.64
    });

    exp['PolyZone'].CreateBox({
        center: new Vector3(-826.44, -1236.89, 7.34),
        length: 0.8,
        width: 3.0,
    }, {
        name: "viceroy-medical-personal",
        heading: 50,
        minZ: 6.34,
        maxZ: 8.59
    });

    // Sandy Medical Clinic
    exp['PolyZone'].CreateBox({
        center: new Vector3(1674.2, 3668.68, 35.34),
        length: 0.95,
        width: 1.65,
    }, {
        name: "sandy-medical-stash",
        heading: 30,
        minZ: 34.34,
        maxZ: 36.74
    });

    exp['PolyZone'].CreateBox({
        center: new Vector3(1668.37, 3653.62, 35.34),
        length: 0.8,
        width: 2.2,
    }, {
        name: "sandy-medical-personal",
        heading: 30,
        minZ: 34.34,
        maxZ: 36.74
    });

    exp['PolyZone'].CreateBox({
        center: new Vector3(1661.08, 3660.31, 35.34),
        length: 3.2,
        width: 1.0,
    }, {
        name: "sandy-medical-shop",
        heading: 300,
        minZ: 34.34,
        maxZ: 36.74
    });

    // Paleto Medical Clinic
    exp['PolyZone'].CreateBox({
        center: new Vector3(-251.61, 6337.97, 32.49),
        length: 0.8,
        width: 1.6,
    }, {
        name: "paleto-medical-stash",
        heading: 45,
        minZ: 31.49,
        maxZ: 33.49
    });

    exp['PolyZone'].CreateBox({
        center: new Vector3(-253.66, 6321.38, 32.45),
        length: 1.1,
        width: 1.05,
    }, {
        name: "paleto-medical-personal",
        heading: 315,
        minZ: 31.45,
        maxZ: 33.45
    });

    exp['PolyZone'].CreateBox({
        center: new Vector3(-252.83, 6322.21, 32.45),
        length: 1.2,
        width: 1.0,
    }, {
        name: "paleto-medical-shop",
        heading: 315,
        minZ: 31.45,
        maxZ: 33.45
    });
});

on("PolyZone:OnEnter", (Poly: any) => {

    if (SharedStashes.includes(Poly.name)) {
        exp['fw-ui'].ShowInteraction('[E] Stash');
        StashThread.start();
        return;
    };

    if (PersonalStashes.includes(Poly.name)) {
        exp['fw-ui'].ShowInteraction('[E] Persoonlijke Stash');
        PersonalStashThread.start();
        return;
    };

    if (Shops.includes(Poly.name)) {
        exp['fw-ui'].ShowInteraction('[E] Winkel / [G] Medicijnenkast');
        ShopThread.start();
        return;
    };
});

on("PolyZone:OnExit", (Poly: any) => {
    if (SharedStashes.includes(Poly.name) || PersonalStashes.includes(Poly.name) || Shops.includes(Poly.name)) {
        exp['fw-ui'].HideInteraction();

        if (StashThread.running) StashThread.stop();
        if (PersonalStashThread.running) PersonalStashThread.stop();
        if (ShopThread.running) ShopThread.stop();
    };
});