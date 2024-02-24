import { writable } from "svelte/store";

export const CurrentTab = writable("clothes");
export const ClosingModal = writable(false);
export const PedId = writable(1);
export const IsCustomPed = writable(false);
export const CustomPeds = writable([]);
export const CurrentSkin = writable({});
export const ComponentsValues = writable({});
export const ClothingPrice = writable(0);

export const MenuTypes = {
    "Creation": [ "clothes", "accessoires", "peds", "parents", "face", "skin", "hair", "makeup", "tattoos" ],
    "Clothes": [ "clothes", "accessoires", "peds" ],
    "Barber": [ "parents", "face", "skin", "hair", "makeup" ],
    "Tattoos": [ "tattoos" ],
}

// Bakker again saving me loads of time.
export const HairPalette = [
    "#0e1214", "#191e1f", "#262221", "#2a190d", "#432813", "#432813", "#6a462c", "#684b31",
    "#765940", "#816648", "#9f8359", "#af9869", "#b8a371", "#c5a763", "#e5c57f", "#ebd094",
    "#a68155", "#854a31", "#652012", "#5d0200", "#610000", "#7b0501", "#a6240d", "#bf451c",
    "#a74b25", "#b04921", "#5f5f5f", "#828282", "#b3b3b3", "#d3d3d3", "#3f304f", "#553769",
    "#763475", "#ff76f3", "#fa4698", "#ff9fc7", "#009aa4", "#005b88", "#003074", "#39a86a",
    "#167d5f", "#0a584f", "#c1cd2d", "#70b100", "#3ca408", "#ecc457", "#f6bb00", "#f79700",
    "#ff8c2a", "#ff8355", "#f38f57", "#dd5534", "#d92715", "#b20000", "#880000", "#120904",
    "#1d120b", "#22150d", "#2c1d11", "#22150b", "#150d05", "#000000", "#6f6b65", "#a27b4b",
]

export const MakeupPalette = [
    "#9d1a28", "#d4305a", "#c84c6b", "#c1627c", "#ae4e6a", "#b83c46", "#802729", "#aa625a",
    "#cd8a7a", "#d8a79c", "#d29794", "#b26f61", "#b95d4c", "#af472a", "#be727a", "#d68297",
    "#ffa4cb", "#f977ab", "#ed3783", "#bb466c", "#6f1b2f", "#47121e", "#b01625", "#ec142a",
    "#da0005", "#f5506f", "#ea38be", "#cc1cb9", "#a40faf", "#6c0a73", "#720560", "#510858",
    "#6a0ca1", "#0d2d6f", "#1048ad", "#1374c4", "#16aada", "#1ccfe1", "#19d9ad", "#1fcc80",
    "#10a22a", "#068800", "#72de3c", "#d3fd2f", "#f3f62a", "#ffef1f", "#ffcc1e", "#ff8e1d",
    "#ff5604", "#c96e0e", "#ffd783", "#fff8ce", "#ffffff", "#bdbfbf", "#969696", "#524948",
    "#090000", "#559ba4", "#486f8f", "#0c1f4f", "#a7806c", "#846150", "#6d4e41", "#35211b",
]