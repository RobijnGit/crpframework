Config = Config or {}
Shared = Shared or {}

Config.Drops = {}

Config.MaxPlayerWeight = 250.0
Config.MaxPlayerSlots = 40

Config.TrunkSpaces = {
    [0]  = { 1.0, 50, 150 }, -- Compacts
    [1]  = { 2.0, 150, 300 }, -- Sedans
    [2]  = { 5.0, 200, 500 }, -- SUVs
    [3]  = { 3.0, 100, 250 }, -- Coupes
    [4]  = { 3.0, 100, 250 }, -- Muscle
    [5]  = { 1.0, 150, 200 }, -- Sports Classics
    [6]  = { 1.0, 150, 200 }, -- Sports
    [7]  = { 1.0, 75, 200 }, -- Super
    [8]  = { 0.0, 0, 0 }, -- Motorcycles
    [9]  = { 1.0, 100, 300 }, -- Off-road
    [10] = { 4.0, 300, 500 }, -- Industrial
    [11] = { 5.0, 250, 500 }, -- Utility
    [12] = { 5.0, 250, 500 }, -- Vans
    [13] = { 0.0, 0, 0 }, -- Cycles
    [14] = { 2.0, 100, 300 }, -- Boats
    [15] = { 1.0, 100, 400 }, -- Helicopters
    [16] = { 5.0, 100, 4000 }, -- Planes
    [17] = { 10.0, 100, 600 }, -- Service
    [18] = { 2.0, 200, 500 }, -- Emergency
    [19] = { 5.0, 200, 500 }, -- Military
    [20] = { 20.0, 250, 2000 }, -- Commerical
    [21] = { 10.0, 200, 500 }, -- Trains
}

Config.Dumpsters = {
    [GetHashKey("prop_cs_dumpster_01a")] = true,
    [GetHashKey("p_dumpster_t")] = true,
    [GetHashKey("prop_dumpster_01a")] = true,
    [GetHashKey("prop_dumpster_02a")] = true,
    [GetHashKey("prop_dumpster_02b")] = true,
    [GetHashKey("prop_dumpster_3a")] = true,
    [GetHashKey("prop_dumpster_4a")] = true,
    [GetHashKey("prop_dumpster_4b")] = true,
}

Config.BackEngine = {
    [GetHashKey("ninef")] = true,
    [GetHashKey("adder")] = true,
    [GetHashKey("vagner")] = true,
    [GetHashKey("t20")] = true,
    [GetHashKey("infernus")] = true,
    [GetHashKey("zentorno")] = true,
    [GetHashKey("reaper")] = true,
    [GetHashKey("comet2")] = true,
    [GetHashKey("comet3")] = true,
    [GetHashKey("jester")] = true,
    [GetHashKey("jester2")] = true,
    [GetHashKey("cheetah")] = true,
    [GetHashKey("cheetah2")] = true,
    [GetHashKey("prototipo")] = true,
    [GetHashKey("turismor")] = true,
    [GetHashKey("pfister811")] = true,
    [GetHashKey("ardent")] = true,
    [GetHashKey("nero")] = true,
    [GetHashKey("nero2")] = true,
    [GetHashKey("tempesta")] = true,
    [GetHashKey("vacca")] = true,
    [GetHashKey("bullet")] = true,
    [GetHashKey("osiris")] = true,
    [GetHashKey("entityxf")] = true,
    [GetHashKey("turismo2")] = true,
    [GetHashKey("fmj")] = true,
    [GetHashKey("re7b")] = true,
    [GetHashKey("tyrus")] = true,
    [GetHashKey("italigtb")] = true,
    [GetHashKey("penetrator")] = true,
    [GetHashKey("monroe")] = true,
    [GetHashKey("ninef2")] = true,
    [GetHashKey("stingergt")] = true,
    [GetHashKey("surfer")] = true,
    [GetHashKey("surfer2")] = true,
    [GetHashKey("gp1")] = true,
    [GetHashKey("autarch")] = true,
    [GetHashKey("tyrant")] = true
}

Config.Throwables = {
    [GetHashKey("weapon_grenade")] = true,
    [GetHashKey("weapon_stickybomb")] = true,
    [GetHashKey("weapon_molotov")] = true,
    [GetHashKey("weapon_brick")] = true,
    [GetHashKey("weapon_flare")] = true,
    [GetHashKey("weapon_smokegrenade")] = true,
    [GetHashKey("weapon_shoe")] = true,
    [GetHashKey("weapon_brick")] = true,
    [GetHashKey("weapon_banana")] = true,
}

Config.Attachments = {
    ['silencer_oilcan'] = {
        -- ['weapon_m70'] = 'COMPONENT_OIL_SUPP',
        -- ['weapon_colt'] = 'COMPONENT_OIL_SUPP',
        -- ['weapon_beretta'] = 'COMPONENT_OIL_SUPP',
        -- ['weapon_glock18c'] = 'COMPONENT_OIL_SUPP',
        -- ['weapon_heavypistol'] = 'COMPONENT_OIL_SUPP',
    },
    ['silencer'] = {
        ['weapon_m70'] = 'COMPONENT_AT_AR_SUPP_02',
        ['weapon_colt'] = 'COMPONENT_AT_PI_SUPP',
        ['weapon_beretta'] = 'COMPONENT_AT_PI_SUPP',
        ['weapon_glock18c'] = 'COMPONENT_AT_PI_SUPP',
        ['weapon_heavypistol'] = 'COMPONENT_AT_PI_SUPP',
    },
}

exports("GetConfig", function()
    return Config
end)

exports("GetShared", function()
    return Shared
end)

function DeepCopyTable(Obj)
    if type(Obj) ~= 'table' then return Obj end
    local res = {}
    
    for k, v in pairs(Obj) do
        res[DeepCopyTable(k)] = DeepCopyTable(v)
    end

    return res
end