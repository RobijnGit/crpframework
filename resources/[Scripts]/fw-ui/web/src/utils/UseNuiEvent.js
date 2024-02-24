import { onMount, onDestroy } from "svelte";

export const UseNuiEvent = (action, handler) => {
    const eventListener = (event) => {
        const { App, Action: eventAction } = event.data;
        if (`${App}/${eventAction}` === action) {
            handler(event.data.Payload);
        }
    };

    onMount(() => window.addEventListener("message", eventListener));
    onDestroy(() => window.removeEventListener("message", eventListener));
};