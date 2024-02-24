
Config = Config or {}

Config.Keys = {["F1"] = 288}
Config.HasHandCuffs = false

Config.Menu = {
    {
        Id = "park_vehicle",
        Title = "Parkeer Voertuig",
        Icon = "#global-park",
        Close = true,
        Event = "fw-vehicles:Client:ParkVehicle",
        Parameters = { Entity = false },
        Enabled = function()
            Config.Menu[1].Parameters = { Entity = false }

            if not exports['fw-vehicles']:IsNearParking() then return false end
            if exports['fw-medical']:GetDeathStatus() then return false end
            if GetVehiclePedIsIn(PlayerPedId()) ~= 0 then return false end

            local Hit, Pos, Entity = exports['fw-ui']:RayCastGamePlayCamera(5.0)
            if Entity ~= 0 and GetEntityType(Entity) == 2 then
                Config.Menu[1].Parameters = { Entity = Entity }
                return true
            end
        end,
    },
    {
        Id = "impound_request",
        Title = "Voertuig Depot",
        Icon = "#global-lock",
        Close = true,
        Event = "fw-vehicles:Client:RequestImpound",
        Parameters = { Entity = false },
        Enabled = function()
            Config.Menu[2].Parameters = { Entity = false }

            local PlayerJob = FW.Functions.GetPlayerData().job
            local MyJob = exports['fw-jobmanager']:GetMyJob()
            if PlayerJob.name ~= "police" and (not MyJob or MyJob.CurrentJob ~= "impound") then
                return false
            end

            if exports['fw-medical']:GetDeathStatus() then return false end
            if GetVehiclePedIsIn(PlayerPedId()) ~= 0 then return false end

            local Hit, Pos, Entity = exports['fw-ui']:RayCastGamePlayCamera(3.5)
            if Entity ~= 0 and GetEntityType(Entity) == 2 then
                Config.Menu[2].Parameters = { Entity = Entity }
                return true
            end

            return false
        end,
    },

    -- Add underneath here, above must be indexed.
    {
        Id = "arcade",
        Title = "Arcade",
        Icon = "#arcade",
        Enabled = function()
            return exports['fw-arcade']:IsGameActive()
        end,
        SubMenus = {'arcade:leave', 'arcade:end', 'arcade:tdm:changeLodout'}
    },
    {
        Id = "citizen",
        Title = "Burger",
        Icon = "#citizen-action",
        Enabled = function()
            if not exports['fw-medical']:GetDeathStatus() then
                return true
            end
        end,
        SubMenus = {'citizen:steal', 'citizen:contact'}
    },
    {
        Id = "animations",
        Title = "Loop Stijl",
        Icon = "#global-walking",
        Enabled = function()
            if not exports['fw-medical']:GetDeathStatus() then
                return true
            end
        end,
        SubMenus = { "animations:chichi", "animations:chubby", "animations:depressed1", "animations:depressed2", "animations:fat1", "animations:femme1", "animations:gangster1", "animations:defaultFemale1", "animations:defaultFemale2", "animations:heels1", "animations:heels2", "animations:hiking1", "animations:hurry7", "animations:hurry8", "animations:injured1", "animations:maneater", "animations:posh1", "animations:sad1", "animations:sad2", "animations:sassy", "animations:sexy", "animations:toolbelt1", "animations:toughGuy1", "animations:injured2", "animations:brave1", "animations:brave2", "animations:brave3", "animations:business1", "animations:business2", "animations:business3", "animations:buzzard", "animations:casual1", "animations:casual2", "animations:casual3", "animations:casual4", "animations:casual5", "animations:casual6", "animations:confident", "animations:depressed3", "animations:depressed4", "animations:tipsy", "animations:drunk1", "animations:drunk2", "animations:drunk3", "animations:fat2", "animations:femme2", "animations:fire", "animations:fire2", "animations:fire3", "animations:ganster2", "animations:ganster3", "animations:ganster4", "animations:ganster5", "animations:ganster6", "animations:ganster7", "animations:grooving", "animations:armored", "animations:cuffed", "animations:defaultMale", "animations:hiking2", "animations:hipster", "animations:hurry1", "animations:hurry2", "animations:hurry3", "animations:hurry4", "animations:hurry5", "animations:hurry6", "animations:injured3", "animations:leafBlower", "animations:money", "animations:muscle", "animations:posh2", "animations:quick", "animations:sad3", "animations:sad4", "animations:sad5", "animations:sassy2", "animations:shady", "animations:swagger", "animations:swagger2", "animations:toolbelt2", "animations:toughGuy2", "animations:franklin", "animations:trevor", "animations:micheal", "animations:micheal2", --[["animations:flee",]] "animations:hobo", "animations:janitor", "animations:jog", "animations:lemar", "animations:lester1", "animations:lester2", "animations:janitor2", "animations:fastrunner", "animations:jimmy", "animations:trash", "animations:trash2", "animations:bag"  }
    },
    {
        Id = "expressions",
        Title = "Gezicht Expressies",
        Icon = "#expressions",
        Enabled = function()
            if not exports['fw-medical']:GetDeathStatus() then
                return true
            end
        end,
        SubMenus = { "expressions:normal", "expressions:drunk", "expressions:angry", "expressions:dumb", "expressions:electrocuted", "expressions:grumpy", "expressions:happy", "expressions:injured", "expressions:joyful", "expressions:mouthbreather", "expressions:oneeye", "expressions:shocked", "expressions:sleeping", "expressions:smug", "expressions:speculative", "expressions:stressed", "expressions:sulking", "expressions:weird", "expressions:weird2"}
    },
    {
        Id = "police",
        Title = "Politie",
        Icon = "#police-action",
        Enabled = function()
            if not exports['fw-medical']:GetDeathStatus() and FW.Functions.GetPlayerData().job.name == 'police' and FW.Functions.GetPlayerData().job.onduty then
                return true
            end
        end,
        SubMenus = {"police:search", "police:tablet", "police:dispatch", "police:seizePossesions", "police:fingerprint", "police:checkBank", "police:removeFacewear", "police:gsr", "police:checkStatus"}
    },
    {
        Id = "storesecurity",
        Title = "Winkel Cooperatie",
        Icon = "#police-action",
        Enabled = function()
            if not exports['fw-medical']:GetDeathStatus() and FW.Functions.GetPlayerData().job.name == 'storesecurity' and FW.Functions.GetPlayerData().job.onduty then
                return true
            end
        end,
        SubMenus = {"police:search", "police:dispatch", "police:fingerprint"}
    },
    {
        Id = "doc",
        Title = "DOC",
        Icon = "#police-action",
        Enabled = function()
            if not exports['fw-medical']:GetDeathStatus() and FW.Functions.GetPlayerData().job.name == 'doc' and FW.Functions.GetPlayerData().job.onduty then
                return true
            end
        end,
        SubMenus = {"police:search", "police:dispatch", "police:seizePossesions", "prison:checkInmateInformation", "ambulance:heal", "ambulance:revive"}
    },
    {
        Id = "police-down",
        Title = "10-13A",
        Icon = "#police-down",
        Close = true,
        Parameters = 'Normal',
        Event = "fw-menu:client:send:down",
        Enabled = function()
            if not exports['fw-inventory']:HasEnoughOfItem("panicbutton", 1) then return end

            if exports['fw-medical']:GetDeathStatus() and (FW.Functions.GetPlayerData().job.name == 'police' or FW.Functions.GetPlayerData().job.name == 'doc' or FW.Functions.GetPlayerData().job.name == 'ems') and FW.Functions.GetPlayerData().job.onduty then
                return true
            end
        end,
    },
    {
        Id = "escort",
        Title = "Escorteren",
        Icon = "#citizen-action-escort",
        Close = true,
        Event = "fw-police:Client:Escort",
        Enabled = function()
            if IsPedInAnyVehicle(PlayerPedId()) then return end

            local Player, Distance = FW.Functions.GetClosestPlayer()
            if Player == -1 or Distance > 2.0 then
                return false
            end
        
            local IsHandcuffed, IsDead = exports['fw-police']:IsPlayerHandcuffed(Player)
            return IsHandcuffed or IsDead
        end,
    },
    {
        Id = "police-down",
        Title = "10-13B",
        Icon = "#police-down",
        Close = true,
        Parameters = 'Urgent',
        Event = "fw-menu:client:send:down",
        Enabled = function()
            if not exports['fw-inventory']:HasEnoughOfItem("panicbutton", 1) then return end

            if exports['fw-medical']:GetDeathStatus() and (FW.Functions.GetPlayerData().job.name == 'police' or FW.Functions.GetPlayerData().job.name == 'doc' or FW.Functions.GetPlayerData().job.name == 'ems') and FW.Functions.GetPlayerData().job.onduty then
                return true
            end
        end,
    },
    {
        Id = "ems-actions",
        Title = "EMS Acties",
        Icon = "#ambulance-action",
        Enabled = function()
            if not exports['fw-medical']:GetDeathStatus() and FW.Functions.GetPlayerData().job.name == 'ems' and FW.Functions.GetPlayerData().job.onduty then
                return true
            end
        end,
        SubMenus = {"ambulance:heal", "ambulance:revive", "police:tablet", "ambulance:blood", "ambulance:dna", "police:dispatch"}
    },
    {
        Id = "vehicle",
        Title = "Voertuig",
        Icon = "#citizen-action-vehicle",
        Enabled = function()
            if not exports['fw-medical']:GetDeathStatus() then
                local Vehicle, Distance = FW.Functions.GetClosestVehicle()
                if Vehicle ~= 0 and Distance < 2.3 then
                    return true
                end
            end
        end,
        SubMenus = {"vehicle:flip", "vehicle:key"}
    },
    {
        Id = "vehicle-doors",
        Title = "Voertuig Opties",
        Icon = "#citizen-action-vehicle-options",
        Close = true,
        Event = "veh:options",
        Enabled = function()
            if not exports['fw-medical']:GetDeathStatus() then
                if IsPedSittingInAnyVehicle(PlayerPedId()) or IsPedInAnyBoat(PlayerPedId()) or IsPedInAnyHeli(PlayerPedId()) or IsPedOnAnyBike(PlayerPedId()) then
                    return true
                end
            end
        end,
    },
    {
        Id = "garage",
        Title = "Garage",
        Icon = "#citizen-action-garage",
        Close = true,
        Event = "fw-vehicles:Client:OpenGarage",
        Parameters = {},
        Enabled = function()
            if not exports['fw-medical']:GetDeathStatus() then
                if exports['fw-vehicles']:IsNearParking() then
                    return true
                end
            end
        end,
    },
    {
        Id = "garage",
        Title = "Voertuigen Acties",
        Icon = "#police-action-vehicle",
        Close = true,
        Event = "fw-vehicles:Client:GarageActions",
        Parameters = {},
        Enabled = function()
            if exports['fw-medical']:GetDeathStatus() then
                return false
            end

            if (FW.Functions.GetPlayerData().job.name ~= 'police' and FW.Functions.GetPlayerData().job.name ~= 'judge') or not FW.Functions.GetPlayerData().job.onduty then
                return false
            end

            return exports['fw-vehicles']:IsNearParking()
        end,
    },
    {
        Id = "judge-actions",
        Title = "Rechter",
        Icon = "#judge-actions",
        Enabled = function()
            if not exports['fw-medical']:GetDeathStatus() and FW.Functions.GetPlayerData().job.name == 'judge' then
                return true
            end
        end,
        SubMenus = {"police:tablet", "judge:job", "judge:createBusiness", "judge:giveLicense", "judge:subpoenaRecords", "judge:subpoenaFinancials", "judge:financialState", "judge:financialMonitor", "judge:createFinancial"}
    },
    {
        Id = "cuff",
        Title = "Boeien",
        Icon = "#citizen-action-cuff",
        Close = true,
        Event = "fw-police:Client:Cuff",
        Enabled = function()
            if not exports['fw-medical']:GetDeathStatus() and Config.HasHandCuffs then
                return true
            end
        end,
    },
    {
        Id = "hospital-menu",
        Title = "In Checken",
        Icon = "#citizen-clipboard",
        Close = true,
        Event = "fw-medical:Client:CheckIn",
        Parameters = true,
        Enabled = function()
            if exports['fw-medical']:NearCheckin() then
                return true
            end
        end,
    },
    {
        Id = "boat-menu",
        Title = "Boot",
        Icon = "#police-boat",
        Close = true,
        Event = "fw-police:Client:SpawnBoat",
        Enabled = function()
            if (FW.Functions.GetPlayerData().job.name ~= 'police' and FW.Functions.GetPlayerData().job.name ~= 'ems') or not FW.Functions.GetPlayerData().job.onduty then
                return false
            end

            if #(GetEntityCoords(PlayerPedId()) - vector3(-798.38, -1503.44, 1.13)) > 10.0 then
                return false
            end

            return true
        end,
    },
    {
        Id = "steal-shoes",
        Title = "Schoenen Stelen",
        Icon = "#citizen-steal-shoes",
        Close = true,
        Event = "fw-misc:Server:StealShoes",
        Enabled = function()
            if not exports['fw-medical']:GetDeathStatus() then
                local Player, Distance = FW.Functions.GetClosestPlayer()
                if Player ~= -1 and Distance < 3.0 then
                    local IsDead = false
                    local TargetPed = GetPlayerPed(GetPlayerFromServerId(Player))
                    local ServerId = Player
                    local FootProp = GetPedDrawableVariation(TargetPed, 6)

                    local IsCuffed, IsDead = exports['fw-police']:IsPlayerHandcuffed(ServerId)
                    if IsEntityPlayingAnim(TargetPed, "missminuteman_1ig_2", "handsup_base", 3) or IsEntityPlayingAnim(TargetPed, "mp_arresting", "idle", 3) or IsDead then
                        if GetEntityModel(TargetPed) == GetHashKey("mp_m_freemode_01") then
                            return FootProp ~= 34
                        elseif GetEntityModel(TargetPed) == GetHashKey("mp_f_freemode_01") then
                            return FootProp ~= 35
                        end
                    end
                end
            end
        end,
    },
    {
        Id = "griffier-actions",
        Title = "Wet en Recht",
        Icon = "#police-action",
        Enabled = function()
            if not exports['fw-medical']:GetDeathStatus() and FW.Functions.GetPlayerData().job.name == 'griffier' or FW.Functions.GetPlayerData().job.name == 'security' then
                return true
            end
        end,
        SubMenus = {"police:tablet", "police:search"}
    },
    {
        Id = "mayor-actions",
        Title = "Burgemeester",
        Icon = "#police-action",
        Enabled = function()
            if not exports['fw-medical']:GetDeathStatus() and FW.Functions.GetPlayerData().job.name == 'mayor' then
                return true
            end
        end,
        SubMenus = {"police:tablet", "judge:createBusiness", "judge:giveLicense", "judge:createFinancial"}
    },
    {
        Id = "lawyer-actions",
        Title = "Advocaat",
        Icon = "#police-action",
        Enabled = function()
            if not exports['fw-medical']:GetDeathStatus() and FW.Functions.GetPlayerData().job.name == 'lawyer' then
                return true
            end
        end,
        SubMenus = {"police:tablet"}
    },
    -- {
    --     Id = "vehicle-extra",
    --     Title = "Voertuig Extra's",
    --     Icon = "#citizen-action-vehicle-extra",
    --     Enabled = function()
    --         if not exports['fw-medical']:GetDeathStatus() then
    --             if IsPedSittingInAnyVehicle(PlayerPedId()) or IsPedInAnyBoat(PlayerPedId()) or IsPedInAnyHeli(PlayerPedId()) or IsPedOnAnyBike(PlayerPedId()) then
    --                 return true
    --             end
    --         end
    --     end,
    --     SubMenus = {"vehicle:extra", "vehicle:extra2", "vehicle:extra3", "vehicle:extra4", "vehicle:extra5", "vehicle:extra6", "vehicle:extra7", "vehicle:extra8", "vehicle:extra9", "vehicle:extra10", "vehicle:extra11", "vehicle:extra12"}
    -- },
    {
        Id = "toggle-clothes",
        Title = "Kleding Aan/Uit",
        Icon = "#global-shirt",
        Enabled = function()
            return true
        end,
        SubMenus = {"clothes:pants", "clothes:shirt", "clothes:shoes", "clothes:vest", "clothes:visor", "clothes:bag", "clothes:gloves", "clothes:neck"}
    },
    {
        Id = "police-closed-compartment",
        Title = "Gesloten Compartiment",
        Icon = "#police-rack",
        Close = true,
        Parameters = "",
        Event = "fw-police:Client:OpenClosedCompartment",
        Enabled = function()
            if GetVehiclePedIsIn(PlayerPedId()) ~= 0 and not exports['fw-medical']:GetDeathStatus() and FW.Functions.GetPlayerData().job.name == 'police' and FW.Functions.GetPlayerData().job.onduty and exports['fw-vehicles']:IsPoliceVehicle(GetVehiclePedIsIn(PlayerPedId())) then
                return true
            end
        end,
    },
    {
        Id = "lock_property",
        Title = "Ontgrendel/Vergrendel Huis",
        Icon = "#global-lock",
        Close = true,
        Parameters = "",
        Event = "fw-housing:Client:LockProperty",
        Enabled = function()
            if exports['fw-medical']:GetDeathStatus() then return false end
            if exports['fw-housing']:GetCurrentHouse() == nil then return false end
            if exports['fw-housing']:IsInside() then return false end

            if exports['fw-housing']:HasKeyToCurrent() or FW.Functions.GetPlayerData().job.name == 'police' then
                -- Only allow (non-keyholders) officers to LOCK the property, and not UNLOCK it.
                if not exports['fw-housing']:HasKeyToCurrent() and FW.Functions.GetPlayerData().job.name == 'police' then
                    local CurrentHouse = exports['fw-housing']:GetCurrentHouse()
                    if not CurrentHouse.Locked then
                        return true
                    end
                else
                    return true
                end
            end

            return false
        end,
    },
    {
        Id = "enter_property",
        Title = "Betreed Huis",
        Icon = "#global-appartment",
        Close = true,
        Parameters = false,
        Event = "fw-housing:Client:EnterProperty",
        Enabled = function()
            if exports['fw-medical']:GetDeathStatus() then return false end
            if exports['fw-housing']:GetCurrentHouse() == nil then return false end
            if exports['fw-housing']:IsInside() then return false end

            return not exports['fw-housing']:GetCurrentHouse().Locked
        end,
    },
    {
        Id = "jail_current_task",
        Title = "Huidige Taak",
        Icon = "#jail-current-task",
        Close = true,
        Event = "fw-prison:Client:ShowCurrentTask",
        Enabled = function()
            return exports['fw-prison']:IsDoingPrisonTask()
        end,
    },
    {
        Id = 'bennys',
        Title = 'Enter Bennys',
        Icon = '#global-wrench',
        Close = true,
        Event = 'fw-bennys:Client:OpenBennys',
        Parameters = false,
        Enabled = function()
            return not exports['fw-medical']:GetDeathStatus() and exports['fw-bennys']:GetIsInBennysZone() and IsPedInAnyVehicle(PlayerPedId()) and GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1) == PlayerPedId()
        end,
    },
    {
        Id = 'jobs_postop_deliver_goods',
        Title = 'Product Afleveren',
        Icon = '#global-box',
        Close = true,
        Event = 'fw-jobmanager:Client:PostOP:DeliverGoods',
        Parameters = false,
        Enabled = function()
            local MyJob = exports['fw-jobmanager']:GetMyJob()
            if not MyJob.CurrentJob then return end

            return not exports['fw-medical']:GetDeathStatus() and MyJob.CurrentJob == 'postop' and exports['fw-jobmanager']:GetCurrentTaskId() == 4 and exports['fw-jobmanager']:IsNearDeliveryStore()
        end,
    },
    {
        Id = "conceal_house",
        Title = "Deur Vergrendelen",
        Icon = "#global-lock",
        Close = true,
        Parameters = "",
        Event = "fw-jobmanager:Client:Houses:ConcealHouse",
        Enabled = function()
            if exports['fw-medical']:GetDeathStatus() then return false end
            local PlayerData = FW.Functions.GetPlayerData()
            return exports['fw-jobmanager']:GetCurrentHouse() and PlayerData.job.name == 'police' and PlayerData.job.onduty
        end,
    },
}

Config.SubMenus = {
    ['police:dispatch'] = {
        Title = "Dispatch",
        Icon = "#police-action-dispatch",
        Close = true,
        Parameters = false,
        Event = "fw-mdw:Client:OpenDispatch"
    },
    ['police:tablet'] = {
        Title = "MDW",
        Icon = "#police-action-tablet",
        Close = true,
        Parameters = false,
        Event = "fw-mdw:Client:OpenMDW"
    },
    ['police:search'] = {
        Title = "Fouilleren",
        Icon = "#police-action-search",
        Close = true,
        Event = "fw-police:Client:SearchPlayer"
    },
    ["police:seizePossesions"] = {
        Title = "Items in beslag",
        Icon = "#police-seize-items",
        Close = true,
        Event = "fw-police:Client:SeizePossesionsClosest"
    },
    ["police:fingerprint"] = {
        Title = "Vingerafdruk scannen",
        Icon = "#police-action-fingerprint",
        Close = true,
        Event = "fw-police:Client:CheckFingerprint"
    },
    ["police:checkBank"] = {
        Title = "Check Bank",
        Icon = "#global-piggy-bank",
        Close = true,
        Event = "fw-police:Client:CheckBank"
    },
    ["police:removeFacewear"] = {
        Title = "Masker afdoen",
        Icon = "#global-mask",
        Close = true,
        Event = "fw-police:Client:RemoveFacewear"
    },
    ["police:gsr"] = {
        Title = "GSR-test Afnemen",
        Icon = "#police-gsr",
        Close = true,
        Event = "fw-police:Client:TakeGSRTest"
    },
    ["police:checkStatus"] = {
        Title = "Status Controleren",
        Icon = "#police-status",
        Close = true,
        Event = "fw-police:Client:CheckStatus"
    },

    ["prison:checkInmateInformation"] = {
        Title = "Gevangenen Informatie",
        Icon = "#police-status",
        Close = true,
        Event = "fw-prison:Client:CheckInmateInformation"
    },

    ['ambulance:heal'] = {
        Title = "Burger Verzorgen",
        Icon = "#ambulance-action-heal",
        Close = true,
        Event = "fw-medical:Client:Medic:Heal"
    },
    ['ambulance:revive'] = {
        Title = "Burger Revive",
        Icon = "#ambulance-action-heal",
        Close = true,
        Event = "fw-medical:Client:Medic:Revive"
    },
    ['ambulance:blood'] = {
        Title = "Bloed Monster Nemen",
        Icon = "#ambulance-action-blood",
        Close = true,
        Event = "fw-medical:Client:Medic:TakeBlood"
    },
    ['ambulance:dna'] = {
        Title = "DNA Afnemen",
        Icon = "#ambulance-action-blood",
        Close = true,
        Event = "fw-medical:Client:Medic:TakeDNA"
    },
    ['vehicle:delete'] = {
        Title = "Voertuig Verwijderen",
        Icon = "#police-action-vehicle-delete",
        Close = true,
        Event = "FW:Command:DeleteVehicle"
    },
    ['judge:job'] = {
        Title = "Advocaat Aannemen",
        Icon = "#judge-actions",
        Close = true,
        Event = "fw-cityhall:client:lawyer:add:closest"
    },
    ['judge:createBusiness'] = {
        Title = "Creëer Bedrijf",
        Icon = "#judge-employment",
        Close = true,
        Event = "fw-businesses:Client:CreateBusiness"
    },
    ['judge:giveLicense'] = {
        Title = "Geef/Ontneem Vergunningen",
        Icon = "#plane-paper",
        Close = true,
        Event = "fw-cityhall:Client:GiveLicense"
    },
    ['judge:subpoenaRecords'] = {
        Title = "Telefoongegevens Aanvragen",
        Icon = "#judge-phone",
        Close = true,
        Event = "fw-cityhall:Client:SubpoenaRecords"
    },
    ['judge:subpoenaFinancials'] = {
        Title = "Financiëlegegevens Aanvragen",
        Icon = "#global-bank",
        Close = true,
        Event = "fw-cityhall:Client:SubpoenaFinancials"
    },
    ['judge:financialState'] = {
        Title = "Rekening (de)activeren",
        Icon = "#global-bank",
        Close = true,
        Event = "fw-cityhall:Client:FinancialState"
    },
    ['judge:financialMonitor'] = {
        Title = "Rekening Monitoren",
        Icon = "#global-bank",
        Close = true,
        Event = "fw-cityhall:Client:FinancialMonitorState"
    },
    ['judge:createFinancial'] = {
        Title = "Creëer Bankrekening",
        Icon = "#global-bank",
        Close = true,
        Event = "fw-cityhall:Client:CreateFinancial"
    },
    ['citizen:contact'] = {
        Title = "Contact Gegevens",
        Icon = "#citizen-contact",
        Close = true,
        Event = "fw-phone:Server:GiveContactDetails"
    },
    ['citizen:steal'] = {
        Title = "Beroven",
        Icon = "#citizen-action-steal",
        Close = true,
        Event = "fw-police:Client:RobPlayer"
    },
    ['vehicle:flip'] = {
        Title = "Voertuig Omduwen",
        Icon = "#citizen-action-vehicle",
        Close = true,
        Event = "fw-menu:client:flip:vehicle"
    },
    ['vehicle:key'] = {
        Title = "Geef Sleutel",
        Icon = "#citizen-action-vehicle-key",
        Close = true,
        Event = "fw-vehicles:Client:GiveKeys"
    },
    -- // Anims and Expression \\ --
    ["animations:chichi"] = {
        Title = "Chichi",
        Icon = "#animation-chichi",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@chichi",
    },
    ["animations:chubby"] = {
        Title = "Chubby",
        Icon = "#animation-wide",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@chubby@a",
    },
    ["animations:depressed1"] = {
        Title = "Depressed 1",
        Icon = "#animation-sad",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@depressed@a",
    },
    ["animations:depressed2"] = {
        Title = "Depressed 2",
        Icon = "#animation-sad",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@depressed@c",
    },
    ["animations:fat1"] = {
        Title = "Fat 1",
        Icon = "#animation-wide",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@fat@a",
    },
    ["animations:femme1"] = {
        Title = "Femme 1",
        Icon = "#animation-female",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@femme@",
    },
    ["animations:gangster1"] = {
        Title = "Gangster 1",
        Icon = "#animation-gangster",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@gangster@ng",
    },
    ["animations:defaultFemale1"] = {
        Title = "Standaard Vrouwelijk 1",
        Icon = "#animation-female",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@generic",
    },
    ["animations:defaultFemale2"] = {
        Title = "Standaard Vrouwelijk 2",
        Icon = "#animation-female",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@multiplayer",
    },
    ["animations:heels1"] = {
        Title = "Heels 1",
        Icon = "#animation-female",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@heels@c",
    },
    ["animations:heels2"] = {
        Title = "Heels 2",
        Icon = "#animation-female",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@heels@d",
    },
    ["animations:hiking1"] = {
        Title = "Hiking 1",
        Icon = "#animation-hiking",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@hiking",
    },
    ["animations:hurry7"] = {
        Title = "Hurry 7",
        Icon = "#animation-hurry",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@hurry@a",
    },
    ["animations:hurry8"] = {
        Title = "Hurry 8",
        Icon = "#animation-hurry",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@hurry@b",
    },
    ["animations:injured1"] = {
        Title = "Injured 1",
        Icon = "#animation-injured",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@injured",
    },
    ["animations:maneater"] = {
        Title = "Maneater",
        Icon = "#animation-maneater",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@maneater",
    },
    ["animations:posh1"] = {
        Title = "Posh 1",
        Icon = "#animation-posh",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@posh@",
    },
    ["animations:sad1"] = {
        Title = "Sad 1",
        Icon = "#animation-sad",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@sad@a",
    },
    ["animations:sad2"] = {
        Title = "Sad 2",
        Icon = "#animation-sad",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@sad@b",
    },
    ["animations:sassy"] = {
        Title = "Sassy",
        Icon = "#animation-sassy",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@sassy",
    },
    ["animations:sexy"] = {
        Title = "Sexy",
        Icon = "#animation-female",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@sexy@a",
    },
    ["animations:toolbelt1"] = {
        Title = "Toolbelt 1",
        Icon = "#animation-tools",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@tool_belt@a",
    },
    ["animations:toughGuy1"] = {
        Title = "Tough Guy 1",
        Icon = "#animation-tough",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_f@tough_guy@",
    },
    ["animations:injured2"] = {
        Title = "Injured 2",
        Icon = "#animation-injured",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_injured_generic",
    },
    ["animations:brave1"] = {
        Title = "Brave 1",
        Icon = "#animation-brave",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@brave",
    },
    ["animations:brave2"] = {
        Title = "Brave 2",
        Icon = "#animation-brave",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@brave@a",
    },
    ["animations:brave3"] = {
        Title = "Brave 3",
        Icon = "#animation-brave",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@brave@b",
    },
    ["animations:business1"] = {
        Title = "Business 1",
        Icon = "#animation-business",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@business@a",
    },
    ["animations:business2"] = {
        Title = "Business 2",
        Icon = "#animation-business",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@business@b",
    },
    ["animations:business3"] = {
        Title = "Business 3",
        Icon = "#animation-business",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@business@c",
    },
    ["animations:buzzard"] = {
        Title = "Buzzard",
        Icon = "#animation-default",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@buzzed",
    },
    ["animations:casual1"] = {
        Title = "Casual 1",
        Icon = "#animation-casual",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@casual@a",
    },
    ["animations:casual2"] = {
        Title = "Casual 2",
        Icon = "#animation-casual",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@casual@b",
    },
    ["animations:casual3"] = {
        Title = "Casual 3",
        Icon = "#animation-casual",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@casual@c",
    },
    ["animations:casual4"] = {
        Title = "Casual 4",
        Icon = "#animation-casual",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@casual@d",
    },
    ["animations:casual5"] = {
        Title = "Casual 5",
        Icon = "#animation-casual",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@casual@e",
    },
    ["animations:casual6"] = {
        Title = "Casual 6",
        Icon = "#animation-casual",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@casual@f",
    },
    ["animations:confident"] = {
        Title = "Confident",
        Icon = "#animation-confident",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@confident",
    },
    ["animations:depressed3"] = {
        Title = "Depressed 3",
        Icon = "#animation-sad",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@depressed@a",
    },
    ["animations:depressed4"] = {
        Title = "Depressed 4",
        Icon = "#animation-sad",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@depressed@b",
    },
    ["animations:tipsy"] = {
        Title = "Tipsy",
        Icon = "#animation-drunk",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@drunk@moderatedrunk",
    },
    ["animations:drunk1"] = {
        Title = "Drunk 1",
        Icon = "#animation-drunk",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@drunk@a",
    },
    ["animations:drunk2"] = {
        Title = "Drunk 2",
        Icon = "#animation-drunk",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "ove_m@drunk@slightlydrunk",
    },
    ["animations:drunk3"] = {
        Title = "Drunk 3",
        Icon = "#animation-drunk",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@drunk@verydrunk",
    },
    ["animations:fat2"] = {
        Title = "Fat 2",
        Icon = "#animation-wide",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@fat@a",
    },
    ["animations:femme2"] = {
        Title = "Femme 2",
        Icon = "#animation-female",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@femme@",
    },
    ["animations:fire"] = {
        Title = "Fire",
        Icon = "#animation-fire",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@fire",
    },
    ["animations:fire2"] = {
        Title = "Fire 2",
        Icon = "#animation-fire",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_characters@franklin@fire",
    },
    ["animations:fire3"] = {
        Title = "Fire 3",
        Icon = "#animation-fire",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_characters@michael@fire",
    },
    ["animations:ganster2"] = {
        Title = "Ganster 2",
        Icon = "#animation-gangster",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@gangster@a",
    },
    ["animations:ganster3"] = {
        Title = "Ganster 3",
        Icon = "#animation-gangster",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@gangster@generic",
    },
    ["animations:ganster4"] = {
        Title = "Ganster 4",
        Icon = "#animation-gangster",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@gangster@ng",
    },
    ["animations:ganster5"] = {
        Title = "Ganster 5",
        Icon = "#animation-gangster",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@gangster@var_e",
    },
    ["animations:ganster6"] = {
        Title = "Ganster 6",
        Icon = "#animation-gangster",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@gangster@var_f",
    },
    ["animations:ganster7"] = {
        Title = "Ganster 7",
        Icon = "#animation-gangster",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@gangster@var_i",
    },
    ["animations:grooving"] = {
        Title = "Grooving",
        Icon = "#animation-default",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "anim@move_m@grooving@",
    },
    ["animations:armored"] = {
        Title = "Armored",
        Icon = "#animation-vest",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@prison_gaurd",
    },
    ["animations:cuffed"] = {
        Title = "Cuffed",
        Icon = "#animation-cuffed",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@prisoner_cuffed",
    },
    ["animations:defaultMale"] = {
        Title = "Standaard Mannelijk",
        Icon = "#animation-default",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@generic",
    },
    ["animations:hiking2"] = {
        Title = "Hiking 2",
        Icon = "#animation-hiking",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@hiking",
    },
    ["animations:hipster"] = {
        Title = "Hipster",
        Icon = "#animation-default",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@hipster@a",
    },
    ["animations:hurry1"] = {
        Title = "Hurry 1",
        Icon = "#animation-hurry",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@hurry@a",
    },
    ["animations:hurry2"] = {
        Title = "Hurry 2",
        Icon = "#animation-hurry",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@hurry@b",
    },
    ["animations:hurry3"] = {
        Title = "Hurry 3",
        Icon = "#animation-hurry",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@hurry@c",
    },
    ["animations:hurry4"] = {
        Title = "Hurry 4",
        Icon = "#animation-hurry",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@hurry_butch@a",
    },
    ["animations:hurry5"] = {
        Title = "Hurry 5",
        Icon = "#animation-hurry",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@hurry_butch@b",
    },
    ["animations:hurry6"] = {
        Title = "Hurry 6",
        Icon = "#animation-hurry",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@hurry_butch@c",
    },
    ["animations:injured3"] = {
        Title = "Injured 3",
        Icon = "#animation-injured",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@injured",
    },
    ["animations:leafBlower"] = {
        Title = "Leaf blower",
        Icon = "#animation-default",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@leaf_blower",
    },
    ["animations:money"] = {
        Title = "Money",
        Icon = "#animation-money",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@money",
    },
    ["animations:muscle"] = {
        Title = "Muscle",
        Icon = "#animation-tough",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@muscle@a",
    },
    ["animations:posh2"] = {
        Title = "Posh 2",
        Icon = "#animation-posh",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@posh@",
    },
    ["animations:quick"] = {
        Title = "Quick",
        Icon = "#animation-quick",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@quick",
    },
    ["animations:sad3"] = {
        Title = "Sad 3",
        Icon = "#animation-sad",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@sad@a",
    },
    ["animations:sad4"] = {
        Title = "Sad 4",
        Icon = "#animation-sad",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@sad@b",
    },
    ["animations:sad5"] = {
        Title = "Sad 5",
        Icon = "#animation-sad",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@sad@c",
    },
    ["animations:sassy2"] = {
        Title = "Sassy 2",
        Icon = "#animation-sassy",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@sassy",
    },
    ["animations:shady"] = {
        Title = "Shady",
        Icon = "#animation-shady",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@shadyped@a",
    },
    ["animations:swagger"] = {
        Title = "Swagger",
        Icon = "#animation-swagger",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@swagger",
    },
    ["animations:swagger2"] = {
        Title = "Swagger 2",
        Icon = "#animation-swagger",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@swagger@b",
    },
    ["animations:toolbelt2"] = {
        Title = "Toolbelt 2",
        Icon = "#animation-tools",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@tool_belt@a",
    },
    ["animations:toughGuy2"] = {
        Title = "Tough Guy 2",
        Icon = "#animation-tough",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@tough_guy@",
    },
    ["animations:franklin"] = {
        Title = "Franklin",
        Icon = "#animation-default",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_p_m_one",
    },
    ["animations:trevor"] = {
        Title = "Trevor",
        Icon = "#animation-default",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_p_m_two",
    },
    ["animations:micheal"] = {
        Title = "Micheal",
        Icon = "#animation-default",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_p_m_zero",
    },
    ["animations:micheal2"] = {
        Title = "Micheal 2",
        Icon = "#animation-default",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_p_m_zero_slow",
    },
    -- ["animations:flee"] = {
    --     Title = "Flee",
    --     Icon = "#animation-flee",
    --     Close = true,
    --     Event = "animations:client:set:walkstyle",
    --     Parameters = "move_f@flee@a",
    -- },
    ["animations:hobo"] = {
        Title = "Hobo",
        Icon = "#animation-hobo",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@hobo@a",
    },
    ["animations:janitor"] = {
        Title = "Janitor",
        Icon = "#animation-broom",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_p_m_zero_janitor",
    },
    ["animations:jog"] = {
        Title = "Jog",
        Icon = "#animation-quick",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@jog@",
    },
    ["animations:lemar"] = {
        Title = "Lemar",
        Icon = "#animation-default",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "anim_group_move_lemar_alley",
    },
    ["animations:lester1"] = {
        Title = "Lester 1",
        Icon = "#animation-default",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_heist_lester",
    },
    ["animations:lester2"] = {
        Title = "Lester 2",
        Icon = "#animation-default",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_lester_caneup",
    },
    ["animations:janitor2"] = {
        Title = "Janitor 2",
        Icon = "#animation-broom",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_ped_bucket",
    },
    ["animations:fastrunner"] = {
        Title = "Fast Runner",
        Icon = "#animation-quick",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "female_fast_runner",
    },
    ["animations:jimmy"] = {
        Title = "Jimmy",
        Icon = "#animation-default",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_characters@jimmy@slow@",
    },
    ["animations:trash"] = {
        Title = "Trash 1",
        Icon = "#animation-global-trash",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "clipset@move@trash_fast_turn",
    },
    ["animations:trash2"] = {
        Title = "Trash 2",
        Icon = "#animation-global-trash",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "missfbi4prepp1_garbageman",
    },
    ["animations:bag"] = {
        Title = "Bag",
        Icon = "#animation-global-bag",
        Close = true,
        Event = "animations:client:set:walkstyle",
        Parameters = "move_m@bag",
    },
    ["expressions:angry"] = {
        Title = "Angry",
        Icon = "#expressions-angry",
        Close = true,
        Event = "expressions",
        Parameters =  { "mood_angry_1" },
    },
    ["expressions:drunk"] = {
        Title = "Drunk",
        Icon = "#expressions-drunk",
        Close = true,
        Event = "expressions",
        Parameters =  { "mood_drunk_1" },
    },
    ["expressions:dumb"] = {
        Title = "Dumb",
        Icon = "#expressions-dumb",
        Close = true,
        Event = "expressions",
        Parameters =  { "pose_injured_1" },
    },
    ["expressions:electrocuted"] = {
        Title = "Electrocuted",
        Icon = "#expressions-electrocuted",
        Close = true,
        Event = "expressions",
        Parameters =  { "electrocuted_1" },
    },
    ["expressions:grumpy"] = {
        Title = "Grumpy",
        Icon = "#expressions-grumpy",
        Close = true,
        Event = "expressions", 
        Parameters =  { "mood_drivefast_1" },
    },
    ["expressions:happy"] = {
        Title = "Happy",
        Icon = "#expressions-happy",
        Close = true,
        Event = "expressions",
        Parameters =  { "mood_happy_1" },
    },
    ["expressions:injured"] = {
        Title = "Injured",
        Icon = "#expressions-injured",
        Close = true,
        Event = "expressions",
        Parameters =  { "mood_injured_1" },
    },
    ["expressions:joyful"] = {
        Title = "Joyful",
        Icon = "#expressions-joyful",
        Close = true,
        Event = "expressions",
        Parameters =  { "mood_dancing_low_1" },
    },
    ["expressions:mouthbreather"] = {
        Title = "Mouthbreather",
        Icon = "#expressions-mouthbreather",
        Close = true,
        Event = "expressions",
        Parameters = { "smoking_hold_1" },
    },
    ["expressions:normal"]  = {
        Title = "Normal",
        Icon = "#expressions-normal",
        Close = true,
        Event = "expressions:clear",
    },
    ["expressions:oneeye"]  = {
        Title = "One Eye",
        Icon = "#expressions-oneeye",
        Close = true,
        Event = "expressions",
        Parameters = { "pose_aiming_1" },
    },
    ["expressions:shocked"]  = {
        Title = "Shocked",
        Icon = "#expressions-shocked",
        Close = true,
        Event = "expressions",
        Parameters = { "shocked_1" },
    },
    ["expressions:sleeping"]  = {
        Title = "Sleeping",
        Icon = "#expressions-sleeping",
        Close = true,
        Event = "expressions",
        Parameters = { "dead_1" },
    },
    ["expressions:smug"]  = {
        Title = "Smug",
        Icon = "#expressions-smug",
        Close = true,
        Event = "expressions",
        Parameters = { "mood_smug_1" },
    },
    ["expressions:speculative"]  = {
        Title = "Speculative",
        Icon = "#expressions-speculative",
        Close = true,
        Event = "expressions",
        Parameters = { "mood_aiming_1" },
    },
    ["expressions:stressed"]  = {
        Title = "Stressed",
        Icon = "#expressions-stressed",
        Close = true,
        Event = "expressions",
        Parameters = { "mood_stressed_1" },
    },
    ["expressions:sulking"]  = {
        Title = "Sulking",
        Icon = "#expressions-sulking",
        Close = true,
        Event = "expressions",
        Parameters = { "mood_sulk_1" },
    },
    ["expressions:weird"]  = {
        Title = "Weird",
        Icon = "#expressions-weird",
        Close = true,
        Event = "expressions",
        Parameters = { "effort_2" },
    },
    ["expressions:weird2"]  = {
        Title = "Weird 2",
        Icon = "#expressions-weird2",
        Close = true,
        Event = "expressions",
        Parameters = { "effort_3" },
    },
    ['vehicle:extra'] = {
        Title = "Extra 1",
        Icon = "#citizen-action-vehicle",
        Close = false,
        Parameters = 1,
        Event = "fw-menu:client:setExtra"
    },
    ['vehicle:extra2'] = {
        Title = "Extra 2",
        Icon = "#citizen-action-vehicle",
        Close = false,
        Parameters = 2,
        Event = "fw-menu:client:setExtra"
    },   
    ['vehicle:extra3'] = {
        Title = "Extra 3",
        Icon = "#citizen-action-vehicle",
        Close = false,
        Parameters = 3,
        Event = "fw-menu:client:setExtra"
    },
    ['vehicle:extra4'] = {
        Title = "Extra 4",
        Icon = "#citizen-action-vehicle",
        Close = false,
        Parameters = 4,
        Event = "fw-menu:client:setExtra"
    },
    ['vehicle:extra5'] = {
        Title = "Extra 5",
        Icon = "#citizen-action-vehicle",
        Close = false,
        Parameters = 5,
        Event = "fw-menu:client:setExtra"
    },
    ['vehicle:extra6'] = {
        Title = "Extra 6",
        Icon = "#citizen-action-vehicle",
        Close = false,
        Parameters = 6,
        Event = "fw-menu:client:setExtra"
    },
    ['vehicle:extra7'] = {
        Title = "Extra 7",
        Icon = "#citizen-action-vehicle",
        Close = false,
        Parameters = 7,
        Event = "fw-menu:client:setExtra"
    },
    ['vehicle:extra8'] = {
        Title = "Extra 8",
        Icon = "#citizen-action-vehicle",
        Close = false,
        Parameters = 8,
        Event = "fw-menu:client:setExtra"
    },
    ['vehicle:extra9'] = {
        Title = "Extra 9",
        Icon = "#citizen-action-vehicle",
        Close = false,
        Parameters = 9,
        Event = "fw-menu:client:setExtra"
    },
    ['vehicle:extra10'] = {
        Title = "Extra 10",
        Icon = "#citizen-action-vehicle",
        Close = false,
        Parameters = 10,
        Event = "fw-menu:client:setExtra"
    },
    ['vehicle:extra11'] = {
        Title = "Extra 11",
        Icon = "#citizen-action-vehicle",
        Close = false,
        Parameters = 11,
        Event = "fw-menu:client:setExtra"
    },
    ['vehicle:extra12'] = {
        Title = "Extra 12",
        Icon = "#citizen-action-vehicle",
        Close = false,
        Parameters = 12,
        Event = "fw-menu:client:setExtra"
    },
    ['clothes:pants'] = {
        Title = "Broek Aan/Uit",
        Icon = "#global-shoes",
        Close = true,
        Event = 'fw-menu:Client:TogglePants',
    },
    ['clothes:shirt'] = {
        Title = "Shirt Aan/Uit",
        Icon = "#global-shirt",
        Close = true,
        Event = 'fw-menu:Client:ToggleShirt',
    },
    ['clothes:shoes'] = {
        Title = "Schoenen Aan/Uit",
        Icon = "#global-shoes",
        Close = true,
        Event = 'fw-menu:Client:ToggleShoes',
    },
    ['clothes:vest'] = {
        Title = "Vest Aan/Uit",
        Icon = "#global-shirt",
        Close = true,
        Event = 'fw-menu:Client:ToggleVest',
    },
    ['clothes:visor'] = {
        Title = "Vizier Omhoog/Omlaag",
        Icon = "#global-helmet",
        Close = true,
        Event = 'fw-menu:Client:ToggleVisor',
    },
    ['clothes:bag'] = {
        Title = "Tas Open/Dicht",
        Icon = "#global-bag",
        Close = true,
        Event = 'fw-menu:Client:ToggleBag',
    },
    ['clothes:gloves'] = {
        Title = "Handschoenen Aan/Uit",
        Icon = "#global-gloves",
        Close = true,
        Event = 'fw-menu:Client:ToggleGloves',
    },
    ['clothes:neck'] = {
        Title = "Ketting Aan/Uit",
        Icon = "#global-necklace",
        Close = true,
        Event = 'fw-menu:Client:ToggleNeck',
    },

    ['arcade:leave'] = {
        Title = "Verlaten",
        Icon = "#arcade-leave",
        Close = true,
        Event = 'fw-arcade:Client:LeaveGame',
        Enabled = function()
            return not exports['fw-arcade']:IsMatchmaker()
        end,
    },
    -- ['arcade:restart'] = {
    --     Title = "Restart",
    --     Icon = "#arcade-restart",
    --     Close = true,
    --     Event = 'fw-arcade:Client:Restart',
    --     Enabled = function()
    --         return exports['fw-arcade']:IsMatchmaker()
    --     end,
    -- },
    ['arcade:end'] = {
        Title = "Spel beëindigen",
        Icon = "#arcade-end",
        Close = true,
        Event = 'fw-arcade:Client:EndGame',
        Enabled = function()
            return exports['fw-arcade']:IsMatchmaker()
        end,
    },
    ['arcade:tdm:changeLodout'] = {
        Title = "Loadout veranderen",
        Icon = "#police-action",
        Close = true,
        Event = 'fw-arcade:Client:TDM:ChangeLoadout',
        Enabled = function()
            return exports['fw-arcade']:IsInTDM()
        end
    },
}