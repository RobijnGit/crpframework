import InitZones from "./zones";
import './interactions';
import { EscapeThread } from "../handlers/prison-break";
import { SetInJail, ResetJail } from "../handlers/prison";
import { FW } from "../client";

onNet("FW:Client:OnPlayerLoaded", () => {
    const Metadata = FW.Functions.GetPlayerData().metadata;
    if (Metadata.islifer) SetInJail(true);
})

onNet("FW:Client:OnPlayerUnload", () => {
    ResetJail();
    EscapeThread.stop();
})

setImmediate(() => {
    InitZones();
})