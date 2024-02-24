import { Vector3Format } from "./classes/math";

export interface Checkpoint {
    Pos: {
        x: number,
        y: number,
        z: number,
    },
    Rotation: {
        x: number,
        y: number,
        z: number,
    },
    Radius: number,
}

export interface Track {
    Id: number;
    Name: string;
    Type: "Laps" | "Sprint";
    IsGov: boolean;
    Distance: number;
    MinLaps: number = 1;
    Checkpoints: Checkpoint[] = [];
}

export interface CreateRaceData {
    TrackId: number;
    Type: "Laps" | "Sprint";
    Name: string;
    Class: string;
    Laps: number = 1;
    Amount: number = 0;
    Countdown: number = 10;
    DNFPosition: number = 10;
    DNFCountdown: number = 180;
    Phasing: string = "None";
    Password: false | string = "";
    Reverse: number = 0;
    ShowPosition: number = 0;
    SendNotification: number = 0;
    ForceFPP: number = 0;
    CheckpointPenalty: number = 0;
    AllowNitrous: boolean = false;
    FreezeStart: boolean = false;
}

export interface Racer {
    Source: number;
    Cid: string;
    Alias: string;
    Finished: boolean;
    BestTime?: number;
    TotalTime?: number;
    GNEReward?: number;
    MoneyReward?: number;
}

export interface Race {
    Id: number;
    TrackId: number,
    Name: string;
    Type: "Laps" | "Sprint" = "Sprint";
    Laps: number;
    Class: string;
    Distance: number;
    State: "Pending" | "Active" | "Completed";
    Creator: string;
    Racers: Racer[];
    IsGov: number | boolean;
    DNFStarted: boolean;
    Settings: CreateRaceData;
    Checkpoints: Checkpoint[];
}

export interface RacerPosition {
    Source: number;
    Cid: string;
    Lap: number;
    Checkpoint: number;
    Total?: number = Number.MAX_SAFE_INTEGER;
    Best?: number = Number.MAX_SAFE_INTEGER;
    DNF?: boolean;
}

export interface RaceMessage {
    Sender: string;
    Message: string;
    Attachments: string[];
    Timestamp: number;
    TimestampLabel: string;
}