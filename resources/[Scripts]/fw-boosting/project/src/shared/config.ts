import { VehicleClass } from "../server/types";

// Propotional chances, 0.5 means 50% of happening.
export const ClassChances: {[key: string]: number} = {
    ["S+"]: 0.02,
    ["S"]:  0.05,
    ["A+"]: 0.10,
    ["A"]:  0.40,
    ["B"]:  0.50,
    ["C"]:  0.60,
    ["D"]:  1.00,
};

// Minimum speed to hack in KMH
export const HackSpeed = 50;

// How many seconds between hacks
export const HackCooldown = 70;

// How many contracts allowed before you stop receiving contracts
export const MaxContractsAllowed = 10;

// How many contracts can be started every 12 hours
export const TsunamiLimit = 6;

// How many contracts can be started a week
export const WeeklyLimit = 56;

// How many days before a new special contract can be done?
export const SpecialContractDays = 14;

// How many vin scratches per week
export const VinLimit = 1;

// Classes index with required experience
// https://docs.google.com/spreadsheets/d/1Nk0jQvpD6larp--VEXj8cgeABRm6cFTtWSIiawWldNk/edit#gid=0
export const ExperienceClasses: {
    Class: VehicleClass;
    Experience: number;
}[] = [
    { Class: "D", Experience: 0 },
    { Class: "C", Experience: 100 },
    { Class: "B", Experience: 500 },
    { Class: "A", Experience: 800 },
    { Class: "A+", Experience: 1060 },
    { Class: "S", Experience: 1280 },
    { Class: "S+", Experience: 1460 },
];

// Klasses boven huidige kan alleen gescratched worden
export const TierConfigs: {[key: string]: {
    Crypto: string;
    BuyIn: number;
    Reward: [number, number];
    Trackers: number;
    HackTypes: string[];
    HackTime: number;
    HackFail: number;
    AlwaysPeds: boolean;
    MinCops: number;
}} = {
    ["D"]: {
        Crypto: "GNE",
        BuyIn: 5,
        Reward: [8, 10],
        Trackers: 0,
        HackTypes: [],
        HackTime: 20,
        HackFail: 0,
        AlwaysPeds: false,
        MinCops: 1,
    },
    ["C"]: {
        Crypto: "GNE",
        BuyIn: 10,
        Reward: [15, 20],
        Trackers: 2,
        HackTypes: ["numeric", "alphabet", "alphanumeric"],
        HackTime: 20,
        HackFail: 1,
        AlwaysPeds: false,
        MinCops: 2,
    },
    ["B"]: {
        Crypto: "GNE",
        BuyIn: 20,
        Reward: [30, 40],
        Trackers: 5,
        HackTypes: ["numeric", "alphabet", "alphanumeric", "greek"],
        HackTime: 20,
        HackFail: 1,
        AlwaysPeds: false,
        MinCops: 2,
    },
    ["A"]: {
        Crypto: "GNE",
        BuyIn: 40,
        Reward: [70, 80],
        Trackers: 10,
        HackTypes: ["numeric", "alphabet", "alphanumeric", "greek"],
        HackFail: 1, // 2
        AlwaysPeds: false,
        HackTime: 15,
        MinCops: 4,
    },
    ["A+"]: {
        Crypto: "XTF",
        BuyIn: 70,
        Reward: [100, 140],
        Trackers: 12,
        HackTypes: ["numeric", "alphabet", "alphanumeric", "greek", "runes"],
        HackTime: 15,
        HackFail: 1, // 2
        AlwaysPeds: false,
        MinCops: 5,
    },
    ["S"]: {
        Crypto: "XTF",
        BuyIn: 100,
        Reward: [140, 200],
        Trackers: 15,
        HackTypes: ["alphabet", "alphanumeric", "greek", "runes", "braille"],
        HackTime: 12,
        HackFail: 1, // 2
        AlwaysPeds: false,
        MinCops: 6,
    },
    ["S+"]: {
        Crypto: "XTF",
        BuyIn: 150,
        Reward: [200, 300],
        Trackers: 18,
        HackTypes: ["greek", "runes", "braille", "symbols"],
        HackTime: 12,
        HackFail: 1, // 2
        AlwaysPeds: false,
        MinCops: 6,
    }
}