Config = Config or {}

Config.Handcuffed, Config.Hardcuffed, Config.Escorted = false, false, false

Config.Barricades = {}
Config.Evidence = {}

-- Cams
Config.SecurityCams = {
    { Coords = vector4(-57.32, -1752.09, 30.4, 266.79),   Label = 'Grove Street' },
    { Coords = vector4(-1485.66, -376.66, 41.4, 137.59),  Label = 'Morningwood' },
    { Coords = vector4(-1220.76, -909.15, 13.55, 37.12),  Label = 'San Andreas' },
    { Coords = vector4(-718.05, -916.04, 20.04, 313.80),  Label = 'Little Seoul' },
    { Coords = vector4(28.55, -1344.2, 29.91, 127.07),    Label = 'Innocence' },
    { Coords = vector4(1132.66, -983.17, 47.11, 279.92),  Label = 'El Rancho' },
    { Coords = vector4(1153.48, -327.02, 70.30, 324.08),  Label = 'West Mirror Drive' },
    { Coords = vector4(378.95, 329.69, 104.8, 111.29),    Label = 'Clinton Ave' },
    { Coords = vector4(-1827.25, 784.65, 139.42, 353.42), Label = 'Banham Canvon' },
    { Coords = vector4(-2965.01, 391.32, 16.24, 93.29),   Label = 'Great Ocean Hyw' },
    { Coords = vector4(-3045.23, 588.74, 8.9, 235.91),    Label = 'Ineseno Road' },
    { Coords = vector4(-3246.29, 1006.2, 13.91, 210.33),  Label = 'Barbareno Rd' },
    { Coords = vector4(544.92, 2666.69, 42.97, 310.03),   Label = 'Route 68' },
    { Coords = vector4(1165.42, 2712.17, 39.35, 181.28),  Label = 'Route 68 2' },
    { Coords = vector4(2676.92, 3285.52, 55.99, 182.06),  Label = 'Senora Fwy' },
    { Coords = vector4(1962.34, 3746.56, 33.26, 154.49),  Label = 'Alhambra Dr' },
    { Coords = vector4(1733.99, 6417.05, 35.85, 98.21),   Label = 'Senora Fwy 2' },
    { Coords = vector4(-161.75, 6319.98, 32.78, 318.76),  Label = 'Pyrite Ave' },
    { Coords = vector4(167.13, 6641.66, 32.56, 81.21),    Label = 'Paleto Blvd' },
    { Coords = vector4(1702.95, 4934.05, 43.26, 181.29),  Label = 'Grapeseed' },
    { Coords = vector4(2553.42, 386.08, 109.71, 212.2),   Label = 'Palomino Fwy' },
    { Coords = vector4(6.35, -1102.92, 30.59, 220.63),    Label = 'Ammunation Legion Square' },
    { Coords = vector4(817.06, -778.56, 26.5, 118.02),    Label = '24/7 Otto\'s' },
    { Coords = vector4(-665.68, -943.22, 23.39, 317.53),  Label = 'Ammunation Little Seoul' },
    { Coords = vector4(-1312.46, -388.69, 38.0, 214.54),  Label = 'Ammunation Morningwood' },
    { Coords = vector4(-1645.21, 2079.44, 72.90, 274.17),  Label = 'Two Hoot Waterfalls' },
}

-- Evidence
Config.IgnoredWeapons = {
    "WEAPON_UNARMED",
    "WEAPON_SNOWBALL",
    "WEAPON_PETROLCAN",
    "WEAPON_TASER",
    "WEAPON_PAINTBALL",
    "WEAPON_FIREEXTINGUISHER",
    "WEAPON_SHOE",
    "WEAPON_BRICK"
}

-- Heli Cam
Config.CameraHelicopters = {
    [GetHashKey('airone')] = true,
}

-- Vehicle
Config.FirstNames = {
    'Emma', 'Noah', 'Olivia', 'Liam', 'Tess', 'Lucas', 
    'Julia', 'Milan', 'Sophie', 'Levi', 'Sara', 'Finn', 
    'Zoe', 'Sem', 'Nora', 'Luuk', 'Anna', 'Bram', 
    'Eva', 'Daan', 'Mia', 'Jack', 'Olivia', 'Dex', 
    'Isa', 'Jesse', 'Lotte', 'Thomas', 'Mila', 'Thijs', 
    'Sara', 'Max', 'Sophie', 'Stijn', 'Zoë', 'Ruben', 
    'Noa', 'Jayden', 'Fenna', 'Sam', 'Lauren', 'Liam', 
    'Olivia', 'Tim', 'Julia', 'Lars', 'Eva', 'Nova', 
    'Finn', 'Tess', 'Tygo', 'Lynn', 'Daan', 'Saar', 
    'Jax', 'Milou', 'Max', 'Emily', 'Luuk', 'Lotte', 
    'Noud', 'Maud', 'Vince', 'Liv', 'Milan', 'Isa', 
    'Jesse', 'Lieve', 'Cas', 'Nova', 'Roos', 'Noah', 
    'Jasmijn', 'Luuk', 'Fleur', 'Dex', 'Evi', 'Mason', 
    'Puck', 'Lars', 'Sofie', 'Niek', 'Pien', 'Liam', 
    'Lieke', 'Boaz', 'Emma', 'Stan', 'Sanne', 'Teun', 
    'Isa', 'Indy', 'Ruben', 'Elise', 'Kai', 'Liv', 
    'Mees', 'Lynn', 'Tom', 'Fien'
}

Config.LastNames = {
    'Jansen', 'van der Berg', 'de Vries', 'van den Broek', 'Bakker', 'van Dijk',
    'Peters', 'Visser', 'Smit', 'van Leeuwen', 'van der Linden', 'Verbeek', 
    'van der Heijden', 'Hendriks', 'Willems', 'Jacobs', 'van Beek', 'van den Bosch', 
    'Bosman', 'Meijer', 'van der Meer', 'van der Valk', 'Hoekstra', 'van der Laan', 
    'Kuijpers', 'van Houten', 'Kuiper', 'Mulder', 'de Jong', 'van der Wal', 
    'van den Heuvel', 'van der Voort', 'Vos', 'van Rijn', 'Groen', 'van Ginkel', 
    'de Boer', 'Schouten', 'van Dam', 'van Es', 'Koster', 'van der Zande', 
    'Dijkstra', 'Bakker', 'van de Ven', 'Verhoeven', 'Janssen', 'van der Woude', 
    'van Rooij', 'van der Horst', 'Scholten', 'van den Brink', 'van der Linde', 'Veenstra', 
    'van der Steen', 'van der Maat', 'de Graaf', 'Hendrikse', 'van der Meulen', 'van der Pol', 
    'van der Plas', 'Peeters', 'van Vliet', 'van der Linden', 'Verheijen', 'Schipper', 
    'van der Venne', 'de Koning', 'van der Velde', 'van der Heuvel', 'de Lange', 'van der Veen', 
    'van den Hoek', 'de Groot', 'van der Kamp', 'van der Kroon', 'van der Berg', 'Smeets', 
    'van der Ploeg', 'van den Brink', 'van der Molen', 'van Loon', 'van Dijk', 'van der Wal', 
    'van der Sluis', 'van de Weerd', 'van Riet', 'de Ruiter', 'van der Meer', 'van Dongen', 
    'van der Pol', 'van Zanten', 'van der Spek', 'van den Bogaard', 'van den Boom', 'de Wit', 
    'van der Kamp', 'van der Berg', 'van der Veer', 'van Doorn'
}


Config.VehicleCerts = {
    ['airone'] = 'AIRONE',
    ['polvic'] = 'STANDAARD',
    ['polchal'] = 'INTERCEPTOR',
    ['polstang'] = 'INTERCEPTOR',
    ['polvette'] = 'INTERCEPTOR',
    ['poltaurus'] = 'STANDAARD',
    ['polexp'] = 'STANDAARD',
    ['polchar'] = 'STANDAARD',
    ['polblazer'] = 'STANDAARD',
    ['polmotor'] = 'MOTORCYCLE',
    ['policeb'] = 'MOTORCYCLE',
    ['ucbanshee'] = 'UNMARKED',
    ['ucrancher'] = 'UNMARKED',
    ['ucbuffalo'] = 'UNMARKED',
    ['ucballer'] = 'UNMARKED',
}

Config.HeliPads = {
    {
        name = "pd_heli_platform_paleto",
        heading = 45,
        minZ = 29.0,
        maxZ = 33.0,
        center = vector3(-474.71, 5988.43, 31.34),
        length = 12.2,
        width = 12.2,
        Coords = vector4(-475.53, 5988.2, 31.34, 313.74),
    },
    {
        center = vector3(449.13, -981.2, 43.69),
        length = 12.2,
        width = 12.2,
        name = "pd_heli_platform_mrpd",
        heading = 0,
        minZ = 42.0,
        maxZ = 46.0,
        Coords = vector4(449.57, -981.33, 43.69, 271.71),
    },
    {
        center = vector3(-745.36, -1468.55, 5.0),
        length = 15.6,
        width = 15.2,
        name = "pd_heli_platform_marina",
        heading = 320,
        minZ = 4.0,
        maxZ = 8.0,
        Coords = vector4(-745.55, -1468.95, 5.16, 320.79),
    },
    {
        center = vector3(1852.95, 3706.48, 33.97),
        length = 12.2,
        width = 12.2,
        name = "pd_heli_platform_sandy",
        heading = 30,
        minZ = 31.0,
        maxZ = 35.0,
        Coords = vector4(1853.62, 3705.66, 33.97, 30.03),
    },
}

Config.LogoutSpots = {
    {
        center = vector3(478.21, -981.88, 30.69),
        length = 2.5,
        width = 4.5,
        name = "pd_logout_mrpd",
        heading = 270,
        minZ = 29.0,
        maxZ = 33.0,
    },
    {
        center = vector3(-456.76, 6008.46, 27.58),
        length = 1.0,
        width = 1.0,
        name = "pd_logout_paleto",
        heading = 270,
        minZ = 25.0,
        maxZ = 29.0,
    },
    {
        center = vector3(1834.37, 3683.94, 34.2),
        length = 1.0,
        width = 1.0,
        name = "pd_logout_sandy",
        heading = 305,
        minZ = 32.0,
        maxZ = 36.0,
    },
}
