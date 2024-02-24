import { exp } from "../shared/utils"
export const FW = exp['fw-core'].GetCoreObject();

import InitWeather from "./handlers/weather";
import InitBlips from "./blips/index";

setImmediate(() => {
    InitWeather();
    InitBlips();
})