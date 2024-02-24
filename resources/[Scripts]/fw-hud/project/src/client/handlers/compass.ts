import { Thread } from "../../shared/classes/thread";
import { SendUIMessage, exp } from "../../shared/utils";

const CompassThread = new Thread("tick", 60);
let LastUpdate = GetGameTimer();
let Area = '';
let StreetLocation = '';

onNet("fw-inventory:Client:Cock", () => {
    if (GetVehiclePedIsIn(PlayerPedId(), false) != 0) return;

    if (CompassThread.running && !exp['fw-inventory'].HasEnoughOfItem("pdwatch", 1)) {
        StopCompass();
    } else if (!CompassThread.running && exp['fw-inventory'].HasEnoughOfItem("pdwatch", 1)) {
        StartCompass();
    };
});

CompassThread.addHook("active", () => {
    if (LastUpdate < GetGameTimer()) {
        LastUpdate = GetGameTimer() + 500;

        if (!GetVehiclePedIsIn(PlayerPedId(), false)) { // For pd compass :)
            StreetLocation = ""
            Area = ""
        } else {
            const [x, y, z] = GetEntityCoords(PlayerPedId(), true)
            const [StreetHash, IntersectionHash] = GetStreetNameAtCoord(x, y, z)
            const StreetName = GetStreetNameFromHashKey(StreetHash);
            const IntersectionName = GetStreetNameFromHashKey(IntersectionHash);
            const Zone = GetNameOfZone(x, y, z).toString()
            Area = GetLabelText(Zone)
    
            if (IntersectionName != null && IntersectionName != "") {
                StreetLocation = `${StreetName} [${IntersectionName}]`
            } else if (StreetName != null && StreetName != "") {
                StreetLocation = StreetName
            } else {
                StreetLocation = ""
            };
        }

    };

    const [x, y, z] = GetFinalRenderedCamRot(0);
    SendUIMessage("Hud", "SetCompassDirection", {
        Direction: Math.floor((360 - z) % 360),
        Street: StreetLocation,
        Area: Area,
    })
});

CompassThread.addHook('afterStop', () => {
    SendUIMessage("Hud", "SetCompassVisibility", {Visible: false});
});

export const StartCompass = () => {
    SendUIMessage("Hud", "SetCompassVisibility", {Visible: true});
    CompassThread.start();
};

export const StopCompass = () => {
    if (exp['fw-inventory'].HasEnoughOfItem("pdwatch", 1)) return;
    CompassThread.stop();
};