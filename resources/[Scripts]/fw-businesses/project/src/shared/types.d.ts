export type PermissionTypes = 'Hire' | 'Fire' | 'ChangeRole' | 'PayEmployee' | 'PayExternal' | 'ChargeExternal' | 'PropertyKeys' | 'StashAccess' | 'CraftAccess' | 'VehicleSales';

export interface Business {
    business_name: string;
    business_owner: string;
    business_account: string;
    business_employees: string;
    business_ranks: string;
    owner_name?: string;
}

export interface BusinessEmployee {
    Cid: string;
    Role: string;
    Name?: string;
}

export interface BusinessRole {
    Name: string;
    Perms: RolePermissions;
}

export interface RolePermissions {
    Hire: boolean;
    Fire: boolean;
    ChangeRole: boolean;
    PayEmployee: boolean;
    PayExternal: boolean;
    ChargeExternal: boolean;
    PropertyKeys: boolean;
    StashAccess: boolean;
    CraftAccess: boolean;
    VehicleSales: boolean;
}

// Business - vehicle-shop
export type VehicleShops = "pdm" | "bennys" | "flightschool" | "lostmc" | "darkwolves" | "losmuertos"

// Business - foodchain
export type DishTypes = "Main" | "Side" | "Dessert" | "Drink";