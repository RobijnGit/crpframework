export const exp = global.exports;

export const Delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));
export const GetRandom = (Min: number, Max: number) => Math.floor(Math.random() * (Max - Min + 1)) + Min;

export const SendUIMessage = !IsDuplicityVersion() ? (Action: string, Data: any) => {
    exp['fw-laptop'].SendUIMessage(Action, Data)
} : () => console.log(`SendUIMessage cannot be used in server-side.`)
