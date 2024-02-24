import { FW } from "../server";

let IsAlarmOn: boolean = false;
FW.RegisterServer("fw-prison:Server:SetAlarmState", (Source: number, State: boolean) => {
    if (IsAlarmOn == State) return;
    IsAlarmOn = State;
    emitNet("fw-prison:Client:SetAlarmState", -1, State);
});