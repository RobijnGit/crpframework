Config = {}

Config.TrunkData = {}
Config.SavedDuiData, Config.DuiLinks = {}, {}

Config.Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

Config.DiscordSettings = {
    ['AppId'] = 1125496943607566406,
    ['Text'] = 'Clarity Roleplay',
}

Config.DisabledTrunk = {
    [GetHashKey("penetrator")] = true,
    [GetHashKey("vacca")] = true,
    [GetHashKey("monroe")] = true,
    [GetHashKey("turismor")] = true,
    [GetHashKey("osiris")] = true,
    [GetHashKey("comet")] = true,
    [GetHashKey("ardent")] = true,
    [GetHashKey("jester")] = true,
    [GetHashKey("nero")] = true,
    [GetHashKey("nero2")] = true,
    [GetHashKey("vagner")] = true,
    [GetHashKey("infernus")] = true,
    [GetHashKey("zentorno")] = true,
    [GetHashKey("comet2")] = true,
    [GetHashKey("comet3")] = true,
    [GetHashKey("comet4")] = true,
    [GetHashKey("bullet")] = true,
}

Config.BlacklistedEntitys = {
    [GetHashKey('SHAMAL')] = true,
    [GetHashKey('LUXOR')] = true,
    [GetHashKey('LUXOR2')] = true,
    [GetHashKey('JET')] = true,
    [GetHashKey('LAZER')] = true,
    [GetHashKey('BUZZARD')] = true,
    [GetHashKey('BUZZARD2')] = true,
    [GetHashKey('ANNIHILATOR')] = true,
    [GetHashKey('SAVAGE')] = true,
    [GetHashKey('TITAN')] = true,
    [GetHashKey('RHINO')] = true,
    [GetHashKey('POLICE')] = true,
    [GetHashKey('POLICE2')] = true,
    [GetHashKey('POLICE3')] = true,
    [GetHashKey('POLICE4')] = true,
    [GetHashKey('POLICET')] = true,
    [GetHashKey('SHERIFF')] = true,
    [GetHashKey('SHERIFF2')] = true,
    [GetHashKey('FIRETRUK')] = true,
    [GetHashKey('AMBULANCE')] = true,
    [GetHashKey('MULE')] = true,
    [GetHashKey('POLMAV')] = true,
    [GetHashKey('MAVERICK')] = true,
    [GetHashKey('BLIMP')] = true,
    [GetHashKey('CARGOBOB')] = true,
    [GetHashKey('CARGOBOB2')] = true,
    [GetHashKey('CARGOBOB3')] = true,
    [GetHashKey('CARGOBOB4')] = true,
    [GetHashKey('BESRA')] = true,
    [GetHashKey('SWIFT')] = true,
    [GetHashKey('FROGGER')] = true,
    [GetHashKey('HYDRA')] = true,
    [GetHashKey('RUINER3')] = true,
    [GetHashKey('MONSTER')] = true,
    [GetHashKey('SOVEREIGN')] = true,
    [GetHashKey('DUMP')] = true,

    -- Peds
    -- [GetHashKey('s_m_y_ranger_01')] = true,
    -- [GetHashKey('s_m_y_sheriff_01')] = true,
    -- [GetHashKey('s_m_y_cop_01')] = true,
    -- [GetHashKey('s_f_y_sheriff_01')] = true,
    -- [GetHashKey('s_f_y_cop_01')] = true,
    -- [GetHashKey('s_m_y_hwaycop_01')] = true,
    -- [GetHashKey('g_m_y_lost_01')] = true,
}