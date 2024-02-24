import { Delay, exp } from "../../shared/utils";
import { FW, GetCurrentClock } from "../client";
import { HasRolePermission, IsBusinessOnLockdown, IsPlayerInBusiness } from "../utils";

onNet("fw-businesses:Client:Electronics:Counter", (Data: {Type: string}) => {
    if (exp['fw-inventory'].CanOpenInventory()) {
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `${Data.Type}_counter`, 10, 200)
    }
});

onNet("fw-businesses:Client:Electronics:Storage", async (Data: {
    Business: string;
    Type: string;
}) => {
    if (!await HasRolePermission(Data.Business, "StashAccess")) return;

    if (await IsBusinessOnLockdown(Data.Business)) {
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error");
    };

    if (exp['fw-inventory'].CanOpenInventory()) {
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `${Data.Type}_stash`, 40, 2000)
    }
});

onNet("fw-businesses:Client:Electronics:Craft", async (Data: {
    Business: string;
    Type: string;
}) => {
    if (!await HasRolePermission(Data.Business, "CraftAccess")) return;

    if (await IsBusinessOnLockdown(Data.Business)) {
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error");
    };

    if (exp['fw-inventory'].CanOpenInventory()) {
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Crafting', Data.Type)
    };
});

onNet("fw-businesses:Client:Electronics:Scrap", async (Data: {
    Business: string;
    Type: string;
}) => {
    if (!exp['fw-inventory'].CanOpenInventory()) return;
    if (!await HasRolePermission(Data.Business, "CraftAccess")) return;

    if (await IsBusinessOnLockdown(Data.Business)) {
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error");
    };

    const Result = await FW.SendCallback("fw-businesses:Server:Electronics:GetScrapItems", Data.Business);
    if (!Result || Result.length == 0) return FW.Functions.Notify("Je hebt geen electronica opzak..", "error");

    let ContextItems = [];
    for (let i = 0; i < Result.length; i++) {
        const {Label, Slot, Parts, Materials} = Result[i];

        ContextItems.push({
            Title: Label,
            Desc: `Slot ${Slot}`,
            SecondMenu: [
                {
                    Title: `<div style="display: flex; justify-content: space-between"><span>Scrappen</span><span>▨ ${Parts}</span></div>`,
                    Icon: "hammer",
                    Data: {
                        Event: "fw-businesses:Server:Electronics:ScrapElectronic",
                        Type: "Server",
                        Business: Data.Business,
                        Parts, Slot
                    }
                },
                {
                    Disabled: Materials < 40,
                    Title: Materials < 40 ? "Repareren" : `Repareren (${Materials} electronica)`,
                    Desc: Materials < 40 ? `De ${Label.toLowerCase()} doet het nog..` : false,
                    Icon: "wrench",
                    Data: {
                        Event: "fw-businesses:Server:Electronics:RepairElectronic",
                        Type: "Server",
                        Business: Data.Business,
                        Materials, Slot
                    }
                }
            ]
        })
    };

    FW.Functions.OpenMenu({MainMenuItems: ContextItems})
});

onNet("fw-businesses:Client:Electronics:AddMusicEntry", async (Data: {
    Business: string;
}) => {
    if (!await HasRolePermission(Data.Business, 'CraftAccess')) return;

    if (await IsBusinessOnLockdown(Data.Business)) {
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error");
    };

    const Result = await exp['fw-ui'].CreateInput([
        { Label: 'SoundCloud Track Id (e.g: 1242868615)', Name: 'TapeId', Type: 'number' },
        { Label: 'Artiest', Icon: 'fas fa-user-music', Name: 'Artist' },
        { Label: 'Titel', Icon: 'fas fa-user-edit', Name: 'Title' },
    ]);

    if (!Result) return;
    if (Result.TapeId.trim().length === 0 || Result.TapeId == '') return;
    if (Result.Artist.trim().length === 0 || Result.Artist == '') return;
    if (Result.Title.trim().length === 0 || Result.Title == '') return;

    FW.TriggerServer("fw-businesses:Server:Electronics:AddMusicEntry", {Business: Data.Business, ...Result})
});

onNet("fw-businesses:Client:Electronics:ManageMusicEntries", async (Data: {
    Business: string;
}) => {
    if (!await HasRolePermission(Data.Business, 'CraftAccess')) return;

    if (await IsBusinessOnLockdown(Data.Business)) {
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error");
    };

    const Tapes = await FW.SendCallback("fw-businesses:Server:Electronics:GetMusicEntries")
    if (Tapes.length === 0) return FW.Functions.Notify("Geen tracks gevonden..", "error");

    const ContextItems = [];

    for (let i = 0; i < Tapes.length; i++) {
        const TapeData = Tapes[i];

        ContextItems.push({
            Title: `(${TapeData.id}) ${TapeData.tape_title}`,
            Desc: `Track Id: ${TapeData.tape_id}; Artist: ${TapeData.tape_artist}`,
            SecondMenu: [
                {
                    Icon: "trash",
                    Title: "Track Verwijderen",
                    Data: {
                        Event: "fw-businesses:Server:Electronics:RemoveMusicEntry",
                        Type: "Server",
                        TrackId: TapeData.id,
                        Business: Data.Business,
                    }
                }
            ]
        })
    }

    FW.Functions.OpenMenu({MainMenuItems: ContextItems, Width: "35vh"})
});

onNet("fw-businesses:Client:Electronics:CreateMusicTape", async (Data: {
    Business: string;
}) => {
    if (!await HasRolePermission(Data.Business, 'CraftAccess')) return;

    if (await IsBusinessOnLockdown(Data.Business)) {
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error");
    };

    const Tapes = await FW.SendCallback("fw-businesses:Server:Electronics:GetMusicEntries")
    if (Tapes.length === 0) return FW.Functions.Notify("Geen tracks gevonden..", "error");

    const Tracks = Tapes.map(({id, tape_artist, tape_title}: {[key: string]: any}) => {
        return { Text: `${tape_artist} - ${tape_title}`, Value: id }
    });

    const Result = await exp['fw-ui'].CreateInput([
        { Label: 'Track', Name: 'TrackId', Choices: Tracks },
        { Label: 'Aantal', Name: 'Copies', Type: "number" },
    ]);

    if (!Result) return;
    if (Result.TrackId === '') return;
    if (Result.Copies == 0 || Result.Copies == '' || Number(Result.Copies) <= 0) return;

    const Duration = 1500 * Number(Result.Copies)
    const Success = await FW.Functions.CompactProgressbar(Duration, 'Cassettebandjes maken...', false, true, { disableMovement: true, disableCarMovement: true, disableMouse: false, disableCombat: true }, { animDict: "anim@amb@business@coc@coc_unpack_cut@", anim: "fullcut_cycle_v6_cokecutter", flags: 0 }, {}, {}, false)
    StopAnimTask(PlayerPedId(), "anim@amb@business@coc@coc_unpack_cut@", "fullcut_cycle_v6_cokecutter", 1.0)
    if (!Success) return;

    FW.TriggerServer("fw-businesses:Server:Electronics:CreateCassetteTapes", {Business: Data.Business, ...Result})
})

// zones
onNet("fw-config:configLoaded", (pConfig: string) => {
    if (!exp['fw-config'].IsConfigReady() || pConfig != "bus-electronics") return;
    loadElectronicsZone();
});

onNet("fw-config:configReady", () => {
    loadElectronicsZone();
});

const loadElectronicsZone = async () => {
    while (!exp['fw-config'].IsConfigReady()) {
        await Delay(100);
    };

    const {zones} = await exp['fw-config'].GetModuleConfig("bus-electronics");

    for (let i = 0; i < zones.length; i++) {
        const ZoneData = zones[i];
        let options: any[] = [];

        if (ZoneData.options.includes("stash")) {
            options.push({
                Name: 'stash',
                Icon: 'fas fa-box-open',
                Label: 'Stash',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Electronics:Storage',
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
                EventName: 'fw-businesses:Client:Electronics:Craft',
                EventParams: ZoneData.data,
                Enabled: () => {
                    const {Business, ClockedIn} = GetCurrentClock();
                    return ClockedIn && Business === ZoneData.data.Business;
                },
            })
        };

        if (ZoneData.options.includes("scrap")) {
            options.push({
                Name: 'scrap',
                Icon: 'fas fa-hammer',
                Label: 'Scrap en repareren',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Electronics:Scrap',
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
                EventName: 'fw-businesses:Client:Electronics:Counter',
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

        if (ZoneData.options.includes("addMusic")) {
            options.push({
                Name: 'addMusicEntry',
                Icon: 'fas fa-music',
                Label: 'Muziek Toevoegen',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Electronics:AddMusicEntry',
                EventParams: { ...ZoneData.data, ClockedIn: true },
                Enabled: async () => {
                    const {Business, ClockedIn} = GetCurrentClock();
                    return ClockedIn && Business === ZoneData.data.Business;
                },
            })
        };

        if (ZoneData.options.includes("manageMusic")) {
            options.push({
                Name: 'manageMusicEntry',
                Icon: 'fas fa-list',
                Label: 'Muziek Beheren',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Electronics:ManageMusicEntries',
                EventParams: { ...ZoneData.data, ClockedIn: true },
                Enabled: async () => {
                    const {Business, ClockedIn} = GetCurrentClock();
                    return ClockedIn && Business === ZoneData.data.Business;
                },
            })
        };

        if (ZoneData.options.includes("createTape")) {
            options.push({
                Name: 'tape',
                Icon: 'fas fa-play-circle',
                Label: 'Maak Cassettabandje',
                EventType: 'Client',
                EventName: 'fw-businesses:Client:Electronics:CreateMusicTape',
                EventParams: { ...ZoneData.data, ClockedIn: true },
                Enabled: async () => {
                    const {Business, ClockedIn} = GetCurrentClock();
                    return ClockedIn && Business === ZoneData.data.Business;
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