import { NumberWithCommas, exp } from "../shared/utils"
export const FW = exp['fw-core'].GetCoreObject();
import initBusiness, { ClockedPlayers } from './business';

import initUtils, { GetBusinessByName, HasPlayerBusinessPermission } from "./utils";
initUtils();

setImmediate(() => {
    initBusiness()
});

FW.Functions.CreateCallback("fw-businesses:Server:PayExternal", async (Source: number, Cb: Function, BusinessName: string, Cid: string, Amount: number, Comment: string) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Business = await GetBusinessByName(BusinessName);
    if (!Business) return Cb({Success: false, Msg: "Ongeldige bedrijf."});

    if (!HasPlayerBusinessPermission(BusinessName, Source, "PayExternal")) {
        return Cb({Success: false, Msg: "Geen toegang."});
    };

    if (!Business.business_account) {
        return Cb({Success: false, Msg: "Geen bankrekening gekoppeld aan bedrijf."});
    };

    const Result = await exp['ghmattimysql'].executeSync("SELECT `citizenid`, `charinfo` FROM `players` WHERE `citizenid` = ?", [ Cid ]);
    if (!Result[0]) return Cb({ Success: false, Msg: "Ongeldige speler." });

    const CharInfo = JSON.parse(Result[0].charinfo);

    if (await exp['fw-financials'].RemoveMoneyFromAccount(Cid, CharInfo.account, Business.business_account, Number(Amount), 'PAY', `Pay External: ${Comment || "Geen commentaar."}`, false)) {
        exp['fw-financials'].AddMoneyToAccount(Cid, Player.PlayerData.charinfo.account, CharInfo.account, Number(Amount), 'PAY', `Pay External: ${Comment || "Geen commentaar."}`);
        return Cb({ Success: true })
    } else {
        Cb({ Success: false, Msg: "Niet genoeg balans op bedrijfsrekening." })
    };
});

FW.Functions.CreateCallback("fw-businesses:Server:ChargeCustomer", async (Source: number, Cb: Function, BusinessName: string, Cid: string, Amount: number, Comment: string) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Business = await GetBusinessByName(BusinessName);
    if (!Business) return Cb({Success: false, Msg: "Ongeldige bedrijf."});

    if (!HasPlayerBusinessPermission(BusinessName, Source, "ChargeExternal")) {
        return Cb({Success: false, Msg: "Geen toegang."});
    };

    if (!Business.business_account) {
        return Cb({Success: false, Msg: "Geen bankrekening gekoppeld aan bedrijf."});
    };

    const Target = FW.Functions.GetPlayerByCitizenId(Cid);
    if (!Target) return Cb({Success: false, Msg: "Ongeldige speler."});

    const TaxIncluded = FW.Shared.CalculateTax("Services", Number(Amount));
    emitNet("fw-phone:Client:Notification", Target.PlayerData.source, `charge-customer-${Cid}`, "fas fa-donate", [ "white", "rgb(38, 50, 56)" ], "Zakelijke Facturatie", `${NumberWithCommas(Number(TaxIncluded))} - ${BusinessName} - ${Comment || "Geen commentaar."}`, false, true, "fw-businesses:Server:AcceptCharge", "fw-businesses:Server:RejectCharge", { Id: `charge-customer-${Cid}`, Account: Business.business_account, Cid: Cid, Charger: Source, Business: BusinessName, Amount: Number(Amount), Comment: Comment || "Geen commentaar." });

    Cb({Success: true})
});

FW.Functions.CreateCallback("fw-businesses:Server:GetClockedInEmployees", (Source: number, Cb: Function, BusinessName: string) => {
    let Retval = [];

    for (const [pId, clockData] of Object.entries(ClockedPlayers)) {
        if (clockData.ClockedIn && clockData.Business == BusinessName) {
            const Player = FW.Functions.GetPlayer(Source);
            if (Player) {
                Retval.push({
                    Cid: Player.PlayerData.citizenid,
                    Name: `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}`,
                    TimeClockedIn: GetGameTimer() - clockData.ClockInTime
                })
            }
        }
    };

    Cb(Retval);
});

onNet("fw-businesses:Server:AcceptCharge", async (Data: {
    Id: string;
    Account: string;
    Cid: string;
    Charger: number,
    Business: string;
    Amount: number;
    Comment: string;
}) => {
    const Source = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Charger = FW.Functions.GetPlayer(Data.Charger);
    if (!Charger) return;

    const TaxIncluded = FW.Shared.CalculateTax("Services", Data.Amount);

    if (await exp['fw-financials'].RemoveMoneyFromAccount(Charger.PlayerData.citizenid, Data.Account, Player.PlayerData.charinfo.account, TaxIncluded, 'PURCHASE', `Betaling zakelijke dienstverlening: ${Data.Comment}`, false)) {
        exp['fw-financials'].AddMoneyToAccount(Player.PlayerData.citizenid, Player.PlayerData.charinfo.account, Data.Account, Data.Amount, 'PURCHASE', `Betaling zakelijke dienstverlening: ${Data.Comment}`);
        emitNet('fw-phone:Client:Notification', Data.Charger, `business-charge-${Data.Cid}`, "fas fa-home", [ "white" , "rgb(38, 50, 56)" ], "Zakelijke Facturatie", "Betaling Voltooid!");
        emitNet('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Betaling Voltooid!", true);
        exp['fw-financials'].AddMoneyToAccount("1001", "1", "1", TaxIncluded - Data.Amount, 'TAX', `${Data.Business} facturatie betaald: ${Data.Comment}`);
    } else {
        emitNet('fw-phone:Client:Notification', Data.Charger, `business-charge-${Data.Cid}`, "fas fa-home", [ "white" , "rgb(38, 50, 56)" ], "Zakelijke Facturatie", "Betaling Geweigerd!");
        emitNet('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Betaling Geweigerd!", true);
    };
});

onNet("fw-businesses:Server:RejectCharge", (Data: {
    Id: string;
    Cid: string;
    Charger: number,
}) => {
    const Source = source;
    emitNet('fw-phone:Client:Notification', Data.Charger, `business-charge-${Data.Cid}`, "fas fa-home", [ "white" , "rgb(38, 50, 56)" ], "Zakelijke Facturatie", "Betaling Geweigerd!");
    emitNet('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Betaling Geweigerd!", true);
});

onNet("fw-businesses:Server:CreateBusiness", async (Data: {
    BusinessOwner: string;
    BusinessName: string;
    BusinessAccount: string;
}) => {
    const Source = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (Player.PlayerData.job.name != "judge" && Player.PlayerData.job.name != "mayor") {
        return;
    };

    await exp['ghmattimysql'].executeSync("INSERT INTO `phone_businesses` (`business_owner`, `business_name`, `business_account`) VALUES (?, ?, ?)", [
        Data.BusinessOwner,
        Data.BusinessName,
        Data.BusinessAccount,
    ]);

    Player.Functions.Notify(`Bedrijf [${Data.BusinessName}] successvol aangemaakt!`, "success")
});