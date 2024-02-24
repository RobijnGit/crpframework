import { Business, BusinessEmployee, BusinessRole, PermissionTypes } from "../shared/types";
import { exp } from "../shared/utils";
import { ClockedPlayers } from "./business";
import { FW } from "./server"

export const GetPlayerNameByCid = async (Cid: string): Promise<string> => {
    const Player = FW.Functions.GetPlayerByCitizenId(Cid);
    if (Player) {
        return `${Player.PlayerData.charinfo.firstname} ${Player.PlayerData.charinfo.lastname}`
    };

    const Result = await exp['ghmattimysql'].executeSync("SELECT `charinfo` FROM `players` WHERE `citizenid` = ?", [Cid]);
    if (!Result[0]) return '';

    const CharInfo = JSON.parse(Result[0].charinfo);
    return `${CharInfo.firstname} ${CharInfo.lastname}`;
};

export const GetBusinessAccount = async (BusinessName: string): Promise<number> => {
    const Result = await exp['ghmattimysql'].executeSync("SELECT `business_account` FROM `phone_businesses` WHERE `business_name` = ?", [BusinessName]);
    if (!Result[0]) return 0;

    return Result[0].business_account;
};

export const GetBusinessByName = async (BusinessName: string): Promise<false | Business> => {
    const Result = await exp['ghmattimysql'].executeSync("SELECT * FROM `phone_businesses` WHERE `business_name` = ?", [BusinessName]);
    if (!Result[0]) return false;

    return Result[0];
};

export const GetBusinessOwner = async (BusinessName: string): Promise<false | string> => {
    const Result = await exp['ghmattimysql'].executeSync("SELECT `business_owner` FROM `phone_businesses` WHERE `business_name` = ?", [BusinessName]);
    if (!Result[0]) return false;

    return Result[0]?.business_owner;
};

export const HasPlayerBusinessPermission = async (BusinessName: string, Source: number, Permission: PermissionTypes): Promise<boolean> => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return false;

    const Business = await GetBusinessByName(BusinessName);
    if (!Business) return false;

    if (Business.business_owner == Player.PlayerData.citizenid) {
        return true
    };

    const Employees: BusinessEmployee[] = JSON.parse(Business.business_employees);
    const Roles: BusinessRole[] = JSON.parse(Business.business_ranks);

    for (let i = 0; i < Employees.length; i++) {
        const Employee = Employees[i];
        if (Employee.Cid != Player.PlayerData.citizenid) continue;

        const Role = Roles.find(Val => Val.Name == Employee.Role);
        if (!Role) return false;

        if (Role.Perms[Permission]) return true;
    };

    return false;
};

export const IsClockedIn = (Source: number, BusinessName: string): boolean => {
    if (!ClockedPlayers[Source]) return false;
    return ClockedPlayers[Source].ClockedIn && ClockedPlayers[Source].Business == BusinessName;
}

// Create exports :)
export default () => {
    exp("GetBusinessAccount", GetBusinessAccount);
    exp("HasPlayerBusinessPermission", HasPlayerBusinessPermission);
    exp("GetBusinessOwner", GetBusinessOwner)
};