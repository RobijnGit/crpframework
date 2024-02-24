import { Delay, RegisterNUICallback, SendUIMessage, SetUIFocus, exp } from "../../shared/utils";
import { FW } from "../client";

let CurrentPolaroidBinder: number;

on("fw-inventory:Client:OnItemInsert", (FromItem: any, ToItem: any) => {
    if (FromItem.Item != "polaroid-photo") return;
    if (ToItem.Item != "polaroid-binder") return;

    FW.TriggerServer("fw-polaroid:Server:AddIntoPhotobook", false, FromItem, ToItem.Slot);
});

onNet("fw-polaroid:Client:OpenBinder", async (Item: any) => {
    CurrentPolaroidBinder = Item.Slot

    RequestAnimDict('amb@code_human_in_bus_passenger_idles@female@tablet@base')
    while (!HasAnimDictLoaded("amb@code_human_in_bus_passenger_idles@female@tablet@base")) {
        await Delay(50)
    }
    TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3.0, 3.0, -1, 49, 0, false, false, false);

    SetUIFocus(true, true);
    SendUIMessage("Polaroid", "SetBinderVisibility", {
        Visible: true,
        Photos: Item.Info?.Photos || [],
    });

    exp['fw-assets'].AddProp("PolaroidPhotobook")
});

RegisterNUICallback("Polaroid/SetPhotoDescription", async (Data: any, Cb: Function) => {
    const Photos = await FW.SendCallback("fw-polaroid:Server:SetPhotoDescription", CurrentPolaroidBinder, Data.PhotoId, Data.Description);
    SendUIMessage("Polaroid", "SetBinderPhotos", {
        Photos: Photos,
    });

    Cb("Ok");
});

RegisterNUICallback("Polaroid/SharePhoto", async (Data: any, Cb: Function) => {
    FW.TriggerServer("fw-polaroid:Server:ShareNearby", CurrentPolaroidBinder, Data.PhotoId);
    Cb("Ok");
});

RegisterNUICallback("Polaroid/MoveToInventory", async (Data: any, Cb: Function) => {
    const Photos = await FW.SendCallback("fw-polaroid:Server:MoveToInventory", CurrentPolaroidBinder, Data.PhotoId);
    SendUIMessage("Polaroid", "SetBinderPhotos", {
        Photos: Photos,
    });

    Cb("Ok");
});

RegisterNUICallback("Polaroid/Delete", async (Data: any, Cb: Function) => {
    const Photos = await FW.SendCallback("fw-polaroid:Server:DeletePhoto", CurrentPolaroidBinder, Data.PhotoId);
    SendUIMessage("Polaroid", "SetBinderPhotos", {
        Photos: Photos,
    });

    Cb("Ok");
});

RegisterNUICallback("Polaroid/Close", () => {
    SetUIFocus(false, false);
    SendUIMessage("Polaroid", "SetBinderVisibility", {
        Visible: false,
    });
    exp['fw-assets'].RemoveProp();
    StopAnimTask(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 1.0);
});