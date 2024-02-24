import { exp } from "../shared/utils"
import { Vector3 } from "../shared/classes/math/vector3"
export const FW = exp['fw-core'].GetCoreObject();

import './handlers/camera';
import './handlers/binder';

FW.Functions.CreateUsableItem("polaroid-photo", async (Source: number, Item: any) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (!await Player.Functions.GetItemBySlot(Item.Slot)) return;

    emitNet('fw-polaroid:Client:ShowPhotoAnim', Source);

    // @ts-ignore
    const Coords = new Vector3().setFromArray(GetEntityCoords(GetPlayerPed(Source.toString())));
    const Players = FW.GetPlayers();
    for (let i = 0; i < Players.length; i++) {
        const Target = Players[i];

        // @ts-ignore
        const [x, y, z] = GetEntityCoords(GetPlayerPed(Target.ServerId));
        if (Coords.getDistance({x, y, z}) < 3.0) emitNet("fw-polaroid:Client:ShowPhoto", Target.ServerId, Item.Info);
    };
});