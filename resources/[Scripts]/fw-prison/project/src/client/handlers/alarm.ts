import { Delay } from "../../shared/utils";
import { FW } from "../client";

on("fw-prison:Client:ToggleAlarm", ({State}: {State: boolean}) => {
    const PlayerData = FW.Functions.GetPlayerData();
    if ((PlayerData.job.name != "doc" && PlayerData.job.name != "police")) return;

    if (State) emitNet("fw-mdw:Server:SendAlert:PrisonLockdown");

    FW.TriggerServer("fw-prison:Server:SetAlarmState", State)
});

onNet("fw-prison:Client:SetAlarmState", async (State: boolean) => {
    if (!State) {
        StopAllAlarms(true);
        return;
    };

    while (!PrepareAlarm("PRISON_ALARMS")) {
        await Delay(10);
    };

    StartAlarm("PRISON_ALARMS", true);
})