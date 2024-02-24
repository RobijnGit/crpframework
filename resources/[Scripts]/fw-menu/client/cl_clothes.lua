-- Variants
local Variations = {
	Jackets = {Male = {}, Female = {}},
	Hair = {Male = {}, Female = {}},
	Bags = {Male = {}, Female = {}},
	Visor = {Male = {}, Female = {}},
	Gloves = {
		Male = { [16] = 4, [17] = 4, [18] = 4, [19] = 0, [20] = 1, [21] = 2, [22] = 4, [23] = 5, [24] = 6, [25] = 8, [26] = 11, [27] = 12, [28] = 14, [29] = 15, [30] = 0, [31] = 1, [32] = 2, [33] = 4, [34] = 5, [35] = 6, [36] = 8, [37] = 11, [38] = 12, [39] = 14, [40] = 15, [41] = 0, [42] = 1, [43] = 2, [44] = 4, [45] = 5, [46] = 6, [47] = 8, [48] = 11, [49] = 12, [50] = 14, [51] = 15, [52] = 0, [53] = 1, [54] = 2, [55] = 4, [56] = 5, [57] = 6, [58] = 8, [59] = 11, [60] = 12, [61] = 14, [62] = 15, [63] = 0, [64] = 1, [65] = 2, [66] = 4, [67] = 5, [68] = 6, [69] = 8, [70] = 11, [71] = 12, [72] = 14, [73] = 15, [74] = 0, [75] = 1, [76] = 2, [77] = 4, [78] = 5, [79] = 6, [80] = 8, [81] = 11, [82] = 12, [83] = 14, [84] = 15, [85] = 0, [86] = 1, [87] = 2, [88] = 4, [89] = 5, [90] = 6, [91] = 8, [92] = 11, [93] = 12, [94] = 14, [95] = 15, [96] = 4, [97] = 4, [98] = 4, [99] = 0, [100] = 1, [101] = 2, [102] = 4, [103] = 5, [104] = 6, [105] = 8, [106] = 11, [107] = 12, [108] = 14, [109] = 15, [110] = 4, [111] = 4, [115] = 112, [116] = 112, [117] = 112, [118] = 112, [119] = 112, [120] = 112, [121] = 112, [122] = 113, [123] = 113, [124] = 113, [125] = 113, [126] = 113, [127] = 113, [128] = 113, [129] = 114, [130] = 114, [131] = 114, [132] = 114, [133] = 114, [134] = 114, [135] = 114, [136] = 15, [137] = 15, [138] = 0, [139] = 1, [140] = 2, [141] = 4, [142] = 5, [143] = 6, [144] = 8, [145] = 11, [146] = 12, [147] = 14, [148] = 112, [149] = 113, [150] = 114, [151] = 0, [152] = 1, [153] = 2, [154] = 4, [155] = 5, [156] = 6, [157] = 8, [158] = 11, [159] = 12, [160] = 14, [161] = 112, [162] = 113, [163] = 114, [165] = 4, [166] = 4, [167] = 4 },
		Female = { [16] = 11, [17] = 3, [18] = 3, [19] = 3, [20] = 0, [21] = 1, [22] = 2, [23] = 3, [24] = 4, [25] = 5, [26] = 6, [27] = 7, [28] = 9, [29] = 11, [30] = 12, [31] = 14, [32] = 15, [33] = 0, [34] = 1, [35] = 2, [36] = 3, [37] = 4, [38] = 5, [39] = 6, [40] = 7, [41] = 9, [42] = 11, [43] = 12, [44] = 14, [45] = 15, [46] = 0, [47] = 1, [48] = 2, [49] = 3, [50] = 4, [51] = 5, [52] = 6, [53] = 7, [54] = 9, [55] = 11, [56] = 12, [57] = 14, [58] = 15, [59] = 0, [60] = 1, [61] = 2, [62] = 3, [63] = 4, [64] = 5, [65] = 6, [66] = 7, [67] = 9, [68] = 11, [69] = 12, [70] = 14, [71] = 15, [72] = 0, [73] = 1, [74] = 2, [75] = 3, [76] = 4, [77] = 5, [78] = 6, [79] = 7, [80] = 9, [81] = 11, [82] = 12, [83] = 14, [84] = 15, [85] = 0, [86] = 1, [87] = 2, [88] = 3, [89] = 4, [90] = 5, [91] = 6, [92] = 7, [93] = 9, [94] = 11, [95] = 12, [96] = 14, [97] = 15, [98] = 0, [99] = 1, [100] = 2, [101] = 3, [102] = 4, [103] = 5, [104] = 6, [105] = 7, [106] = 9, [107] = 11, [108] = 12, [109] = 14, [110] = 15, [111] = 3, [112] = 3, [113] = 3, [114] = 0, [115] = 1, [116] = 2, [117] = 3, [118] = 4, [119] = 5, [120] = 6, [121] = 7, [122] = 9, [123] = 11, [124] = 12, [125] = 14, [126] = 15, [127] = 3, [128] = 3, [132] = 129, [133] = 129, [134] = 129, [135] = 129, [136] = 129, [137] = 129, [138] = 129, [139] = 130, [140] = 130, [141] = 130, [142] = 130, [143] = 130, [144] = 130, [145] = 130, [146] = 131, [147] = 131, [148] = 131, [149] = 131, [150] = 131, [151] = 131, [152] = 131, [154] = 153, [155] = 153, [156] = 153, [157] = 153, [158] = 153, [159] = 153, [160] = 153, [162] = 161, [163] = 161, [164] = 161, [165] = 161, [166] = 161, [167] = 161, [168] = 161, [169] = 15, [170] = 15, [171] = 0, [172] = 1, [173] = 2, [174] = 3, [175] = 4, [176] = 5, [177] = 6, [178] = 7, [179] = 9, [180] = 11, [181] = 12, [182] = 14, [183] = 129, [184] = 130, [185] = 131, [186] = 153, [187] = 0, [188] = 1, [189] = 2, [190] = 3, [191] = 4, [192] = 5, [193] = 6, [194] = 7, [195] = 9, [196] = 11, [197] = 12, [198] = 14, [199] = 129, [200] = 130, [201] = 131, [202] = 153, [203] = 161, [204] = 161, [206] = 3, [207] = 3, [208] = 3 }
	}
}

function AddNewVariation(Type, Gender, From, To)
	local Where = Variations[Type][Gender]
    Where[From] = To
    Where[To] = From
end

Citizen.CreateThread(function()
	AddNewVariation("Visor", "Male", 9, 10) -- Male Visor/Hat Variations
	AddNewVariation("Visor", "Male", 18, 67)
	AddNewVariation("Visor", "Male", 82, 67)
	AddNewVariation("Visor", "Male", 44, 45)
	AddNewVariation("Visor", "Male", 50, 68)
	AddNewVariation("Visor", "Male", 51, 69)
	AddNewVariation("Visor", "Male", 52, 70)
	AddNewVariation("Visor", "Male", 53, 71)
	AddNewVariation("Visor", "Male", 62, 72)
	AddNewVariation("Visor", "Male", 65, 66)
	AddNewVariation("Visor", "Male", 73, 74)
	AddNewVariation("Visor", "Male", 76, 77)
	AddNewVariation("Visor", "Male", 79, 78)
	AddNewVariation("Visor", "Male", 80, 81)
	AddNewVariation("Visor", "Male", 91, 92)
	AddNewVariation("Visor", "Male", 104, 105)
	AddNewVariation("Visor", "Male", 109, 110)
	AddNewVariation("Visor", "Male", 116, 117)
	AddNewVariation("Visor", "Male", 118, 119)
	AddNewVariation("Visor", "Male", 123, 124)
	AddNewVariation("Visor", "Male", 125, 126)
	AddNewVariation("Visor", "Male", 127, 128)
	AddNewVariation("Visor", "Male", 130, 131)
	AddNewVariation("Visor", "Female", 43, 44) -- Female Visor/Hat Variations
	AddNewVariation("Visor", "Female", 49, 67)
	AddNewVariation("Visor", "Female", 64, 65)
	AddNewVariation("Visor", "Female", 65, 64)
	AddNewVariation("Visor", "Female", 51, 69)
	AddNewVariation("Visor", "Female", 50, 68)
	AddNewVariation("Visor", "Female", 52, 70)
	AddNewVariation("Visor", "Female", 62, 71)
	AddNewVariation("Visor", "Female", 72, 73)
	AddNewVariation("Visor", "Female", 75, 76)
	AddNewVariation("Visor", "Female", 78, 77)
	AddNewVariation("Visor", "Female", 79, 80)
	AddNewVariation("Visor", "Female", 18, 66)
	AddNewVariation("Visor", "Female", 66, 81)
	AddNewVariation("Visor", "Female", 81, 66)
	AddNewVariation("Visor", "Female", 86, 84)
	AddNewVariation("Visor", "Female", 90, 91)
	AddNewVariation("Visor", "Female", 103, 104)
	AddNewVariation("Visor", "Female", 108, 109)
	AddNewVariation("Visor", "Female", 115, 116)
	AddNewVariation("Visor", "Female", 117, 118)
	AddNewVariation("Visor", "Female", 122, 123)
	AddNewVariation("Visor", "Female", 124, 125)
	AddNewVariation("Visor", "Female", 126, 127)
	AddNewVariation("Visor", "Female", 129, 130)
	AddNewVariation("Bags", "Male", 45, 44) -- Male Bags
	AddNewVariation("Bags", "Male", 41, 40)
	AddNewVariation("Bags", "Female", 45, 44) -- Female Bags
	AddNewVariation("Bags", "Female", 41, 40)
end)

-- Code
local Clothes = {
    [GetHashKey("mp_m_freemode_01")] = {
        ["Pants"] = { Draw = 61, Txd = 0 },
        ["Shirt"] = { Draw = 15, Txd = 0 },
        ["Jacket"] = { Draw = 15, Txd = 0 },
        ["Arms"] = { Draw = 15, Txd = 0 },
        ["Shoes"] = { Draw = 34, Txd = 0 },
        ["Vest"] = { Draw = 0, Txd = 0 },
        ["Neck"] = { Draw = 0, Txd = 0 }
    },
    [GetHashKey("mp_f_freemode_01")] = {
        ["Pants"] = { Draw = 15, Txd = 3 },
        ["Shirt"] = { Draw = 14, Txd = 0 },
        ["Jacket"] = { Draw = 15, Txd = 3 },
        ["Arms"] = { Draw = 15, Txd = 0 },
        ["Shoes"] = { Draw = 35, Txd = 0 },
        ["Vest"] = { Draw = 0, Txd = 0 },
        ["Neck"] = { Draw = 0, Txd = 0 }
    }
}

local Animations = {
    ["Vest"] = { Dict = "clothingtie", Anim = "try_tie_negative_a", Move = 51, Timeout = 1200 },
    ["Shoes"] = { Dict = "random@domestic", Anim = "pickup_low", Move = 0, Timeout = 1200 },
    ["Shirt"] = { Dict = "clothingtie", Anim = "try_tie_negative_a", Move = 51, Timeout = 1200 },
	["Pants"] = { Dict = "re@construction", Anim = "out_of_breath", Move = 51, Timeout = 1300 },
    ["Visor"] = { Dict = "mp_masks@standard_car@ds@", Anim = "put_on_mask", Move = 51, Timeout = 600 },
    ["Bag"] = { Dict = "anim@heists@ornate_bank@grab_cash", Anim = "intro", Move = 51, Timeout = 1600 },
    ["Gloves"] = { Dict = "nmt_3_rcm-10", Anim = "cs_nigel_dual-10", Move = 51, Timeout = 1200 },
    ["Neck"] = {Dict = "clothingtie", Anim = "try_tie_positive_a", Move = 51, Timeout = 2100},
}

local hasPantsOff = false
local lastPants = {}
RegisterNetEvent('fw-menu:Client:TogglePants', function()
    RequestAnimDict(Animations["Pants"].Dict)
    while not HasAnimDictLoaded(Animations["Pants"].Dict) do Wait(3) end

    TaskPlayAnim(PlayerPedId(), Animations["Pants"].Dict, Animations["Pants"].Anim, 3.0, 3.0, Animations["Pants"].Timeout, Animations["Pants"].Move, 0, false, false, false)

    Citizen.SetTimeout(Animations["Pants"].Timeout, function()
        if not hasPantsOff then
            if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") or GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
                
                StopAnimTask(PlayerPedId(), Animations["Pants"].Dict, Animations["Pants"].Anim, 1.0)
                hasPantsOff = true
                lastPants = { Draw = GetPedDrawableVariation(PlayerPedId(), 4), Txd = GetPedTextureVariation(PlayerPedId(), 4) }
                
                SetPedComponentVariation(PlayerPedId(), 4, Clothes[GetEntityModel(PlayerPedId())]["Pants"].Draw, Clothes[GetEntityModel(PlayerPedId())]["Pants"].Txd, 0)
            end
        else
            if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") or GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
                hasPantsOff = false
                SetPedComponentVariation(PlayerPedId(), 4, lastPants.Draw, lastPants.Txd, 0)
                lastPants = {}
            end
        end
    end)
end)

local hasShirtOff = false
local hasVestOff = false
local lastJackets = {}
local lastArms = {}
local lastVest = {}
RegisterNetEvent('fw-menu:Client:ToggleShirt', function()
    RequestAnimDict(Animations["Shirt"].Dict)
    while not HasAnimDictLoaded(Animations["Shirt"].Dict) do Wait(3) end

    TaskPlayAnim(PlayerPedId(), Animations["Shirt"].Dict, Animations["Shirt"].Anim, 3.0, 3.0, Animations["Shirt"].Timeout, Animations["Shirt"].Move, 0, false, false, false)

    Citizen.SetTimeout(Animations["Shirt"].Timeout, function()
        if not hasShirtOff then
            if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") or GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
                StopAnimTask(PlayerPedId(), Animations["Shirt"].Dict, Animations["Shirt"].Anim, 1.0)
                hasShirtOff = true
                lastJackets = { Draw = GetPedDrawableVariation(PlayerPedId(), 11), Txd = GetPedTextureVariation(PlayerPedId(), 11) }
                lastArms = { Draw = GetPedDrawableVariation(PlayerPedId(), 3), Txd = GetPedTextureVariation(PlayerPedId(), 3) }
                lastVest = { Draw = GetPedDrawableVariation(PlayerPedId(), 9), Txd = GetPedTextureVariation(PlayerPedId(), 9) }
                lastShirt = { Draw = GetPedDrawableVariation(PlayerPedId(), 8), Txd = GetPedTextureVariation(PlayerPedId(), 8) }
        
                SetPedComponentVariation(PlayerPedId(), 8, Clothes[GetEntityModel(PlayerPedId())]["Shirt"].Draw, Clothes[GetEntityModel(PlayerPedId())]["Shirt"].Txd, 0)
                SetPedComponentVariation(PlayerPedId(), 9, Clothes[GetEntityModel(PlayerPedId())]["Vest"].Draw, Clothes[GetEntityModel(PlayerPedId())]["Vest"].Txd, 0)
                SetPedComponentVariation(PlayerPedId(), 3, Clothes[GetEntityModel(PlayerPedId())]["Arms"].Draw, GetPedTextureVariation(PlayerPedId(), 3), 0)
                SetPedComponentVariation(PlayerPedId(), 11, Clothes[GetEntityModel(PlayerPedId())]["Jacket"].Draw, Clothes[GetEntityModel(PlayerPedId())]["Jacket"].Txd, 0)
            end
        else
            if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") or GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
                hasShirtOff = false
                
                SetPedComponentVariation(PlayerPedId(), 8, lastShirt.Draw, lastShirt.Txd, 0)
                SetPedComponentVariation(PlayerPedId(), 9, lastVest.Draw, lastVest.Txd, 0)
                SetPedComponentVariation(PlayerPedId(), 3, lastArms.Draw, GetPedTextureVariation(PlayerPedId(), 3), 0)
                SetPedComponentVariation(PlayerPedId(), 11, lastJackets.Draw, lastJackets.Txd, 0)
                lastJackets = {}
                lastArms = {}
            end
        end
    end)
end)

local hasShoesOff = false
local lastShoes = {}
RegisterNetEvent('fw-menu:Client:ToggleShoes', function()
    RequestAnimDict(Animations["Shoes"].Dict)
    while not HasAnimDictLoaded(Animations["Shoes"].Dict) do Wait(3) end

    TaskPlayAnim(PlayerPedId(), Animations["Shoes"].Dict, Animations["Shoes"].Anim, 3.0, 3.0, Animations["Shoes"].Timeout, Animations["Shoes"].Move, 0, false, false, false)

    Citizen.SetTimeout(Animations["Shoes"].Timeout, function()
        if not hasShoesOff then
            if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") or GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
                
                StopAnimTask(PlayerPedId(), Animations["Shoes"].Dict, Animations["Shoes"].Anim, 1.0)
                hasShoesOff = true
                lastShoes = { Draw = GetPedDrawableVariation(PlayerPedId(), 6), Txd = GetPedTextureVariation(PlayerPedId(), 6) }
                
                SetPedComponentVariation(PlayerPedId(), 6, Clothes[GetEntityModel(PlayerPedId())]["Shoes"].Draw, Clothes[GetEntityModel(PlayerPedId())]["Shoes"].Txd, 0)
            end
        else
            if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") or GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
                hasShoesOff = false
                SetPedComponentVariation(PlayerPedId(), 6, lastShoes.Draw, lastShoes.Txd, 0)
                lastShoes = {}
            end
        end
    end)
end)

RegisterNetEvent('fw-menu:Client:ToggleVest', function()
    RequestAnimDict(Animations["Vest"].Dict)
    while not HasAnimDictLoaded(Animations["Vest"].Dict) do Wait(3) end

    TaskPlayAnim(PlayerPedId(), Animations["Vest"].Dict, Animations["Vest"].Anim, 3.0, 3.0, Animations["Vest"].Timeout, Animations["Vest"].Move, 0, false, false, false)

    Citizen.SetTimeout(Animations["Vest"].Timeout, function()
        if not hasVestOff then
            if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") or GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
                
                StopAnimTask(PlayerPedId(), Animations["Vest"].Dict, Animations["Vest"].Anim, 1.0)
                hasVestOff = true
                lastVest = { Draw = GetPedDrawableVariation(PlayerPedId(), 9), Txd = GetPedTextureVariation(PlayerPedId(), 9) }
                
                SetPedComponentVariation(PlayerPedId(), 9, Clothes[GetEntityModel(PlayerPedId())]["Vest"].Draw, Clothes[GetEntityModel(PlayerPedId())]["Vest"].Txd, 0)
            end
        else
            if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") or GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
                hasVestOff = false
                SetPedComponentVariation(PlayerPedId(), 9, lastVest.Draw, lastVest.Txd, 0)
                lastVest = {}
            end
        end
    end)
end)

RegisterNetEvent('fw-menu:Client:ToggleVisor', function()
    local Gender = GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") == "Female" and "Female" or "Male"
    local Current = GetPedPropIndex(PlayerPedId(), 0)
    local Texture = GetPedPropTextureIndex(PlayerPedId(), 0)
    local NewProp = Variations.Visor[Gender][Current]
    if NewProp == nil then
        FW.Functions.Notify("Deze helm heeft geen visier..", "error")
        return
    end

    RequestAnimDict(Animations["Visor"].Dict)
    while not HasAnimDictLoaded(Animations["Visor"].Dict) do Wait(3) end
    TaskPlayAnim(PlayerPedId(), Animations["Visor"].Dict, Animations["Visor"].Anim, 3.0, 3.0, Animations["Visor"].Timeout, Animations["Visor"].Move, 0, false, false, false)

    Citizen.SetTimeout(Animations["Visor"].Timeout, function()
        StopAnimTask(PlayerPedId(), Animations["Visor"].Dict, Animations["Visor"].Anim, 1.0)
        SetPedPropIndex(PlayerPedId(), 0, NewProp, Texture, true)
    end)
end)

RegisterNetEvent('fw-menu:Client:ToggleBag', function()
    local Gender = GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") == "Female" and "Female" or "Male"
    local Current = GetPedDrawableVariation(PlayerPedId(), 5)
    local Texture = GetPedTextureVariation(PlayerPedId(), 5)
    local NewProp = Variations.Bags[Gender][Current]
    print(Current, Texture, NewProp)
    if NewProp == nil then
        FW.Functions.Notify("Deze rugzak doet niet zo veel..", "error")
        return
    end

    RequestAnimDict(Animations["Bag"].Dict)
    while not HasAnimDictLoaded(Animations["Bag"].Dict) do Wait(3) end
    TaskPlayAnim(PlayerPedId(), Animations["Bag"].Dict, Animations["Bag"].Anim, 3.0, 3.0, Animations["Bag"].Timeout, Animations["Bag"].Move, 0, false, false, false)

    Citizen.SetTimeout(Animations["Bag"].Timeout, function()
        StopAnimTask(PlayerPedId(), Animations["Bag"].Dict, Animations["Bag"].Anim, 1.0)
        SetPedComponentVariation(PlayerPedId(), 5, NewProp, Texture, 0)
    end)
end)

local OriginalGloves = {}
RegisterNetEvent('fw-menu:Client:ToggleGloves', function()
    local Gender = GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") == "Female" and "Female" or "Male"
    local Current = GetPedDrawableVariation(PlayerPedId(), 3)
    local Texture = GetPedTextureVariation(PlayerPedId(), 3)
    local NewProp = Variations.Gloves[Gender][Current]
    if NewProp == nil then
        if OriginalGloves.Draw then
            NewProp = OriginalGloves.Draw
            Texture = OriginalGloves.Txt
        else
            FW.Functions.Notify("Deze handschoenen lijken wel vast te zitten..", "error")
            return
        end
    else
        OriginalGloves.Draw = Current
        OriginalGloves.Txt = Texture
    end

    RequestAnimDict(Animations["Gloves"].Dict)
    while not HasAnimDictLoaded(Animations["Gloves"].Dict) do Wait(3) end
    TaskPlayAnim(PlayerPedId(), Animations["Gloves"].Dict, Animations["Gloves"].Anim, 3.0, 3.0, Animations["Gloves"].Timeout, Animations["Gloves"].Move, 0, false, false, false)

    Citizen.SetTimeout(Animations["Gloves"].Timeout, function()
        StopAnimTask(PlayerPedId(), Animations["Gloves"].Dict, Animations["Gloves"].Anim, 1.0)
        SetPedComponentVariation(PlayerPedId(), 3, NewProp, Texture, 0)
    end)
end)

local HasNeckOff = false
local LastNeck = {}
RegisterNetEvent('fw-menu:Client:ToggleNeck', function()
    RequestAnimDict(Animations["Neck"].Dict)
    while not HasAnimDictLoaded(Animations["Neck"].Dict) do Wait(3) end

    TaskPlayAnim(PlayerPedId(), Animations["Neck"].Dict, Animations["Neck"].Anim, 3.0, 3.0, Animations["Neck"].Timeout, Animations["Neck"].Move, 0, false, false, false)

    Citizen.SetTimeout(Animations["Neck"].Timeout, function()
        if not HasNeckOff then
            if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") or GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
                
                StopAnimTask(PlayerPedId(), Animations["Neck"].Dict, Animations["Neck"].Anim, 1.0)
                HasNeckOff = true
                LastNeck = { Draw = GetPedDrawableVariation(PlayerPedId(), 7), Txd = GetPedTextureVariation(PlayerPedId(), 7) }
                
                SetPedComponentVariation(PlayerPedId(), 7, Clothes[GetEntityModel(PlayerPedId())]["Neck"].Draw, Clothes[GetEntityModel(PlayerPedId())]["Neck"].Txd, 0)
            end
        else
            if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") or GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
                HasNeckOff = false
                SetPedComponentVariation(PlayerPedId(), 7, LastNeck.Draw, LastNeck.Txd, 0)
                LastNeck = {}
            end
        end
    end)
end)