Config = Config or {}

Config.IllegalSells = vector4(847.92, 2864.03, 57.49, 120.1)
Config.IllegalSelling = {
    ['beer'] = math.random(11, 50),
    ['heirloom'] = math.random(45, 75),
    ['goldchain'] = math.random(85, 115),
    ['cult-necklace'] = math.random(115, 145),
    ['gold-record'] = math.random(125, 250),
    ['cannabiscup'] = math.random(125, 250),
    ['rolex'] = math.random(145, 230),
    ['goldbar'] = math.random(500, 850),
    ['white-pearl'] = math.random(16, 20),
}

-- coords, size, increase rate
-- increase rate is +1, everything under is a decrease.
Config.PanningLocations = {
    -- { vector3(-1603.16, 2101.63, 66.24), 75.0, 1.3 }, -- Waterfall
    { vector3(1189.67, -109.39, 56.86), 150.0, 1.1 }, -- The Dam / Casino
    { vector3(-1527.29, 1512.65, 111.1), 125.0, 1.2 }, -- Tongya Falley, Seashark Rental
    { vector3(1111.26, -648.5, 56.61), 25.0, 1.3 }, -- Mirror Park
    { vector3(2553.41, 6150.72, 162.39), 75.0, 1.6 }, -- Mount Gordo Lake
}

--
Config.VehicleDebtByClass = {
    ['S'] = 5000,
    ['A'] = 3750,
    ['B'] = 2250,
    ['C'] = 1250,
    ['D'] = 750,
    ['E'] = 500,
    ['M'] = 400,
    ['Others'] = 2750, -- emergency etc
}