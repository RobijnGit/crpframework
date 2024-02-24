// NUI Functions
import { get, writable } from "svelte/store";
import { DropdownData } from "../stores";
import { FetchNui } from "./FetchNui";
import { UseNuiEvent } from "./UseNuiEvent";

export const SendEvent = (Event, Data, Cb, Resource = "fw-ui") => {
    if (!Cb) Cb = () => {};

    FetchNui(Data?.__resource || Resource, `${Event}`, Data || {}).then((ReturnData) => {
        Cb(true, ReturnData);
    }).catch((e) => {
        Cb(false, e);
    });
}

export const AsyncSendEvent = (App, Event, Data) => {
    return new Promise((Res) => {
        SendEvent(`${App}/${Event}`, Data, (Success, Result) => {
            Res([Success, Result])
        })
    })
}

export const OnEvent = (App, Event, Cb) => {
    UseNuiEvent(`${App}/${Event}`, Cb);
}

export const Debug = (Message) => {
    // Disabled for PROD.
    // console.log(`[fw-ui]: ${Message}`);
}

export const SetExitHandler = (nuiEvent, luaEvent, isActive, data) => {
    window.addEventListener("keyup", (e) => {
        if (e.key != 'Escape') return;
        if (!isActive()) return;

        SendEvent(luaEvent, data)
        window.dispatchEvent(
            new MessageEvent("message", {
                data: {
                    Action: nuiEvent,
                    Data: data || {},
                },
            })
        );
    });
};

export const SetDropdown = (Show, Options, Positioning) => {
    if (!Positioning) Positioning = {};
    Positioning.Width = Positioning?.Width || 'max-content';

    DropdownData.set({
        Show: Show,
        Options: Options,
        Positioning: Positioning
    })
}

// JS Functions
export const IsEnvBrowser = () => !(window).invokeNative;
export const Delay = Sec => new Promise( Res => setTimeout(Res, Sec * 1000) );

export const AddSpaces = Value => {
    return Value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ")
};

export const FormatCurrency = new Intl.NumberFormat('nl-NL', {
    style: 'currency',
    currency: 'EUR',
});

export const CalculateTimeLeftExact = (Time) => {
    var NowTime = new Date();
    var ItemTime = new Date(Time);
    var DifferenceMS = (ItemTime - NowTime);
    var DifferenceHours = Math.floor((DifferenceMS % 86400000) / 3600000);
    var DifferenceMins = Math.round(((DifferenceMS % 86400000) % 3600000) / 60000);

    return {Hours: DifferenceHours, Minutes: DifferenceMins}
}

export const GetTimeLabel = (date, nowDate = Date.now(), rft = new Intl.RelativeTimeFormat('nl', { numeric: "auto" })) => {
    const SECOND = 1000;
    const MINUTE = 60 * SECOND;
    const HOUR = 60 * MINUTE;
    const DAY = 24 * HOUR;
    const WEEK = 7 * DAY;
    const MONTH = 30 * DAY;
    const YEAR = 365 * DAY;
    const intervals = [
        { ge: YEAR, divisor: YEAR, unit: 'year' },
        { ge: MONTH, divisor: MONTH, unit: 'month' },
        { ge: WEEK, divisor: WEEK, unit: 'week' },
        { ge: DAY, divisor: DAY, unit: 'day' },
        { ge: HOUR, divisor: HOUR, unit: 'hour' },
        { ge: MINUTE, divisor: MINUTE, unit: 'minute' },
        { ge: 30 * SECOND, divisor: SECOND, unit: 'seconds' },
        { ge: 0, divisor: 1, text: 'zojuist' },
    ];
    const now = typeof nowDate === 'object' ? nowDate.getTime() : new Date(nowDate).getTime();
    const diff = now - (typeof date === 'object' ? date : new Date(date)).getTime();
    const diffAbs = Math.abs(diff);
    for (const interval of intervals) {
        if (diffAbs >= interval.ge) {
            const x = Math.round(Math.abs(diff) / interval.divisor);
            const isFuture = diff < 0;
            return interval.unit ? rft.format(isFuture ? x : -x, interval.unit) : interval.text;
        };
    };
};

export const GetLongTimeLabel = (timestamp) => new Date(timestamp).toLocaleString('nl-NL', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
});

export const CopyToClipboard = (text) => {
    const textarea = document.createElement('textarea');
    textarea.value = text;
    document.body.appendChild(textarea);
    textarea.select();
    document.execCommand('copy');
    document.body.removeChild(textarea);
};