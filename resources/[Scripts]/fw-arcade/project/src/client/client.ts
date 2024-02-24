import { exp } from "../shared/utils"
export const FW = exp['fw-core'].GetCoreObject();

import initBusiness from "./business";
import initGames from "./games";
import './lobby/main'

setImmediate(() => {
    initBusiness();
    initGames();
});