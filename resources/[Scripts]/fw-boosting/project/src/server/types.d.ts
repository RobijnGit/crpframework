export type VehicleClass = "S+" | "S" | "A+" | "A" | "B" | "C" | "D" | "E"

export interface BoosterData {
    Experience: number; // Total experience
    WeekContracts: number; // Amount of contracts past 7 days
    WeekScratches: number; // Amount of vin scratches past 7 days
    WeekStartTime: number; // Time of the 7 days.
    ContractsDone: number;
    LastVinScratch: number;
    IsQueued?: boolean;
    Cid?: string;
    Progress?: {
        Current: string;
        Previous: string;
        Next: string;
        Progress: number;
    }
};

export interface Queuer {
    Source: number;
    Cid: string;
    GroupId: number;
}