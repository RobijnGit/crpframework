import { Delay, SendUIMessage, exp } from "../shared/utils"
export const FW = exp['fw-core'].GetCoreObject();

import './handlers/camera';
import './handlers/binder';

onNet("fw-polaroid:Client:ShowPhotoAnim", async () => {
    RequestAnimDict("paper_1_rcm_alt1-9")
    while (!HasAnimDictLoaded("paper_1_rcm_alt1-9")) {
        await Delay(5);
    };

	TaskPlayAnim(PlayerPedId(), "paper_1_rcm_alt1-9", "player_one_dual-9", 1.0, 1.0, -1, 8, 0, false, false, false);

	exp['fw-assets'].AddProp('PolaroidPhoto')
	setTimeout(() => {
		exp['fw-assets'].RemoveProp()
		ClearPedTasks(PlayerPedId())
    }, 2500);
});

onNet("fw-polaroid:Client:ShowPhoto", (Data: any) => {
    SendUIMessage("Polaroid", "ShowPhoto", {
        Photo: {
            Image: Data.Image,
            Date: Data.Date,
            Description: Data.Description || false,
        }
    })
});