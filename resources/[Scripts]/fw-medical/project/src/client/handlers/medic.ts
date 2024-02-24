import { Thread } from "../../shared/classes/thread";
import { GetRandom, exp } from "../../shared/utils";
import { FW } from "../client";
import { LoadAnimDict } from "../utils";

const AnimThread = new Thread("tick", 2000);

AnimThread.addHook('preStart', async () => {
    emit("fw-emotes:Client:SetEmotesState", true);
    await LoadAnimDict("weapons@first_person@aim_rng@generic@projectile@thermal_charge@");
    TaskPlayAnim(PlayerPedId(), "weapons@first_person@aim_rng@generic@projectile@thermal_charge@", "plant_floor" ,3.0, 3.0, -1, 16, 0, false, false, false)
});

AnimThread.addHook('active', () => {
    TaskPlayAnim(PlayerPedId(), "weapons@first_person@aim_rng@generic@projectile@thermal_charge@", "plant_floor" ,3.0, 3.0, -1, 16, 0, false, false, false)
});

AnimThread.addHook('afterStop', () => {
    emit("fw-emotes:Client:SetEmotesState", false);
    StopAnimTask(PlayerPedId(), "weapons@first_person@aim_rng@generic@projectile@thermal_charge@", "plant_floor", 1.0);
});

setImmediate(() => {
    console.log("Job: medical initialized, registering job..")
});

const GetClosestPlayer = async () => {
    const [Player, Distance] = await FW.Functions.GetClosestPlayer();
    if (!Player || Player < 0 || Distance > 2.0 || IsPedInAnyVehicle(GetPlayerPed(GetPlayerFromServerId(Player)), false)) {
        FW.Functions.Notify("Geen speler gevonden..", "error")
        return [false, 0];
    };
    
    return [true, Player]
};

on("fw-medical:Client:Medic:Heal", async () => {
    const [ NearPlayer, PlayerId ] = await GetClosestPlayer();
    if (!NearPlayer) return;

    if (!exp['fw-inventory'].HasEnoughOfItem('medkit', 1)) return FW.Functions.Notify("Je mist een medkit..", "error");

    AnimThread.start();

    const Finished = await FW.Functions.CompactProgressbar(4000, "Burger verzorgen", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {}, {}, {}, false)

    AnimThread.stop();
    if (!Finished) return;

    FW.TriggerServer("fw-medical:Server:HealPlayer", PlayerId);
});

on("fw-medical:Client:Medic:Revive", async () => {
    const [ NearPlayer, PlayerId ] = await GetClosestPlayer();
    if (!NearPlayer) return;

    if (!exp['fw-inventory'].HasEnoughOfItem('medkit', 1)) return FW.Functions.Notify("Je mist een medkit..", "error");

    AnimThread.start();

    const Finished = await FW.Functions.CompactProgressbar(8000, "Burger reviven", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {}, {}, {}, false)

    AnimThread.stop();
    if (!Finished) return;

    FW.TriggerServer("fw-medical:Server:RevivePlayer", PlayerId)
});

onNet("fw-medical:Client:HealPlayer", async () => {
    SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()));
});

on("fw-medical:Client:Medic:TakeBlood", async () => {
    const [ NearPlayer, PlayerId ] = await GetClosestPlayer();
    if (!NearPlayer) return;

    TriggerEvent("fw-emotes:Client:PlayEmote", "phone2", false, true)

    const Finished = await FW.Functions.CompactProgressbar(GetRandom(8, 15) * 1000, "Bloed afnemen", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {}, {}, {}, false)

    if (!Finished) return;
    FW.TriggerServer("fw-medical:Server:TakeBlood", PlayerId)

    TriggerEvent("fw-emotes:Client:CancelEmote", true)
});

on("fw-medical:Client:Medic:TakeDNA", async () => {
    const [ NearPlayer, PlayerId ] = await GetClosestPlayer();
    if (!NearPlayer) return;

    TriggerEvent("fw-emotes:Client:PlayEmote", "phone2", false, true)

    const Finished = await FW.Functions.CompactProgressbar(GetRandom(8, 15) * 1000, "Speeksel afnemen", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {}, {}, {}, false)

    if (!Finished) return;
    FW.TriggerServer("fw-medical:Server:SwabDNA", PlayerId)

    TriggerEvent("fw-emotes:Client:CancelEmote", true)
});