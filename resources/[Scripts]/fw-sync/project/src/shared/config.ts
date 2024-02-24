import type { Weather } from "./types.d";

export const WeatherTypes: [string, Weather, number][] = [
    // ["Sneeuwstorm", "BLIZZARD", 0x27EA2814],
    ["Helder", "CLEAR", 0x36A83D84],
    ["Opklaren", "CLEARING", 0x6DB1A50D],
    ["Bewolkt", "CLOUDS", 0x30FDAF5C],
    ["Extra zonnig", "EXTRASUNNY", 0x97AA0A79],
    ["Mistig", "FOGGY", 0xAE737644],
    ["Halloween", "HALLOWEEN", 0xC91A3202],
    // ["Neutraal", "NEUTRAL", 0xA4CA1326],
    ["Zwaarbewolkt", "OVERCAST", 0xBB898D2D],
    ["Regen", "RAIN", 0x54A69840],
    ["Smog", "SMOG", 0x10DCF4B5],
    ["Sneeuw", "SNOW", 0xEFB6EFF6],
    // ["Sneeuwachtig", "SNOWLIGHT", 0x23FB812B],
    ["Onweer", "THUNDER", 0xB677829F],
    ["Kerst", "XMAS", 0xAAC9C895]
];