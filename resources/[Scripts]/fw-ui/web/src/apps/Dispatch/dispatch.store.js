import { writable } from "svelte/store"

export const DispatchAlerts = writable([]);
export const DispatchCalls = writable([]);
export const DispatchUnits = writable({ Police: [], EMS: [] });