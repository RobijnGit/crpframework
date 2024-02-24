import { BoostingContract } from "../../shared/types";
import { Queuer } from "../types"
import { ExperienceClasses } from "../../shared/config";
import { FW } from "../server";
import { GetClassesFromExperience, GetContractsByCid, TransferContract } from "./contracts";
import { GetBoostingDataByCid } from "./db";
import { AddCidToQueue, Queuers, RemoveCidFromQueue } from "./queue";
import { exp } from "../../shared/utils";
import { GetAuctionContracts } from "./auction";

export default () => {
    FW.Functions.CreateCallback("fw-boosting:Server:GetData", async (Source: number, Cb: Function) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;
    
        let BoostData = await GetBoostingDataByCid(Player.PlayerData.citizenid);
        const [CurrentClass, PreviousClass] = GetClassesFromExperience(BoostData.Experience);
    
        const CurrentIndex = ExperienceClasses.findIndex(Val => Val.Class == CurrentClass);
        const CurrentExperience = ExperienceClasses[CurrentIndex].Experience;
    
        const NextClass = ExperienceClasses[CurrentIndex + 1] ? ExperienceClasses[CurrentIndex + 1] : ExperienceClasses[CurrentIndex];
        const ProgressPercentage = (BoostData.Experience - CurrentExperience) / (NextClass.Experience - CurrentExperience) * 100;
    
        BoostData.Progress = {
            Current: CurrentClass,
            Previous: PreviousClass,
            Next: NextClass.Class,
            Progress: ProgressPercentage
        }
    
        BoostData.IsQueued = Queuers.findIndex((Val: Queuer) => Val.Cid == Player.PlayerData.citizenid) != -1;
        BoostData.Cid = Player.PlayerData.citizenid;
    
        Cb(BoostData);
    });
    
    FW.Functions.CreateCallback("fw-boosting:Server:SetQueue", async (Source: number, Cb: Function, State: boolean) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;
    
        if (State) {
            await AddCidToQueue(Source, Player.PlayerData.citizenid)
            Cb("Ok")
        } else {
            RemoveCidFromQueue(Source, Player.PlayerData.citizenid)
            Cb("Ok")
        };
    });
    
    FW.Functions.CreateCallback("fw-boosting:Server:GetContracts", async (Source: number, Cb: Function) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;
    
        const Retval = await GetContractsByCid(Player.PlayerData.citizenid);
        Cb(Retval);
    });
    
    FW.Functions.CreateCallback("fw-boosting:Server:TransferContract", async (Source: number, Cb: Function, Data: any) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;
    
        const Result: any = await TransferContract(Source, Data.target, Data.contract);
    
        Cb({
            data: Result,
            contracts: await GetContractsByCid(Player.PlayerData.citizenid)
        });
    });
    
    FW.Functions.CreateCallback("fw-boosting:Server:DeclineContract", async (Source: number, Cb: Function, Contract: BoostingContract) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;
    
        await exp['ghmattimysql'].executeSync("DELETE FROM laptop_boosting WHERE id = ?", [ Contract.Id ]);
    
        Cb({
            contracts: await GetContractsByCid(Player.PlayerData.citizenid)
        });
    });
    
    FW.Functions.CreateCallback("fw-boosting:Server:AuctionContract", async (Source: number, Cb: Function, Data: {bid: number, contract: BoostingContract}) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;
    
        await exp['ghmattimysql'].executeSync('UPDATE `laptop_boosting` SET `auction` = 1, `seller` = ?, `start_bid` = ?, `bid` = 0, `bidder` = "1001", `auction_end` = ? WHERE `id` = ?', [
            `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}`,
            Data.bid,
            new Date().getTime() + ((1000 * 60) * 30),
            Data.contract.Id
        ])
    
        emitNet("fw-boosting:Client:SetAuctions", -1, await GetAuctionContracts())
    
        Cb({
            contracts: await GetContractsByCid(Player.PlayerData.citizenid)
        });
    });
}