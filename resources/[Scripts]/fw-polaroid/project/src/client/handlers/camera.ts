import { FW } from "../client";
import { Thread } from "../../shared/classes/thread";
import { Delay, GetRandom, SendUIMessage, exp } from "../../shared/utils";
import { Filters } from "../../shared/config";

const CameraThread = new Thread("tick", 4);
const PauseThread = new Thread("tick", 4);
PauseThread.addHook("active", () => SetPauseMenuActive(false));

let FovMax = 80.0;
let FovMin = 20.0;
let CurrentFov = 40.0;
let SnappingPhoto: boolean = false;

let DiscordWebhook: string;
setImmediate(async () => {
    DiscordWebhook = await FW.SendCallback("fw-polaroid:Server:GetWebhook")
});

on("fw-inventory:Client:OnItemInsert", async (FromItem: any, ToItem: any) => {
    if (FromItem.Item != "polaroid-battery") return;
    if (ToItem.Item != "polaroid-camera") return;

    const Quality = await exp['fw-inventory'].CalculateQuality(ToItem.Item, ToItem.CreateDate);
    if (Quality >= 20.0) return FW.Functions.Notify("Je Polaroid Camera is al opgeladen..", "error");

    exp['fw-inventory'].SetBusyState(true);

    await Delay(200);

    const Finished = await FW.Functions.CompactProgressbar(5000, "Batterijen vervangen..", false, true, {
        disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
    }, {
        animDict: 'amb@world_human_hang_out_street@female_hold_arm@idle_a',
        anim: 'idle_a',
        flags: 8,
    }, {}, {}, false)

    StopAnimTask(PlayerPedId(), 'amb@world_human_hang_out_street@female_hold_arm@idle_a', 'idle_a', 1.0);

    exp['fw-inventory'].SetBusyState(false);

    if (!Finished) return;

    const DidRemove = await FW.SendCallback("FW:RemoveItem", "polaroid-battery", 1, FromItem.Slot);
    if (!DidRemove) return;

    FW.TriggerServer("fw-polaroid:Server:RechargeCamera", ToItem.Slot);
});

onNet("fw-polaroid:Client:OpenCamera", async () => {
    if (!exp['fw-inventory'].HasEnoughOfItem("polaroid-paper", 1)) {
        return FW.Functions.Notify("Je hebt Polaroid Film nodig om een foto te kunnen maken..");
    };

    if (SnappingPhoto) return;

    exp['fw-inventory'].SetBusyState(true);

    const FilmsLeft = await exp['fw-inventory'].GetItemCount('polaroid-paper');
    SendUIMessage("Polaroid", "SetCameraVisibility", {
        Visible: true,
        FilmsLeft,
    });

    CameraThread.start();
    PauseThread.start();
});

on("fw-polaroid:Client:ChangeTimecycle", (Data: any) => {
    if (Data.Timecycle == 'Clear') {
        ClearTimecycleModifier()
    } else {
        SetTimecycleModifier(Data.Timecycle)
    };
});

let PolaroidCamera: number;
CameraThread.addHook("preStart", () => {
    PolaroidCamera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true);
    AttachCamToEntity(PolaroidCamera, PlayerPedId(), 0.0, 0.5, 0.7, true);
    SetCamRot(PolaroidCamera, 0.0, 0.0, GetEntityHeading(PlayerPedId()), 0);
    SetCamFov(PolaroidCamera, 40.0);
    RenderScriptCams(true, false, 0, true, false);

    CurrentFov = 40.0;

    TriggerEvent('fw-emotes:Client:PlayEmote', "photography", null, true)
    exp['fw-assets'].AddProp(`PolaroidCamera${GetRandom(1, 3)}`);
});

CameraThread.addHook("active", async () => {
    if (SnappingPhoto) return;

    HandleZoom(PolaroidCamera, CurrentFov);
    CheckInputRotation(PolaroidCamera, 1.0);

    SetPauseMenuActive(false);
    if (IsControlJustPressed(0, 25) || IsControlJustPressed(0, 200)) {
        CameraThread.stop();
    };

    DisableControlAction(0, 24, true);
    if (IsDisabledControlJustReleased(0, 24)) {
        FW.Functions.OpenMenu({
            MainMenuItems: [
                ...Filters.map((Val) => {
                    return {
                        Icon: "image-polaroid",
                        Title: Val.Label,
                        Desc: "Klik om de filter te selecteren.",
                        Data: { Event: 'fw-polaroid:Client:ChangeTimecycle', Type: 'Client', Timecycle: Val.Timecycle }
                    }
                })
            ]
        });
    };

    if (IsControlJustReleased(0, 38)) {
        SnappingPhoto = true;

        const DidRemove = await FW.SendCallback("FW:RemoveItem", "polaroid-paper", 1);
        if (!DidRemove) {
            SnappingPhoto = false;
            return;
        };

        let Data: any = {};
        exp['screenshot-basic'].requestScreenshotUpload(DiscordWebhook, 'files[]', {
            encoding: 'jpg',
            ratio: "1:1",
            quality: 0.8
        }, (Result: any) => {
            Data = JSON.parse(Result);
        });

        await Delay(300);

        CameraThread.stop();

        const Finished = await FW.Functions.CompactProgressbar(12000, "Printen..", false, false, {
            disableMovement: false, disableCarMovement: false, disableMouse: false, disableCombat: true
        }, {
            animDict: 'friends@fra@ig_1',
            anim: 'base_idle',
            flags: 8,
        }, {}, {}, false);

        SnappingPhoto = false;
        StopAnimTask(PlayerPedId(), 'friends@fra@ig_1', 'base_idle', 1.0);

        if (Finished && Data?.attachments) {
            if (exp['fw-inventory'].HasEnoughOfItem("polaroid-binder", 1)) {
                FW.TriggerServer("fw-polaroid:Server:AddIntoPhotobook", Data.attachments[0].proxy_url)
            } else {
                FW.TriggerServer("fw-polaroid:Server:ReceivePhoto", Data.attachments[0].proxy_url)
            };
        };
    };
});

CameraThread.addHook("afterStop", () => {
    exp['fw-assets'].RemoveProp();
    exp['fw-ui'].CloseContextMenu({Force: true});
    RenderScriptCams(false, false, 1, true, true);
    SetCamActive(PolaroidCamera, false);
    SetFocusEntity(PlayerPedId());
    DestroyCam(PolaroidCamera, true);
    ClearPedTasks(PlayerPedId());
    ClearTimecycleModifier();
    exp['fw-inventory'].SetBusyState(false);

    SendUIMessage("Polaroid", "SetCameraVisibility", { Visible: false });
    
    setTimeout(() => {
        PauseThread.stop();
    }, 500);
});

const CheckInputRotation = (Camera: number, ZoomValue:  number) => {
    const RightAxisX = GetDisabledControlNormal(0, 220);
    const RightAxisY = GetDisabledControlNormal(0, 221);
    const [x, y, z] = GetCamRot(Camera, 2)

    if (RightAxisX != 0 || RightAxisY != 0) {
        const NewX = Math.max(Math.min(45.0, x + RightAxisY * -1.0 * 8.0 * (ZoomValue + 0.1)), -89.5);
        const NewZ = z + RightAxisX * -1.0 * 8.0 * (ZoomValue + 0.1);
        SetCamRot(Camera, NewX, 0.0, NewZ, 2)
        if (GetVehiclePedIsIn(PlayerPedId(), false) == 0) SetEntityHeading(PlayerPedId(), NewZ);
    };
};

const HandleZoom = (Camera: number, Fov: number) => {
    const CurrentCFov = GetCamFov(Camera);

    if (IsControlJustPressed(0, 241)) CurrentFov = Math.max(Fov - 10.0, FovMin);
    if (IsControlJustPressed(0, 242)) CurrentFov = Math.min(Fov + 10.0, FovMax);

	SetCamFov(Camera, CurrentFov + (CurrentFov - CurrentCFov) * 0.05);
}