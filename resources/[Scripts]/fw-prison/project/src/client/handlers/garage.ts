import { exp } from "../../shared/utils";
import { FW } from "../client";

on("fw-prison:Client:PurchaseVehicle", () => {
    if (FW.Functions.GetPlayerData().job.name != 'doc') {
        return FW.Functions.Notify("Geen toegang..", "error")
    }

    let BuyVehicles: Array<any> = [];
    const DOCVehicles = [ 'polvic', 'polexp', 'pbus' ]

    for (let i = 0; i < DOCVehicles.length; i++) {
        const Model = DOCVehicles[i];

        const SharedData = FW.Shared.HashVehicles[GetHashKey(Model)]
        BuyVehicles.push({
            Icon: 'car',
            Title: SharedData.Name,
            Desc: exp['fw-businesses'].NumberWithCommas(FW.Shared.CalculateTax("Vehicle Registration Tax", SharedData.Price)),
            SecondMenu: [
                {
                    Icon: 'user',
                    Title: 'Bevestig aankoop',
                    CloseMenu: true,
                    Data: { Event: 'fw-prison:Server:PurchaseVehicle', Vehicle: Model }
                },
            ]
        })

        if (FW.Functions.GetPlayerData().metadata.ishighcommand) {
            BuyVehicles[BuyVehicles.length - 1].SecondMenu[1] = {
                Icon: 'people-arrows',
                Title: 'Bevestig aankoop (Gezamelijk)',
                CloseMenu: true,
                Data: { Event: 'fw-prison:Server:PurchaseVehicle', Vehicle: Model, Shared: true }
            }
        }
    }

    FW.Functions.OpenMenu({
        MainMenuItems: BuyVehicles
    })
});

setImmediate(() => {
    exp['fw-ui'].AddEyeEntry("doc_purchase_vehicle", {
        Type: 'Entity',
        EntityType: 'Ped',
        SpriteDistance: 10.0,
        Distance: 1.5,
        Position: { x: 1853.76, y: 2685.33, z: 44.97, w: 91.33 },
        Model: 's_m_m_prisguard_01',
        Options: [
            {
                Name: "purchase",
                Icon: "fas fa-garage-car",
                Label: "Voertuig Aanschaffen",
                EventType: "Client",
                EventName: "fw-prison:Client:PurchaseVehicle",
                EventParams: {},
                Enabled: () => true,
            }
        ]
    })
})