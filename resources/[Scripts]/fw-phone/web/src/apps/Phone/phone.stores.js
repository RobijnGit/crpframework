import { writable } from "svelte/store";

// Global
export const Brand = writable('Android') // Android | iOS
export const HasVpn = writable(false); // false | true
export const HasRacingUsb = writable(true); // false | true
export const HasPDRacingUsb = writable(false); // false | true
export const RacingAlias = writable("");
export const PlayerData = writable({
    Id: 0,
    Cid: '2001',
    Job: 'police'
});

// Modals
export const LoaderModal = writable(false);
export const SuccessModal = writable(false);
export const InputModal = writable({ Visible: false });

// Preferences
export const PhoneBackground = writable("https://i.imgur.com/3KTfLIV.jpg");
export const EmbedsEnabled = writable(true);

// Apps
export const CurrentArticle = writable({})
export const CurrentBusiness = writable({});
export const JobManager = writable({});
export const CurrentDocument = writable({});
export const DocumentIsDrop = writable(false);
export const CurrentChat = writable(false);