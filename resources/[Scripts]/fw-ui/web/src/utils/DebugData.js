import { IsEnvBrowser } from "./Utils";

export const DebugData = (events, timer) => {
    if (IsEnvBrowser()) {
        for (const event of events) {
            setTimeout(() => {
                window.dispatchEvent(
                    new MessageEvent("message", {
                        data: {
                            App: event.app,
                            Action: event.action,
                            Payload: event.payload,
                        },
                    })
                );
            }, timer || 1000);
        }
    }
};