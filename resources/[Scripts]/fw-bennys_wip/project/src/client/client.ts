import { RegisterNUICallback, SetUIFocus, exp } from "../shared/utils"
import { Menu } from "./handler/menu";
export const FW = exp['fw-core'].GetCoreObject();
import './handler/zone';
import { CurrentBennyZone, IsInBennysZone } from "./handler/zone";

let VehicleMods = [];

exp("GetIsInBennysZone", () => IsInBennysZone);
exp("IsInSecretBennys", () => false);

RegisterNUICallback("Bennys/PlaySoundFrontend", (Data: {
    Name: string;
    Set: string;
}, Cb: Function) => {
    PlaySoundFrontend(-1, Data.Name, Data.Set, true);
    Cb("Ok");
});

RegisterNUICallback("Bennys/PreviewUpgrade", (Data: any, Cb: Function) => {

    Cb("Ok");
});

RegisterNUICallback("Bennys/PurchaseUpgrade", (Data: any, Cb: Function) => {
    const Vehicle = GetVehiclePedIsIn(PlayerPedId(), false);

    if (Data.Id == "RepairVehicle") {
        const Cash = FW.Functions.GetPlayerData().money.cash;
        if (Data.Costs > Cash) {
            return FW.Functions.Notify("Je hebt niet genoeg cash..", "error");
        };

        const BodyHealth = GetVehicleBodyHealth(Vehicle);
        const EngineHealth = GetVehicleEngineHealth(Vehicle);

        const MissingBodyHealth = 1000.0 - BodyHealth;
        const MissingEngineHealth = 1000.0 - EngineHealth;

        SetVehicleHandbrake(Vehicle, true);

        if (MissingEngineHealth > 50) {
            const Finished = FW.Functions.CompactProgressbar(5000 + (MissingEngineHealth / 50), "Motor repareren...", false, false, {disableMovement: true, disableCarMovement: true, disableMouse: false, disableCombat: true}, {}, {}, {}, false);
            if (Finished) {
                SetVehicleEngineHealth(Vehicle, EngineHealth + MissingEngineHealth);
                SetVehiclePetrolTankHealth(Vehicle, 1000.0);
            };
        };

        if (MissingBodyHealth > 50) {
            const Finished = FW.Functions.CompactProgressbar(5000 + (MissingBodyHealth / 50), "Body repareren...", false, false, {disableMovement: true, disableCarMovement: true, disableMouse: false, disableCombat: true}, {}, {}, {}, false);
            if (Finished) {
                SetVehicleDeformationFixed(Vehicle);
                SetVehicleBodyHealth(Vehicle, BodyHealth + MissingBodyHealth);
            };
        };

        if (GetVehicleBodyHealth(Vehicle) >= 900 && GetVehicleEngineHealth(Vehicle) >= 900) {
            FW.VSync.SetVehicleFixed(Vehicle)
        };

        SetVehicleHandbrake(Vehicle, false);

        
    } else {

    }

    Cb("Ok");
});

onNet("fw-bennys:Client:OpenBennys", (IsAdmin: boolean) => {
    const Vehicle = GetVehiclePedIsIn(PlayerPedId(), false);
    if (!DoesEntityExist(Vehicle)) return;

    const DriverPed = GetPedInVehicleSeat(Vehicle, -1);
    if (DriverPed != PlayerPedId()) return;

    // todo: add mechanic online check.

    SetVehicleModKit(Vehicle, 0);
    PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true);
    if (CurrentBennyZone && CurrentBennyZone.data && CurrentBennyZone.data.Heading) {
        SetEntityHeading(Vehicle, CurrentBennyZone.data.Heading);
    };

    FreezeEntityPosition(Vehicle, true);
    SetNuiFocusKeepInput(true);
    SetUIFocus(true, false);

    // todo: disable control 75 to disallow exiting vehicle.

    Menu.Open(Vehicle);
})