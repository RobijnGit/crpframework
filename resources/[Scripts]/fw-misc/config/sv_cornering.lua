Config = Config or {}

-- If adding more zones, try to stay away from beaches, hills and 'overpopulated' areas.
-- More populated areas = less money per meth baggy
Config.CornerPrices = {
    ['meth'] = {
        VCANA = 78,
        KOREAT = 66,
        DELSOL = 59,
        LOSPUER = 52,
        STRAW = 88,
        CHAMH = 73,
        PALETO = 60,
    },
    ['weed'] = {
        VCANA = 61,
        KOREAT = 67,
        DELSOL = 73,
        LOSPUER = 77,
        STRAW = 93,
        CHAMH = 115,
        PALETO = 65,
    },
}

Config.CornerZones = {
    ['VCANA'] = true, -- Vespucci Canals
    ['KOREAT'] = true, -- Little Seoul
    ['DELSOL'] = true, -- La Puerta (La Puerta Docks)
    ['LOSPUER'] = true, -- La Puerta
    ['STRAW'] = true, -- Strawberry
    ['CHAMH'] = true, -- Chamberlain Hills

    -- 'DAVIS', -- Davis  
    -- 'DELBE', -- Del Perro Beach  
    -- 'DELPE', -- Del Perro  
    -- 'DESRT', -- Grand Senora Desert  
    -- 'DOWNT', -- Downtown  
    -- 'DTVINE', -- Downtown Vinewood  
    -- 'EAST_V', -- East Vinewood  
    -- 'EBURO', -- El Burro Heights  
    -- 'ELGORL', -- El Gordo Lighthouse  
    -- 'ELYSIAN', -- Elysian Island  
    -- 'GALFISH', -- Galilee  
    -- 'GOLF', -- GWC and Golfing Society  
    -- 'GRAPES', -- Grapeseed  
    -- 'GREATC', -- Great Chaparral  
    -- 'HARMO', -- Harmony  
    -- 'HAWICK', -- Hawick  
    -- 'HORS', -- Vinewood Racetrack  
    -- 'HUMLAB', -- Humane Labs and Research  
    -- 'JAIL', -- Bolingbroke Penitentiary  
    -- 'LACT', -- Land Act Reservoir  
    -- 'LAGO', -- Lago Zancudo  
    -- 'LDAM', -- Land Act Dam  
    -- 'LEGSQU', -- Legion Square  
    -- 'LMESA', -- La Mesa  
    -- 'MIRR', -- Mirror Park  
    -- 'MORN', -- Morningwood  
    -- 'MOVIE', -- Richards Majestic  
    -- 'MTCHIL', -- Mount Chiliad  
    -- 'MTGORDO', -- Mount Gordo  
    -- 'MTJOSE', -- Mount Josiah  
    -- 'MURRI', -- Murrieta Heights  
    -- 'NCHU', -- North Chumash  
    -- 'NOOSE', -- N.O.O.S.E  
    -- 'OCEANA', -- Pacific Ocean  
    -- 'PALCOV', -- Paleto Cove  
    -- 'PALETO', -- Paleto Bay  
    -- 'PALFOR', -- Paleto Forest  
    -- 'PALHIGH', -- Palomino Highlands  
    -- 'PALMPOW', -- Palmer-Taylor Power Station  
    -- 'PBLUFF', -- Pacific Bluffs  
    -- 'PBOX', -- Pillbox Hill  
    -- 'PROCOB', -- Procopio Beach  
    -- 'RANCHO', -- Rancho  
    -- 'RGLEN', -- Richman Glen  
    -- 'RICHM', -- Richman  
    -- 'ROCKF', -- Rockford Hills  
    -- 'RTRAK', -- Redwood Lights Track  
    -- 'SANAND', -- San Andreas  
    -- 'SANCHIA', -- San Chianski Mountain Range  
    -- 'SANDY', -- Sandy Shores  
    -- 'SKID', -- Mission Row  
    -- 'SLAB', -- Stab City  
    -- 'STAD', -- Maze Bank Arena  
    -- 'TATAMO', -- Tataviam Mountains  
    -- 'TERMINA', -- Terminal  
    -- 'TEXTI', -- Textile City  
    -- 'TONGVAH', -- Tongva Hills  
    -- 'TONGVAV', -- Tongva Valley  
    -- 'VESP', -- Vespucci  
    -- 'VINE', -- Vinewood  
    -- 'WINDF', -- Ron Alternates Wind Farm  
    -- 'WVINE', -- West Vinewood  
    -- 'ZANCUDO', -- Zancudo River  
    -- 'ZP_ORT', -- Port of South Los Santos  
    -- 'ZQ_UAR', -- Davis Quartz  
}