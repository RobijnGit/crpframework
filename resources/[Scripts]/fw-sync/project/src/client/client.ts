import { exp } from "../shared/utils"
export const FW = exp['fw-core'].GetCoreObject();

import InitBlips from "./blips/index";
import InitWeather from "./handlers/weather";

setImmediate(() => {
    InitWeather();
    InitBlips();
});