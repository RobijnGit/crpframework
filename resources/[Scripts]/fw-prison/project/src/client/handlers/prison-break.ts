import { Vector3, Vector3Format } from "../../shared/classes/math";
import { Thread } from "../../shared/classes/thread";
import { InJail } from "./prison";

export const EscapeThread = new Thread("tick", 5000);
export const Prison: Vector3Format = {x: 1694.9, y: 2587.19, z: 45.56};

EscapeThread.addHook("active", () => {
    if (!InJail) {
        EscapeThread.stop();
        return;
    }

    const [x, y, z] = GetEntityCoords(PlayerPedId(), false);

    if (new Vector3().setFromObject(Prison).getDistance({x, y, z}) > 195) {
        DoScreenFadeOut(1);

        setTimeout(() => {
            emit("fw-prison:Client:SetJail", true);
        }, 100);
    };
});