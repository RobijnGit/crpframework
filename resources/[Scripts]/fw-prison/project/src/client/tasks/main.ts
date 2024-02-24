import type { PrisonTask } from "../types.d"
import { Delay, exp } from "../../shared/utils"
import { FW } from "../client";
import { PrisonTasks } from "./task";
import { InJail } from "../handlers/prison";

import './kitchen';
import './scrapyard';

let CurrentTask: false | PrisonTask = false;

export const IsDoingPrisonTask = () => {
    return CurrentTask;
};

export const GetCurrentTask = () => {
    return CurrentTask;
};
exp("IsDoingPrisonTask", IsDoingPrisonTask);

export const ResetTaskData = () => {
    CurrentTask = false;
    FW.TriggerServer("fw-prison:Server:SetCurrentTask", false)
};

export const ReduceJailTime = (Time: number) => {
    if (!InJail) return;
    if (Math.random() > 0.75) return;

    const JailTime: number = FW.Functions.GetPlayerData().metadata.jailtime
    if (JailTime - Time > 1) {
        FW.Functions.Notify(`Strafvermindering ontvangen. ${JailTime - Time} maand(en) resterend.`, null, 7000);
        FW.TriggerServer('fw-prison:Server:ReduceJailTime', Time)
    };
};

onNet("fw-prison:Client:ChangeTask", () => {
    const MenuItems = [];

    for (let i = 0; i < PrisonTasks.length; i++) {
        const Data = PrisonTasks[i];

        MenuItems.push({
            Icon: 'list-alt',
            Title: Data[1],
            Desc: Data[2],
            Data: {
                Event: "fw-prison:Client:SetCurrentTask",
                Type: "Client",
                Task: Data[0],
            }
        });
    };

    FW.Functions.OpenMenu({ MainMenuItems: MenuItems, Width: '35vh' });
});

onNet("fw-prison:Client:SetCurrentTask", ({Task}: {Task: string}) => {
    const TaskData = PrisonTasks[PrisonTasks.findIndex((Val: [string, string, string, any]) => Val[0] == Task)];
    if (!TaskData) return;

    TaskData[3].startJob();

    CurrentTask = { Task };
    FW.TriggerServer("fw-prison:Server:SetCurrentTask", TaskData[1])
});

onNet("fw-prison:Client:DoPrisonTask", ({Task, Job}: {Task: string, Job: string}) => {
    const TaskData = PrisonTasks[PrisonTasks.findIndex((Val: [string, string, string, any]) => Val[0] == Task)];
    if (!TaskData) return;

    TaskData[3].setTask(Job);
});

onNet("fw-prison:Client:ShowCurrentTask", async () => {
    if (!CurrentTask || !CurrentTask.Task) return;

    // @ts-ignore
    const TaskIndex = PrisonTasks.findIndex((Val: [string, string, string, any]) => Val[0] == CurrentTask.Task);
    if (!TaskIndex) return;

    exp['fw-ui'].ShowInteraction(`${PrisonTasks[TaskIndex][1]} - ${PrisonTasks[TaskIndex][2]}`);
    await Delay(5000)
    exp['fw-ui'].HideInteraction();
});