import { GetRandom } from "../../shared/utils";
import { FW } from "../client";
import { ReduceJailTime } from "./main";
import { PrisonTask } from "./task";

const Kitchen = new PrisonTask("Kitchen", "Keuken", "Sorteer de keuken en poets de tafels.");

Kitchen.addTask("SortKitchen", async () => {
    const Finished = await FW.Functions.CompactProgressbar(20000, "Sorteren", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {
        animDict: "missexile3", anim: "ex03_dingy_search_case_a_michael", flags: 8
    }, {}, {}, false);

    StopAnimTask(PlayerPedId(), "missexile3", "ex03_dingy_search_case_a_michael", 1.0);
    if (!Finished) return;

    FW.TriggerServer("fw-prison:Server:TaskReward", GetRandom(6, 13));
    ReduceJailTime(4);
});

Kitchen.addTask("CleanTable", async () => {
    const Finished = await FW.Functions.CompactProgressbar(10000, "Tafel schoonmaken...", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {
        animDict: "timetable@maid@cleaning_surface@base", anim: "base", flags: 8
    }, {}, {}, false);

    StopAnimTask(PlayerPedId(), "timetable@maid@cleaning_surface@base", "base", 1.0);
    if (!Finished) return;

    FW.TriggerServer("fw-prison:Server:TaskReward", GetRandom(3, 6));

    ReduceJailTime(2);
});