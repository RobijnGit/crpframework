import { Delay, exp } from "../shared/utils"
import InitLobby from "./lobby/main";
export const FW = exp['fw-core'].GetCoreObject();

setImmediate(() => {
    InitLobby();

    FW.RegisterServer("fw-arcade:Server:RepairArcadeMachine", async (Source: number, Game: string) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;

        if (!await exp['fw-businesses'].HasPlayerBusinessPermission("Coopers Arcade", Source, "CraftAccess")) {
            return;
        };

        const {arcadeMachines, arcadeStats} = await exp['fw-config'].GetModuleConfig("bus-arcade", {
            arcadeMachines: false,
            arcadeStats: false
        });

        if (!arcadeMachines || !arcadeMachines[Game]) return;

        const RequiredMaterials = Math.floor(1200 - (1200 * (Math.floor(arcadeMachines[Game]) / 100)));
        if (RequiredMaterials <= 0) return Player.Functions.Notify("The arcade machine looks just fine!");
    
        if (!Player.Functions.HasEnoughOfItem("electronics", RequiredMaterials) || !Player.Functions.HasEnoughOfItem("plastic", RequiredMaterials)) {
            return Player.Functions.Notify("You don't have enough materials..", "error")
        };

        Player.Functions.RemoveItemByName("electronics", RequiredMaterials, true);
        Player.Functions.RemoveItemByName("plastic", RequiredMaterials, true);

        arcadeMachines[Game] = 100.0;
        arcadeStats[Game].lastRepair = new Date().getTime();

        exp['fw-config'].SetConfigValue("bus-arcade", "arcadeMachines", arcadeMachines);
        await Delay(1);
        exp['fw-config'].SetConfigValue("bus-arcade", "arcadeStats", arcadeStats);

        Player.Functions.Notify("Arcade machine repaired!", "success")
    });

    FW.Functions.CreateCallback("fw-arcade:Server:GetPlayerCharName", async (Source: number, Cb: Function, Cid: string) => {
        Cb(await FW.Functions.GetPlayerCharName(Cid))
    });
})

onNet("fw-arcade:Server:PurchaseToken", async (Data: {
    Payment: "Cash" | "Card",
    Amount: number
}) => {
    const Player = FW.Functions.GetPlayer(source);
    if (!Player) return;

    if (Data.Amount <= 0) {
        return Player.Functions.Notify("You need to purchase at least one token!", "error")
    }

    const BusinessAccount = await exp['fw-businesses'].GetBusinessAccount("Coopers Arcade");
    const BusinessOwner = await exp['fw-businesses'].GetBusinessOwner("Coopers Arcade");
    const {ticketPrice} = await exp['fw-config'].GetModuleConfig("bus-arcade", { ticketPrice: 299 });

    if (
        (Data.Payment == "Cash" && Player.Functions.RemoveMoney("cash", ticketPrice * Data.Amount)) ||
        (Data.Payment == "Card" && await exp['fw-financials'].RemoveMoneyFromAccount(BusinessOwner, BusinessAccount, Player.PlayerData.charinfo.account, ticketPrice * Data.Amount, 'PURCHASE', 'Arcade Token purchase.', false))
    ) {
        exp['fw-financials'].AddMoneyToAccount(Player.PlayerData.citizenid, Player.PlayerData.charinfo.account, BusinessAccount, ticketPrice * Data.Amount, "PURCHASE", `Payment for business services: Arcade Token purchase`, false)
        Player.Functions.AddItem("arcadetoken", Data.Amount, false, {
            purchaser: Player.PlayerData.citizenid,
            games: 3
        }, true, false)
    } else {
        Player.Functions.Notify("You don't have enough money..", "error")
    };
});

onNet("fw-arcade:Server:RevokeMembership", () => {

});