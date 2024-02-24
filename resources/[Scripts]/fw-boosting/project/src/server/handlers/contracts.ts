import { BoostingContract } from "../../shared/types";
import { VehicleClass } from "../types";
import { ClassChances, ExperienceClasses } from "../../shared/config"
import { BoostVehicles } from "../../shared/vehicleClasses";
import { ContractNames } from "../../shared/ContractNames";
import { GetBoostingDataByCid } from "./db";
import { FW, ParseContracts } from "../server";
import { GetRandom, exp } from "../../shared/utils";

export const Contracts: BoostingContract[] = [];
export const ContractsPerCid: {[key: string]: BoostingContract} = {};

export const GenerateContractForCid = async (Source: number, Cid: string, Classes: VehicleClass[]) => {
    const BoostData = await GetBoostingDataByCid(Cid);
    if (!BoostData || typeof BoostData == "boolean") return;

    const Class = GetRandomContractClass(Classes[0], Classes[1]);
    const Vehicle = GetRandomBoostVehicle(Class);

    await exp['ghmattimysql'].executeSync("INSERT INTO `laptop_boosting` (cid, class, contractor, vehicle, xp, expire) VALUES (?, ?, ?, ?, ?, ?)", [
        Cid,
        Class,
        GetRandomContracterName(),
        Vehicle,
        Class == Classes[0] ? 4 : 1,
        GetRandom(4000000, 9000000) + new Date().getTime()
    ]);

    emit("fw-phone:Server:Mails:AddMail", "Boosting Service", `${Class}-${Cid}`, `Je hebt een ${Class} contract ontvangen!`, Source);
};

export const GetClassesFromExperience = (Experience: number, IsGenerating?: boolean): VehicleClass[] => {
    const Index = ExperienceClasses.findIndex(Val => Experience < Val.Experience);
    if (Index == -1) return (IsGenerating ? ['A', 'B'] : ['S+', 'S+']);

    const CurrentClass: VehicleClass = ExperienceClasses[Index - 1]?.Class || 'D';
    const PreviousClass: VehicleClass = ExperienceClasses[Index - 2]?.Class || 'D';

    // If GENERATING a contract, and the current class is a SPECIAL CONTRACT CLASS, return the latest non-special contract type.
    const SpecialContractsClasses = ['A+', 'S', 'S+'];
    if (IsGenerating && (SpecialContractsClasses.includes(CurrentClass))) {
        return ['A', 'B']
    };

    return [CurrentClass, PreviousClass]
};

export const GetRandomContractClass = (CurrentClass: VehicleClass, PreviousClass: VehicleClass): VehicleClass => {
    const TotalChance = ClassChances[CurrentClass] + ClassChances[PreviousClass];
    const Random = Math.random() * TotalChance;

    if (Random < ClassChances[CurrentClass]) return CurrentClass;
    return PreviousClass;
};

export const GetRandomBoostVehicle = (Class: VehicleClass): string => {
    const Vehicles = BoostVehicles.filter(Val => Val.Class == Class);
    if (Vehicles.length == 0) return "dloader";

    const RandomIndex = Math.floor(Math.random() * Vehicles.length);
    let Vehicle = Vehicles[RandomIndex].Vehicle
    if (!FW.Shared.HashVehicles[GetHashKey(Vehicle)]) {
        Vehicle = GetRandomBoostVehicle(Class);
    };

    return Vehicle;
};

export const GetRandomContracterName = (): string => {
    const RandomIndex = Math.floor(Math.random() * ContractNames.length);
    return ContractNames[RandomIndex];
};

export const GetPendingContractsByCid = async (Cid: string) => {
    const Result = await exp['ghmattimysql'].executeSync("SELECT COUNT(*) AS amount FROM laptop_boosting WHERE cid = ?", [Cid]);
    return Result[0].amount
};

export const GetContractsByCid = async (Cid: string) => {
    const Result = await exp['ghmattimysql'].executeSync("SELECT * FROM laptop_boosting WHERE auction = 0 AND cid = ? ORDER BY `expire` ASC", [Cid])
    return await ParseContracts(Result);
}

export const TransferContract = async (PlayerSource: number, TargetSource: number, Contract: BoostingContract) => {
    const Target = FW.Functions.GetPlayer(TargetSource);

    if (TargetSource == PlayerSource) {
        return {
            success: true,
            message: "Je hebt het contract aan jezelf overgedragen domme lul",
            dumb: true,
        }
    };

    if (Target) {
        exp["ghmattimysql"].executeSync("UPDATE `laptop_boosting` SET `cid` = ? WHERE `id` = ?", [
            Target.PlayerData.citizenid,
            Contract.Id
        ]);
    };

    return {
        success: true,
        message: "Contract succesvol overgedragen!"
    };
};