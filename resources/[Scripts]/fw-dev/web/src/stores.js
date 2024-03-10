import { writable } from "svelte/store";

// Misc
export const ImageHoverData = writable({Show: false, Source: '', Top: 0, Left: 0})
export const DropdownData = writable({Show: false});