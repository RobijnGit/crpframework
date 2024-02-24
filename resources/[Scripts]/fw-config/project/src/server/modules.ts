export const Config: {[key: string]: any} = {};
export let isConfigReady: boolean = false;
const IsObjectEmpty = (obj: Record<string, any>): boolean => Object.keys(obj).length === 0;
const Modules = JSON.parse(LoadResourceFile("fw-config", "config/_modules.json") || "{}");

export const LoadModule = (Module: string, isRefresh: boolean = false) => {
    if (!Config[Module] || isRefresh) {
        Config[Module] = {};
    } else {
        console.log(`[WARNING]: Duplicate module "${Module}" detected, skipping duplication config!`);
        return false;
    }
    
    const fileContent = JSON.parse(LoadResourceFile("fw-config", `config/${Module}.json`) || "{}");
    if (IsObjectEmpty(fileContent)) {
        console.log(`[CONFIG]: Failed to load module "${Module}", either unaccesible files or empty configuration!`);
        return false;
    };

    Config[Module] = {...Config[Module], ...fileContent};

    emit("fw-config:configLoaded", Module);
    emitNet("fw-config:configLoaded", -1, Module);

    return true;
}

(() => {
    let loadedModules = 0;
    for (let i = 0; i < Modules.length; i++) {
        const Result = LoadModule(Modules[i]);
        if (Result) loadedModules++;
    };
    
    isConfigReady = true;
    console.log(`[CONFIG]: Loaded ${loadedModules}/${Modules.length} modules loaded!`);

    emit("fw-config:configReady");
    emitNet("fw-config:configReady", -1);
})();