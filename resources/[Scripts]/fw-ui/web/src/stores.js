import { writable } from "svelte/store";

// Misc
export const DropdownData = writable({Show: false});

// Global
export const PlayerData = writable({
    Cid: "1000",
    Job: "police",
    Duty: false
});
export const Tax = writable({
    Property: 1.0,
    Vehicle: 1.0,
    Goods: 1.0,
    Clothes: 1.0,
})