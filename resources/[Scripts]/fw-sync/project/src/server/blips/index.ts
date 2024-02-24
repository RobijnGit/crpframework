import { blipTypes } from "../../shared/blips";
import { Thread } from "../../shared/classes/thread";

const blipsCache: {[key: number]: any} = {}
const BlipThread = new Thread("tick", 2000);

BlipThread.addHook("active", () => {
    for (let i = 0; i < blipTypes.length; i++) {
        const BlipGroup = blipTypes[i];
        
        // Fetch the data we want to send to the client
        let blipData = [];
        for (let j = 0; j < BlipGroup.subscribers.length; j++) {
            const Subscriber = BlipGroup.subscribers[j];
            
            if (Subscriber) {
                // @ts-ignore
                const Ped = GetPlayerPed(Subscriber.source);
                if (DoesEntityExist(Ped)) {

                    // @ts-ignore
                    const [x, y, z] = GetEntityCoords(Ped);

                    // @ts-ignore
                    const Label = blipsCache[Subscriber.source]?.label || GetPlayerName(Subscriber.source);

                    // array instead of object bcuz its less packet size :)
                    blipData.push([
                        x, y, z, // position
                        i, // group id for blip template (color, scale, alpha etc)
                        Subscriber.subGroup,
                        Subscriber.source, // player id, to check if it exists on the client - if so, it should generate a blip on entity and not on pos for realtime update
                        Label, // label of the blip
                    ]);
                };
            };
        };

        // Send the data to the subscribers
        for (let j = 0; j < BlipGroup.subscribers.length; j++) {
            const Subscriber = BlipGroup.subscribers[j];
            if (Subscriber) {
                emitNet("fw-sync:Client:Blips:SyncBlips", Subscriber.source, blipData);
            };
        };
    };
});

onNet("fw-sync:Server:Blips:SubscribeToGroup", (Group: string, SubGroup?: string) => {
    const Src = source;
    const groupIndex = blipTypes.findIndex(Val => Val.group == Group);
    if (groupIndex == -1) return;

    // Already subscribed??
    if (blipTypes[groupIndex].subscribers.findIndex(Val => Val.source == Src) != -1) return;

    if (!blipsCache[Src]) blipsCache[Src] = {}
    blipsCache[Src].group = Group;
    blipTypes[groupIndex].subscribers.push({
        source: Src,
        subGroup: SubGroup
    });
});

onNet("fw-sync:Server:Blips:UnsubscribeFromGroup", (Group: string) => {
    const Src = source;
    blipsCache[Src] = undefined;

    const groupIndex = blipTypes.findIndex(Val => Val.group == Group);
    if (groupIndex == -1) return;

    blipTypes[groupIndex].subscribers = blipTypes[groupIndex].subscribers.filter(Val => Val.source != Src);
    for (let i = 0; i < blipTypes[groupIndex].subscribers.length; i++) {
        emitNet("fw-sync:Client:Blips:RemoveUnsubscriber", blipTypes[groupIndex].subscribers[i].source, Src)
    }
});

onNet("fw-sync:Server:Blips:RegisterSourceName", (Name: string, Target?: number) => {
    const Src = Target || source;
    if (!blipsCache[Src]) blipsCache[Src] = {};
    blipsCache[Src].label = Name;
});

on("playerDropped", () => {
    const Src = source;
    if (!blipsCache[Src]) return;
    
    const groupIndex = blipTypes.findIndex(Val => Val.group == blipsCache[Src].group);
    if (groupIndex == -1) return;

    blipsCache[Src] = undefined;

    blipTypes[groupIndex].subscribers = blipTypes[groupIndex].subscribers.filter(Val => Val.source != Src);
    for (let i = 0; i < blipTypes[groupIndex].subscribers.length; i++) {
        emitNet("fw-sync:Client:Blips:RemoveUnsubscriber", blipTypes[groupIndex].subscribers[i].source, Src)
    }
});

export default () => {
    BlipThread.start();
}