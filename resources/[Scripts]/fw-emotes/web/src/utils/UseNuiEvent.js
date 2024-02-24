import { onMount, onDestroy } from "svelte";

export const UseNuiEvent = (action, handler) => {
    const eventListener = (event) => {
        const { Action: eventAction, Data } = event.data;
        if (`${eventAction}` === action) {
            handler(Data);
        }
    };

    onMount(() => window.addEventListener("message", eventListener));
    onDestroy(() => window.removeEventListener("message", eventListener));
};