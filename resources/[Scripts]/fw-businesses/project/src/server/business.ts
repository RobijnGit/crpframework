import { Business, BusinessEmployee, BusinessRole, PermissionTypes, RolePermissions } from "../shared/types";
import { exp } from "../shared/utils";
import { FW } from "./server";
import { GetBusinessByName, GetPlayerNameByCid, HasPlayerBusinessPermission } from "./utils";
import './businesses';

export let ClockedPlayers: {
    [key: number]: {
        Business: string;
        ClockedIn: boolean;
        ClockInTime: number;
    }
} = {};

onNet("fw-businesses:Server:SetClock", (Data: {
    Business: string;
    ClockedIn: boolean;
    ClockInTime: number;
}) => {
    const Source: number = source;
    Data.ClockInTime = GetGameTimer();
    ClockedPlayers[Source] = Data;
});

on("playerDropped", (Reason: string) => {
    const Source: number = source;
    ClockedPlayers[Source] = { Business: '', ClockedIn: false, ClockInTime: 0 };
});

export default () => {
    // Getters
    FW.Functions.CreateCallback("fw-businesses:Server:GetBusinessesByPlayer", async (Source: number, Cb: Function) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return Cb([]);
    
        const Retval = [];
        const Result: Business[] = await exp['ghmattimysql'].executeSync("SELECT * FROM `phone_businesses` WHERE `business_employees` LIKE ? OR `business_owner` = ?", [
            `%${Player.PlayerData.citizenid}%`,
            Player.PlayerData.citizenid
        ]);

        for (let i = 0; i < Result.length; i++) {
            const Business = Result[i];

            let Employees: BusinessEmployee[] = [];
            let ParsedEmployees = JSON.parse(Business.business_employees);
            for (let j = 0; j < ParsedEmployees.length; j++) {
                const Employee = ParsedEmployees[j];
                const Name = await GetPlayerNameByCid(Employee.Cid);

                if (Name) {
                    Employees.push({
                        ...Employee,
                        Name
                    });
                };
            }

            Retval.push({
                ...Business,
                business_employees: Employees,
                business_ranks: JSON.parse(Business.business_ranks),
                owner_name: await GetPlayerNameByCid(Business.business_owner),
            });
        };

        Cb(Retval);
    });

    FW.Functions.CreateCallback("fw-businesses:Server:GetBusinessByName", async (Source: number, Cb: Function, BusinessName: string) => {
        Cb(await GetBusinessByName(BusinessName));
    });

    // Employees
    FW.Functions.CreateCallback('fw-businesses:Server:AddEmployee', async (Source: number, Cb: Function, BusinessName: string, Cid: string, Role: string) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return Cb({Success: false, Msg: "Ongeldige speler."});

        const Business = await GetBusinessByName(BusinessName);
        if (!Business) return Cb({Success: false, Msg: "Ongeldig bedrijf."});

        const PlayerData = await exp['ghmattimysql'].executeSync("SELECT `citizenid` FROM `players` WHERE `citizenid` = ?", [Cid]);
        if (!PlayerData[0]) return Cb({Success: false, Msg: "Ongeldige speler."});

        // Is the player in the business?
        const Employees: BusinessEmployee[] = JSON.parse(Business.business_employees) || [];
        if (Employees.findIndex(Val => Val.Cid == Cid) != -1) return Cb({Success: false, Msg: "Speler is al een werknemer"});

        Employees.push({Cid, Role});
        await exp['ghmattimysql'].executeSync("UPDATE `phone_businesses` SET `business_employees` = ? WHERE `business_name` = ?", [
            JSON.stringify(Employees),
            BusinessName
        ])

        let Retval = [];
        for (let i = 0; i < Employees.length; i++) {
            const Employee = Employees[i];
            const Name = await GetPlayerNameByCid(Employee.Cid);
            if (Name) {
                Retval.push({
                    ...Employee,
                    Name
                });
            };
        };

        Cb({Success: true, Employees: Retval})
    });

    FW.Functions.CreateCallback('fw-businesses:Server:SetEmployeeRank', async (Source: number, Cb: Function, BusinessName: string, Cid: string, Role: string) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return Cb({Success: false, Msg: "Ongeldige speler."});

        const Business = await GetBusinessByName(BusinessName);
        if (!Business) return Cb({Success: false, Msg: "Ongeldig bedrijf."});

        const PlayerData = await exp['ghmattimysql'].executeSync("SELECT `citizenid` FROM `players` WHERE `citizenid` = ?", [Cid]);
        if (!PlayerData[0]) return Cb({Success: false, Msg: "Ongeldige speler."});

        // Is the player in the business?
        const Employees: BusinessEmployee[] = JSON.parse(Business.business_employees) || [];
        const EmployeeIndex = Employees.findIndex(Val => Val.Cid == Cid);
        if (EmployeeIndex == -1) return Cb({Success: false, Msg: "Speler is geen werknemer"});

        Employees[EmployeeIndex].Role = Role;

        // Employees.push({Cid, Role});
        await exp['ghmattimysql'].executeSync("UPDATE `phone_businesses` SET `business_employees` = ? WHERE `business_name` = ?", [
            JSON.stringify(Employees),
            BusinessName
        ])

        let Retval: BusinessEmployee[] = [];
        for (let i = 0; i < Employees.length; i++) {
            const Employee = Employees[i];
            const Name = await GetPlayerNameByCid(Employee.Cid);
            if (Name) {
                Retval.push({
                    ...Employee,
                    Name
                });
            };
        };

        Cb({Success: true, Employees: Retval})
    });

    FW.Functions.CreateCallback('fw-businesses:Server:RemoveEmployee', async (Source: number, Cb: Function, BusinessName: string, Cid: string) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return Cb({Success: false, Msg: "Ongeldige speler."});

        const Business = await GetBusinessByName(BusinessName);
        if (!Business) return Cb({Success: false, Msg: "Ongeldig bedrijf."});

        const PlayerData = await exp['ghmattimysql'].executeSync("SELECT `citizenid` FROM `players` WHERE `citizenid` = ?", [Cid]);
        if (!PlayerData[0]) return Cb({Success: false, Msg: "Ongeldige speler."});

        // Is the player in the business?
        let Employees: BusinessEmployee[] = JSON.parse(Business.business_employees) || [];
        if (Employees.findIndex(Val => Val.Cid == Cid) == -1) return Cb({Success: false, Msg: "Speler is geen werknemer"});

        Employees = Employees.filter(Val => Val.Cid != Cid);

        await exp['ghmattimysql'].executeSync("UPDATE `phone_businesses` SET `business_employees` = ? WHERE `business_name` = ?", [
            JSON.stringify(Employees),
            BusinessName
        ])

        let Retval: BusinessEmployee[] = [];
        for (let i = 0; i < Employees.length; i++) {
            const Employee = Employees[i];
            const Name = await GetPlayerNameByCid(Employee.Cid);
            if (Name) {
                Retval.push({
                    ...Employee,
                    Name
                });
            };
        };

        Cb({Success: true, Employees: Retval})
    });

    // Roles
    FW.Functions.CreateCallback("fw-businesses:Server:CreateRole", async (Source: number, Cb: Function, BusinessName: string, Name: string, RoleData: RolePermissions) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return Cb({Success: false, Msg: "Ongeldige Speler"});

        const Business = await GetBusinessByName(BusinessName);
        if (!Business) return Cb({Success: false, Msg: "Ongeldig Bedrijf"});

        if (Name.trim().length == 0) {
            return Cb({Success: false, Msg: "Ongeldige rol."})
        };

        const Roles: BusinessRole[] = JSON.parse(Business.business_ranks);
        if (Roles.findIndex(Val => Val.Name.toLowerCase() == Name.toLowerCase()) != -1) return Cb({Success: false, Msg: "Rol bestaat al."});

        Roles.push({
            Name,
            Perms: {
                Hire: !!RoleData.Hire,
                Fire: !!RoleData.Fire,
                ChangeRole: !!RoleData.ChangeRole,
                PayEmployee: !!RoleData.PayEmployee,
                PayExternal: !!RoleData.PayExternal,
                ChargeExternal: !!RoleData.ChargeExternal,
                PropertyKeys: !!RoleData.PropertyKeys,
                StashAccess: !!RoleData.StashAccess,
                CraftAccess: !!RoleData.CraftAccess,
                VehicleSales: !!RoleData.VehicleSales,
            }
        })

        await exp['ghmattimysql'].executeSync("UPDATE `phone_businesses` SET `business_ranks` = ? WHERE `business_name` = ?", [
            JSON.stringify(Roles),
            BusinessName
        ])

        Cb({Success: true, Ranks: Roles})
    });

    FW.Functions.CreateCallback("fw-businesses:Server:EditRole", async (Source: number, Cb: Function, BusinessName: string, Name: string, RoleData: RolePermissions) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return Cb({Success: false, Msg: "Ongeldige Speler"});

        const Business = await GetBusinessByName(BusinessName);
        if (!Business) return Cb({Success: false, Msg: "Ongeldig Bedrijf"});

        if (Name.trim().length == 0) {
            return Cb({Success: false, Msg: "Ongeldige rol."})
        };

        const Roles: BusinessRole[] = JSON.parse(Business.business_ranks);
        const RoleIndex = Roles.findIndex(Val => Val.Name.toLowerCase() == Name.toLowerCase());
        if (RoleIndex == -1) return Cb({Success: false, Msg: "Rol bestaat niet."});

        Roles[RoleIndex].Perms = {
            Hire: !!RoleData.Hire,
            Fire: !!RoleData.Fire,
            ChangeRole: !!RoleData.ChangeRole,
            PayEmployee: !!RoleData.PayEmployee,
            PayExternal: !!RoleData.PayExternal,
            ChargeExternal: !!RoleData.ChargeExternal,
            PropertyKeys: !!RoleData.PropertyKeys,
            StashAccess: !!RoleData.StashAccess,
            CraftAccess: !!RoleData.CraftAccess,
            VehicleSales: !!RoleData.VehicleSales,
        };

        await exp['ghmattimysql'].executeSync("UPDATE `phone_businesses` SET `business_ranks` = ? WHERE `business_name` = ?", [
            JSON.stringify(Roles),
            BusinessName
        ])

        Cb({Success: true, Ranks: Roles})
    });

    FW.Functions.CreateCallback("fw-businesses:Server:Delete", async (Source: number, Cb: Function, BusinessName: string, Name: string) => {
        const Player = FW.Functions.GetPlayer(Source);
        if (!Player) return Cb({Success: false, Msg: "Ongeldige Speler"});

        const Business = await GetBusinessByName(BusinessName);
        if (!Business) return Cb({Success: false, Msg: "Ongeldig Bedrijf"});

        if (Name.trim().length == 0) {
            return Cb({Success: false, Msg: "Ongeldige rol."})
        };

        const Employees: BusinessEmployee[] = JSON.parse(Business.business_employees);
        if (Employees.findIndex(Val => Val.Role.toLowerCase() == Name.toLowerCase()) != -1) return Cb({Success: false, Msg: "Een werknemer heeft deze rol."});

        let Roles: BusinessRole[] = JSON.parse(Business.business_ranks);
        Roles = Roles.filter(Val => Val.Name.toLowerCase() != Name.toLowerCase());
        
        await exp['ghmattimysql'].executeSync("UPDATE `phone_businesses` SET `business_ranks` = ? WHERE `business_name` = ?", [
            JSON.stringify(Roles),
            BusinessName
        ])

        Cb({Success: true, Ranks: Roles})
    });

    FW.Functions.CreateCallback("fw-businesses:Server:HasPlayerBusinessPermission", async (Source: number, Cb: Function, BusinessName: string, Permission: PermissionTypes) => {
        Cb(await HasPlayerBusinessPermission(BusinessName, Source, Permission))
    });
};

exp("GetClockedInPlayers", () => ClockedPlayers);