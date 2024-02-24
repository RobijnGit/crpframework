import { writable } from "svelte/store";

export const CurrentBallot = writable(0);
export const Ballots = writable([]);