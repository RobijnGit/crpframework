import { exp } from "../../../shared/utils";
import { FW } from "../../client";
import { currentLobby } from "../../lobby/utils";
import { currentMap } from "./base";

let loadoutCam: number;

export const DestroyLoadoutCam = () => {
    SetCamActive(loadoutCam, false);
    DestroyCam(loadoutCam, false);
    RenderScriptCams(false, false, 0, false, false);
};

export const OpenLoadoutMenu = (Respawn: boolean) => {
    if (Respawn) {
        loadoutCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true);
        SetCamCoord(loadoutCam, currentMap.Cam.x, currentMap.Cam.y, currentMap.Cam.z);
        SetCamRot(loadoutCam, -15.0, 0.0, currentMap.Cam.w, 0);
        SetCamActive(loadoutCam, true);
    
        RenderScriptCams(true, false, 0, false, false);
    }

    const LoadoutMenu: any = [
        {
            Title: "Loadout"
        },
        {
            Title: Respawn ? "Spawn" : "Terug naar spel",
            Data: {Event: "fw-arcade:Client:TDM:Spawn", Respawn}
        },
        {
            Title: "Verwijder huidige wapens",
            CloseMenu: false,
            Data: {Event: "fw-arcade:Server:TDM:RemoveLoadout" }
        }
    ];

    const Weapons: Array<{AmmoType: string, WeaponID: string}> = Object.values(exp['fw-weapons'].GetAllWeaponList());
    const WeaponTypes: {[key: string]: string} = {
        AMMO_PISTOL: "PISTOL Wapens",
        AMMO_REVOLVER: "REVOLVER Wapens",
        AMMO_SHOTGUN: "SHOTGUN Wapens",
        AMMO_RIFLE: "AR Wapens",
        AMMO_SMG: "SMG Wapens",
        AMMO_NONE: "MELEE Wapens",
        // AMMO_FIRE: "EXPLOSIVES Wapens",
        // AMMO_SNOWBALLLAUNCHER: "Sneeuw Wapens",
    };

    for (let i = 0; i < Weapons.length; i++) {
        const {AmmoType, WeaponID: WeaponId} = Weapons[i];
        if (!WeaponTypes[AmmoType]) continue;

        const ItemData = exp['fw-inventory'].GetItemData(WeaponId);
        if (!ItemData) continue;
        if (ItemData.Label.startsWith("(PD) ")) continue;

        const LoadoutIndex = LoadoutMenu.findIndex((Val: {Title: string}) => Val.Title == WeaponTypes[AmmoType]);
        if (LoadoutIndex == -1) {
            LoadoutMenu.push({
                Title: WeaponTypes[AmmoType],
                Desc: `Bekijk alle ${WeaponTypes[AmmoType].replace("Wapens", "wapens")}`,
                SecondMenu: [
                    {
                        Title: ItemData.Label,
                        CloseMenu: false,
                        Data: {Event: "fw-arcade:Server:TDM:GiveLoadout", Id: currentLobby, Weapon: WeaponId }
                    }
                ]
            })
        } else {
            LoadoutMenu[LoadoutIndex].SecondMenu.push({
                Title: ItemData.Label,
                CloseMenu: false,
                Data: {Event: "fw-arcade:Server:TDM:GiveLoadout", Id: currentLobby, Weapon: WeaponId }
            });
        }
    };

    FW.Functions.OpenMenu({
        MainMenuItems: LoadoutMenu,
        CloseEvent: {Event: "fw-arcade:Client:TDM:Spawn", Respawn}
    })
};

on("fw-arcade:Client:TDM:ChangeLoadout", () => {
    OpenLoadoutMenu(false)
});