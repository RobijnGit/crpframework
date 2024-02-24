import { Vector3 } from "../../shared/classes/math/vector3";
import { exp } from "../../shared/utils";
import { FW } from "../server";
import { DateTime } from 'luxon';

FW.Functions.CreateUsableItem("polaroid-binder", async (Source: number, Item: any) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    if (!await Player.Functions.GetItemBySlot(Item.Slot)) return;

    emitNet("fw-polaroid:Client:OpenBinder", Source, Item);
});

FW.Functions.CreateCallback("fw-polaroid:Server:SetPhotoDescription", async (Source: number, Cb: Function, BinderSlot: number, PhotoId: number, Description: string) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Item = await exp['fw-inventory'].GetInventoryItemBySlot(`ply-${Player.PlayerData.citizenid}`, BinderSlot);
    if (!Item || Item.Item != "polaroid-binder") return;

    const Photos = Item.Info?.Photos || [];

    if (Photos[PhotoId]) Photos[PhotoId].Description = Description;

    Player.Functions.SetItemKV("polaroid-binder", BinderSlot, 'Photos', Photos);

    Cb(Photos);
});

FW.Functions.CreateCallback("fw-polaroid:Server:MoveToInventory", async (Source: number, Cb: Function, BinderSlot: number, PhotoId: number) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Item = await exp['fw-inventory'].GetInventoryItemBySlot(`ply-${Player.PlayerData.citizenid}`, BinderSlot);
    if (!Item || Item.Item != "polaroid-binder") return;

    const Photos = Item.Info?.Photos || [];

    if (Photos[PhotoId]) {
        Player.Functions.AddItem("polaroid-photo", 1, false, {
            Image: Photos[PhotoId].Image,
            Date: Photos[PhotoId].Date,
            Description: Photos[PhotoId].Description,
        }, true);
    };

    Photos.splice(PhotoId, 1);
    Player.Functions.SetItemKV("polaroid-binder", BinderSlot, 'Photos', Photos);

    Cb(Photos);
});

FW.Functions.CreateCallback("fw-polaroid:Server:DeletePhoto", async (Source: number, Cb: Function, BinderSlot: number, PhotoId: number) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Item = await exp['fw-inventory'].GetInventoryItemBySlot(`ply-${Player.PlayerData.citizenid}`, BinderSlot);
    if (!Item || Item.Item != "polaroid-binder") return;

    const Photos = Item.Info?.Photos || [];
    Photos.splice(PhotoId, 1);
    Player.Functions.SetItemKV("polaroid-binder", BinderSlot, 'Photos', Photos);

    Cb(Photos);
});

FW.RegisterServer("fw-polaroid:Server:AddIntoPhotobook", async (Source: number, Url?: string, ItemData?: any, BinderSlot?: number) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Binder = Player.Functions.GetItemByName("polaroid-binder");
    if (!Binder) {
        return Player.Functions.Notify("Je hebt geen binder!", "error");
    }

    const Photos = Binder.Info?.Photos || [];

    if (Url) {
        Photos.push({
            Image: Url,
            Date: DateTime.now().toFormat('MM/dd/yyyy'),
        });

        Player.Functions.SetItemKV("polaroid-binder", Binder.Slot, 'Photos', Photos);
    } else if (ItemData) {
        const Item = await exp['fw-inventory'].GetInventoryItemBySlot(`ply-${Player.PlayerData.citizenid}`, ItemData.Slot);

        Photos.push({
            Image: Item.Info.Image,
            Date: Item.Info.Date,
            Description: Item.Info?.Description || undefined,
        });

        Player.Functions.SetItemKV("polaroid-binder", BinderSlot, 'Photos', Photos);
        Player.Functions.RemoveItem('polaroid-photo', 1, ItemData.Slot, true);
    };
});

FW.RegisterServer("fw-polaroid:Server:ShareNearby", async (Source: number, BinderSlot: number, PhotoId: number) => {
    const Player = FW.Functions.GetPlayer(Source);
    if (!Player) return;

    const Item = await exp['fw-inventory'].GetInventoryItemBySlot(`ply-${Player.PlayerData.citizenid}`, BinderSlot);
    if (!Item || Item.Item != "polaroid-binder") return;

    const Photos = Item.Info?.Photos || [];

    if (Photos[PhotoId]) {
        // @ts-ignore
        const Coords = new Vector3().setFromArray(GetEntityCoords(GetPlayerPed(Source.toString())));
        const Players = FW.GetPlayers();
        for (let i = 0; i < Players.length; i++) {
            const Target = Players[i];
    
            // @ts-ignore
            const [x, y, z] = GetEntityCoords(GetPlayerPed(Target.ServerId));
            if (Coords.getDistance({x, y, z}) < 3.0) emitNet("fw-polaroid:Client:ShowPhoto", Target.ServerId, Photos[PhotoId]);
        };
    }
});