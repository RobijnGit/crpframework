// NUI Functions
import { get } from "svelte/store";
import { DropdownData, MdwCerts, MdwRanks, MdwTags, MdwCharges, MdwEvidence, MdwRoles, MdwProfile } from "../stores";
import { FetchNui } from "./FetchNui";
import { UseNuiEvent } from "./UseNuiEvent";

export const SendEvent = (Event, Data, Cb) => {
    if (!Cb) Cb = () => {};

    FetchNui("fw-mdw", Event, Data || {}).then((ReturnData) => {
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
    // console.log(`[MDW-UI]: ${Message}`);
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
        }
    }
}

export const GetLongTimeLabel = (timestamp) => new Date(timestamp).toLocaleString('nl-NL', {
    day: 'numeric',
    month: 'short',
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


// MDW Functions
export const GetRankById = Id => {
    return get(MdwRanks).filter(Val => Val.id == Id)[0];
}

export const GetChargeById = Id => {
    return get(MdwCharges).filter(Val => Val.id == Id)[0];
}

export const GetCertById = Id => {
    return get(MdwCerts).filter(Val => Val.id == Id)[0];
}

export const GetRoleById = Id => {
    return get(MdwRoles).filter(Val => Val.id == Id)[0] || { name: "Ongeldig", Icon: "exclamation-circle", color: "#ff0000", permissions: {} };
}

export const GetTagById = Id => {
    return get(MdwTags).filter(Val => Val.id == Id)[0];
}

export const GetEvidenceById = Type => {
    return get(MdwEvidence).filter(Val => Val.Text == Type)[0];
}

export const HasCidPermission = (Permission) => {
    if (!get(MdwProfile)) return;

    const ProfileRoles = get(MdwProfile).roles;
    const Roles = get(MdwRoles);

    for (let i = 0; i < ProfileRoles.length; i++) {
        const RoleIndex = Roles.findIndex(Val => Val.id == ProfileRoles[i]);
        if (RoleIndex >= 0 && Roles[RoleIndex].permissions[Permission]) {
            return true;
        };
    };

    return false;
}