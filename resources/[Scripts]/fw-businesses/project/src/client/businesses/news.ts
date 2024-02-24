import { Delay, exp } from "../../shared/utils";
import { Vector3 } from "../../shared/classes/math"; 
import { FW } from "../client";
import { Thread } from "../../shared/classes/thread";

onNet("fw-business:Client:News:OpenStash", (Data: {
    Stash: string;
}) => {
    const Job = FW.Functions.GetPlayerData().job;
    if (Job.name != "news" || Job.grade.level != '1') return FW.Functions.Notify("Geen toegang..", "error");

    if (!exp['fw-inventory'].CanOpenInventory()) return;
    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', `business_news_${Data.Stash}`, 20, 2000)
});

const [ FovMax, FovMin, ZoomSpeed, SpeedLR, SpeedUD ] = [ 70, 5, 10, 8.0, 8.0 ];
let Camera: number = 0;
let CameraCam: number = 0;
let CameraFov = (FovMax + FovMin) / 2;

const CameraThread = new Thread("tick", 4);
CameraThread.addHook("active", () => {
    if (!IsEntityPlayingAnim(PlayerPedId(), "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 3)) {
        TaskPlayAnim(PlayerPedId(), "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 1.0, -1, -1, 50, 0, false, false, false)
    };

    DisablePlayerFiring(PlayerId(), true);
    DisableControlAction(0, 25, true);
    DisableControlAction(0, 44, true);
    DisableControlAction(0, 37, true);

    const RightAxisX = GetDisabledControlNormal(0, 220);
    const RightAxisY = GetDisabledControlNormal(0, 221);
    const [RotationX, RotationY, RotationZ] = GetCamRot(CameraCam, 2);

    if (RightAxisX != 0.0 || RightAxisY != 0.0) {
        const ZoomValue = (1.0 / (FovMax - FovMin)) * (CameraFov - FovMin)
        SetCamRot(CameraCam, Math.max(Math.min(20.0, RotationX + RightAxisY * -1.0 * (SpeedLR) * (ZoomValue+0.1)), -89.5), 0.0, RotationZ + RightAxisX * -1.0 * (SpeedUD) * (ZoomValue + 0.1), 2);
    };

    let CurrentFov = GetCamFov(CameraCam);
    if (IsControlJustPressed(0, 241)) CameraFov = Math.max(CameraFov - ZoomSpeed, FovMin);
    if (IsControlJustPressed(0, 242)) CameraFov = Math.min(CameraFov + ZoomSpeed, FovMax);
    if (Math.abs(CameraFov - CurrentFov) < 0.1) CameraFov = CurrentFov;

    SetCamFov(CameraCam, CurrentFov + (CameraFov - CurrentFov) * 0.05);

    let CamHeading = GetGameplayCamRelativeHeading();
    let CamPitch = GetGameplayCamRelativePitch();
    if (CamPitch < -70.0) {
        CamPitch = -70.0
    } else if (CamPitch > 42.0) {
        CamPitch = 42.0
    };
    CamPitch = (CamPitch + 70.0) / 112.0;

    if (CamHeading < -180.0) {
        CamHeading = -180.0
    } else if (CamHeading > 180.0) {
        CamHeading = 180.0
    };
    CamHeading = (CamHeading + 180.0) / 360.0;

    SetTaskMoveNetworkSignalFloat(PlayerPedId(), "Pitch", CamPitch);
    SetTaskMoveNetworkSignalFloat(PlayerPedId(), "Heading", CamHeading * -1.0 + 1.0);
});

CameraThread.addHook("afterStop", () => {
    ClearTimecycleModifier()
    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(CameraCam, false)
    SetNightvision(false)
    SetSeethrough(false)
    DeleteObject(Camera)
    StopAnimTask(PlayerPedId(), "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 1.0)
});

onNet("fw-items:Client:Used:NewsCamera", async () => {
    if (CameraThread.running) return CameraThread.stop();

    CameraFov = (FovMax + FovMin) / 2;

    while (!HasModelLoaded("prop_v_cam_01")) {
        RequestModel("prop_v_cam_01");
        await Delay(100);
    }

    while (!HasAnimDictLoaded("missfinale_c2mcs_1")) {
        RequestAnimDict("missfinale_c2mcs_1");
        await Delay(100);
    };

    const [camCoordsX, camCoordsY, camCoordsZ] = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -5.0)
    Camera = CreateObjectNoOffset(GetHashKey("prop_v_cam_01"), camCoordsX, camCoordsY, camCoordsZ, true, true, false);

    await Delay(100);

    SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(Camera), true);
    NetworkSetNetworkIdDynamic(NetworkGetNetworkIdFromEntity(Camera), true);
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(Camera), false);

    AttachEntityToEntity(Camera, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 0, true);
    TaskPlayAnim(PlayerPedId(), "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 1.0, -1, -1, 50, 0, false, false, false);

    CameraCam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)

    AttachCamToEntity(CameraCam, PlayerPedId(), 0.0, 0.0, 1.0, true)
    SetCamRot(CameraCam, 2.0, 1.0, GetEntityHeading(PlayerPedId()), 0)
    SetCamFov(CameraCam, CameraFov)
    RenderScriptCams(true, false, 0, true, false);

    CameraThread.start();
});

let HasNewsMic: boolean = false;
let Microphone: number = 0;
onNet("fw-items:Client:Used:NewsMic", async () => {
    HasNewsMic = !HasNewsMic;

    if (!HasNewsMic) {
        DeleteObject(Microphone);
        return;
    };

    while (!HasModelLoaded("p_ing_microphonel_01")) {
        RequestModel("p_ing_microphonel_01");
        await Delay(100);
    };

    const [MicCoordsX, MicCoordsY, MicCoordsZ] = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -5.0);
    Microphone = CreateObject(GetHashKey("p_ing_microphonel_01"), MicCoordsX, MicCoordsY, MicCoordsZ, true, false, false)
    await Delay(100);
    SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(Microphone), true)
    NetworkSetNetworkIdDynamic(NetworkGetNetworkIdFromEntity(Microphone), true)
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(Microphone), false)
    AttachEntityToEntity(Microphone, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), 0.055, 0.05, 0.0, 240.0, 0.0, 0.0, true, true, false, true, 0, true);
});

setImmediate(() => {
    exp['fw-ui'].AddEyeEntry("news-highcommand-cabin", {
        Type: 'Zone',
        SpriteDistance: 10.0,
        Distance: 1.0,
        ZoneData: {
            Center: new Vector3(-566.51, -916.43, 23.87),
            Length: 2.4,
            Width: 0.3,
            Data: {
                heading: 0,
                minZ: 22.87,
                maxZ: 24.87
            },
        },
        Options: [
            {
                Name: 'employees',
                Icon: 'fas fa-users',
                Label: 'Nieuws Mederwekerslijst',
                EventType: 'Client',
                EventName: 'fw-police:Client:OpenEmployeelist',
                EventParams: { Job: 'news' },
                Enabled: () => {
                    const Job = FW.Functions.GetPlayerData().job;
                    return Job.name == "news" && Job.grade.level == '1';
                },
            },
            {
                Name: 'highcommand_badge',
                Icon: 'fas fa-id-badge',
                Label: 'Nieuws Pas Maken',
                EventType: 'Client',
                EventName: 'fw-ui:Client:CreateBadge',
                EventParams: { Badge: 'news', Department: "Los Santos Broadcasting Network" },
                Enabled: () => {
                    const Job = FW.Functions.GetPlayerData().job;
                    return Job.name == "news" && Job.grade.level == '1';
                },
            },
            {
                Name: 'stash',
                Icon: 'fas fa-box-open',
                Label: 'Open',
                EventType: 'Client',
                EventName: 'fw-business:Client:News:OpenStash',
                EventParams: { Stash: 'Highcommand' },
                Enabled: () => {
                    const Job = FW.Functions.GetPlayerData().job;
                    return Job.name == "news" && Job.grade.level == '1';
                },
            }
        ]
    });

    exp['fw-ui'].AddEyeEntry("news-grab-equipment", {
        Type: 'Zone',
        SpriteDistance: 10.0,
        Distance: 1.0,
        ZoneData: {
            Center: new Vector3(-587.38, -921.97, 23.87),
            Length: 1.2,
            Width: 2.4,
            Data: {
                heading: 315,
                minZ: 23.77,
                maxZ: 24.27
            },
        },
        Options: [
            {
                Name: 'grab_camera',
                Icon: 'fas fa-camera',
                Label: 'Camera Kopen (€ 85,00)',
                EventType: 'Server',
                EventName: 'fw-businesses:Server:News:PurchaseCamera',
                EventParams: {},
                Enabled: () => {
                    const Job = FW.Functions.GetPlayerData().job;
                    return Job.name == "news" && Job.grade.level == '1';
                },
            },
            {
                Name: 'grab_mic',
                Icon: 'fas fa-microphone',
                Label: 'Microfoon Kopen (€ 85,00)',
                EventType: 'Server',
                EventName: 'fw-businesses:Server:News:PurchaseMic',
                EventParams: {},
                Enabled: () => {
                    const Job = FW.Functions.GetPlayerData().job;
                    return Job.name == "news" && Job.grade.level == '1';
                },
            },
        ]
    });
});