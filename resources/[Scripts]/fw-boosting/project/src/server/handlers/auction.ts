import { exp } from "../../shared/utils"
import { FW, ParseContracts } from "../server";
import { BoostingContract } from "../../shared/types";
import { AddCryptoToPlayer } from "./db";

export const GetAuctionContracts = async () => {
    const Result = await exp['ghmattimysql'].executeSync("SELECT * FROM `laptop_boosting` WHERE `auction` = 1 ORDER BY `expire` ASC");
    return await ParseContracts(Result)
};

export default () => {
    FW.Functions.CreateCallback("fw-boosting:Server:GetAuctionContracts", async (Source: number, Cb: Function) => {
        Cb(await GetAuctionContracts())
    })
    
    FW.Functions.CreateCallback("fw-boosting:Server:PlaceBid", async (Source: number, Cb: Function, Data: { bid: number, contract: BoostingContract}) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;
    
        if (Data.bid > 0 && !Player.Functions.RemoveCrypto(Data.contract.Crypto, Data.bid)) {
            return Cb({
                data: {
                    succes: false,
                    message: `Je hebt niet genoeg ${Data.contract.Crypto} voor dit bod!`
                }
            });
        };
    
        const Result = await exp['ghmattimysql'].executeSync("SELECT * FROM `laptop_boosting` WHERE `id` = ?", [
            Data.contract.Id
        ]);
    
        if (!Result[0]) {
            Player.Functions.AddCrypto(Data.contract.Crypto, Data.bid);
            return Cb({
                data: {
                    success: false,
                    message: "Er is iets misgegaan, probeer het later nog eens!"
                }
            });
        };
    
        // "Refund" the crypto to the previous bidder, they have been outbid.
        AddCryptoToPlayer(Result[0].bidder, Data.contract.Crypto, Result[0].bid);
    
        const PreviousBidder = FW.Functions.GetPlayerByCitizenId(Result[0].bidder);
        if (PreviousBidder) {
            emitNet("fw-phone:Client:Notification", PreviousBidder.PlayerData.source, `boosting-auction-${Data.contract.Id}`, 'fas fa-gavel', [ 'white', '#1c305c' ], "Overboden", `${Result[0].bid} ${Data.contract.Crypto} is teruggestort in je wallet.`)
        }
    
        await exp['ghmattimysql'].executeSync("UPDATE `laptop_boosting` SET `bid` = ?, `bidder` = ?, `auction_end` = `auction_end` + ? WHERE `id` = ?", [
            Data.bid,
            Player.PlayerData.citizenid,
            Result[0].auction_end - new Date().getTime() < 30 ? 30 * 1000 : 0,
            Data.contract.Id
        ]);
    
        emitNet("fw-boosting:Client:SetAuctions", -1, await GetAuctionContracts());
    
        Cb({
            data: {
                success: true,
                message: "Bod geplaatst!"
            }
        });
    })
}