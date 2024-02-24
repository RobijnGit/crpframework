import { exp } from "../shared/utils"
import { ClockCoords } from "../shared/config";
import initUtils, { IsBusinessOnLockdown, IsPlayerInBusiness } from "./utils";
export const FW = exp['fw-core'].GetCoreObject();
import './businesses';
import { Thread } from "../shared/classes/thread";

export let CurrentClock = { Business: '', ClockedIn: false };
const ClockThread = new Thread("tick", 3000);

setImmediate(() => {
    initUtils();
});

onNet("fw-businesses:Client:SetClock", async (Data: {
    Business: string;
    ClockedIn: boolean;
}) => {
    if (Data.ClockedIn && !IsPlayerInBusiness(Data.Business)) {
        return FW.Functions.Notify("Ze herkennen je niet..", "error");
    };

    if (Data.ClockedIn && await IsBusinessOnLockdown(Data.Business)) {
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error");
    };

    CurrentClock = Data;
    emitNet("fw-businesses:Server:SetClock", Data);

    Data.ClockedIn && ClockCoords[Data.Business] ? ClockThread.start() : ClockThread.stop();
});

onNet("fw-businesses:Client:CreateBusiness", async () => {
    const PlayerJob = FW.Functions.GetPlayerData().job;
    if (PlayerJob.name != 'judge' && PlayerJob.name != 'mayor') return;

    const Result = await exp['fw-ui'].CreateInput([
        { Label: 'Bedrijfsnaam', Icon: 'fas fa-heading', Name: 'BusinessName' },
        { Label: 'BSN Eigenaar', Icon: 'fas fa-id-card', Name: 'BusinessOwner' },
        { Label: 'Bankrekeningnummer', Icon: 'fas fa-money-check-alt', Name: 'BusinessAccount' },
    ])

    emitNet("fw-businesses:Server:CreateBusiness", Result)
})

ClockThread.addHook("active", () => {
    if (!CurrentClock.ClockedIn) return;
    if (ClockCoords[CurrentClock.Business] == undefined) return;

    const [x, y, z] = GetEntityCoords(PlayerPedId(), false);

    if (ClockCoords[CurrentClock.Business].getDistanceFromArray([x, y, z]) < 45.0) {
        return
    };

    emit("fw-businesses:Client:SetClock", {Business: "", ClockedIn: false});
});

export const GetCurrentClock = () => CurrentClock;
exp("GetCurrentClock", GetCurrentClock);

exp("GetClockedInEmployees", async (BusinessName: string): Promise<boolean> => { 
    const Result = await FW.SendCallback("fw-businesses:Server:GetClockedInEmployees", BusinessName);
    return Result;
});