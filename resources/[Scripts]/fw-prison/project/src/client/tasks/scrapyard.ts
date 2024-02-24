import { Vector3Format } from "../../shared/classes/math";
import { Delay, GetRandom } from "../../shared/utils";
import { FW } from "../client";
import { ReduceJailTime } from "./main";
import { PrisonTask } from "./task";

const Scrapyard = new PrisonTask("Scrapyard", "Scrapyard", "Sorteer troep en stapel stenen.");
let HasScrap: boolean = false;
let TaskBlip: number = 0;

Scrapyard.addTask("StackBricks", async () => {
    TaskStartScenarioInPlace(PlayerPedId(), "CODE_HUMAN_MEDIC_TIME_OF_DEATH", 0, true)
    const Finished = await FW.Functions.CompactProgressbar(20000, "Tellen...", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {}, {}, {}, false);

    ClearPedTasks(PlayerPedId())
    if (!Finished) return;

    FW.TriggerServer("fw-prison:Server:TaskReward", GetRandom(3, 7));

    ReduceJailTime(2);
});

Scrapyard.addTask("SortScrap", async () => {
    if (HasScrap) return FW.Functions.Notify("Je hebt al een doos met troep..", "error");

    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_CONST_DRILL", 0, true)
    const Finished = await FW.Functions.CompactProgressbar(20000, "Troep sorteren...", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {}, {}, {}, false);

    ClearPedTasks(PlayerPedId());
    if (!Finished) return;

    FW.Functions.Notify("Je hebt een doos gevuld met troep, breng deze naar het afleverpunt.");
    CreateTaskBlip(50, 16, 'Afleverpunt', {x: 1720.44, y: 2566.67, z: 45.55});
    TriggerEvent('fw-emotes:Client:PlayEmote', "box", null, true)
    HasScrap = true;

    // if (Math.random() == 0.01) {
    //     FW.Functions.Notify("Je vondt een gek telefoontje..", "error")
    // };
});

Scrapyard.addTask("DeliverScrap", async () => {
    if (!HasScrap) return FW.Functions.Notify("Je hebt wel echt veel troep man..", "error");

    TriggerEvent("fw-emotes:Client:CancelEmote", true)
    await Delay(100);
    TriggerEvent('fw-emotes:Client:PlayEmote', "clipboard", null, true)
    const Finished = await FW.Functions.CompactProgressbar(10000, "Doos met materialen inleveren...", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {}, {}, {}, false);

    TriggerEvent("fw-emotes:Client:CancelEmote", true)
    if (!Finished) return;

    HasScrap = false;

    FW.TriggerServer("fw-prison:Server:TaskReward", GetRandom(10, 15));

    ReduceJailTime(4);
    if (DoesBlipExist(TaskBlip)) RemoveBlip(TaskBlip);
});

const CreateTaskBlip = (Sprite: number, Color: number, Text: string, Coords: Vector3Format) => {
    if (DoesBlipExist(TaskBlip)) RemoveBlip(TaskBlip);
    TaskBlip = AddBlipForCoord(Coords.x, Coords.y, Coords.z)
    SetBlipSprite(TaskBlip, Sprite)
    SetBlipColour(TaskBlip, Color)
    SetBlipScale(TaskBlip, 0.7)
    SetBlipAsShortRange(TaskBlip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Text)
    EndTextCommandSetBlipName(TaskBlip)
}