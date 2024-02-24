const exp = global.exports;
export const FW = exp['fw-core'].GetCoreObject();
let isConfigReady = false;

const IsConfigReady = () => isConfigReady;
exp("IsConfigReady", IsConfigReady);

const GetServerCode = async (): Promise<string> => GetConvar("sv_serverCode", await FW.SendCallback("fw-config:getConfigValue", "misc", "defaultServerCode", "wl"));
exp("GetServerCode", GetServerCode);

const GetModuleConfig = async (Module: string, Key: string, Fallback: any = false): Promise<any> => FW.SendCallback("fw-config:getModuleConfig", Module, Key, Fallback);
exp("GetModuleConfig", GetModuleConfig);

// setImmediate is called when all resources are loaded, otherwise GetModuleConfig could potentionly be called before config is loaded server-side.
setImmediate(() => {
    isConfigReady = true;
    setTimeout(() => {
        emit("fw-config:configReady");
    }, 2000);
});