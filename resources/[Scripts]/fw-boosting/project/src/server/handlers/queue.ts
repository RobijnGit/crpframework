import { Thread } from "../../shared/classes/thread";
import { MaxContractsAllowed } from "../../shared/config";
import { GetRandom, exp } from "../../shared/utils";
import { FW } from "../server";
import { Queuer } from "../types";
import { GenerateContractForCid, GetClassesFromExperience, GetPendingContractsByCid, GetRandomContractClass } from "./contracts";
import { GetBoostingDataByCid } from "./db";

export const QueueThread = new Thread("tick", (1000 * 10));
export let Queuers: Queuer[] = [];
let NextQueueGiveout: number;

import { ExpireThread } from './expire';

QueueThread.addHook("preStart", () => {
    ExpireThread.start();
    console.log(`[Boosting]: Queue Initiated.`)
});

QueueThread.addHook("active", async () => {
    if (NextQueueGiveout > new Date().getTime()) return;

    // Give a boost every 10-17 minutes.
    NextQueueGiveout = new Date().getTime() + ((GetRandom(10, 17) * 60) * 1000)

    for (let i = 0; i < Queuers.length; i++) {
        const Data = Queuers[i];

        const Player = FW.Functions.GetPlayerByCitizenId(Data.Cid);
        if (!Player) continue;

        const ContractsAmount = await GetPendingContractsByCid(Data.Cid);
        if (ContractsAmount >= MaxContractsAllowed) {
            continue
        }

        // Add contract
        const BoostData = await GetBoostingDataByCid(Data.Cid);
        if(!BoostData || typeof BoostData == "boolean") continue;

        const [CurrentClass, PreviousClass] = GetClassesFromExperience(BoostData.Experience, true);
        GenerateContractForCid(Data.Source, Data.Cid, [CurrentClass, PreviousClass])
    };
});

export const AddCidToQueue = async (Source: number, Cid: string) => {
    if (Queuers.findIndex((Val: Queuer) => Val.Cid == Cid) == -1) {
        const Job = exp['fw-jobmanager'].GetGroupByUser(Cid);
        if (Job != undefined) return false;

        emitNet("fw-jobmanager:Client:SignIn", Source, "boosting");

        setTimeout(() => {
            emitNet("fw-boosting:Client:CreateGroup", Source);
            setTimeout(() => {
                const Group = exp['fw-jobmanager'].GetGroupByUser(Cid);
                if (!Group) return false;

                Queuers.push({ Source, Cid, GroupId: Group.GroupId });
                return true;
            }, 500);
        }, 500);
    } else {
        return true
    };
};

export const RemoveCidFromQueue = (Source: number, Cid: string) => {
    const Index = Queuers.findIndex((Val: Queuer) => Val.Cid == Cid);
    if (Index == -1) return;
    Queuers.splice(Index, 1);

    const Job = exp['fw-jobmanager'].GetGroupByUser(Cid);
    if (Job?.JobId == "boosting") emitNet("fw-jobmanager:Client:SignOut", Source);
};

onNet("fw-jobmanager:Server:SignOut", (JobId: string, GroupId: number) => {
    if (JobId != 'boosting') return;

    const Source = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    RemoveCidFromQueue(Source, Player.PlayerData.citizenid);
});