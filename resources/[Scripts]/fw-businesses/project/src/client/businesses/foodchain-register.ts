import { ClockCoords } from "../../shared/config";
import { Delay, NumberWithCommas, exp } from "../../shared/utils";
import { CurrentClock, FW } from "../client";
import { IsBusinessOnLockdown } from "../utils";

on("fw-businesses:Client:Foodchain:SetupPayment", async (Data: {
    RegisterId: number;
}) => {
    await Delay(50);

    if (!CurrentClock.ClockedIn) return;

    const Result = await exp['fw-ui'].CreateInput([
        { Label: "Kosten", Icon: "fas fa-euro-sign", Name: "Costs", Type: "number" },
        { Label: "Bestelling", Icon: "fas fa-pencil", Name: "Comment" },
    ]);

    if (await IsBusinessOnLockdown(CurrentClock.Business)) {
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error")
    };

    if (Result && Number(Result.Costs) > 0 && Result.Comment.trim().length > 0) {
        FW.TriggerServer("fw-businesses:Server:Foodchain:SetPaymentData", CurrentClock.Business, Data.RegisterId, Result.Comment, Number(Result.Costs));
    };
});

on("fw-businesses:Client:Foodchain:GetPayments", async (Data: {
    Business: string;
    RegisterId: number;
}) => {
    await Delay(50);

    const Result = await FW.SendCallback("fw-businesses:Server:Foodchain:GetPaymentData", Data.Business, Data.RegisterId);
    if (!Result) {
        return FW.Functions.Notify("Geen openstaande bestelling..", "error");
    };

    FW.Functions.OpenMenu({
        MainMenuItems: [
            {
                Icon: 'info-circle',
                Title: "Restaurant Bestelling",
                Desc: `${NumberWithCommas(Result.Costs)} | ${Result.Order}`,
                Data: { Event: "", Type: ""}
            },
            {
                Icon: 'credit-card',
                Title: "Betalen met Bank",
                CloseMenu: true,
                Data: {
                    Event: "fw-businesses:Server:Foodchain:PayRegister",
                    Type: "Server",
                    PaymentType: "Bank",
                    ...Data
                }
            },
            {
                Icon: 'money-bill',
                Title: "Betalen met Cash",
                CloseMenu: true,
                Data: {
                    Event: "fw-businesses:Server:Foodchain:PayRegister",
                    Type: "Server",
                    PaymentType: "Cash",
                    ...Data
                }
            },
        ]
    });
});

onNet("fw-businesses:Client:Foodchain:RecieveReceipt", (Business: string, Data: any) => {
    if (!CurrentClock.ClockedIn || CurrentClock.Business != Business) return;
    if (Business == "Digital Den" && ClockCoords["Digital Den"].getDistanceFromArray(GetEntityCoords(PlayerPedId(), false)) > 25.0) return;
    if (Business == "Digital Dean" && ClockCoords["Digital Dean"].getDistanceFromArray(GetEntityCoords(PlayerPedId(), false)) > 25.0) return;
    if (Business == "Mattronics" && ClockCoords["Mattronics"].getDistanceFromArray(GetEntityCoords(PlayerPedId(), false)) > 25.0) return;

    emitNet("fw-businesses:Server:ReceiveReceipt", Data);
});