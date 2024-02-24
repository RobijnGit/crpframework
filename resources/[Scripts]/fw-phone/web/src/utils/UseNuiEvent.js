import { onMount, onDestroy } from "svelte";

export const UseNuiEvent = (action, handler) => {
    const eventListener = (event) => {
        const { Action: eventAction } = event.data;
        if (`${eventAction}` === action) {
            handler(event.data);
        }
    };

    onMount(() => window.addEventListener("message", eventListener));
    onDestroy(() => window.removeEventListener("message", eventListener));
};