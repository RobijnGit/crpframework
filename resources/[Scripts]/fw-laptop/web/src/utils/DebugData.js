import { IsEnvBrowser } from "./Utils";

export const DebugData = (events, timer) => {
    if (IsEnvBrowser()) {
        for (const event of events) {
            setTimeout(() => {
                window.dispatchEvent(
                    new MessageEvent("message", {
                        data: {
                            Action: event.action,
                            Data: event.data,
                        },
                    })
                );
            }, timer || 1000);
        }
    }
};