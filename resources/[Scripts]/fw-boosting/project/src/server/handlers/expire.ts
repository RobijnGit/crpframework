import { Thread } from "../../shared/classes/thread";
import { exp } from "../../shared/utils";
import { FW } from "../server";
import { GetAuctionContracts } from "./auction";
import { AddCryptoToPlayer } from "./db";

export const ExpireThread = new Thread("tick", (1000 * 60) * 1);

ExpireThread.addHook("active", async () => {
    const CurrentTime = new Date().getTime();

    // Delete expired contacts
    await exp['ghmattimysql'].executeSync("DELETE FROM `laptop_boosting` WHERE `started` = 0 and `expire` < ?", [
        CurrentTime
    ]);

    // Update expired auctions
    const FinishedAuctions = await exp['ghmattimysql'].executeSync("SELECT * FROM `laptop_boosting` WHERE `auction` = 1 AND `bid` > 0 AND `auction_end` < ?", [
        CurrentTime
    ]);

    for (let i = 0; i < FinishedAuctions.length; i++) {
        const Data = FinishedAuctions[i];

        if (Data.bidder == '1001') {
            await exp['ghmattimysql'].executeSync("UPDATE `laptop_boosting` SET `auction` = 0, `auction_end` = 0, `bid` = 0, `bidder` = '1001' WHERE `id` = ?", [Data.id])
            continue;
        };

        AddCryptoToPlayer(Data.cid, 'GNE', Data.bid);

        const PreviousBidder = FW.Functions.GetPlayerByCitizenId(Data.bidder);
        if (PreviousBidder) {
            emitNet("fw-phone:Client:Notification", PreviousBidder.PlayerData.source, `boosting-auction-${Data.id}`, 'fas fa-gavel', [ 'white', '#1c305c' ], "Veiling gewonnen", `${FW.Shared.HashVehicles[GetHashKey(Data.vehicle)].Name} voor ${Data.bid} GNE.`)
        };

        await exp['ghmattimysql'].executeSync("UPDATE `laptop_boosting` SET `cid` = ?, `auction` = 0, `auction_end` = 0, `bid` = 0, `bidder` = '1001' WHERE `id` = ?", [Data.bidder, Data.id])
    };

    await exp['ghmattimysql'].executeSync("UPDATE `laptop_boosting` SET `auction` = 0, `auction_end` = 0, `bid` = 0, `bidder` = '1001' WHERE `auction` = 1 AND `auction_end` < ?", [CurrentTime])
    emitNet("fw-boosting:Client:SetAuctions", -1, await GetAuctionContracts());
});
