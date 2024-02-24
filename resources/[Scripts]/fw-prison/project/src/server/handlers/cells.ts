import { exp } from "../../shared/utils";
import { FW } from "../server";

export default () => {
    FW.Functions.CreateCallback('fw-prison:Server:IsCellClaimed', async (Source: number, Cb: Function, CellId: number) => {
        Cb(await IsCellClaimed(CellId));
    });

    FW.Functions.CreateCallback('fw-prison:Server:IsCellClaimee', async (Source: number, Cb: Function, CellId: number) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return Cb(false);

        const Result = await exp['ghmattimysql'].executeSync("SELECT * FROM `prison_cells` WHERE `cell_id` = ?", [CellId]);
        Cb(Result[0].claimee == Player.PlayerData.citizenid);
    });

    FW.RegisterServer("fw-prison:Server:SetLastUsed", async (Source: number, CellId: number) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return;

        await exp['ghmattimysql'].executeSync("UPDATE `prison_cells` SET `last_used` = ? WHERE `cell_id` = ?", [new Date().getTime(), CellId])
    });
};

onNet("fw-prison:Server:ClaimCell", async ({CellId}: {CellId: number}) => {
    const Source = source;
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    // Is the current cell claimed?
    if (await IsCellClaimed(CellId)) {
        return Player.Functions.Notify("Deze cel is al door iemand anders geclaimed..", "error");
    };

    // Do I already have a claimed cell?
    const Result = await exp['ghmattimysql'].executeSync("SELECT COUNT(*) AS `amount` FROM `prison_cells` WHERE `claimee` = ?", [Player.PlayerData.citizenid]);
    if (Result[0].amount > 0) return Player.Functions.Notify("Je hebt al een cel geclaimed..", "error");

    await exp['ghmattimysql'].executeSync("UPDATE `prison_cells` SET `claimee` = ?, `last_used` = ? WHERE `cell_id` = ?", [Player.PlayerData.citizenid, new Date().getTime(), CellId])
    Player.Functions.Notify("Cel geclaimed!");
});

const IsCellClaimed = async (CellId: number): Promise<boolean> => {
    const Result = await exp['ghmattimysql'].executeSync("SELECT * FROM `prison_cells` WHERE `cell_id` = ?", [CellId]);
    
    // Does a cell exist with the cellId?
    if (!Result[0]) return true;

    // Has it been a week since a cell action has been used?
    const weekInMs = 6048e+8;
    const currentTimestamp = new Date().getTime();
    if (currentTimestamp - Result[0].last_used > weekInMs) {
        return false;
    };

    // Is the cell claimed?
    if (Result[0].claimee != "1001") {
        return true;
    };

    return false;
};