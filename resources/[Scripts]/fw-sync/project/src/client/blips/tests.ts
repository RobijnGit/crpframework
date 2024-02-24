import { AddSubscriberToGroup, RemoveSubscriberFromGroup } from "."

RegisterCommand("subscribeToGroup", (Source: number, Args: string[], Raw: string) => {
    AddSubscriberToGroup(Args[0], Args[1]);

}, false)

RegisterCommand("removeSubscribeFromGroup", (Source: number, Args: string[], Raw: string) => {
    RemoveSubscriberFromGroup(Args[0]);
}, false)