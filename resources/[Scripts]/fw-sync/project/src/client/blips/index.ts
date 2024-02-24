// import './tests';
import { blipTypes } from "../../shared/blips";
import { Thread } from '../../shared/classes/thread';
import { exp } from '../../shared/utils';

const BlipThread = new Thread("tick", 1000);
const debug = GetConvar("sv_serverCode", "wl") == "dev";
let blipsCache: {[key: number]: any} = {};

export const AddSubscriberToGroup = (Group: string, SubGroup?: string) => {
    if (debug) console.log(`[BLIPS]: Subscribing ${GetPlayerServerId(PlayerId())} to '${Group}' (subGroup: ${SubGroup || "none"})`);
    emitNet("fw-sync:Server:Blips:SubscribeToGroup", Group, SubGroup);
};
exp("AddSubscriberToGroup", AddSubscriberToGroup);

export const RemoveSubscriberFromGroup = (Group: string) => {
    emitNet("fw-sync:Server:Blips:UnsubscribeFromGroup", Group);

    for (const [_subscriberId, subscriberData] of Object.entries(blipsCache)) {
        if (subscriberData?.syncedBlipId) RemoveBlip(subscriberData.syncedBlipId);
        if (subscriberData?.blipId) RemoveBlip(subscriberData.blipId);
    }
    blipsCache = {};

    if (debug) console.log(`[BLIPS]: Unsubscribing ${GetPlayerServerId(PlayerId())} from '${Group}'`);
};
exp("RemoveSubscriberFromGroup", RemoveSubscriberFromGroup);

const CreatePlayerBlip = (x: number, y: number, z: number, Properties: any) => {
    if (blipsCache[Properties.subscriberId].blipId) RemoveBlip(blipsCache[Properties.subscriberId]);

    const blipId = AddBlipForCoord(x + 0.001, y + 0.001, z + 0.001);
    SetBlipProperties(blipId, Properties);
    return blipId;
};

const SetBlipProperties = (BlipId: number, Properties: any) => {
    const currentSprite = GetBlipSprite(BlipId);
    const currentColor = GetBlipColour(BlipId);

    // update blip if changed
    const BlipConfiguration = blipTypes[Properties.groupId];

    let Sprite = BlipConfiguration?.sprite || 1;
    let Color = BlipConfiguration?.color || 0;
    let Scale = BlipConfiguration?.scale || 1.0;
    let Alpha = BlipConfiguration?.alpha || 255;
    let ShowOffScreen = BlipConfiguration?.showOffScreen || false;
    let ShowLocalDirection = BlipConfiguration?.showLocalDirection || false;

    const Vehicle = GetVehiclePedIsIn(Properties.playerPed, false);
    if (Vehicle != -1 && GetVehicleClass(Vehicle) == 15) Sprite = 43;

    if (Properties.subGroup) {
        const SubGroupData = BlipConfiguration?.subGroups?.find(Val => Val.id == Properties.subGroup);
        if (SubGroupData && SubGroupData.color) Color = SubGroupData.color;
    }

    if (currentSprite != Sprite || currentColor != Color) {
        SetBlipSprite(BlipId, Sprite);
        SetBlipColour(BlipId, Color);
        SetBlipScale(BlipId, Scale);
        SetBlipAlpha(BlipId, Alpha);
        SetBlipAsShortRange(BlipId, !ShowOffScreen);
        ShowHeadingIndicatorOnBlip(BlipId, ShowLocalDirection);
        if (ShowLocalDirection) SetBlipRotation(BlipId, Math.ceil(GetEntityHeading(Properties.playerPed)));
        SetBlipCategory(BlipId, 7);
    };

    // always update label
    BeginTextCommandSetBlipName('STRING');
    AddTextComponentString(Properties.label);
    EndTextCommandSetBlipName(BlipId);
};

const UpdatePlayerBlip = (SubscriberId: number, SubscriberCache: any, GroupId: number, subGroup?: string) => {
    if (!SubscriberCache.needsServer) return;

    if (!blipsCache[SubscriberId]?.blipId) {
        blipsCache[SubscriberId].blipId = CreatePlayerBlip(SubscriberCache.x, SubscriberCache.y, SubscriberCache.z, SubscriberCache);
    };

    // remove synced blip if it exists.
    if (blipsCache[SubscriberId].syncedBlipId) {
        RemoveBlip(blipsCache[SubscriberId].syncedBlipId);
        blipsCache[SubscriberId].syncedBlipId = undefined;
    };

    if (blipsCache[SubscriberId].blipId && DoesBlipExist(blipsCache[SubscriberId].blipId)) {
        SetBlipCoords(blipsCache[SubscriberId].blipId, SubscriberCache.x + 0.001, SubscriberCache.y + 0.001, SubscriberCache.z + 0.001);
    };
}

onNet("fw-sync:Client:Blips:RemoveUnsubscriber", (Unsubscriber: number) => {
    const subscriberData = blipsCache[Unsubscriber]
    if (!subscriberData) return;

    blipsCache[Unsubscriber] = undefined;
    if (subscriberData.syncedBlipId) RemoveBlip(subscriberData.syncedBlipId);
    if (subscriberData.blipId) RemoveBlip(subscriberData.blipId);
});

onNet("fw-sync:Client:Blips:SyncBlips", (blipData: any) => {
    const ServerId = GetPlayerServerId(PlayerId());

    // if (debug) {
    //     console.log(`[BLIPS]: Updating blips..`, JSON.stringify(blipData))
    // };

    for (let i = 0; i < blipData.length; i++) {
        const [x, y, z, groupId, subGroup, subscriberId, label]: [number, number, number, number, string, number, string] = blipData[i];

        if (!blipsCache[subscriberId]) blipsCache[subscriberId] = {};
        blipsCache[subscriberId].needsServer = true;

        // If the player is ACTIVE on NETWORK, they are in range to be set on entity instead of pos!
        const playerId = GetPlayerFromServerId(subscriberId);
        const IsNetworked = NetworkIsPlayerActive(playerId);

        if (IsNetworked) {
            blipsCache[subscriberId].needsServer = false;
            blipsCache[subscriberId].playerPed = GetPlayerPed(playerId);

            // Do not show self on production.
            if (subscriberId == ServerId && !debug) blipsCache[subscriberId].ignored = true;
        } else {
            // if (debug) console.log(`[BLIPS]: ${subscriberId} is not networked..`);
        };

        // if ingored, skip to next blip.
        blipsCache[subscriberId] = {...blipsCache[subscriberId], x, y, z, groupId, subGroup, subscriberId, label};
        if (!blipsCache[subscriberId].needsServer || blipsCache[subscriberId].ignored) continue;

        if (blipsCache[subscriberId].blipId) {
            UpdatePlayerBlip(subscriberId, blipsCache[subscriberId], groupId, subGroup);
        } else {
            blipsCache[subscriberId].blipId = CreatePlayerBlip(x, y, z, blipsCache[subscriberId])
        }
    };
});

BlipThread.addHook("active", () => {
    for (const [_subscriberId, subscriberData] of Object.entries(blipsCache)) {
        if (!subscriberData || subscriberData.ignored) continue;
        const subscriberId: number = Number(_subscriberId);

        // In case if it was just synced, but the player left in between the time of the latest sync and this loop.
        const playerId = GetPlayerFromServerId(subscriberId);
        const IsNetworked = NetworkIsPlayerActive(playerId);
        if (!IsNetworked) {
            blipsCache[subscriberId].needsServer = true;
            UpdatePlayerBlip(subscriberId, blipsCache[subscriberId], subscriberData.groupId, subscriberData.subGroup);
            continue;
        };

        if (subscriberData.blipId) {
            RemoveBlip(subscriberData.blipId)
            blipsCache[subscriberId].blipId = false;
        };
        if (!subscriberData.syncedBlipId) blipsCache[subscriberId].syncedBlipId = AddBlipForEntity(subscriberData.playerPed);

        if (GetBlipFromEntity(subscriberData.playerPed)) {
            SetBlipProperties(blipsCache[subscriberId].syncedBlipId, subscriberData);
        };
    };
});

export default () => {
    BlipThread.start();

    // const playerData = FW.Functions.GetPlayerData();
    // AddSubscriberToGroup("gov", playerData.metadata.division)
    // emitNet("fw-sync:Server:Blips:RegisterSourceName", `${playerData.metadata.callsign} | ${playerData.charinfo.firstname} ${playerData.charinfo.lastname}`)
}