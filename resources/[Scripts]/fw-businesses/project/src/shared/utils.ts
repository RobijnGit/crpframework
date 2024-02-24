export const exp = global.exports;

export const Delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));
export const GetRandom = (Min: number, Max: number) => Math.floor(Math.random() * (Max - Min + 1)) + Min;

export const SendUIMessage = !IsDuplicityVersion() ? (App: string, Event: string, Data?: any) => {
    exp['fw-ui'].SendUIMessage(App, Event, Data)
} : () => console.warn(`SendUIMessage does exist on server.`);

export const SetUIFocus = !IsDuplicityVersion() ? (HasFocus: boolean, HasCursor: boolean) => {
    exp['fw-ui'].SetUIFocus(HasFocus, HasCursor)
} : () => console.warn(`SetUIFocus does exist on server.`);

export const RegisterNUICallback = !IsDuplicityVersion() ? (Name: string, Cb: Function) => {
    RegisterNuiCallbackType(Name);
    on(`__cfx_nui:${Name}`, Cb);
} : () => console.log(`RegisterNUICallback can't be used on server.`);

const CommaValue = (amount: number): string => {
    let formatted = amount.toString();
    while (true) {
        const matches = formatted.match(/^(-?\d+)(\d\d\d)/);
        if (!matches) break;
        formatted = matches[1] + "." + matches[2];
    }
    return formatted;
}

export const Round = (value: number, decimals: number | undefined): number => {
    return decimals ? Math.floor((value * 10 ** decimals) + 0.5) / (10 ** decimals) : Math.floor(value + 0.5);
}

export const NumberWithCommas = (amount: number): string => {
    return new Intl.NumberFormat('nl-NL', {
        style: 'currency',
        currency: 'EUR',
    }).format(amount);
};
exp("NumberWithCommas", NumberWithCommas);