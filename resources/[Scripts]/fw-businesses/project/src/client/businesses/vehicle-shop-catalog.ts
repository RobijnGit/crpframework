import { VehicleShops } from "../../shared/types";
import { Thread } from "../../shared/classes/thread";
import { Vector3, Vector3Format, Vector4 } from "../../shared/classes/math";
import { Delay, RegisterNUICallback, SendUIMessage, SetUIFocus, exp } from "../../shared/utils";
import { FW } from "../client";

const CatalogThread = new Thread("tick", 4);

const UndergroundShowroom = new Vector3(-41.36324, -1052.294, -42.50);
const UndergroundShowroomCar = new Vector4(-37.26872, -1054.309, -43.37314, 32.1);

let Cam: number = 0;
let Vehicle: number = 0;
let UsingCatalog: boolean = false;

const AddCatalogZone = (ShopId: VehicleShops, ShopAbbvr: string, ShopLabel: string, ZoneData: {
    center: Vector3Format;
    length: number;
    width: number;
    heading: number;
    minZ: number;
    maxZ: number;
}) => {
    exp['PolyZone'].CreateBox({
        center: ZoneData.center,
        length: ZoneData.length,
        width: ZoneData.width,
    }, {
        name: `${ShopId}_catalog`,
        heading: ZoneData.heading,
        minZ: ZoneData.minZ,
        maxZ: ZoneData.maxZ,
    }, (IsInside: boolean) => {
        if (IsInside) {
            CatalogThread.data = {
                ShopId,
                ShopAbbvr,
                ShopLabel
            };
            CatalogThread.start();
        } else {
            CatalogThread.stop();
        }
    });
};

CatalogThread.addHook("preStart", (Data) => {
    exp['fw-ui'].ShowInteraction(`[E] ${Data.ShopAbbvr} Catalogus`)
});

CatalogThread.addHook("active", async (Data) => {
    if (IsControlJustReleased(0, 38) && !UsingCatalog) {
        UsingCatalog = true;

        exp['fw-assets'].AddProp('Tablet')
        await exp['fw-assets'].RequestAnimationDict('amb@code_human_in_bus_passenger_idles@female@tablet@base')
        TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3.0, 3.0, -1, 49, 0, false, false, false);

        const Vehicles = await FW.SendCallback("fw-businesses:Server:GetCatalog", Data.ShopId)
        SetUIFocus(true, true)
        SendUIMessage("VehicleCatalog", "SetVisibility", {
            Visible: true,
            Shop: Data.ShopLabel,
            Vehicles: Vehicles
        })

        exp['fw-ui'].HideInteraction()

        await Delay(1500);
        ToggleCatalogCam(true);
    };
})

CatalogThread.addHook("afterStop", () => {
    exp['fw-ui'].HideInteraction();
});

const ToggleCatalogCam = (pCreateCam: boolean) => {
    if (pCreateCam) {
        const CamCoords = UndergroundShowroom;

        Cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true);
        SetFocusArea(CamCoords.x, CamCoords.y,CamCoords.z, 0.0, 0.0, 0.0);
        SetCamCoord(Cam, CamCoords.x, CamCoords.y, CamCoords.z);
        SetCamRot(Cam, -15.0, 0.0, 252.063, 0);
        SetCamFov(Cam, 50.0);
        SetCamActive(Cam, true);
        RenderScriptCams(true, false, 1, true, true);
    } else {
        if (!Cam) return;
        RenderScriptCams(false, false, 1, true, true);
        SetCamActive(Cam, false);
        DestroyCam(Cam, true);
        SetFocusEntity(PlayerPedId());
        Cam = 0;
    };
}

const ResetCamFov = (ModelName: string) => {
    const IsVehicleBig = CalculateCamPos(ModelName, 15.5)
    SetCamFov(Cam, IsVehicleBig ? 70.0 : 50.0);
};

const CalculateCamPos = (ModelName: string, LargeCamSize: number = 15.5): boolean => {
    const [[minX, minY, minZ], [maxX, maxY, maxZ]] = GetModelDimensions(ModelName);
    const [midX, midY, midZ] = [maxX - minX, maxY - minY, maxZ - minZ];
    const ModelVolume = midX * midY * midZ;
    return ModelVolume > LargeCamSize
};

const SpawnCatalogVehicle = async (ModelName: string) => {
    if (Vehicle) {
        FW.VSync.DeleteVehicle(Vehicle)
        Vehicle = 0;
    };

    await exp['fw-assets'].RequestModelHash(ModelName);

    Vehicle = CreateVehicle(ModelName, UndergroundShowroomCar.x, UndergroundShowroomCar.y, UndergroundShowroomCar.z, UndergroundShowroomCar.w, false, true);
    SetVehicleOnGroundProperly(Vehicle);
    FreezeEntityPosition(Vehicle, true);
    SetEntityHeading(Vehicle, UndergroundShowroomCar.w);
    SetVehicleEngineOn(Vehicle, true, true, false);
    SetVehicleDirtLevel(Vehicle, 0.0);
    SetVehicleModKit(Vehicle, 0);
    SetEntityInvincible(Vehicle, true);
    SetEntityCollision(Vehicle, false, true);
    SetModelAsNoLongerNeeded(ModelName);

    ResetCamFov(ModelName)
};

const CloseCatalog = () => {
    UsingCatalog = false;
    SetUIFocus(false, false);
    SendUIMessage("VehicleCatalog", "SetVisibility", { Visible: false });

    if (Vehicle) {
        FW.VSync.DeleteVehicle(Vehicle);
        Vehicle = 0;
    };

    exp['fw-assets'].RemoveProp();
    StopAnimTask(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 1.0);

    ToggleCatalogCam(false);
};

RegisterNUICallback("VehicleCatalog/Close", (Data: any, Cb: Function) => {
    CloseCatalog();
    Cb("ok");
});

RegisterNUICallback("VehicleCatalog/SetVehicle", async (Data: {
    Model: string;
}, Cb: Function) => {
    SpawnCatalogVehicle(Data.Model)

    const VehicleInfo: {
        Acceleration?: number;
        Speed?: number;
        Handling?: number;
        Braking?: number;
    } = {}
    const IsMotorCycle = IsThisModelABike(Data.Model)

    let Timeout = false
    setTimeout(() => {
        Timeout = true
    }, 13500);

    while (!DoesEntityExist(Vehicle) && !Timeout) await Delay(100);

    if (Timeout) return Cb(false);

    const InitialDriveMaxFlatVel = GetVehicleHandlingFloat(Vehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel')
    const InitialDriveForce = GetVehicleHandlingFloat(Vehicle, 'CHandlingData', 'fInitialDriveForce')
    const InitialDragCoeff = GetVehicleHandlingFloat(Vehicle, 'CHandlingData', 'fInitialDragCoeff')
    const TractionCurveMax = GetVehicleHandlingFloat(Vehicle, 'CHandlingData', 'fTractionCurveMax')
    const TractionCurveMin = GetVehicleHandlingFloat(Vehicle, 'CHandlingData', 'fTractionCurveMin')
    const SuspensionReboundDamp = GetVehicleHandlingFloat(Vehicle, 'CHandlingData', 'fSuspensionReboundDamp')
    const BrakeForce = GetVehicleHandlingFloat(Vehicle, 'CHandlingData', 'fBrakeForce')
    let Force = InitialDriveForce;

    if (InitialDriveForce > 0 && InitialDriveForce < 1) Force = Force * 1.1;

    const Accel = (InitialDriveMaxFlatVel * Force) / 10
    VehicleInfo.Acceleration = Accel

    const Speed = ((InitialDriveMaxFlatVel / InitialDragCoeff) * (TractionCurveMax + TractionCurveMin)) / 40
    VehicleInfo.Speed = IsMotorCycle ? Speed * 2 : Speed;

    const Handling = (TractionCurveMax + SuspensionReboundDamp) * TractionCurveMin
    VehicleInfo.Handling = IsMotorCycle ? Handling * 2 : Handling;

    const Braking = ((TractionCurveMin / InitialDragCoeff) * BrakeForce) * 7
    VehicleInfo.Braking = IsMotorCycle ? Braking * 2 : Braking;

    Cb(VehicleInfo)
});

RegisterNUICallback("VehicleCatalog/DoRPM", (Data: any, Cb: Function) => {
    if (Vehicle && DoesEntityExist(Vehicle)) SetVehicleCurrentRpm(Vehicle, 1.0);
    Cb("ok")
})

setImmediate(async () => {
    while (!exp['fw-config'].IsConfigReady()) {
        await Delay(100)
    };

    const CatalogZones: {
        shopId: VehicleShops;
        shopAbbvr: string;
        shopLabel: string;
        catalogZone: {
            center: Vector3Format;
            length: number;
            width: number;
            heading: number;
            minZ: number;
            maxZ: number;
        }
    }[] = Object.values(await exp['fw-config'].GetModuleConfig("bus-vehicleshop-catalog"));

    for (let i = 0; i < CatalogZones.length; i++) {
        const { shopId, shopAbbvr, shopLabel, catalogZone } = CatalogZones[i];
        AddCatalogZone(shopId, shopAbbvr, shopLabel, catalogZone);
    }
});

onNet("fw-ui:appRestart", (pApp: string) => {
    if (!UsingCatalog || (pApp != "root" && pApp != "VehicleCatalog")) return;
    CloseCatalog();
});