import { SendUIMessage, exp } from "../../shared/utils"
import { FW } from "../client";
import { StartBoostContract } from "./boost";

const SetContracts = (Contracts: any[]) => {
    SendUIMessage("Boosting/SetContracts", Contracts)
};

export const GetData = async (Data: any) => {
    const Result = await FW.SendCallback("fw-boosting:Server:GetData");
    return Result;
};

export const GetContracts = async (Data: any) => {
    const Result = await FW.SendCallback("fw-boosting:Server:GetContracts")
    return Result;
};

export const GetAuctions = async (Data: any) => {
    const Result = await FW.SendCallback("fw-boosting:Server:GetAuctionContracts")
    return Result;
};

export const SetQueue = async (Data: any) => {
    const Result = await FW.SendCallback("fw-boosting:Server:SetQueue", Data.State);
    return Result;
};

export const StartContract = async (Data: any) => {
    const Result = await StartBoostContract(Data);
    return Result;
};

export const DeclineContract = async (Data: any) => {
    const Result = await FW.SendCallback("fw-boosting:Server:DeclineContract", Data.contract);

    setTimeout(() => {
        SetContracts(Result.contracts);
    }, 100);

    return { success: true, message: "Contract geweigerd!" };
};

export const CancelContract = async (Data: any) => {
    const Result = await FW.SendCallback("fw-boosting:Server:CancelContract", Data.contract);

    setTimeout(() => {
        SetContracts(Result.contracts);
    }, 100);

    return { success: true, message: "Contract geannuleerd, je inkoop is gerefund!" };
};

export const AuctionContract = async (Data: any) => {
    const Result = await FW.SendCallback("fw-boosting:Server:AuctionContract", Data);

    setTimeout(() => {
        SetContracts(Result.contracts);
    }, 100);

    return { success: true, message: "Contract succesvol op de veiling aangeboden!" };
};

export const TransferContract = async (Data: any) => {
    const Result = await FW.SendCallback("fw-boosting:Server:TransferContract", Data)

    setTimeout(() => {
        SetContracts(Result.contracts);
    }, 100);

    return Result.data;
};

export const PlaceBid = async (Data: any) => {
    const Result = await FW.SendCallback("fw-boosting:Server:PlaceBid", Data)
    return Result.data;
};

onNet("fw-boosting:Client:SetAuctions", (Auctions: any[]) => {
    SendUIMessage("Boosting/SetAuctions", Auctions)
});

onNet("fw-boosting:Client:SetData", (Data: any[]) => {
    SendUIMessage("Boosting/SetUserData", Data)
});

exp("GetData", GetData);
exp("GetContracts", GetContracts);
exp("GetAuctions", GetAuctions);
exp("SetQueue", SetQueue);
exp("StartContract", StartContract);
exp("DeclineContract", DeclineContract);
exp("CancelContract", CancelContract);
exp("AuctionContract", AuctionContract);
exp("TransferContract", TransferContract);
exp("PlaceBid", PlaceBid);