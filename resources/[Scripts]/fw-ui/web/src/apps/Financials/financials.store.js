import { writable } from "svelte/store";

export const ModalData = writable({});
export const IsATM = writable(false);
export const CurrentAccount = writable({});
export const CurrentTransactions = writable([]);
export const Cash = writable(0);