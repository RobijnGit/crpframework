import { AddNotification, IsEnvBrowser } from "./Utils";

export interface CallbackResult {
    success: boolean;
    message: string;
    dumb?: boolean;
    warn?: boolean;
}

export async function FetchNui<T = any>(Resource: string | undefined, EventName: string, Data?: any, DebugData?: T): Promise<T> {
    if (IsEnvBrowser() && DebugData) {
        await new Promise(resolve => setTimeout(resolve, 1000));
        return DebugData;
    }
    const ResourceName = Resource || ((window as any).GetParentResourceName ? (window as any).GetParentResourceName() : "nui-frame-app");
    const Response = await fetch(`https://${ResourceName}/${EventName}`, {
        method: "post",
        headers: {
            "Content-Type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify(Data),
    });

    return await Response.json();
}

export function addResultNotification(title: string, result: CallbackResult) {
    AddNotification(
        "boosting-notif.png",
        ["#1a1922", "white"],
        title,
        result.message
    );
}
