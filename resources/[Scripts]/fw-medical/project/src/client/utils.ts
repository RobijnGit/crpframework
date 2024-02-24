import { Delay } from "../shared/utils";

export const LoadAnimDict = async (AnimDict: string) => {
    if (HasAnimDictLoaded(AnimDict)) return true;

    RequestAnimDict(AnimDict);
    while (!HasAnimDictLoaded(AnimDict)) {
        await Delay(100)
    };

    return true
}