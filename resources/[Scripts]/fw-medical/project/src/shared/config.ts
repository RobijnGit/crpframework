import { Vector3 } from "./classes/math";

// todo create interface
export const Config: any = {
    AdrenalineTimer: 10, // Amount of seconds of adrenaline effect.
    MedicalFee: 125,
    FeeMultiplier: 2.0, // If checked in dead, multiply by x (must be above 1.0)
    RespawnTimer: 300,
    MinorTimer: 60,
    EnableGovTimer: true, // Use MinorTimer instead of RespawnTimer for gov employees (pd/ems).
    OxyBloodThreshold: 65, // If 1-100 number is generated above this value, it will not bleed for that time.
    RagdollBones: [ 'LLEG', 'RLEG', 'LFOOT', 'RFOOT' ],
    VehicleCerts: {
        emsspeedo: 'SPEEDO',
        emstau: 'TAURUS',
        emsmotor: 'MOTOR',
        emsexp: 'COMMANDER',
        emsaw139: 'FLIGHT',
        dinghy4: 'WATER',
    },
    HospitalBeds: [
        // Crusade Medical Center
        {
            Center: new Vector3(347.17, -1400.94, 32.5),
            Beds: [
                {BedId: 1, Model: 1004440924, Coords: new Vector3(361.18, -1407.45, 32.06)},
                {BedId: 2, Model: 1004440924, Coords: new Vector3(365.27, -1402.61, 32.06)},
                {BedId: 3, Model: 1004440924, Coords: new Vector3(367.84, -1404.77, 32.06)},
                {BedId: 4, Model: 1004440924, Coords: new Vector3(370.38, -1406.90, 32.06)},
                {BedId: 5, Model: 1004440924, Coords: new Vector3(366.33, -1411.76, 32.06)},
                {BedId: 6, Model: 1004440924, Coords: new Vector3(372.98, -1409.09, 32.06)},
                {BedId: 7, Model: 1004440924, Coords: new Vector3(368.90, -1413.92, 32.06)},
            ]
        },
        // Viceroy Medical Center
        {
            Center: new Vector3(-818.38, -1228.65, 7.34),
            Beds: [
                {BedId: 8, Model: 1631638868, Coords: new Vector3(-800.10, -1234.66, 6.90)},
                {BedId: 9, Model: 1631638868, Coords: new Vector3(-804.13, -1231.27, 6.90)},
                {BedId: 10, Model: 1631638868, Coords: new Vector3(-806.74, -1229.08, 6.90)},
                {BedId: 11, Model: 1631638868, Coords: new Vector3(-809.52, -1226.75, 6.90)},
                {BedId: 12, Model: 1631638868, Coords: new Vector3(-812.25, -1224.46, 6.90)},
                {BedId: 13, Model: 1631638868, Coords: new Vector3(-809.21, -1220.92, 6.90)},
                {BedId: 14, Model: 1631638868, Coords: new Vector3(-805.48, -1224.05, 6.90)},
                {BedId: 15, Model: 1631638868, Coords: new Vector3(-801.01, -1227.80, 6.90)},
                {BedId: 16, Model: 1631638868, Coords: new Vector3(-797.06, -1231.11, 6.90)},
            ]
        },
        // Sandy Medical Clinic
        {
            Center: new Vector3(1670.36, 3654.27, 35.34),
            Beds: [
                {BedId: 17, Model: 1004440924, Coords: new Vector3(1676.07, 3647.12, 34.90)},
            ]
        },
        // Paleto Medical Clinic
        {
            Center: new Vector3(-252.43, 6322.02, 32.45),
            Beds: [
                {BedId: 18, Model: 1004440924, Coords: new Vector3(-244.22, 6317.58, 32.01)},
            ]
        },
        // Prison
        {
            Center: new Vector3(1765.11, 2594.72, 45.73),
            IsPrison: true,
            Beds: [
                {BedId: 19, Model: 2117668672, Coords: new Vector3(1771.98, 2591.80, 45.30)},
                {BedId: 20, Model: 2117668672, Coords: new Vector3(1771.98, 2594.88, 45.30)},
                {BedId: 21, Model: 2117668672, Coords: new Vector3(1771.98, 2597.95, 45.30)},
                {BedId: 22, Model: 2117668672, Coords: new Vector3(1761.87, 2597.73, 45.30)},
                {BedId: 23, Model: 2117668672, Coords: new Vector3(1761.87, 2594.64, 45.30)},
                {BedId: 24, Model: 2117668672, Coords: new Vector3(1761.87, 2591.56, 45.30)},
            ]
        },
    ]
};