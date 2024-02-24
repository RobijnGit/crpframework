export const exp = global.exports;
export const Delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));
export const GetRandom = (Min: number, Max: number) => Math.floor(Math.random() * (Max - Min + 1)) + Min;