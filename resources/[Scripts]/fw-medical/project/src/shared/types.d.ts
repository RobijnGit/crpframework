import { Vector3 } from "./classes/math";

export interface Injury {
    Id: string;
    IsMinor: boolean;
}

export interface HospitalBed {
    BedId: number;
    Model: number;
    Coords: Vector3;
}

export interface WeaponObject {
    WeaponID: string;
    AmmoType: string;
    SelectFire: boolean;
    MaxAmmo: number;
    AddAmmo: number;
}

export interface BoneHealth {
    Name: string;
    Health: number;
}