import { VinLimit } from "../../shared/config";
import { exp } from "../../shared/utils";
import { BoostVehicles, UnscratchableVehicles } from "../../shared/vehicleClasses";
import { FW } from "../server";
import { BoosterData } from "../types";
let InsertedCids: string[] = [];

export const GetBoostingDataByCid = async (Cid: string): Promise<BoosterData> => {
    const Result = await exp['ghmattimysql'].executeSync("SELECT `boosting` FROM `laptop_data` WHERE `cid` = ?", [Cid]);
    if (!Result[0]) {
        const BoostData: BoosterData = {
            Experience: 0,
            ContractsDone: 0,
            WeekContracts: 0,
            WeekScratches: 0,
            WeekStartTime: new Date().getTime(),
            LastVinScratch: 0,
        };

        await SetBoostingDataByCid(Cid, BoostData, !InsertedCids.includes(Cid))
        return BoostData;
    };

    return JSON.parse(Result[0].boosting);
};

export const SetBoostingDataByCid = async (Cid: string, Data: BoosterData, Insert?: boolean): Promise<boolean> => {
    if (Insert) {
        InsertedCids.push(Cid);
        const Result = await exp['ghmattimysql'].executeSync("INSERT INTO `laptop_data` (`cid`, `boosting`) VALUES (?, ?)", [Cid, JSON.stringify(Data)]);
        return Result.affectedRows > 0;
    } else {
        const Result = await exp['ghmattimysql'].executeSync("UPDATE `laptop_data` SET `boosting` = ? WHERE `cid` = ?", [JSON.stringify(Data), Cid]);
        return Result.affectedRows > 0;
    };
};

export const AddCryptoToPlayer = async (Cid: string, Crypto: string, Amount: number) => {
    const Player = FW.Functions.GetPlayerByCitizenId(Cid);
    if (Player) {
        Player.Functions.AddCrypto(Crypto, Amount);
    } else {
        const Result = await exp['ghmattimysql'].executeSync("SELECT money FROM players WHERE citizenid = ?", [Cid])
        if (!Result[0]) return;

        const ParsedMoney = JSON.parse(Result[0].money);
        ParsedMoney["crypto"][Crypto] += Amount;
        exp['ghmattimysql'].executeSync("UPDATE players SET money = ? WHERE citizenid = ?", [
            JSON.stringify(ParsedMoney),
            Cid
        ]);
    };
};

export const IsContractScratchable = async (Cid: string, Vehicle: string): Promise<boolean> => {
    const CurrentTime = new Date().getTime();
    const BoosterData = await GetBoostingDataByCid(Cid);
    if (BoosterData.ContractsDone == 0) return false;

    // Is the limit reached?
    const HasWeekEnded = (CurrentTime - BoosterData.LastVinScratch) / (1000 * 60 * 60) >= 168;
    if (!HasWeekEnded && BoosterData.WeekScratches >= VinLimit) return false;

    // Is the vehicle unscratchable?
    if (UnscratchableVehicles.includes(Vehicle)) return false;

    // Is the limit reached of this specific vehicle?
    const BoostVehicle = BoostVehicles.find(Val => Val.Vehicle == Vehicle);
    if (!BoostVehicle || BoostVehicle.Class == "D") return false;

    const VehicleLimit = BoostVehicle.TotalScratchesAvailable
    if (VehicleLimit == 0) return false;

    const Result = await exp['ghmattimysql'].executeSync('SELECT COUNT(*) as TotalScratches FROM `player_vehicles` WHERE `vinscratched` = 1 AND `vehicle` = ?', [Vehicle]);
    return Result[0].TotalScratches < VehicleLimit;
};

export const AddPlayerRep = async (Cid: string, Rep: number) => {
    const BoostData = await GetBoostingDataByCid(Cid);
    BoostData.Experience += Rep;

    SetBoostingDataByCid(Cid, BoostData);
};

export const RemovePlayerRep = async (Cid: string, Rep: number) => {
    const BoostData = await GetBoostingDataByCid(Cid);
    BoostData.Experience -= Rep;

    SetBoostingDataByCid(Cid, BoostData);
};