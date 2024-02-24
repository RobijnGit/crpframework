import { Delay, RegisterNUICallback, SendUIMessage, SetUIFocus, exp } from "../shared/utils"
export const FW = exp['fw-core'].GetCoreObject();

import './createBook'

onNet("fw-books:Client:OpenBook", async (Images: string[]) => {
    RequestAnimDict('amb@code_human_in_bus_passenger_idles@female@tablet@base')
    while (!HasAnimDictLoaded("amb@code_human_in_bus_passenger_idles@female@tablet@base")) {
        await Delay(50)
    }
    TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3.0, 3.0, -1, 49, 0, false, false, false);
    exp['fw-assets'].AddProp("Book")

    SetUIFocus(true, true);
    SendUIMessage("Books", "OpenBook", {Images});
});

RegisterNUICallback("Books/Close", (Data: any, Cb: Function) => {
    SetUIFocus(false, false);
    SendUIMessage("Books", "CloseBook");
    exp['fw-assets'].RemoveProp();
    StopAnimTask(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 1.0);
})

setImmediate(() => {
    exp['fw-ui'].AddEyeEntry("comic_store", {
        Type: 'Entity',
        EntityType: 'Ped',
        SpriteDistance: 10.0,
        Distance: 1.5,
        Position: { x: -143.67, y: 230.2, z: 93.94, w: 358.82 },
        Model: 'a_m_y_epsilon_01',
        Options: [
            {
                Name: "book",
                Icon: "fas fa-book",
                Label: "Boek Maken",
                EventType: "Client",
                EventName: "fw-books:Client:WriteBook",
                EventParams: {},
                Enabled: () => {
                    return exp['fw-inventory'].HasEnoughOfItem("paper", 1);
                },
            },
            {
                Name: "paper",
                Icon: "fas fa-file",
                Label: "Papier kopen (€130,00)",
                EventType: "Server",
                EventName: "fw-books:Server:PurchasePaper",
                EventParams: {},
                Enabled: () => true,
            },
            // {
            //     Name: "copy",
            //     Icon: "fas fa-copy",
            //     Label: "Boek Kopiëren (€500,00)",
            //     EventType: "Client",
            //     EventName: "fw-books:Client:CopyBook",
            //     EventParams: {},
            //     Enabled: () => true,
            // }
        ]
    })
})