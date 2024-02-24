import { FW } from "../client";

export const IsDoc =() => {
    const PlayerData = FW.Functions.GetPlayerData();
    if (PlayerData.job.name != 'doc' || !PlayerData.job.onduty) return false;
    return true
}

export const GetClosestPlayer = async () => {
    const [Player, Distance] = await FW.Functions.GetClosestPlayer();
    if (!Player || Player < 0 || Distance > 2.0 || IsPedInAnyVehicle(GetPlayerPed(GetPlayerFromServerId(Player)), false)) {
        FW.Functions.Notify("Geen speler gevonden..", "error")
        return [false, 0];
    };
    
    return [true, Player]
};

on("fw-prison:Client:OpenDOCActions", () => {
    if (!IsDoc()) return;

    const MenuItems = [];

    MenuItems.push({
        Icon: 'box-open',
        Title: 'Persoonlijke Stash',
        Desc: 'Voor je persoonlijke spullen.',
        Data: { Event: "fw-prison:Client:PersonalStash", Type: "Client" }
    });

    MenuItems.push({
        Icon: 'trash',
        Title: 'Prullenbak',
        Desc: 'Gooi jezelf er maar in, hier hoor je thuis.',
        Data: { Event: "fw-prison:Client:Trash", Type: "Client" }
    });

    MenuItems.push({
        Icon: 'shield-alt',
        Title: 'Wapenkluis',
        Desc: 'Voor je wapens en andere benodigdheden.',
        Data: { Event: "fw-prison:Client:Armory", Type: "Client" }
    });

    FW.Functions.OpenMenu({ MainMenuItems: MenuItems, Width: '35vh' });
});

on("fw-prison:Client:PersonalStash", () => {
    if (!IsDoc()) return;
    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `doc-storage-${FW.Functions.GetPlayerData().citizenid}`, 30, 300)
});

on("fw-prison:Client:Trash", () => {
    if (!IsDoc()) return;
    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `temp-doc-trash`, 50, 300)
});

on("fw-prison:Client:Armory", () => {
    if (!IsDoc()) return;
    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Store', 'DocArmory')
});

on("fw-prison:Client:CheckInmateInformation", async () => {
    if (!IsDoc()) return;

    const [ NearPlayer, PlayerId ] = await GetClosestPlayer();
    if (!NearPlayer) return;
    
    const InmateData = await FW.SendCallback("fw-prison:Server:GetInmateData", PlayerId)
    const MenuItems = [];

    MenuItems.push({
        Icon: 'info-circle',
        Title: 'Gevangenen Informatie',
    });

    MenuItems.push({
        Title: `Inmate #${InmateData.citizenid}`,
        Desc: InmateData.metadata.islifer ? 'Tijd resterend: levenslang' : `Tijd resterend: ${InmateData.metadata.jailtime} maand(en)`,
    });

    MenuItems.push({
        Title: `Voorwaardelijk: ${InmateData.metadata.paroletime} maand(en)`,
        Desc: "Voorwaardelijke straf telt af na celstraf."
    });

    MenuItems.push({
        Title: `Huidige Taak`,
        Desc: InmateData.CurrentTask ? InmateData.CurrentTask : "Geen actieve taak."
    });

    FW.Functions.OpenMenu({ MainMenuItems: MenuItems });
});

export default () => {

};