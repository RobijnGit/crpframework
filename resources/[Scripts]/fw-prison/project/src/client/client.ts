import { Delay, exp } from "../shared/utils"
export const FW = exp['fw-core'].GetCoreObject();

import './tasks/main';
import './handlers/prison';
import './handlers/prison-break';
import './handlers/alarm';
import './handlers/kitchen';
import './handlers/garage';
import './handlers/cells';
import './job/main';

import InitZones from "./zones";

setImmediate(() => {
    InitZones();
})

on("fw-prison:Client:CheckCurrentInmates", async () => {
    const Inmates = await FW.SendCallback("fw-prison:Server:GetCurrentInmates")
    const Officers = await FW.SendCallback("fw-prison:Server:GetCurrentOfficers")
    await Delay(100);

    const MenuItems: any = [
        {
            Title: `Aanwezige Gevangenen`,
            Desc: Inmates.length == 0 ? "Alle gevangenen slapen.." : "",
            Disabled: Inmates.length == 0,
            SecondMenu: []
        },
        {
            Title: `Aanwezige Corrections Officers`,
            Desc: Officers.length == 0 ? "Momenteel geen Corrections Officer aanwezig!" : "",
            Disabled: Officers.length == 0,
            SecondMenu: []
        },
    ];

    for (let i = 0; i < Inmates.length; i++) {
        const Inmate = Inmates[i];
        
        MenuItems[0].SecondMenu.push({
            Title: `Inmate #${Inmate.Cid} (${Inmate.Name})`,
            Desc: `Tijd resterend: ${Inmate.TimeLeft}`
        });
    }

    for (let i = 0; i < Officers.length; i++) {
        const Officer = Officers[i];
        
        MenuItems[1].SecondMenu.push({
            Icon: "shield-alt",
            Title: Officer.Name,
            Desc: Officer.Grade
        });
    }

    FW.Functions.OpenMenu({ MainMenuItems: MenuItems });
});

on("fw-prison:Client:OpenPrisonCraft", () => {
    if (!exp['fw-inventory'].CanOpenInventory()) return;
    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Crafting', 'Prison');
});