import { writable } from "svelte/store";

// Misc
export const ImageHoverData = writable({Show: false, Source: '', Top: 0, Left: 0})
export const DropdownData = writable({Show: false});

// Global
export const Tax = writable({
    Property: 1.0,
    Vehicle: 1.0,
    Goods: 1.0,
    Clothes: 1.0,
})