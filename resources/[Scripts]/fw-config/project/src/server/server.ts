const exp = global.exports;

import { Config, LoadModule, isConfigReady } from './modules';
export const FW = exp['fw-core'].GetCoreObject();

const GetServerCode = () => GetConvar("sv_serverCode", Config["misc"]?.defaultServerCode);
exp("GetServerCode", GetServerCode);

const IsConfigReady = (): boolean => isConfigReady;
exp("IsConfigReady", IsConfigReady);

const GetModuleConfig = (Module: string, Fallback: any = false) => {
    if (!Config[Module]) return Fallback;
    return Config[Module];
};
exp("GetModuleConfig", GetModuleConfig);

const GetConfigValue = (Module: string, Key: string, Fallback: any = false) => {
    if (!Config[Module]) return Fallback;
    if (Config[Module][Key] == undefined) return Fallback;

    return Config[Module][Key];
};
exp("GetConfigValue", GetConfigValue);

const SetConfigValue = (Module: string, Key: string, Value: any) => {
    if (!Config[Module]) return false;
    if (Value == undefined) return false;

    Config[Module][Key] = Value;

    // @ts-ignore
    SaveResourceFile("fw-config", `config/${Module}.json`, JSON.stringify(Config[Module], undefined, 2), -1);
};
exp("SetConfigValue", SetConfigValue);

FW.Functions.CreateCallback("fw-config:getConfigValue", (Source: number, Cb: Function, Module: string, Key: string, Fallback: any = false) => {
    Cb(GetConfigValue(Module, Key, Fallback))
});

FW.Functions.CreateCallback("fw-config:getModuleConfig", (Source: number, Cb: Function, Module: string, Fallback: any = false) => {
    Cb(GetModuleConfig(Module, Fallback))
});

FW.Functions.CreateCallback("fw-config:isConfigReady", (Source: number, Cb: Function) => {
    Cb(isConfigReady)
});

RegisterCommand("refreshConfigModule", (Source: number, Args: string[]) => {
    if (Source != 0) return;

    if (!Args[0]) return console.log("Invalid module!");

    const Module: string = Args[0];
    if (!Config[Module]) console.log(`[CONFIG]: Module "${Module}" does not exist.. Creating new module!`);

    LoadModule(Module, true);
}, true);