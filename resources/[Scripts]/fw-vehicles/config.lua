Config = Config or {}

Config.EmsVehicles = { 'emsspeedo', 'emsexp', 'emstau', 'emsmotor' }
Config.PoliceVehicles = { 'polvic', 'polchal', 'polstang', 'polvette', 'poltaurus', 'polexp', 'polchar', 'polblazer', 'polmotor', 'policeb', 'ucbanshee', 'ucrancher', 'ucbuffalo', 'ucballer', 'pbus' }
Config.PursuitVehicles = { 'poltaurus', 'polchal', 'polstang', 'polvette', 'polchar' }
Config.PursuitMods = {
    B = { Engine = -1, Brakes = -1, Transmission = -1 },
    A = { Engine = 3, Brakes = 1, Transmission = 3 },
    S = { Engine = 5, Brakes = 3, Transmission = 4 },
}
Config.PursuitModes = {
    [GetHashKey('poltaurus')] = { 'B', 'A' },
    [GetHashKey('polchar')] = { 'B', 'A' },
    [GetHashKey('polmotor')] = { 'B', 'A', 'S' },
    [GetHashKey('policeb')] = { 'B', 'A', 'S' },
    [GetHashKey('polchal')] = { 'B', 'A', 'S' },
    [GetHashKey('polstang')] = { 'B', 'A', 'S' },
    [GetHashKey('polvette')] = { 'B', 'A', 'S' },
}

-- Vehicle Failure
Config.BodySafeGuard, Config.EngineSafeGuard = 50.0, 50.0

-- Vehicle Metadata
Config.DefaultMeta = {
    Body = 1000.0, Engine = 1000.0, Fuel = 100.0, -- Defaults
    Harness = 0.0,
    Nitrous = 0.0,
    Flagged = false, -- todo
    FakePlate = false, -- todo
    WheelFitment = {},
    Outfits = {},
    Waxed = false,
    Gifted = false,
}

-- Vehicle Keys
Config.VehicleKeys = {}

-- Vehicle Nitroous
Config.NosActive = {}

-- Vehicle Rental
Config.Rentals = {
    Cars = {
        -- { Label = "Boat Trailer", Model = "boattrailer", Price = 500 },
        { Label = "Bison", Model = "bison", Price = 500 },
        { Label = "Enus", Model = "cog55", Price = 1500 },
        { Label = "Futo", Model = "Futo", Price = 600 },
        { Label = "Buccaneer", Model = "buccaneer", Price = 625 },
        -- { Label = "Sultan", Model = "sultan", Price = 700 },
        -- { Label = "Buffalo S", Model = "buffalo2", Price = 725 },
        { Label = "Scooter", Model = "faggio", Price = 750 },
        { Label = "Sanchez", Model = "sanchez", Price = 10000 },
        { Label = "Coach", Model = "coach", Price = 800 },
        { Label = "Shuttle Bus", Model = "rentalbus", Price = 800 },
        { Label = "Tour Bus", Model = "tourbus", Price = 800 },
        { Label = "Taco Truck", Model = "nptaco", Price = 800 },
        { Label = "Limo", Model = "stretch", Price = 1500 },
        { Label = "Hearse", Model = "romero", Price = 1500 },
        { Label = "Clown Car", Model = "speedo2", Price = 5000 },
        { Label = "Festival Bus", Model = "pbus2", Price = 10000 },
    },
    Boats = {
        { Label = "Jet Ski", Model = "seashark", Price = 250 },
        { Label = "Suntrap", Model = "suntrap", Price = 500 },
        { Label = "Squalo", Model = "squalo", Price = 500 },
        { Label = "Speeder", Model = "speeder", Price = 750 },
        { Label = "Dinghy", Model = "dinghy", Price = 1000 },
        { Label = "Marquis", Model = "marquis", Price = 1250 },
        { Label = "Onderzeeër", Model = "submersible", Price = 2000 },
    },
}

Config.RentalSpawn = {
    Cars = vector4(117.84, -1079.95, 29.23, 355.92),
    Boats = vector4(-845.19, -1361.23, 0.09, 109.32),
}

-- Vehicle Garages
Config.Garages = {
    ['apartment_1'] = {
        Name = "No3 Apartments Garage",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(-320.51, -982.35, 31.08), 6.6, 51.8, 340, 30.08, 34.08 },
        Spots = {
            vector4(-297.85, -990.41, 30.48, 159.99),
            vector4(-301.24, -989.18, 30.48, 159.99),
            vector4(-304.62, -987.94, 30.48, 159.99),
            vector4(-308.0, -986.71, 30.48, 159.99),
            vector4(-311.48, -985.44, 30.48, 159.99),
            vector4(-315.05, -984.14, 30.48, 159.99),
            vector4(-318.4, -982.84, 30.48, 158.89),
            vector4(-321.86, -981.51, 30.48, 159.36),
            vector4(-325.42, -980.2, 30.48, 159.84),
            vector4(-328.9, -978.92, 30.48, 159.84),
            vector4(-332.37, -977.64, 30.48, 159.84),
            vector4(-335.65, -976.43, 30.48, 159.84),
            vector4(-339.22, -975.13, 30.48, 159.92),
            vector4(-342.76, -973.74, 30.48, 158.66),
        },
    },
    ['legionsquare_1'] = {
        Name = "Legion Square Garage",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(219.81, -801.88, 30.74), 10.95, 10, 338, 29.74, 33.74 },
        Spots = {
            vector4(220.49, -806.56, 30.69, 240.71),
            vector4(221.60, -804.05, 30.69, 240.71),
            vector4(222.80, -801.57, 30.69, 240.71),
            vector4(223.58, -798.93, 30.69, 240.71),
            vector4(215.76, -804.36, 30.69, 68.45),
            vector4(216.48, -801.75, 30.69, 68.45),
            vector4(217.00, -799.08, 30.69, 68.45),
            vector4(218.49, -796.84, 30.69, 68.45),            
        },
    },
    ['paletobay_1'] = {
        Name = "Paleto Bay Garage",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(66.65, 6402.56, 30.61), 18.2, 18.0, 45, 29.61, 33.61 },
        Spots = {
            vector4(62.28, 6403.58, 31.22, 32.89),
            vector4(59.37, 6400.46, 31.22, 32.89),
            vector4(65.02, 6405.86, 31.22, 32.89),
            vector4(72.11, 6403.87, 31.22, 310.32),
            vector4(75.05, 6401.27, 31.22, 310.32),
            vector4(-453.29, 6050.36, 31.34, 317.85),
            vector4(-449.46, 6052.93, 31.34, 296.52),
            vector4(-445.27, 6054.98, 31.34, 299.87),
            vector4(-432.19, 6028.0, 31.34, 20.31),
            vector4(-434.64, 6025.52, 31.34, 128.67),
        },
    },
    ['paletobay_2'] = {
        Name = "Paleto Bay PD",
        Zone = { vector3(-449.5, 6053.54, 31.34), 10.0, 13.0, 35.0, 29.61, 34.0 },
        Spots = {
            vector4(-453.29, 6050.36, 31.34, 214.85),
            vector4(-449.46, 6052.93, 31.34, 212.09),
            vector4(-445.27, 6054.98, 31.34, 208.37),
        },
    },
    ['sandy_2'] = {
        Name = "Sandy PD garage",
        Zone = { vector3(1863.9, 3696.09, 33.97), 13.0, 10.0, 30, 29.61, 34.0 },
        Spots = {
            vector4(1862.19, 3699.65, 33.97, 118.82),
            vector4(1863.19, 3695.76, 33.97, 115.94),
            vector4(1865.58, 3692.85, 33.97, 121.81)
        },
    },
    ['mrpd_1'] = {
        Name = "MRPD Garage",
        Zone = { vector3(442.48, -1026.13, 28.47), 17.8, 6.0, 276, 27.47, 32.27 },
        Spots = {
            vector4(449.55, -1025.67, 28.24, 4.01),
            vector4(446.0, -1025.5, 28.44, 5.66),
            vector4(442.32, -1025.89, 28.51, 7.06),
            vector4(439.01, -1026.28, 28.57, 6.24),
            vector4(435.63, -1027.01, 28.65, 5.96),
        },
    },
    ['tunershop_1'] = {
        Name = "6STR. Tuner Shop Garage",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(163.92, -2999.51, 5.31), 23.0, 9.4, 0, 4.31, 8.31 },
        Spots = {
            vector4(162.79, -3009.26, 5.9, 269.83),
            vector4(163.37, -3006.26, 5.9, 270.32),
            vector4(162.99, -3003.03, 5.9, 271.79),
            vector4(163.23, -2996.33, 5.9, 272.05),
            vector4(162.88, -2993.01, 5.9, 271.45),
            vector4(163.04, -2989.69, 5.9, 268.68),
        },
    },
    ['hayes_1'] = {
        Name = "Hayes Garage",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(-1376.83, -449.41, 33.86), 6.0, 14.0, 35, 32.86, 36.86 },
        Spots = {
            vector4(-1372.28, -446.28, 34.14, 215.03),
            vector4(-1374.64, -447.94, 34.14, 216.91),
            vector4(-1376.7, -449.84, 34.14, 216.41),
            vector4(-1378.74, -451.24, 34.14, 218.4),
            vector4(-1381.24, -452.76, 34.14, 215.53),
        },
    },
    ['townhall_1'] = {
        Name = "Townhall Garage",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(-487.36, -198.02, 37.01), 4.4, 48.6, 300, 35.01, 40.01 },
        Spots = {
            vector4(-497.73, -180.1, 37.04, 209.51),
            vector4(-494.96, -185.04, 36.9, 209.43),
            vector4(-492.23, -189.91, 36.75, 209.35),
            vector4(-489.14, -195.44, 36.58, 209.27),
            vector4(-486.07, -200.96, 36.42, 209.17),
            vector4(-483.19, -206.16, 36.27, 209.09),
            vector4(-479.88, -211.35, 36.11, 210.09),
            vector4(-477.18, -216.04, 35.97, 209.97),
        },
    },
    ['crusade_hospital_1'] = {
        Name = "Crusade Hospital Garage",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(307.19, -1378.41, 31.85), 31.2, 6.0, 320, 29.45, 34.45 },
        Spots = {
            vector4(299.48, -1388.08, 30.82, 320.39),
            vector4(303.0, -1383.13, 31.13, 321.76),
            vector4(307.17, -1378.36, 31.3, 318.69),
            vector4(311.07, -1373.94, 31.33, 318.54),
            vector4(314.93, -1369.59, 31.31, 318.31)
        },
    },  
    -- ['maldinis_1'] = {
    --     Name = "Maldinis Pizza Garage",
    --     Blip = { Sprite = 357, Color = 3, Text = "Garage" },
    --     Zone = { vector3(805.49, -727.63, 27.01), 17.0, 7.6, 40, 26.01, 30.01 },
    --     Spots = {
    --         vector4(800.35, -722.85, 27.37, 135.99),
    --         vector4(803.23, -724.64, 27.15, 132.82),
    --         vector4(805.4, -727.51, 27.0, 135.65),
    --         vector4(807.61, -730.11, 26.97, 132.15),
    --         vector4(809.67, -733.17, 26.97, 134.34),
    --     },
    -- },
    ['burgershot_1'] = {
        Name = "Burger Shot Garage",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(-1169.33, -882.24, 14.1), 24.2, 7.2, 30, 13.1, 17.1  },
        Spots = {
            vector4(-1174.41, -873.42, 13.5, 123.13),
            vector4(-1172.69, -876.42, 13.51, 120.92),
            vector4(-1170.93, -879.74, 13.5, 122.49),
            vector4(-1168.72, -883.26, 13.5, 122.73),
            vector4(-1165.81, -887.8, 13.51, 122.02),
            vector4(-1163.86, -891.36, 13.5, 121.86),
        }
    },
    ['uwucafe_1'] = {
        Name = "UwU Cafe Garage",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(-577.42, -1117.53, 22.38), 37.6, 14.4, 0, 21.38, 25.78  },
        Spots = {
            vector4(-573.56, -1100.79, 21.55, 269.43),
            vector4(-573.6, -1104.29, 21.55, 269.43),
            vector4(-573.72, -1108.29, 21.56, 267.62),
            vector4(-572.93, -1111.72, 21.55, 266.79),
            vector4(-573.07, -1115.52, 21.55, 268.91),
            vector4(-573.06, -1119.04, 21.55, 267.81),
            vector4(-572.69, -1122.97, 21.55, 268.99),
            vector4(-572.75, -1126.47, 21.56, 268.99),
            vector4(-572.82, -1130.37, 21.56, 268.99),
            vector4(-572.88, -1133.97, 21.56, 268.99),
            vector4(-582.28, -1133.75, 21.55, 89.62),
            vector4(-582.26, -1130.35, 21.56, 89.62),
            vector4(-582.24, -1127.05, 21.56, 89.62),
            vector4(-582.33, -1123.03, 21.56, 90.25),
            vector4(-582.35, -1119.23, 21.56, 90.25),
            vector4(-582.36, -1116.04, 21.56, 90.25),
            vector4(-582.54, -1112.04, 21.55, 90.25),
            vector4(-582.68, -1108.04, 21.56, 89.78),
            vector4(-582.67, -1104.54, 21.56, 89.78),
            vector4(-582.65, -1101.04, 21.56, 89.78),
        }
    },
    ['airport_1'] = {
        Name = "Airport Garage 1",
        Blip = { Sprite = 307, Color = 3, Text = "Vliegtuig Garage" },
        Zone = { vector3(-1664.01, -3131.58, 13.99), 20.0, 20.0, 330, 12.9, 18.9 },
        Spots = {
            vector4(-1664.01, -3131.58, 13.99, 330.19)
        },
    },
    ['littleseoul_news'] = {
        Name = "Weazel News Garage",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(-615.7, -922.53, 23.02), 5.2, 26.0, 271, 20.82, 25.82 },
        Spots = {
            vector4(-616.09, -933.34, 21.67, 111.44),
            vector4(-616.22, -929.27, 21.98, 112.0),
            vector4(-615.89, -924.62, 22.42, 111.54),
            vector4(-616.05, -920.2, 22.81, 104.99),
            vector4(-615.95, -916.05, 23.12, 109.37),
            vector4(-615.91, -911.72, 23.41, 109.36),
        }
    },
    -- ['casino_01'] = {
    --     Name = "Diamond Casino & Resort Garage",
    --     Blip = { Sprite = 357, Color = 3, Text = "Garage" },
    --     Zone = { vector3(914.09, 50.95, 80.9), 46.6, 3.4, 328, 78.3, 83.7 },
    --     Spots = {
    --         vector4(922.81, 65.42, 79.78, 148.41),
    --         vector4(919.14, 59.45, 80.27, 148.41),
    --         vector4(914.97, 52.67, 80.28, 148.4),
    --         vector4(911.15, 46.47, 80.27, 148.4),
    --         vector4(907.22, 40.08, 80.02, 148.32),
    --         vector4(903.67, 34.75, 79.53, 145.05),
    --     }
    -- },
    ['helipads_ls_01'] = {
        Name = "Plezierhaven Garage",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(-680.38, -1408.05, 5.0), 20, 6.4, 357, 4.0, 7.2 },
        Spots = {
            vector4(-680.56, -1399.99, 4.37, 86.77),
            vector4(-680.78, -1403.88, 4.38, 86.77),
            vector4(-681.08, -1408.19, 4.38, 84.4),
            vector4(-681.47, -1412.22, 4.38, 84.4),
            vector4(-681.01, -1416.46, 4.38, 87.57),
        }
    },
    ['impound_01'] = {
        Name = "Impound Garage",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(1021.65, -2311.52, 30.51), 19.4, 5.8, 85, 29.51, 33.51 },
        Spots = {
            vector4(1029.23, -2311.87, 29.92, 352.15),
            vector4(1025.69, -2311.71, 29.92, 355.04),
            vector4(1017.77, -2310.61, 29.92, 353.51),
            vector4(1014.21, -2310.92, 29.92, 355.44)
        }
    },
    ['little_seoul_01'] = {
        Name = "Little Seoul Garage 1",
        Zone = { vector3(-754.77, -1078.78, 11.79), 6.6, 13.0, 30, 10.79, 14.79 },
        Spots = {
            vector4(-750.64, -1076.56, 11.59, 31.44),
            vector4(-754.41, -1078.77, 11.59, 29.74),
            vector4(-758.63, -1080.68, 11.6, 27.64)
        }
    },
    ['little_seoul_02'] = {
        Name = "Little Seoul Garage 2",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(-761.42, -1064.96, 11.95), 6.4, 26.0, 28, 10.95, 14.95 },
        Spots = {
            vector4(-770.57, -1070.09, 11.65, 208.66),
            vector4(-767.34, -1068.14, 11.7, 210.04),
            vector4(-757.67, -1063.48, 11.76, 210.51),
            vector4(-754.77, -1061.43, 11.76, 209.92),
            vector4(-751.31, -1059.89, 11.76, 209.96)
        }
    },
    ['little_seoul_03'] = {
        Name = "Little Seoul Garage 3",
        Zone = { vector3(-728.25, -1062.42, 12.33), 6.6, 18.4, 32, 11.33, 15.33 },
        Spots = {
            vector4(-734.12, -1066.29, 12.16, 30.74),
            vector4(-730.9, -1063.62, 12.15, 32.92),
            vector4(-727.59, -1061.0, 12.16, 31.65),
            vector4(-723.18, -1058.84, 12.21, 32.82)
        }
    },
    ['digital_den_01'] = {
        Name = "Digital Den 1",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(1144.1, -476.7, 66.38), 6.2, 15.0, 76, 64.38, 68.98 },
        Spots = {
            vector4(1146.14, -471.4, 65.95, 256.58),
            vector4(1144.94, -474.81, 65.79, 253.07),
            vector4(1144.46, -478.6, 65.57, 256.79),
            vector4(1143.63, -482.05, 65.28, 254.09)
        }
    },
    ['dragons_den_01'] = {
        Name = "Dragons Den 1",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(-205.68, 300.98, 96.95), 24.0, 5, 270, 95.95, 99.95 },
        Spots = {
            vector4(-195.81, 301.8, 96.74, 0.63),
            vector4(-198.83, 302.15, 96.74, 1.88),
            vector4(-202.09, 302.0, 96.74, 0.84),
            vector4(-205.66, 302.08, 96.74, 2.18),
            vector4(-209.28, 301.81, 96.74, 1.8),
            vector4(-213.09, 301.0, 96.74, 1.17),
            vector4(-216.39, 301.08, 96.74, 0.77),
        }
    },
    ['vbmarket_01'] = {
        Name = "Vespucci Market 1",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(-1186.52, -1484.57, 4.38), 26.6, 13.0, 35, 3.38, 7.38 },
        Spots = {
            vector4(-1183.41, -1495.98, 3.77, 125.32),
            vector4(-1185.5, -1493.54, 3.77, 123.78),
            vector4(-1187.36, -1491.14, 3.77, 125.96),
            vector4(-1188.99, -1488.68, 3.77, 122.63),
            vector4(-1191.2, -1486.13, 3.77, 123.84),
            vector4(-1192.74, -1483.53, 3.78, 123.91),
            vector4(-1194.64, -1480.66, 3.77, 125.01),
            vector4(-1176.47, -1491.09, 3.77, 302.9),
            vector4(-1178.3, -1488.77, 3.77, 304.9),
            vector4(-1180.3, -1486.2, 3.77, 302.19),
            vector4(-1181.69, -1483.27, 3.78, 305.19),
            vector4(-1183.83, -1480.84, 3.77, 305.17),
            vector4(-1185.49, -1478.54, 3.78, 304.51),
            vector4(-1187.19, -1475.96, 3.77, 303.77),
            vector4(-1189.29, -1473.32, 3.78, 310.44)
        }
    },
    ['airport_2'] = {
        Name = "Airport Garage 2",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(-893.49, -2695.55, 13.61), 5.0, 30, 240, 12.61, 16.61 },
        Spots = {
            vector4(-900.27, -2705.9, 13.05, 329.13),
            vector4(-897.58, -2701.04, 13.05, 332.74),
            vector4(-894.55, -2695.12, 13.07, 327.55),
            vector4(-891.22, -2689.53, 13.07, 330.16),
            vector4(-888.34, -2684.71, 13.07, 329.01)
        }
    },
    ['prison_1'] = {
        Name = "Bolingbroke Penitentiary 1",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(1854.85, 2560.06, 45.67), 6.4, 41.65, 90, 44.67, 48.67 },
        Spots = {
            vector4(1855.19, 2578.95, 45.01, 270.94),
            vector4(1855.25, 2575.13, 45.07, 269.08),
            vector4(1855.13, 2571.45, 45.07, 269.15),
            vector4(1855.72, 2567.69, 45.07, 270.34),
            vector4(1854.58, 2564.18, 45.07, 265.67),
            vector4(1855.37, 2560.18, 45.07, 266.25),
            vector4(1855.37, 2556.62, 45.07, 268.49),
            vector4(1855.05, 2552.87, 45.07, 267.04),
            vector4(1855.7, 2549.33, 45.07, 267.92),
            vector4(1855.73, 2545.79, 45.07, 269.17),
            vector4(1855.19, 2541.98, 45.07, 269.21)
        }
    },
    ['pinkcage_1'] = {
        Name = "Pink Cage Motel 1",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(316.59, -204.62, 54.09), 7.0, 14.2, 70, 53.09, 56.69 },
        Spots = {
            vector4(318.58, -199.81, 53.48, 248.28),
            vector4(316.86, -202.86, 53.48, 246.63),
            vector4(315.33, -206.1, 53.48, 247.22),
            vector4(315.41, -209.64, 53.48, 246.32)
        }
    },
    ['bennys_1'] = {
        Name = "Bennys Motorworks 1",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(-239.81, -1338.71, 31.3), 6.0, 14.8, 0, 30.3, 34.3 },
        Spots = {
            vector4(-234.59, -1338.15, 30.67, 0.52),
            vector4(-237.87, -1338.5, 30.67, 0.77),
            vector4(-241.6, -1338.13, 30.67, 1.0),
            vector4(-244.74, -1338.55, 30.67, 1.19)
        }
    },
    ['del_perro_pier_1'] = {
        Name = "Del Perro Pier 1",
        Blip = { Sprite = 357, Color = 3, Text = "Garage" },
        Zone = { vector3(-1593.31, -1053.01, 13.02), 13.6, 6.8, 50, 12.02, 16.02 },
        Spots = {
            vector4(-1589.21, -1056.02, 12.41, 319.63),
            vector4(-1591.75, -1054.08, 12.41, 319.94),
            vector4(-1594.59, -1052.22, 12.41, 320.32),
            vector4(-1597.0, -1049.8, 12.41, 321.51)
        }
    },

    -- PD
    ['gov_mrpd'] = {
        Name = "PD MRPD Garage",
        Zone = { vector3(441.65, -991.52, 25.7), 13.6, 12.4, 0, 24.7, 28.7  },
        Spots = {
            vector4(445.94, -997.1, 25.46, 270.58),
            vector4(437.38, -996.9, 25.47, 270.96),
            vector4(445.4, -994.33, 25.46, 269.56),
            vector4(437.14, -994.28, 25.46, 269.49),
            vector4(445.64, -991.55, 25.46, 271.48),
            vector4(436.95, -991.64, 25.47, 271.33),
            vector4(445.65, -988.89, 25.46, 270.75),
            vector4(436.66, -988.94, 25.46, 269.56),
            vector4(445.85, -986.11, 25.46, 271.64),
            vector4(437.03, -985.96, 25.46, 266.3),
        },
    },
    ['gov_beaver'] = {
        Name = "PD Beaver Bush Garage",
        Zone = { vector3(374.34, 796.81, 187.28), 7.2, 4.4, 0, 186.28, 189.28 },
        Spots = {
            vector4(374.42, 796.6, 186.8, 182.77)
        },
    },
    ['gov_vespucci'] = {
        Name = "PD Vespucci Garage",
        Zone = { vector3(-1122.99, -830.36, 3.75), 17.0, 6.8, 306, 2.75, 5.95 },
        Spots = {
            vector4(-1117.68, -826.7, 3.03, 217.41),
            vector4(-1121.05, -829.03, 3.03, 214.65),
            vector4(-1124.51, -831.97, 3.03, 216.17),
            vector4(-1127.8, -834.07, 3.03, 218.78),
        },
    },
    ['gov_paleto'] = {
        Name = "PD Paleto Bay Garage",
        Zone = { vector3(-475.58, 6031.99, 31.34), 24.4, 6.2, 315, 30.34, 34.34 },
        Spots = {
            vector4(-482.65, 6024.66, 30.62, 223.01),
            vector4(-479.59, 6027.9, 30.61, 224.57),
            vector4(-475.69, 6031.65, 30.61, 224.56),
            vector4(-472.39, 6035.63, 30.61, 226.22),
            vector4(-468.8, 6038.78, 30.61, 228.28),
        },
    },
    ['gov_sdso'] = {
        Name = "PD Sandy Shores Garage",
        Zone = { vector3(1829.96, 3688.12, 33.97), 15.4, 5.0, 300, 32.97, 36.97 },
        Spots = {
            vector4(1834.99, 3691.12, 33.25, 30.85),
            vector4(1831.67, 3688.85, 33.25, 30.66),
            vector4(1828.54, 3686.9, 33.25, 28.15),
            vector4(1824.98, 3685.15, 33.25, 29.14),
        },
    },
    ['gov_lamesa'] = {
        Name = "PD La Mesa Garage",
        Zone = { vector3(843.9, -1342.19, 26.07), 6.6, 26.2, 270, 25.07, 28.47 },
        Spots = {
            vector4(844.78, -1335.04, 25.53, 241.87),
            vector4(844.15, -1340.34, 25.49, 249.94),
            vector4(844.15, -1340.34, 25.49, 249.94),
            vector4(844.09, -1352.24, 25.51, 243.61),
        },
    },
    ['gov_davis'] = {
        Name = "PD Davis Garage",
        Zone = { vector3(390.03, -1611.88, 28.67), 12.4, 6.8, 320, 27.67, 31.67 },
        Spots = {
            vector4(393.29, -1608.4, 28.67, 231.28),
            vector4(391.16, -1611.05, 28.67, 231.28),
            vector4(389.28, -1613.39, 28.67, 231.28),
            vector4(387.53, -1615.58, 28.67, 231.28),
        },
    },

    -- EMS
    ['gov_crusade'] = {
        Name = "EMS Crusade Hospital Garage",
        Zone = { vector3(310.72, -1429.67, 29.92), 7.8, 12.0, 320, 28.32, 32.12 },
        Spots = {
            vector4(313.56, -1432.27, 29.92, 140.2),
            vector4(310.58, -1429.74, 29.92, 140.11),
            vector4(307.46, -1427.1, 29.92, 141.5),
        },
    },
    ['gov_clinic_sandy'] = {
        Name = "EMS Sandy Shores Clinic Garage",
        Zone = { vector3(1658.39, 3670.1, 35.34), 7.8, 12.0, 300, 34.34, 38.14 },
        Spots = {
            vector4(1656.31, 3673.21, 35.34, 302.09),
            vector4(1658.05, 3669.75, 35.34, 300.78),
            vector4(1660.0, 3666.4, 35.34, 301.1),
        },
    },
    ['gov_clinic_paleto'] = {
        Name = "EMS Paleto Bay Clinic Garage",
        Zone = { vector3(-262.3, 6343.85, 32.43), 14.6, 5.0, 315, 31.43, 35.43 },
        Spots = {
            vector4(-259.08, 6347.63, 32.43, 268.33),
            vector4(-261.22, 6344.18, 32.43, 263.75),
            vector4(-264.88, 6340.93, 32.43, 277.26),
        },
    },
    
    -- DOC
    ['gov_prison'] = {
        Name = "DOC Bolingbroke Penitentiary Garage",
        Zone = { vector3(1854.6, 2661.15, 45.67), 18.8, 6.4, 0, 44.67, 48.67 },
        Spots = {
            vector4(1854.62, 2653.72, 45.07, 270.91),
            vector4(1854.56, 2657.35, 45.07, 270.91),
            vector4(1854.49, 2661.6, 45.07, 270.91),
            vector4(1854.44, 2664.85, 45.07, 270.91),
            vector4(1854.37, 2668.72, 45.07, 270.91)
        },
    },
}

Config.DepotSpots = {
    vector4(1014.08, -2310.49, 29.91, 357.78),
    vector4(1017.76, -2310.67, 29.91, 353.75),
    vector4(1025.65, -2311.95, 29.91, 356.02),
    vector4(1029.19, -2311.67, 29.91, 354.47)
}

Config.FuelPrice = 4
Config.FuelStations = {
    -- Paleto PD, Helicopter
    {
        center = vector3(-475.14, 5988.95, 31.34),
        length = 28.4,
        width = 20.6,
        heading = 45,
        minZ = 30.34,
        maxZ = 36.74,
        data = {
            vehicleClass = 15
        }
    },

    -- VBPD, Helicopter
    {
        center = vector3(-1095.41, -835.28, 37.68),
        length = 11.0,
        width = 10.8,
        heading = 39,
        minZ = 36.68,
        maxZ = 43.08,
        data = {
            vehicleClass = 15
        }
    },

    -- Marina, Helicopter
    {
        center = vector3(-724.52, -1444.08, 5.0),
        length = 15.0,
        width = 15.2,
        heading = 50,
        minZ = 4.0,
        maxZ = 10.4,
        data = {
            vehicleClass = 15
        }
    },

    -- MRPD, Helicopter
    {
        center = vector3(481.83, -982.1, 41.01),
        length = 11.0,
        width = 10.8,
        heading = 91,
        minZ = 40.01,
        maxZ = 46.41,
        data = {
            vehicleClass = 15
        }
    },

    -- Grapeseed, Airplane
    {
        center = vector3(2104.14, 4784.48, 41.06),
        length = 11.0,
        width = 10.8,
        heading = 116,
        minZ = 40.06,
        maxZ = 46.46,
        data = {
            vehicleClass = 16
        }
    },

    -- Sandy Shores, Airplane
    {
        center = vector3(1734.57, 3298.99, 41.11),
        length = 16.4,
        width = 42.4,
        heading = 104,
        minZ = 40.11,
        maxZ = 46.51,
        data = {
            vehicleClass = 16
        }
    },

    -- Sandy Shores, Helicopter
    {
        center = vector3(1770.36, 3239.85, 41.36),
        length = 14.0,
        width = 14.8,
        heading = 15,
        minZ = 40.79,
        maxZ = 45.79,
        data = {
            vehicleClass = 15
        }
    },

    -- LSIA, Airplane
    {
        center = vector3(-1272.96, -3383.31, 13.94),
        length = 38.8,
        width = 46.8,
        heading = 60,
        minZ = 12.94,
        maxZ = 21.54,
        data = {
            vehicleClass = 16
        }
    },

    -- Drift School, Cars
    {
        blip = true,
        center = vector3(-66.37, -2532.39, 6.01),
        length = 20.2,
        width = 18.8,
        heading = 54,
        minZ = 4.86,
        maxZ = 10.86
    },

    -- Innocence Blvd / La Puerta, Cars
    {
        blip = true,
        center = vector3(-319.98, -1471.75, 30.72),
        length = 19.4,
        width = 28.6,
        heading = 30,
        minZ = 29.57,
        maxZ = 35.57
    },

    -- Panorama Drive, Sandy, Cars
    {
        blip = true,
        center = vector3(1785.61, 3330.48, 41.24),
        length = 7.6,
        width = 6.05,
        heading = 29,
        minZ = 40.09,
        maxZ = 46.09
    },

    -- Palamino Freway, Cars
    {
        blip = true,
        center = vector3(2580.96, 361.65, 108.46),
        length = 24.2,
        width = 15.45,
        heading = 88,
        minZ = 107.46,
        maxZ = 111.26
    },

    -- Clinton Avenue, Cars
    {
        blip = true,
        center = vector3(621.11, 269.04, 103.03),
        length = 28.0,
        width = 19.25,
        heading = 90,
        minZ = 102.03,
        maxZ = 105.83
    },

    -- Mirror Park Blvd, Cars
    {
        blip = true,
        center = vector3(1181.16, -330.36, 69.18),
        length = 25.8,
        width = 16.05,
        heading = 10,
        minZ = 68.18,
        maxZ = 71.98
    },

    -- El Rancho Blvd, Cars
    {
        blip = true,
        center = vector3(1208.43, -1402.33, 35.23),
        length = 18.55,
        width = 8.65,
        heading = 45,
        minZ = 34.23,
        maxZ = 38.03
    },

    -- Vespucci Blvd, Cars
    {
        blip = true,
        center = vector3(818.88, -1029.24, 26.12),
        length = 29.15,
        width = 17.05,
        heading = 271,
        minZ = 25.12,
        maxZ = 28.92
    },

    -- Strawberry, Cars
    {
        blip = true,
        center = vector3(264.06, -1261.88, 29.17),
        length = 30.55,
        width = 23.65,
        heading = 269,
        minZ = 28.17,
        maxZ = 31.97
    },

    -- Grove Street, Cars
    {
        blip = true,
        center = vector3(-70.69, -1761.35, 29.39),
        length = 28.55,
        width = 15.65,
        heading = 249,
        minZ = 28.39,
        maxZ = 32.19
    },

    -- Calais Ave / Dutch London, Cars
    {
        blip = true,
        center = vector3(-525.44, -1211.17, 18.18),
        length = 20.55,
        width = 17.65,
        heading = 247,
        minZ = 17.18,
        maxZ = 20.98
    },

    -- Lindsay Circus, Cars
    {
        blip = true,
        center = vector3(-723.7, -935.56, 19.01),
        length = 25.95,
        width = 14.45,
        heading = 270,
        minZ = 18.01,
        maxZ = 21.81
    },

    -- West Eclipse Blvd, Cars
    {
        blip = true,
        center = vector3(-2096.84, -318.99, 13.02),
        length = 26.15,
        width = 20.85,
        heading = 264,
        minZ = 12.02,
        maxZ = 15.82
    },

    -- Perth Street, Cars
    {
        blip = true,
        center = vector3(-1436.6, -275.84, 46.56),
        length = 19.75,
        width = 19.05,
        heading = 221,
        minZ = 45.16,
        maxZ = 48.96
    },

    -- North Rockford Drive, Cars
    {
        blip = true,
        center = vector3(-1799.94, 803.18, 138.7),
        length = 16.15,
        width = 26.25,
        heading = 224,
        minZ = 137.3,
        maxZ = 141.1
    },

    -- Route 68, Cars
    {
        blip = true,
        center = vector3(-2555.18, 2332.81, 33.06),
        length = 16.15,
        width = 27.05,
        heading = 274,
        minZ = 31.66,
        maxZ = 35.46
    },

    -- Cascabel Avenue, Cars
    {
        blip = true,
        center = vector3(-93.79, 6420.09, 31.42),
        length = 10.2,
        width = 14.0,
        heading = 45,
        minZ = 30.37,
        maxZ = 34.37
    },

    -- Paleto Gas Station, Cars
    {
        blip = true,
        center = vector3(179.51, 6602.49, 31.85),
        length = 15.4,
        width = 27.8,
        heading = 10,
        minZ = 30.8,
        maxZ = 34.8
    },

    -- Great Ocean  Highway / Paleto, Cars
    {
        blip = true,
        center = vector3(1701.99, 6416.48, 32.61),
        length = 14.0,
        width = 10.6,
        heading = 65,
        minZ = 31.61,
        maxZ = 35.61
    },

    -- Grapeseed, Cars
    {
        blip = true,
        center = vector3(1687.92, 4929.84, 42.08),
        length = 14.6,
        width = 10.2,
        heading = 55,
        minZ = 41.08,
        maxZ = 45.08
    },

    -- Marina Drive, Cars
    {
        blip = true,
        center = vector3(2005.41, 3774.53, 32.18),
        length = 14.6,
        width = 10.2,
        heading = 299,
        minZ = 31.18,
        maxZ = 35.18
    },

    -- Senora Fwy, Cars
    {
        blip = true,
        center = vector3(2680.2, 3264.51, 55.24),
        length = 14.6,
        width = 10.2,
        heading = 151,
        minZ = 54.24,
        maxZ = 58.24
    },

    -- Senora Way, Cars
    {
        blip = true,
        center = vector3(2536.92, 2593.69, 37.95),
        length = 4.0,
        width = 4.8,
        heading = 113,
        minZ = 36.95,
        maxZ = 40.95
    },

    -- Route 68, Harmony, Cars
    {
        blip = true,
        center = vector3(1208.14, 2660.14, 37.81),
        length = 10.6,
        width = 9.4,
        heading = 135,
        minZ = 36.81,
        maxZ = 40.81
    },

    -- Route 68, Motel, Cars
    {
        blip = true,
        center = vector3(1038.76, 2671.25, 39.55),
        length = 17.6,
        width = 13.6,
        heading = 90,
        minZ = 38.55,
        maxZ = 42.55
    },

    -- Route 68, Joshua Road, Cars
    {
        blip = true,
        center = vector3(264.23, 2607.21, 44.98),
        length = 7.0,
        width = 9.2,
        heading = 100,
        minZ = 43.98,
        maxZ = 47.98
    },

    -- Route 68, Approach, Cars
    {
        blip = true,
        center = vector3(50.05, 2778.29, 57.88),
        length = 9.8,
        width = 10.8,
        heading = 52,
        minZ = 56.88,
        maxZ = 60.88
    },

    -- Flight school, Helicopter
    {
        center = vector3(-1877.15, 2805.01, 32.81),
        length = 13.4,
        width = 12.6,
        heading = 330,
        minZ = 31.81,
        maxZ = 35.81,
        data = {
            vehicleClass = 15
        }
    },

    -- Flight school, Airplane
    {
        center = vector3(-1818.56, 2966.05, 32.81),
        length = 14.6,
        width = 15.6,
        heading = 330,
        minZ = 31.61,
        maxZ = 35.61,
        data = {
            vehicleClass = 16
        }
    },

    -- -- Sandy PD, Helicopters
    -- {
    --     center = vector3(1853.24, 3706.56, 33.98),
    --     length = 10.0,
    --     width = 10.0,
    --     heading = 31.0,
    --     minZ = 32.0,
    --     maxZ = 38.0,
    --     data = {
    --         vehicleClass = 15
    --     }
    -- },

    -- Crusade Hospital, Helicopters
    {
        center = vector3(299.77, -1453.53, 46.51),
        length = 11.0,
        width = 11.4,
        heading = 320,
        minZ = 45.51,
        maxZ = 49.51,
        data = {
            vehicleClass = 15
        }
    },

    -- Popular St, Otto's Autos, Cars
    -- {
    --     blip = true,
    --     center = vector3(809.76, -789.85, 26.2),
    --     length = 8.8,
    --     width = 14.2,
    --     heading = 0,
    --     minZ = 25.2,
    --     maxZ = 30.3
    -- },
}

Config.ImpoundList = {
    {
        Title = 'Voertuig Scuff',
        Desc = 'Voertuig zit in een onherstelbare staat.',
        Hours = 0, Fee = 0, Strikes = 0,
        Gov = false,
    },
    {
        Title = 'Bewijs van een misdaad',
        Desc = 'Het voertuig is gebruikt bij of is een bewijs van een misdrijf.',
        Hours = 12, Fee = 0, Strikes = 0,
        Gov = true,
    },
    {
        Title = 'Joyride',
        Desc = 'Voertuig gestolen zonder toestemming van de eigenaar.',
        Hours = 1, Fee = 800, Strikes = 0,
        Gov = true,
    },
    {
        Title = 'Parkeerovertreding',
        Desc = 'Voertuig geparkeerd op een beperkte of niet-geautoriseerde plaats.',
        Hours = 0, Fee = 400, Strikes = 0,
        Gov = true,
    },
    {
        Title = 'Verlaten plaats ongeval',
        Desc = 'Het voertuig verliet de plaats van een ongeval met letsel of de dood tot gevolg.',
        Hours = 0, Fee = 950, Strikes = 0,
        Gov = true,
    },
    {
        Title = 'Ontsnapping',
        Desc = 'Het voertuig is gebruikt om van een ambtenaar te vluchten.',
        Hours = 24, Fee = 1250, Strikes = 1,
        Gov = true,
    },
    {
        Title = 'Roekeloos Rijgedrag',
        Desc = 'Onzorgvuldig gereden met grote minachting voor het menselijk leven.',
        Hours = 0, Fee = 490, Strikes = 0,
        Gov = true,
    },
    {
        Title = 'Straatracen',
        Desc = 'Voertuig werd gebruikt in een snelheids- of tijdwedstrijd op de openbare weg/snelweg.',
        Hours = 0, Fee = 900, Strikes = 2,
        Gov = true,
    },
    {
        Title = 'Rijden onder invloed',
        Desc = 'Rijden onder invloed van drugs en/of alcohol.',
        Hours = 0, Fee = 150, Strikes = 0,
        Gov = true,
    },
    {
        Title = 'Gewelddadig misdrijf',
        Desc = 'Gebruikt bij het plegen van een geweldsmisdrijf, zoals bij een drive-by shooting, of voor transport van en naar de plaats van een geweldsmisdrijf.',
        Hours = 36, Fee = 1750, Strikes = 2,
        Gov = true,
    },
    {
        Title = 'Onbruikbaar op plaatsdelict',
        Desc = 'Voertuig in onbruikbare staat ter plaatse aangetroffen.',
        Hours = 0, Fee = 400, Strikes = 0,
        Gov = true,
    },
    {
        Title = 'Overval / Ontvoering / Heling',
        Desc = 'Het voertuig werd gebruikt bij het plegen van een misdrijf dat verband hield met diefstal of ontvoering.',
        Hours = 36, Fee = 2250, Strikes = 2,
        Gov = true,
    },
    {
        Title = 'Misdrijf niet vermeld',
        Desc = 'Gebruikt bij een misdrijf waarvoor geen impound reden is, handmatige depot.',
        Hours = 0, Fee = 0, Strikes = 0,
        Gov = true,
    },
    -- {
    --     Title = 'Depot Medewerker',
    --     Desc = 'Stuur een melding naar een depotmedewerker.',
    --     Hours = 0, Fee = 0, Strikes = 0,
    --     Reason = '',
    --     Gov = true,
    -- },
}

-- Emergency Lights
--[[
    Airhorn
    AIRHORN_EQD - Generic Bullhorn               SirenSound - SIRENS_AIRHORN

    Police Bike
    SIREN_WAIL_03 - PoliceB Main                 SirenSound - RESIDENT_VEHICLES_SIREN_WAIL_03
    SIREN_QUICK_03 - PoliceB Secondary           SirenSound - RESIDENT_VEHICLES_SIREN_QUICK_03

    FIB
    SIREN_WAIL_02 - FIB Primary                  SirenSound - RESIDENT_VEHICLES_SIREN_WAIL_02
    SIREN_QUICK_02 - FIB Secondary               SirenSound - RESIDENT_VEHICLES_SIREN_QUICK_02

    Police
    SIREN_PA20A_WAIL - Police Primary            SirenSound - VEHICLES_HORNS_SIREN_1
    SIREN_2 - Police Secondary                   SirenSound - VEHICLES_HORNS_SIREN_2
    POLICE_WARNING     - Police Warning          SirenSound - VEHICLES_HORNS_POLICE_WARNING

    Ambulance
    SIREN_WAIL_01 - Ambulance Primary            SirenSound - RESIDENT_VEHICLES_SIREN_WAIL_01
    SIREN_QUICK_01 - Ambulance Secondary         SirenSound - RESIDENT_VEHICLES_SIREN_QUICK_01
    AMBULANCE_WARNING - Ambulance Warning        SirenSound - VEHICLES_HORNS_AMBULANCE_WARNING

    Fire Trucks
    FIRE_TRUCK_HORN - Fire Horn                  SirenSound - VEHICLES_HORNS_FIRETRUCK_WARNING
    SIREN_FIRETRUCK_WAIL_01 - Fire Primary       SirenSound - RESIDENT_VEHICLES_SIREN_FIRETRUCK_WAIL_01
    SIREN_FIRETRUCK_QUICK_01 - Fire Secondary    SirenSound - RESIDENT_VEHICLES_SIREN_FIRETRUCK_QUICK_01
]]

Config.SirenData = {
    [GetHashKey("polvic")] = {
        SirenSounds = { "VEHICLES_HORNS_SIREN_1", "VEHICLES_HORNS_SIREN_2", "VEHICLES_HORNS_POLICE_WARNING" },
    },
    [GetHashKey("polchal")] = {
        SirenSounds = { "VEHICLES_HORNS_SIREN_1", "VEHICLES_HORNS_SIREN_2", "VEHICLES_HORNS_POLICE_WARNING" },
    },
    [GetHashKey("polstang")] = {
        SirenSounds = { "VEHICLES_HORNS_SIREN_1", "VEHICLES_HORNS_SIREN_2", "VEHICLES_HORNS_POLICE_WARNING" },
    },
    [GetHashKey("polvette")] = {
        SirenSounds = { "VEHICLES_HORNS_SIREN_1", "VEHICLES_HORNS_SIREN_2", "VEHICLES_HORNS_POLICE_WARNING" },
    },
    [GetHashKey("poltaurus")] = {
        SirenSounds = { "VEHICLES_HORNS_SIREN_1", "VEHICLES_HORNS_SIREN_2", "VEHICLES_HORNS_POLICE_WARNING" },
    },
    [GetHashKey("polexp")] = {
        SirenSounds = { "VEHICLES_HORNS_SIREN_1", "VEHICLES_HORNS_SIREN_2", "VEHICLES_HORNS_POLICE_WARNING" },
    },
    [GetHashKey("polchar")] = {
        SirenSounds = { "VEHICLES_HORNS_SIREN_1", "VEHICLES_HORNS_SIREN_2", "VEHICLES_HORNS_POLICE_WARNING" },
    },
    [GetHashKey("polblazer")] = {
        SirenSounds = { "VEHICLES_HORNS_SIREN_1", "VEHICLES_HORNS_SIREN_2", "VEHICLES_HORNS_POLICE_WARNING" },
    },
    [GetHashKey("polmotor")] = {
        SirenSounds = { "RESIDENT_VEHICLES_SIREN_WAIL_03", "RESIDENT_VEHICLES_SIREN_QUICK_03" },
    },
    [GetHashKey("policeb")] = {
        SirenSounds = { "RESIDENT_VEHICLES_SIREN_WAIL_03", "RESIDENT_VEHICLES_SIREN_QUICK_03" },
    },
    [GetHashKey("ucbanshee")] = {
        SirenSounds = { "VEHICLES_HORNS_SIREN_1", "VEHICLES_HORNS_SIREN_2", "VEHICLES_HORNS_POLICE_WARNING" },
    },
    [GetHashKey("ucrancher")] = {
        SirenSounds = { "VEHICLES_HORNS_SIREN_1", "VEHICLES_HORNS_SIREN_2", "VEHICLES_HORNS_POLICE_WARNING" },
    },
    [GetHashKey("ucbuffalo")] = {
        SirenSounds = { "VEHICLES_HORNS_SIREN_1", "VEHICLES_HORNS_SIREN_2", "VEHICLES_HORNS_POLICE_WARNING" },
    },
    [GetHashKey("ucballer")] = {
        SirenSounds = { "VEHICLES_HORNS_SIREN_1", "VEHICLES_HORNS_SIREN_2", "VEHICLES_HORNS_POLICE_WARNING" },
    },
    [GetHashKey("emsspeedo")] = {
        SirenSounds = { "RESIDENT_VEHICLES_SIREN_WAIL_01", "RESIDENT_VEHICLES_SIREN_QUICK_01", "VEHICLES_HORNS_AMBULANCE_WARNING" },
    },
    [GetHashKey("emsexp")] = {
        SirenSounds = { "RESIDENT_VEHICLES_SIREN_WAIL_01", "RESIDENT_VEHICLES_SIREN_QUICK_01", "VEHICLES_HORNS_AMBULANCE_WARNING" },
    },
    [GetHashKey("emstau")] = {
        SirenSounds = { "RESIDENT_VEHICLES_SIREN_WAIL_01", "RESIDENT_VEHICLES_SIREN_QUICK_01", "VEHICLES_HORNS_AMBULANCE_WARNING" },
    },
    [GetHashKey("emsmotor")] = {
        SirenSounds = { "RESIDENT_VEHICLES_SIREN_WAIL_03", "RESIDENT_VEHICLES_SIREN_QUICK_03" },
    },
}

-- Misc
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