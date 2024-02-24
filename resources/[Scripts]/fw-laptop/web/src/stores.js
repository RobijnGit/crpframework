import { writable } from "svelte/store";

// Misc
export const ImageHoverData = writable({Show: false, Source: '', Top: 0, Left: 0})
export const DropdownData = writable({Show: false});

// Global
export const PlayerData = writable({});
export const HasVPN = writable(false);
export const FocusedApp = writable({});
export const CurrentApps = writable([]);
export const LaptopPreferences = writable({background: 'https://i.imgur.com/Ieoe8Kl.jpg', whiteFont: true})