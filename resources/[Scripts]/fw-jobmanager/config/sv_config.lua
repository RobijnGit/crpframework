Config = Config or {}

-- Mining
Config.MaterialTypes = {'metalscrap', 'steel', 'aluminum', 'copper'}

-- Fishing
Config.FishingSpots = {
    vector3(-90.34, 4248.4, 31.25),
    vector3(-172.15, 4147.83, 31.54),
    vector3(-153.44, 3898.95, 31.68),
    vector3(1838.03, 3987.78, 31.7),
    vector3(2386.61, 4333.67, 31.87),
    vector3(2084.86, 4571.23, 32.89),
    vector3(1793.9, 4525.72, 33.02),
    vector3(1601.1, 4452.89, 32.7),
    vector3(1097.45, 4232.08, 31.53),
    vector3(-98.47, 4249.87, 31.34),
    vector3(-153.04, 3903.23, 31.71),
}

Config.FishTypes = {'Bass', 'Blue', 'Cod', 'Flounder', 'Mackerel'}
Config.BigFishTypes = {'Shark', 'Whale'}

-- Chopshop
Config.ChopShop = {
    Spawners = {
        vector4(-489.28, -595.69, 30.8, 180.47), vector4(-482.23, -595.82, 30.48, 177.61), vector4(-333.47, -1495.37, 30.04, 0.9), vector4(-310.32, -772.62, 33.26, 159.34), vector4(-303.49, -775.66, 38.08, 160.2),
        vector4(-299.61, -743.63, 38.08, 340.23), vector4(-308.14, -757.38, 42.91, 158.53), vector4(-342.31, -756.97, 47.73, 87.8), vector4(-306.96, -757.62, 52.55, 340.54), vector4(9.0, -1758.59, 28.69, 230.29),
        vector4(506.35, -1842.59, 27.01, 138.95), vector4(-17.91, -1030.59, 28.25, 339.59), vector4(47.35, -872.05, 29.75, 339.35), vector4(975.0, -1516.27, 30.48, 0.48), vector4(-44.97, -220.65, 44.75, 158.45),
        vector4(-48.74, -220.04, 44.75, 161.52), vector4(-52.54, -218.72, 44.75, 158.45), vector4(-62.98, -214.37, 44.75, 159.04), vector4(408.52, -641.25, 27.8, 271.64), vector4(415.74, -644.01, 27.8, 268.99),
        vector4(409.35, -646.74, 27.8, 271.2), vector4(1195.54, -1303.94, 34.52, 176.36), vector4(1207.51, -1332.69, 34.61, 266.72), vector4(459.32, -1091.74, 28.5, 267.83), vector4(459.15, -1087.65, 28.5, 270.89),
        vector4(471.71, -1092.53, 28.5, 269.69), vector4(1135.8, -974.29, 45.98, 279.0), vector4(743.64, -966.6, 23.96, 88.77), vector4(770.6, -926.52, 24.83, 274.98), vector4(-2.37, -1038.04, 37.46, 67.98),
        vector4(14.08, -1053.38, 37.45, 72.29), vector4(13.67, -1056.65, 37.45, 68.54), vector4(273.23, -224.87, 53.32, 12.44), vector4(284.19, -228.97, 53.33, 13.42), vector4(109.8, -134.02, 54.14, 251.16),
        vector4(122.05, -129.59, 54.22, 246.92), vector4(166.02, -734.08, 32.44, 248.25), vector4(-29.6, -110.94, 56.44, 69.13), vector4(-28.24, -93.74, 56.64, 68.69), vector4(154.74, -749.14, 32.44, 340.49),
        vector4(-163.25, -53.88, 52.56, 252.29), vector4(-176.03, -159.82, 43.01, 251.02), vector4(-527.37, -268.32, 34.65, 112.23), vector4(1875.79, 2542.51, 44.97, 267.03),
        vector4(1869.71, 2542.59, 44.97, 269.54), vector4(-670.72, -744.86, 26.94, 181.78), vector4(-716.19, -764.01, 25.84, 182.18), vector4(2014.93, 3071.95, 46.37, 146.31), vector4(-720.27, -763.89, 30.47, 176.19),
        vector4(-704.76, -732.67, 32.41, 354.81), vector4(-666.99, -751.77, 34.79, 356.45), vector4(-720.49, -751.63, 34.81, 357.8), vector4(-691.38, -744.54, 37.39, 181.81), vector4(1894.66, 3706.2, 32.13, 121.46),
        vector4(2907.34, 4398.54, 49.56, 208.66), vector4(2903.85, 4397.37, 49.56, 199.77), vector4(-1253.79, -646.15, 25.29, 309.78), vector4(-1188.83, -671.21, 25.29, 309.33), vector4(1106.41, 241.8, 80.16, 146.73),
        vector4(-1228.03, -667.53, 30.11, 311.19), vector4(1103.43, 244.31, 80.16, 328.24), vector4(-1181.91, -687.79, 30.11, 308.98), vector4(1099.86, 246.1, 80.16, 147.45), vector4(1112.08, 250.17, 80.16, 56.57),
        vector4(1123.32, 243.16, 80.16, 58.17), vector4(-1228.53, -668.1, 34.93, 129.64), vector4(-1254.58, -636.68, 34.93, 308.74), vector4(-1211.58, -665.9, 39.75, 310.14), vector4(901.36, -27.58, 78.07, 236.49),
        vector4(899.57, -30.29, 78.07, 236.49), vector4(897.7, -33.1, 78.07, 236.49), vector4(895.77, -36.02, 78.07, 236.49), vector4(-1228.2, -638.0, 39.74, 39.87), vector4(-1188.2, -681.66, 39.74, 130.79),
        vector4(-1136.3, -757.41, 18.45, 286.45), vector4(-1186.2, -742.98, 19.48, 307.13), vector4(-950.74, -1961.39, 12.56, 135.29), vector4(-948.78, -1963.91, 12.56, 135.16), vector4(-946.21, -1966.73, 12.56, 136.46),
        vector4(-943.84, -1969.02, 12.57, 135.4), vector4(-941.74, -1971.86, 12.56, 138.45), vector4(-938.79, -1973.76, 12.56, 137.15), vector4(-936.86, -1976.37, 12.57, 135.56), vector4(-953.57, -1959.23, 12.57, 314.4),
        vector4(-956.14, -1956.88, 12.57, 310.65), vector4(-958.49, -1954.3, 12.56, 313.73), vector4(-969.47, -1967.06, 12.57, 316.6), vector4(-972.19, -1964.91, 12.57, 315.9), vector4(-974.78, -1962.58, 12.56, 314.88),
        vector4(-1090.75, -478.9, 35.91, 28.31), vector4(-1037.14, -492.22, 35.92, 26.44), vector4(-1021.7, -509.55, 36.13, 115.17), vector4(-1269.95, -647.05, 26.27, 126.12), vector4(-1338.26, -560.73, 29.78, 30.99),
        vector4(-1639.1, -915.23, 7.97, 319.2), vector4(-1635.45, -910.51, 8.08, 320.79), vector4(-1631.95, -920.45, 7.98, 144.47), vector4(-1634.48, -918.72, 7.98, 138.11), vector4(-1419.39, -596.27, 29.85, 298.02),
        vector4(-1481.27, -659.07, 28.33, 35.99), vector4(-1466.27, -647.99, 28.89, 214.69), vector4(-2012.44, -482.12, 10.78, 322.52), vector4(-2009.88, -483.61, 10.79, 323.38), vector4(-2017.51, -493.2, 11.09, 319.86),
        vector4(-2023.81, -487.95, 11.09, 130.68), vector4(-1594.66, -1052.0, 12.41, 140.49), vector4(-1585.31, -1031.21, 12.41, 205.37), vector4(-1544.49, -1010.25, 12.4, 255.16), vector4(-1536.66, -977.56, 12.4, 319.42),
        vector4(-1420.87, -961.22, 6.64, 62.61), vector4(-1426.06, -965.66, 6.66, 240.41), vector4(-1435.14, -963.95, 6.66, 142.29), vector4(-1424.94, -950.72, 6.53, 142.33), vector4(-1478.93, -998.15, 5.75, 53.37),
        vector4(-1475.44, -1012.02, 5.69, 323.53),
    },
    Vehicles = {
        "emperor", "primo", "schafter2", "prairie", "buffalo",
        "gauntlet", "fugitive", "picador", "asea", "granger",
        "premier", "exemplar", "landstalker", "regina", "virgo",
        "phoenix", "coquette", "asterope", "dilettante", "felon",
        "ninef", "tailgater", "jackal", "f620", "vacca",
        "habanero", "fq2", "baller", "penumbra", "comet2",
        "fusilade", "deviant", "bullet", "dominator", "stanier",
        "warrener", "issi2", "issi7", "stratum", "elegy2",
        "zion", "serrano", "bjxl", "jugular", "oracle",
        "ingot", "sentinel", "oracle2", "superd", "fugitive"
    },
    Scrapyards = {
        vector3(1516.51, -2099.0, 76.83), -- El Burro Heights
        vector3(-424.7, -1686.68, 19.03), -- La Puerta
        vector3(2339.13, 3050.14, 48.15), -- Grand Senora Desert
        vector3(1538.87, 6337.27, 24.08), -- Mount Chiliad, down the 'anti-capitalism' camp.
    }
}

-- Sanitation
Config.Sanitation = {
    Zones = {
        [1] = { Zone = "DelPe", Label = "Del Perro", Busy = false },
        [2] = { Zone = "DelSol", Label = "La Puerta", Busy = false },
        [3] = { Zone = "DTVine", Label = "Downtown Vinewood", Busy = false },
        [4] = { Zone = "East_V", Label = "East Vinewood", Busy = false },
        [5] = { Zone = "EBuro", Label = "El Burro Heights", Busy = false },
        [6] = { Zone = "Elysian", Label = "Elysian Island", Busy = false },
        [7] = { Zone = "Murri", Label = "Murrieta Heights", Busy = false },
        [8] = { Zone = "PBOX", Label = "Pillbox Hill", Busy = false },
        [9] = { Zone = "RANCHO", Label = "Rancho", Busy = false },
        [10] = { Zone = "Richm", Label = "Richman", Busy = false },
        [11] = { Zone = "Rockf", Label = "Rockford Hills", Busy = false },
        [12] = { Zone = "SKID", Label = "Mission Row", Busy = false },
        [13] = { Zone = "Hawick", Label = "Hawick", Busy = false },
        [14] = { Zone = "Koreat", Label = "Little Seoul", Busy = false },
        [15] = { Zone = "LMesa", Label = "La Mesa", Busy = false },
        [16] = { Zone = "Mirr", Label = "Mirror Park", Busy = false },
        [17] = { Zone = "Morn", Label = "Morningwood", Busy = false },
        [18] = { Zone = "WVine", Label = "West Vinewood", Busy = false },
        [19] = { Zone = "Alta", Label = "Alta", Busy = false },
        [20] = { Zone = "Banning", Label = "Banning", Busy = false },
        [21] = { Zone = "Burton", Label = "Burton", Busy = false },
        [22] = { Zone = "ChamH", Label = "Chamberlain Hills", Busy = false },
        [23] = { Zone = "Cypre", Label = "Cypress Flats", Busy = false },
        [24] = { Zone = "Davis", Label = "Davis", Busy = false },
        [25] = { Zone = "STRAW", Label = "Strawberry", Busy = false },
        [26] = { Zone = "TEXTI", Label = "Textile City", Busy = false },
        [27] = { Zone = "VCana", Label = "Vespucci Canals", Busy = false },
    }
}

-- Impound Worker
Config.Impound = {
    Coords = {
        vector4(-2480.87, -211.96, 17.39, 59.62),
        vector4(487.24, -30.82, 88.85, 59.62),
        vector4(-2723.39, 13.20, 15.12, 59.62),
        vector4(-3139.75, 1078.71, 20.18, 59.62),
        vector4(-1656.93, -246.16, 54.51, 59.62),
        vector4(-1586.65, -647.56, 29.44, 59.62),
        vector4(-1036.14, -491.05, 36.21, 59.62),
        vector4(-1029.18, -475.53, 36.41, 59.62),
        vector4(209.16, 375.62, 107.02, 59.62),
        vector4(-534.60, -756.71, 31.59, 59.62),
        vector4(-4.5, -670.27, 31.85, 59.62),
        vector4(-772.20, -1281.81, 4.56, 59.62),
        vector4(-111.89, 91.96, 71.08, 59.62),
        vector4(-314.26, -698.23, 32.54, 59.62),
        vector4(322.36, 322.36, 25.77, 59.62),
        vector4(-858.91, -260.47, 39.56, 59.62),
        vector4(-775.55, 372.80, 87.87, 59.62),
        vector4(-416.16, 292.86, 83.22, 59.62),
        vector4(909.27, -56.61, 78.76, 59.62),
        vector4(1269.01, -366.17, 69.04, 59.62),
        vector4(1164.29, -1648.24, 36.91, 59.62),
        vector4(-1061.69, -2022.52, 13.16, 59.62),
    },
    Vehicles = {
        'sultanrs', 'oracle', 'zion',
        'chino', 'baller2', 'stanier',
        'washington', 'buffalo', 'feltzer2',
        'asea', 'fq2', 'sultan', 'panto',
    }
}

Config.ImpoundRequests = {}

-- Post Op
Config.DeliveryStores = {
    vector3(-43.71, -1750.0, 29.42),
    vector3(26.56, -1340.15, 29.5),
    vector3(1129.45, -982.13, 46.42),
    vector3(-708.63, -905.25, 19.22),
    vector3(-1219.48, -913.86, 11.57),
    vector3(-1482.17, -375.58, 40.16),
    vector3(1160.31, -314.69, 69.21),
    vector3(376.57, 332.66, 103.57),
    vector3(2549.89, 383.12, 108.62),
    vector3(-1827.69, 798.86, 138.17),
    vector3(-2962.01, 389.59, 15.04),
    vector3(-3046.62, 587.15, 7.91),
    vector3(-3249.38, 1003.72, 12.83),
    vector3(546.85, 2663.67, 42.16),
    vector3(1166.78, 2715.75, 38.16),
    vector3(1958.87, 3748.47, 32.34),
    vector3(1706.4, 4920.97, 42.06),
    vector3(1733.36, 6420.53, 35.04)
}

-- Oxy
Config.OxyDelivery = {
    Cops = 0, -- 2,
    Vehicles = { 'blista2', 'dilettante', 'issi3', 'rhapsody', 'oracle', 'oracle2', 'intruder', 'kanjo', 'sentinel', 'windsor2', 'windsor', 'bison', 'chino', 'dominator', 'asbo', 'baller', 'bjxl', 'habanero', 'comet2' },
    Peds = { 'a_f_m_fatwhite_01', 'a_f_m_prolhost_01', 'a_f_m_ktown_01', 'a_f_m_skidrow_01', 'a_f_m_tourist_01', 'a_f_y_hipster_02', 'a_m_m_bevhills_01', 'a_m_m_bevhills_02', 'a_m_m_og_boss_01', 'a_m_m_salton_03', 'a_m_m_prolhost_01', 'a_m_m_stlat_02', 'a_m_y_vinewood_03', 'a_m_m_mlcrisis_01', 'cs_manuel', 'cs_hunter', 'g_m_importexport_01', 'g_m_m_armlieut_01', 'g_m_m_chicold_01', 'g_m_m_chigoon_01', 'g_m_m_korboss_01', 'g_m_m_mexboss_01', 'g_m_y_ballaeast_01', 'g_m_y_famfor_01', 'ig_djsolfotios' },
}

Config.Oxy = {
    {
        Id = 1,
        Available = true,
        Coords = vector4(202.41, -158.24, 56.82, 67.40),
        Spawner = vector4(244.68, -163.12, 59.76, 151.16),
    },
    {
        Id = 2,
        Available = true,
        Coords = vector4(41.69, -97.78, 56.44, 67.40),
        Spawner = vector4(91.49, -129.66, 55.69, 338.64),
    },
    {
        Id = 3,
        Available = true,
        Coords = vector4(-33.06, -70.34, 59.21, 253.06),
        Spawner = vector4(-68.27, -44.92, 62.69, 168.58),
    },
    {
        Id = 4,
        Available = true,
        Coords = vector4(-1783.93, -380.62, 44.86, 140.09),
        Spawner = vector4(-1784.81, -346.14, 44.82, 230.25),
    },
    {
        Id = 5,
        Available = true,
        Coords = vector4(-1695.15, -445.09, 41.26, 229.55),
        Spawner = vector4(-1657.85, -461.18, 38.84, 141.25),
    },
    {
        Id = 6,
        Available = true,
        Coords = vector4(-1100.08, -1507.88, 4.6, 304.72),
        Spawner = vector4(-1117.44, -1532.65, 4.3, 37.59),
    },
    {
        Id = 7,
        Available = true,
        Coords = vector4(-14.56, -1799.19, 27.42, 321.10),
        Spawner = vector4(-15.19, -1834.92, 25.30, 57.18),
    },
    {
        Id = 8,
        Available = true,
        Coords = vector4(401.59, -2074.46, 20.66, 47.95),
        Spawner = vector4(443.93, -2092.28, 21.70, 138.59),
    },
    {
        Id = 9,
        Available = true,
        Coords = vector4(257.41, -1993.64, 20.08, 50.13),
        Spawner = vector4(290.62, -2004.06, 20.22, 138.37),
    },
    {
        Id = 10,
        Available = true,
        Coords = vector4(249.99, -1952.85, 23.01, 231.95),
        Spawner = vector4(221.26, -1947.91, 22.14, 322.84),
    },
    {
        Id = 11,
        Available = true,
        Coords = vector4(-56.59, -1502.28, 31.40, 233.22),
        Spawner = vector4(-76.95, -1473.36, 32.09, 139.68),
    },
    {
        Id = 12,
        Available = true,
        Coords = vector4(-112.56, -1603.33, 31.71, 140.01),
        Spawner = vector4(-99.51, -1561.80, 32.93, 226.01),
    },
    {
        Id = 13,
        Available = true,
        Coords = vector4(-212.88, -1635.14, 33.56, 90.72),
        Spawner = vector4(-180.63, -1645.40, 33.35, 353.14),
    },
    {
        Id = 14,
        Available = true,
        Coords = vector4(-174.50, -1364.08, 30.37, 25.79),
        Spawner = vector4(-147.07, -1375.52, 29.52, 118.33),
    },
    {
        Id = 15,
        Available = true,
        Coords = vector4(83.85, -828.21, 30.93, 30.93),
        Spawner = vector4(78.63, -796.12, 31.52, 246.14),
    },
    {
        Id = 16,
        Available = true,
        Coords = vector4(365.11, -812.00, 29.29, 359.39),
        Spawner = vector4(382.48, -843.67, 29.27, 91.51),
    },
    {
        Id = 17,
        Available = true,
        Coords = vector4(-66.7, 90.48, 73.34, 61.11),
        Spawner = vector4(-32.40, 92.17, 76.40, 152.67),
    },
    {
        Id = 18,
        Available = true,
        Coords = vector4(-422.10, -311.61, 34.19, 169.80),
        Spawner = vector4(-428.56, -282.36, 35.95, 231.60),
    },
}