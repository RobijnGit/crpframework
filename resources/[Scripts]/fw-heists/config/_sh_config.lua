Config = Config or {}

Config.RequiredCopsStores = 1
Config.RequiredCopsPickup = 2
Config.RequiredCopsJewelry = 3
Config.RequiredBanktruckCops = 3
Config.RequiredCopsFleeca = 4
Config.RequiredCopsBobcat = 4
Config.RequiredCopsBaycity = 5
Config.RequiredCopsPaleto = 5
Config.RequiredVaultCops = 6

function DeepCopyTable(Obj)
    if type(Obj) ~= 'table' then return Obj end
    local res = {}
    
    for k, v in pairs(Obj) do
        res[DeepCopyTable(k)] = DeepCopyTable(v)
    end

    return res
end

function GetRandomFromArray(Array, Ignore, IgnoreCb)
    local AvailableOptions = {}

    for i, v in ipairs(Array) do
        local isIgnored = IgnoreCb ~= nil and not IgnoreCb(v)

        if not isIgnored then
            for k, ignoreValue in ipairs(Ignore) do
                if v == ignoreValue then
                    isIgnored = true
                    break
                end
            end
        end

        if not isIgnored then
            table.insert(AvailableOptions, v)
        end
    end

    if #AvailableOptions == 0 then
        return nil
    end

    
    local Result = AvailableOptions[math.random(1, #AvailableOptions)]
    return Result
end

Config.LootHacks = {
    'Grid',
    'Keystroke',
    'Thermite',
    'Datacrack',
    'Shape',
    'Phone',
}

-- Gloves
Config.MaleNoGloves = {
    [0] = true, [1] = true, [2] = true, [3] = true,
    [4] = true, [5] = true, [6] = true, [7] = true,
    [8] = true, [9] = true, [10] = true, [11] = true,
    [12] = true, [13] = true, [14] = true, [15] = true,
    [18] = true, [52] = true, [53] = true,
    [54] = true, [55] = true, [56] = true, [57] = true,
    [58] = true, [59] = true, [60] = true, [61] = true,
    [62] = true, [112] = true, [113] = true, [114] = true,
    [118] = true, [125] = true, [132] = true,
}

Config.FemaleNoGloves = {
    [0] = true, [1] = true, [2] = true, [3] = true,
    [4] = true, [5] = true, [6] = true, [7] = true,
    [8] = true, [9] = true, [10] = true, [11] = true,
    [12] = true, [13] = true, [14] = true, [15] = true,
    [19] = true, [59] = true, [60] = true, [61] = true,
    [62] = true, [63] = true, [64] = true, [65] = true,
    [66] = true, [67] = true, [68] = true, [69] = true,
    [70] = true, [71] = true, [129] = true, [130] = true,
    [131] = true, [135] = true, [142] = true, [149] = true,
    [153] = true, [157] = true, [161] = true,[165] = true,
}