import { Business, BusinessEmployee, PermissionTypes } from "../shared/types";
import { exp } from "../shared/utils";
import { FW } from "./client";

export const IsBusinessOwner = async (BusinessName: string): Promise<boolean> => {
    const Business: Business = await FW.SendCallback("fw-businesses:Server:GetBusinessByName", BusinessName);
    return Business.business_owner == FW.Functions.GetPlayerData().citizenid;
};

export const HasRolePermission = async (BusinessName: string, Permission: PermissionTypes): Promise<boolean> => {
    const HasPermission: boolean = await FW.SendCallback("fw-businesses:Server:HasPlayerBusinessPermission", BusinessName, Permission);
    return HasPermission;
};

export const IsPlayerInBusiness = async (BusinessName: string): Promise<boolean> => {
    const Business: Business = await FW.SendCallback("fw-businesses:Server:GetBusinessByName", BusinessName);
    const Cid = FW.Functions.GetPlayerData().citizenid;

    if (Business.business_owner == Cid) return true;
    return JSON.parse(Business.business_employees).findIndex((Val: BusinessEmployee) => Val.Cid == Cid) != -1;
};

export const IsBusinessOnLockdown = async (BusinessName: string): Promise<boolean> => {
    const OnLockdown = await exp['fw-cityhall'].IsLockdownActive(`business-${BusinessName}`);

    if (OnLockdown && exp['fw-cityhall'].IsGov()) return false;
    return OnLockdown
}

export default () => {
    exp("IsBusinessOwner", IsBusinessOwner);
    exp("HasRolePermission", HasRolePermission);
    exp("IsPlayerInBusiness", IsPlayerInBusiness);
};