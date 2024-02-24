import { exp } from "../../shared/utils";
import { FW } from "../server";
import { HasPlayerBusinessPermission } from "../utils";

// function FormatString(template: string, ...values: string[]): string {
//     return template.replace(/%s/g, () => values.shift() || '');
// }

const FillLicenseTemplate = (Data: string[]): string => {
    const Template = exp['fw-cityhall'].GetLicenseTemplate();
    return Template.replace(/%s/g, () => Data.shift() || '');
}

FW.Functions.CreateCallback("fw-businesses:Server:Flightschool:GivePilotLicense", async (Source: number, Cb: Function, Data: {
    Cid: string;
    Give: boolean;
}) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return Cb({Success: false, Msg: "Ongeldige speler."});


    const Target = FW.Functions.GetPlayerByCitizenId(Data.Cid);
    if (!Target) return Cb({Success: false, Msg: "Ongeldige speler."});

    const CanChargeExternal = await HasPlayerBusinessPermission("Los Santos Vliegschool", Source, "ChargeExternal");
    if (!CanChargeExternal) return Cb({Success: false, Msg: "Geen toegang.."});

    if (Data.Give) {
        const _Date = new Date();
        const Year = _Date.getFullYear();
        const Month = _Date.getMonth();
        const Day = _Date.getDate();
        const Hour = _Date.getHours();
        const Minutes = _Date.getMinutes();

        emit('fw-phone:Server:Documents:AddDocument', '1001', {
            Type: 1,
            Title: `Vliegbrevet - ${Target.PlayerData.citizenid}`,
            Content: FillLicenseTemplate([
                `${Target.PlayerData.charinfo.firstname} ${Target.PlayerData.charinfo.lastname}`,
                Target.PlayerData.citizenid,
                Target.PlayerData.charinfo.gender == 0 ? "Man" : "Vrouw",
                `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}`,
                `${Day}/${Month + 1}/${Year} ${Hour}:${Minutes}`
            ]),
            Signatures: [
                { Signed: true, Name: 'De Staat', Timestamp: _Date.getTime(), Cid: '1001' },
            ],
            Sharees: [ Target.PlayerData.citizenid ],
            Finalized: 1,
        })
    } else {
        exp['ghmattimysql'].executeSync("DELETE FROM `phone_documents` WHERE `type` = 1 AND `title` = ? AND `sharees` LIKE ?", [
            `Vliegbrevet - ${Target.PlayerData.citizenid}`,
            `%${Target.PlayerData.citizenid}%`
        ])
    };

    Target.Functions.SetMetaDataTable('licenses', 'flying', Data.Give);
    Cb({Success: true})
})