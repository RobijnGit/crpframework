// NUI Functions
import { get, writable } from "svelte/store";
import { DropdownData } from "../stores";
import { FetchNui } from "./TypedUtils";
import { UseNuiEvent } from "./UseNuiEvent";

export const SendEvent = (Event, Data, Cb) => {
    if (!Cb) Cb = () => {};

    FetchNui("fw-laptop", Event, Data || {}).then((ReturnData) => {
        Cb(true, ReturnData);
    }).catch((e) => {
        Cb(false, e);
    });
}

export const AsyncSendEvent = (Event, Data) => {
    return new Promise((Res) => {
        SendEvent(Event, Data, (Success, Data) => {
            Res([Success, Data])
        })
    })
}

export const OnEvent = (Event, Cb) => {
    UseNuiEvent(Event, Cb);
}

export const Debug = (Message) => {
    // Disabled for PROD.
    console.log(`[LAPTOP-UI]: ${Message}`);
}

export const SetExitHandler = (Event, NuiEvent, IsActive, Data) => {
    // Event = NUI Event, so you can reset data or smth
    // NuiEvent = NUI Callback in LUA
    // IsActive = Function Callback if the UI is focused (or active)
    // Data = Data to be sent to the Event & NUIEvent

    window.addEventListener("keyup", (e) => {
        if (e.key != 'Escape') return;
        if (!IsActive()) return;

        SendEvent(NuiEvent, Data)
        window.dispatchEvent(
            new MessageEvent("message", {
                data: {
                    Action: Event,
                    Data: Data || {},
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

export const CopyToClipboard = (text) => {
    const textarea = document.createElement('textarea');
    textarea.value = text;
    document.body.appendChild(textarea);
    textarea.select();
    document.execCommand('copy');
    document.body.removeChild(textarea);
};

export const ExtractImageUrls = (Str) => {
    const Regex = /https?:\/\/[^\s]+\.(?:jpg|jpeg|gif|png)/gi;
    const Urls = Str.match(Regex);
    const ModifiedStr = Str.replace(Regex, "");
    return [Urls || [], ModifiedStr];
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

export const FormatDate = (timestamp) => {
    const _Date = new Date(timestamp);
    
    const Day = String(_Date.getDate()).padStart(2, '0');
    const Month = String(_Date.getMonth() + 1).padStart(2, '0');
    const Year = _Date.getFullYear();
    
    const Hours = String(_Date.getHours()).padStart(2, '0');
    const Minutes = String(_Date.getMinutes()).padStart(2, '0');
    
    return `${Day}/${Month}/${Year} ${Hours}:${Minutes}`;
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
        }
    }
}

export const GetLongTimeLabel = (timestamp) => new Date(timestamp).toLocaleString('nl-NL', {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
});

// Laptop Functions
export let Notifications = writable([]);
export let TempNotifications = writable([]);

export const AddNotification = (Icon, Colors, Header, Text) => {
    let NotifId = new Date().getTime();
    let Data = {
        Icon, Colors, Header, Text,
        Id: NotifId,
    };

    Notifications.set([Data, ...get(Notifications)]);
    TempNotifications.set([...get(TempNotifications), {...Data, AnimateState: 'in'}]);

    setTimeout(() => {
        let TempNotifs = get(TempNotifications);
        let NotifIndex = TempNotifs.findIndex(Val => Val.Id == NotifId);

        TempNotifs[NotifIndex].AnimateState = 'out';
        TempNotifications.set(TempNotifs);

        setTimeout(() => {
            TempNotifications.set(get(TempNotifications).filter(Val => Val.Id != NotifId));
        }, 250);
    }, 5000);
};