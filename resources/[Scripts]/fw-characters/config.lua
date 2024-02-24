Config = Config or {}

Config.WelcomeVehicles = {
    { Model = "weevil", Chance = 0.5 },
    { Model = "panto", Chance = 0.8 },
    { Model = "rhapsody", Chance = 0.8 },
    { Model = "brioso2", Chance = 0.5 },
    { Model = "kalahari", Chance = 0.2 },
    { Model = "rebel", Chance = 0.7 },
    { Model = "dynasty", Chance = 0.1 },
    { Model = "fagaloa", Chance = 0.1 },
    { Model = "minivan", Chance = 0.5 }
}

Config.HideCoords = vector3(2844.64, -1465.4, 13.4)
Config.CamCoords = vector4(2850.52, -1445.4, 14.5, 324.0)
Config.PedCoords = {
    vector3(2852.155, -1439.16, 13.92243),
    vector3(2853.134, -1439.275, 13.92243),
    vector3(2854.071, -1439.58, 13.92243),
    vector3(2854.931, -1440.063, 13.92243),
    vector3(2855.678, -1440.705, 13.92243),
    vector3(2856.286, -1441.481, 13.92243),
}

-- Array of STEAM IDs of players that may ingore character limit.
Config.LimitOverride = {
    ['STEAM_ID'] = true,
}

-- Spawns
-- Add at bottom!
Config.SpawnLocations = {
    {
        Id = "lastlocation",
        Name = "Laatste Locatie",
        Icon = 'fas fa-map-pin',
        Coords = { X = 0.0, Y = 0.0, Z = 0.0 },
        Type = 'Location',
        Hidden = false,
    },
    {
        Id = "apartment",
        Name = "No3 Appartement",
        Icon = 'fas fa-building',
        Color = '#f2a365',
        Coords = { X = -271.15, Y = -957.91, Z = 31.22 },
        Type = 'Apartment',
        Hidden = false,
    },
    {
        Id = "bus",
        Name = "Bus Station",
        Icon = "map-marker-alt",
        Coords = {X = 454.77, Y = -659.29, Z = 27.62, H = 177.66},
        Type = "Location",
        Hidden = false
    },
    {
        Id = "motels",
        Name = "Motel Parking",
        Icon = "map-marker-alt",
        Coords = {X = 275.49, Y = -354.11, Z = 44.98, H = 154.26},
        Type = "Location",
        Hidden = false
    },
    {
        Id = "pier",
        Name = "Del Perro Pier",
        Icon = "map-marker-alt",
        Coords = {X = -1648.76, Y = -994.26, Z = 13.02, H = 230.24},
        Type = "Location",
        Hidden = false
    },
    {
        Id = "harmonymotel",
        Name = "Harmony Motel",
        Icon = "map-marker-alt",
        Coords = {X = 1122.11, Y =  2667.24, Z = 38.04, H = 180.39},
        Type = "Location",
        Hidden = false
    },
    {
        Id = "paleto",
        Name = "Paleto Bay",
        Icon = "map-marker-alt",
        Coords = {X = 145.62, Y = 6563.19, Z = 32.0, H = 42.83},
        Type = "Location",
        Hidden = false
    },
    {
        Id = "airport",
        Name = "Los Santos International Airport",
        Icon = "map-marker-alt",
        Coords = {X = -1037.68, Y = -2737.68, Z = 20.17, H = 331.25},
        Type = "Location",
        Hidden = false
    },
    {
        Id = "vinewood",
        Name = "Vinewood Blvd. Taxi Stop",
        Icon = "map-marker-alt",
        Coords = {X = 272.16, Y = 185.44, Z = 104.67, H = 320.57},
        Type = "Location",
        Hidden = false
    },
    {
        Id = "hospital",
        Name = "Crusade Medical Center Bus Stop",
        Icon = "map-marker-alt",
        Coords = {X = 374.22, Y = -1537.64, Z = 29.29, H = 139.53},
        Type = "Location",
        Hidden = false
    },
    {
        Id = "bolingbroke_penitentiary",
        Name = 'Bolingbroke Penitentiary',
        Icon = 'fas fa-voicemail',
        Coords = { X = 1845.903, Y = 2585.873, Z = 45.672 },
        Type = 'Jail',
        Hidden = true,
    },
}

function DeepCopyTable(Obj)
    if type(Obj) ~= 'table' then return Obj end
    local res = {}
    
    for k, v in pairs(Obj) do
        res[DeepCopyTable(k)] = DeepCopyTable(v)
    end

    return res
end