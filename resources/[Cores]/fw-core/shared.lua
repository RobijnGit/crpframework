Shared = {}

Shared.Tax = {}

Shared.VehicleMods = {
    ['ModSpoilers'] = 0,
    ['ModFrontBumper'] = 1,
    ['ModRearBumper'] = 2,
    ['ModSideSkirt'] = 3,
    ['ModExhaust'] = 4,
    ['ModFrame'] = 5,
    ['ModGrille'] = 6,
    ['ModHood'] = 7,
    ['ModFender'] = 8,
    ['ModRightFender'] = 9,
    ['ModRoof'] = 10,
    ['ModEngine'] = 11,
    ['ModBrakes'] = 12,
    ['ModTransmission'] = 13,
    ['ModHorns'] = 14,
    ['ModSuspension'] = 15,
    ['ModArmor'] = 16,
    ['ModTurbo'] = 18,
    ['ModXenon'] = 22,
    ['ModFrontWheels'] = 23,
    ['ModBackWheels'] = 24,
    ['ModPlateHolder'] = 25,
    ['ModVanityPlate'] = 26,
    ['ModTrimA'] = 27,
    ['ModOrnaments'] = 28,
    ['ModDashboard'] = 29,
    ['ModDial'] = 30,
    ['ModDoorSpeaker'] = 31,
    ['ModSeats'] = 32,
    ['ModSteeringWheel'] = 33,
    ['ModShifterLeavers'] = 34,
    ['ModAPlate'] = 35,
    ['ModSpeakers'] = 36,
    ['ModTrunk'] = 37,
    ['ModHydrolic'] = 38,
    ['ModEngineBlock'] = 39,
    ['ModAirFilter'] = 40,
    ['ModStruts'] = 41,
    ['ModArchCover'] = 42,
    ['ModAerials'] = 43,
    ['ModTrimB'] = 44,
    ['ModTank'] = 45,
    ['ModWindows'] = 46,
    ['ModLivery'] = 48,
}

function Shared.CalculateTax(Type, Number)
    if not IsDuplicityVersion() and next(Shared.Tax) == nil then
        Shared.Tax = FW.SendCallback("FW:GetTax")
    end

    if Shared.Tax[Type] == nil then return Number end
    local Multiplier = 1.0 + (Shared.Tax[Type] / 100)

    return math.ceil(Number * Multiplier)
end

function Shared.DeductTax(Type, Number)
    if not IsDuplicityVersion() and next(Shared.Tax) == nil then
        Shared.Tax = FW.SendCallback("FW:GetTax")
    end

    return math.ceil(Number * (1.0 - (Shared.Tax[Type] / 100))), math.ceil(Number * (Shared.Tax[Type] / 100))
end

local StringCharset = {}
local NumberCharset = {}
for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end
for i = 65,  90 do table.insert(StringCharset, string.char(i)) end
for i = 97, 122 do table.insert(StringCharset, string.char(i)) end

Shared.RandomStr = function(length)
	if length > 0 then
		return Shared.RandomStr(length-1) .. StringCharset[math.random(1, #StringCharset)]
	else
		return ''
	end
end

Shared.RandomInt = function(length)
	if length > 0 then
		return Shared.RandomInt(length-1) .. NumberCharset[math.random(1, #NumberCharset)]
	else
		return ''
	end
end

Shared.SplitStr = function(str, delimiter)
	local result = { }
	local from  = 1
	local delim_from, delim_to = string.find( str, delimiter, from  )
	while delim_from do
		table.insert( result, string.sub( str, from , delim_from-1 ) )
		from  = delim_to + 1
		delim_from, delim_to = string.find( str, delimiter, from  )
	end
	table.insert( result, string.sub( str, from  ) )
	return result
end

function Shared.EncryptString(Str)
    return (Str:gsub('.', function(C)
        return string.format('%02X', string.byte(C))
    end))
end

function Shared.DecryptString(Str)
    return (Str:gsub('..', function(CC)
        return string.char(tonumber(CC, 16))
    end))
end

Shared.StarterItems = {
    ["phone"] = {amount = 1, item = "phone"},
    ["id_card"] = {amount = 1, item = "id_card"},
    ["driver_license"] = {amount = 1, item = "driver_license"},
    ["welcome"] = {amount = 1, item = "welcome"},
}

Shared.Jobs = {
    ["unemployed"] = {
        label = "UWV",
        payment = 70,
        grades = {
            ['0'] = {
                name = "Uitkering",
                payment = 70
            },
        },
        defaultDuty = true,
    },
    ["news"] = {
        label = "Weazel News",
        payment = 70,
        grades = {
            ['0'] = {
                name = "Medewerker",
                payment = 100
            },
            ['1'] = {
                name = "Leidinggevende",
                payment = 115
            },
        },
        defaultDuty = true,
    },
    ["police"] = {
        label = "Politie",
        payment = 100,
        grades = {
            ['0'] = {
                name = "Stagiair",
                payment = 150
            },
            ['1'] = {
                name = "Medewerker",
                payment = 230
            },
            ['2'] = {
                name = "Leidinggevende",
                payment = 260
            },
        },
        defaultDuty = false,
    },
    ["doc"] = {
        label = "Department of Corrections",
        payment = 200,
        grades = {
            ['0'] = {
                name = "Stagiair",
                payment = 150
            },
            ['1'] = {
                name = "Medewerker",
                payment = 230
            },
            ['2'] = {
                name = "Leidinggevende",
                payment = 260
            },
        },
        defaultDuty = false,
    },
    ["ems"] = {
        label = "Crusade Medisch Centrum",
        payment = 100,
        grades = {
            ['0'] = {
                name = "Stagiair",
                payment = 250
            },
            ['1'] = {
                name = "Medewerker",
                payment = 330 
            },
            ['2'] = {
                name = "Leidinggevende",
                payment = 360
            },
        },
        defaultDuty = false,
    },
    ["lawyer"] = {
        label = "Wet en Recht",
        payment = 130,
        grades = {
            ['0'] = {
                name = "Advocaat",
                payment = 130
            },
        },
        defaultDuty = false,
    },
    ["judge"] = {
        label = "Wet en Recht",
        payment = 260,
        grades = {
            ['0'] = {
                name = "Rechter",
                payment = 260
            },
            ['1'] = {
                name = "Chief of Justice",
                payment = 300
            },
        },
        defaultDuty = false,
    },
    ["usmarshals"] = {
        label = "U.S. Marshals",
        payment = 150,
        grades = {
            ['0'] = {
                name = "Medewerker",
                payment = 150
            },
        },
        defaultDuty = false,
    },
    ["mayor"] = {
        label = "Gemeente Los Santos",
        payment = 300,
        grades = {
            ['0'] = {
                name = "Burgemeester",
                payment = 300
            },
        },
        defaultDuty = false,
    },
    ["councilor"] = {
        label = "City Councilor",
        payment = 150,
        grades = {
            ['0'] = {
                name = "City Councilor",
                payment = 150
            },
        },
        defaultDuty = false,
    },
    ["storesecurity"] = {
        label = "Winkel Cooperatie",
        payment = 125,
        grades = {
            ['0'] = {
                name = "Medewerker",
                payment = 125
            },
        },
        defaultDuty = false,
    },
}

Shared.Colors = {
    [0] = "Metallic Black",
    [1] = "Metallic Graphite Black",
    [2] = "Metallic Black Steel",
    [3] = "Metallic Dark Silver",
    [4] = "Metallic Silver",
    [5] = "Metallic Blue Silver",
    [6] = "Metallic Steel Gray",
    [7] = "Metallic Shadow Silver",
    [8] = "Metallic Stone Silver",
    [9] = "Metallic Midnight Silver",
    [10] = "Metallic Gun Metal",
    [11] = "Metallic Anthracite Grey",
    [12] = "Matte Black",
    [13] = "Matte Gray",
    [14] = "Matte Light Grey",
    [15] = "Util Black",
    [16] = "Util Black Poly",
    [17] = "Util Dark silver",
    [18] = "Util Silver",
    [19] = "Util Gun Metal",
    [20] = "Util Shadow Silver",
    [21] = "Worn Black",
    [22] = "Worn Graphite",
    [23] = "Worn Silver Grey",
    [24] = "Worn Silver",
    [25] = "Worn Blue Silver",
    [26] = "Worn Shadow Silver",
    [27] = "Metallic Red",
    [28] = "Metallic Torino Red",
    [29] = "Metallic Formula Red",
    [30] = "Metallic Blaze Red",
    [31] = "Metallic Graceful Red",
    [32] = "Metallic Garnet Red",
    [33] = "Metallic Desert Red",
    [34] = "Metallic Cabernet Red",
    [35] = "Metallic Candy Red",
    [36] = "Metallic Sunrise Orange",
    [37] = "Metallic Classic Gold",
    [38] = "Metallic Orange",
    [39] = "Matte Red",
    [40] = "Matte Dark Red",
    [41] = "Matte Orange",
    [42] = "Matte Yellow",
    [43] = "Util Red",
    [44] = "Util Bright Red",
    [45] = "Util Garnet Red",
    [46] = "Worn Red",
    [47] = "Worn Golden Red",
    [48] = "Worn Dark Red",
    [49] = "Metallic Dark Green",
    [50] = "Metallic Racing Green",
    [51] = "Metallic Sea Green",
    [52] = "Metallic Olive Green",
    [53] = "Metallic Green",
    [54] = "Metallic Gasoline Blue Green",
    [55] = "Matte Lime Green",
    [56] = "Util Dark Green",
    [57] = "Util Green",
    [58] = "Worn Dark Green",
    [59] = "Worn Green",
    [60] = "Worn Sea Wash",
    [61] = "Metallic Midnight Blue",
    [62] = "Metallic Dark Blue",
    [63] = "Metallic Saxony Blue",
    [64] = "Metallic Blue",
    [65] = "Metallic Mariner Blue",
    [66] = "Metallic Harbor Blue",
    [67] = "Metallic Diamond Blue",
    [68] = "Metallic Surf Blue",
    [69] = "Metallic Nautical Blue",
    [70] = "Metallic Bright Blue",
    [71] = "Metallic Purple Blue",
    [72] = "Metallic Spinnaker Blue",
    [73] = "Metallic Ultra Blue",
    [74] = "Metallic Bright Blue",
    [75] = "Util Dark Blue",
    [76] = "Util Midnight Blue",
    [77] = "Util Blue",
    [78] = "Util Sea Foam Blue",
    [79] = "Uil Lightning blue",
    [80] = "Util Maui Blue Poly",
    [81] = "Util Bright Blue",
    [82] = "Matte Dark Blue",
    [83] = "Matte Blue",
    [84] = "Matte Midnight Blue",
    [85] = "Worn Dark blue",
    [86] = "Worn Blue",
    [87] = "Worn Light blue",
    [88] = "Metallic Taxi Yellow",
    [89] = "Metallic Race Yellow",
    [90] = "Metallic Bronze",
    [91] = "Metallic Yellow Bird",
    [92] = "Metallic Lime",
    [93] = "Metallic Champagne",
    [94] = "Metallic Pueblo Beige",
    [95] = "Metallic Dark Ivory",
    [96] = "Metallic Choco Brown",
    [97] = "Metallic Golden Brown",
    [98] = "Metallic Light Brown",
    [99] = "Metallic Straw Beige",
    [100] = "Metallic Moss Brown",
    [101] = "Metallic Biston Brown",
    [102] = "Metallic Beechwood",
    [103] = "Metallic Dark Beechwood",
    [104] = "Metallic Choco Orange",
    [105] = "Metallic Beach Sand",
    [106] = "Metallic Sun Bleeched Sand",
    [107] = "Metallic Cream",
    [108] = "Util Brown",
    [109] = "Util Medium Brown",
    [110] = "Util Light Brown",
    [111] = "Metallic White",
    [112] = "Metallic Frost White",
    [113] = "Worn Honey Beige",
    [114] = "Worn Brown",
    [115] = "Worn Dark Brown",
    [116] = "Worn straw beige",
    [117] = "Brushed Steel",
    [118] = "Brushed Black steel",
    [119] = "Brushed Aluminium",
    [120] = "Chrome",
    [121] = "Worn Off White",
    [122] = "Util Off White",
    [123] = "Worn Orange",
    [124] = "Worn Light Orange",
    [125] = "Metallic Securicor Green",
    [126] = "Worn Taxi Yellow",
    [127] = "police car blue",
    [128] = "Matte Green",
    [129] = "Matte Brown",
    [130] = "Worn Orange",
    [131] = "Matte White",
    [132] = "Worn White",
    [133] = "Worn Olive Army Green",
    [134] = "Pure White",
    [135] = "Hot Pink",
    [136] = "Salmon pink",
    [137] = "Metallic Vermillion Pink",
    [138] = "Orange",
    [139] = "Green",
    [140] = "Blue",
    [141] = "Mettalic Black Blue",
    [142] = "Metallic Black Purple",
    [143] = "Metallic Black Red",
    [144] = "hunter green",
    [145] = "Metallic Purple",
    [146] = "Metaillic V Dark Blue",
    [147] = "MODSHOP BLACK1",
    [148] = "Matte Purple",
    [149] = "Matte Dark Purple",
    [150] = "Metallic Lava Red",
    [151] = "Matte Forest Green",
    [152] = "Matte Olive Drab",
    [153] = "Matte Desert Brown",
    [154] = "Matte Desert Tan",
    [155] = "Matte Foilage Green",
    [156] = "DEFAULT ALLOY COLOR",
    [157] = "Epsilon Blue",
    [158] = "Unknown",
    [159] = "Unknown"
}