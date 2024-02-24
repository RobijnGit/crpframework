import { Vector3 } from "./classes/math";
import { Checkpoint } from "./types";

export const Delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));
export const GetRandom = (Min: number, Max: number) => Math.floor(Math.random() * (Max - Min + 1)) + Min;

export const CalculateDistance = (Checkpoints: Checkpoint[]): number => {
    let totalDistance = 0;

    for (let i = 0; i < Checkpoints.length - 1; i++) {
        const currentCheckpoint = Checkpoints[i];
        const nextCheckpoint = Checkpoints[i + 1];

        const CurrentPos = new Vector3().setFromObject(currentCheckpoint.Pos);
        const DistanceBetweenCheckpoints = CurrentPos.getDistance2D(nextCheckpoint.Pos.x, nextCheckpoint.Pos.y);
        totalDistance += DistanceBetweenCheckpoints;
    }

    return totalDistance;
};
