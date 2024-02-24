local Container = false
local ContainerState = 0
local ContainerType = "Misc"

local TypeLabels = {
    Materials = "materialen",
    Jewelery = "juwelen en goud",
    Weapons = "wapens",
    Misc = "waardevolle goederen",
}

local Items = {
    Materials = {
        -- { Item = "iron", AllowMultiple = true, Chance = 0.4 },
        { Item = "aluminum", AllowMultiple = true, Chance = 0.4 },
        { Item = "steel", AllowMultiple = true, Chance = 0.4 },
        { Item = "copper", AllowMultiple = true, Chance = 0.4 },
        { Item = "metalscrap", AllowMultiple = true, Chance = 0.4 },
        { Item = "plastic", AllowMultiple = true, Chance = 0.4 },
        { Item = "rubber", AllowMultiple = true, Chance = 0.4 },
        { Item = "glass", AllowMultiple = true, Chance = 0.4 },
        { Item = "electronics", AllowMultiple = true, Chance = 0.4 },
    },
    Jewelery = {
        { Item = "rolex", AllowMultiple = false, Chance = 0.8 },
        { Item = "coin", AllowMultiple = false, Chance = 0.8 },
        { Item = "goldchain", AllowMultiple = false, Chance = 0.7 },
        { Item = "cult-necklace", AllowMultiple = false, Chance = 0.7 },
        { Item = "goldnugget", AllowMultiple = false, Chance = 0.6 },
        { Item = "white-pearl", AllowMultiple = false, Chance = 0.6 },
        { Item = "heirloom", AllowMultiple = false, Chance = 0.5 },
        { Item = "gold-record", AllowMultiple = false, Chance = 0.5 },
        { Item = "platinum-record", AllowMultiple = false, Chance = 0.5 },
        { Item = "diamond-record", AllowMultiple = false, Chance = 0.5 },
        { Item = "diamond-blue", AllowMultiple = false, Chance = 0.5 },
        { Item = "diamond-yellow", AllowMultiple = false, Chance = 0.5 },
        { Item = "cannabiscup", AllowMultiple = false, Chance = 0.5 },
    },
    Weapons = {
        { Item = "weapon_bat", AllowMultiple = false, Chance = 0.3, IsWeapon = true },
        { Item = "weapon_switchblade", AllowMultiple = false, Chance = 0.3, IsWeapon = true },
        { Item = "weapon_poolcue", AllowMultiple = false, Chance = 0.3, IsWeapon = true },
        { Item = "weapon_wrench", AllowMultiple = false, Chance = 0.3, IsWeapon = true },
        { Item = "weapon_crowbar", AllowMultiple = false, Chance = 0.3, IsWeapon = true },
        { Item = "weapon_fn502", AllowMultiple = false, Chance = 0.05, IsWeapon = true },
        { Item = "weapon_katana", AllowMultiple = false, Chance = 0.05, IsWeapon = true },
    },
    Misc = {
        { Item = "tow-rope", AllowMultiple = false, Chance = 0.4 },
        { Item = "teddy", AllowMultiple = false, Chance = 0.4 },
        { Item = "fertilizer", AllowMultiple = false, Chance = 0.4 },
        { Item = "mugoftea", AllowMultiple = false, Chance = 0.4 },
        { Item = "screwdriver", AllowMultiple = false, Chance = 0.4 },
        { Item = "bakingsoda", AllowMultiple = false, Chance = 0.3 },
        { Item = "silencer_oilcan", AllowMultiple = false, Chance = 0.3 },
        { Item = "hacking_device", AllowMultiple = false, Chance = 0.3 },
        { Item = "binoculars", AllowMultiple = false, Chance = 0.3 },
        { Item = "vpn", AllowMultiple = false, Chance = 0.3 },
        { Item = "nightvision", AllowMultiple = false, Chance = 0.2 },
    }
}

local WashedContainers = {
    {"prop_container_ld_d", vector3(-506.21197509765627, -2291.802001953125, -0.26423501968383), vector3(-90.91986083984375, 70.60382843017578, 149.50730895996095)},
    {"prop_container_ld_d", vector3(2752.233154296875, -1630.742431640625, -0.97168743610382), vector3(-10.03836059570312, 8.64916515350341, -115.38118743896485)},
    {"prop_container_ld_d", vector3(2797.360595703125, 1258.8057861328126, -1.63255703449249), vector3(-17.38650512695312, -14.33797359466552, -124.05592346191406)},
    {"prop_container_ld_d", vector3(3757.78515625, 3827.998779296875, 3.48549747467041), vector3(-171.76258850097657, -9.63745212554931, 113.75570678710938)},
    {"prop_container_ld_d", vector3(2491.41943359375, 6612.31640625, 1.97171020507812), vector3(176.1405487060547, 7.67260980606079, -54.04775619506836)},
    {"prop_container_ld_d", vector3(-2182.6669921875, 4618.10888671875, 1.6478236913681), vector3(118.30354309082031, 87.1296157836914, -61.0445442199707)},
    {"prop_container_ld_d", vector3(-2809.400634765625, 2339.94091796875, 2.59640407562255), vector3(168.9916229248047, 8.18813705444336, -2.25479865074157)},
    {"prop_container_ld_d", vector3(-859.1848754882813, -3130.4267578125, 2.38024139404296), vector3(-58.76180267333984, 83.21791076660156, -178.0699005126953)},
    {"prop_container_ld_d", vector3(41.7848014831543, -2217.97216796875, 3.45076513290405), vector3(-167.40354919433595, 11.11937713623046, 48.17865753173828)},
    {"prop_container_ld_d", vector3(2113.41796875, -2426.499755859375, 2.44362020492553), vector3(-163.7687225341797, -3.80716681480407, 103.81306457519531)},
    {"prop_container_ld_d", vector3(2639.3193359375, -2003.191650390625, 2.33094024658203), vector3(171.98037719726563, 2.32122445106506, -75.86721801757813)},
    {"prop_container_ld_d", vector3(2802.142333984375, -1439.77783203125, 2.68346691131591), vector3(176.49221801757813, 4.49324178695678, 64.4011001586914)},
    {"prop_container_ld_d", vector3(2697.956787109375, -903.4697875976563, 3.17768836021423), vector3(179.25489807128907, -5.94264316558837, 165.39773559570313)},
    {"prop_container_ld_d", vector3(2809.841064453125, -548.6639404296875, 1.68731105327606), vector3(-175.55130004882813, 2.43100380897521, -178.44369506835938)},
    {"prop_container_ld_d", vector3(2871.35302734375, -116.85820007324219, 1.09368884563446), vector3(106.77002716064453, 78.67137908935547, -96.24565124511719)},
    {"prop_container_ld_d", vector3(2871.35302734375, -116.85820007324219, 1.09368884563446), vector3(106.77002716064453, 78.67137908935547, -96.24565124511719)},
    {"prop_container_ld_d", vector3(2922.06005859375, 326.09991455078127, 2.07116961479187), vector3(142.4751434326172, 81.78330993652344, 179.6791534423828)},
    {"prop_container_ld_d", vector3(2938.140625, 631.9205322265625, 1.46526563167572), vector3(163.0208740234375, 86.39196014404297, -54.86590194702148)},
    {"prop_container_ld_d", vector3(3020.5400390625, 1839.976806640625, 1.92363786697387), vector3(60.00194549560547, -81.91716003417969, -46.9443359375)},
    {"prop_container_ld_d", vector3(3120.611083984375, 1959.5772705078126, 3.25537824630737), vector3(163.431884765625, 2.48072862625122, -174.62173461914063)},
    {"prop_container_ld_d", vector3(3063.4599609375, 2111.512939453125, 2.83915710449218), vector3(172.93655395507813, -3.39222979545593, -175.1353302001953)},
    {"prop_container_ld_d", vector3(3348.65625, 2538.065185546875, -2.4006712436676), vector3(-17.03742599487304, -3.16030645370483, -94.97235107421875)},
    {"prop_container_ld_d", vector3(3576.642333984375, 2572.58349609375, -0.64768481254577), vector3(-23.26222801208496, 11.36850833892822, -94.76322937011719)},
    {"prop_container_ld_d", vector3(3525.57080078125, 2801.231689453125, -0.08471131324768), vector3(-7.97931337356567, 10.91504859924316, -176.79298400878907)},
    {"prop_container_ld_d", vector3(3916.170654296875, 3429.474609375, 1.55264925956726), vector3(65.00277709960938, -78.13827514648438, 2.23791098594665)},
    {"prop_container_ld_d", vector3(3916.170654296875, 3429.474609375, 1.55264925956726), vector3(65.00277709960938, -78.13827514648438, 2.23791098594665)},
    {"prop_container_ld_d", vector3(3853.705810546875, 3645.887451171875, 1.48302245140075), vector3(-147.7760772705078, 60.50159454345703, -82.79165649414063)},
    {"prop_container_ld_d", vector3(3951.01416015625, 4396.25, 0.70376372337341), vector3(-78.45569610595703, 82.29998779296875, 146.88046264648438)},
    {"prop_container_ld_d", vector3(3875.659423828125, 4423.6650390625, 1.03283333778381), vector3(-78.45570373535156, 82.30001831054688, -118.11952209472656)},
    {"prop_container_ld_d", vector3(3833.345947265625, 4512.50146484375, 1.41413187980651), vector3(-12.59193229675293, 78.51039123535156, -152.40716552734376)},
    {"prop_container_ld_d", vector3(3740.94287109375, 4675.10595703125, 2.62203359603881), vector3(174.7711944580078, -5.26097059249877, -89.34404754638672)},
    {"prop_container_ld_d", vector3(3643.189453125, 4633.77978515625, 3.47680473327636), vector3(168.5529327392578, 3.66514706611633, -14.79092788696289)},
    {"prop_container_ld_d", vector3(3221.5078125, 5331.2705078125, 2.49549961090087), vector3(105.14002990722656, 76.18148803710938, 154.3531036376953)},
    {"prop_container_ld_d", vector3(3417.33740234375, 5431.982421875, -0.86504220962524), vector3(-12.80396556854248, 0.43557673692703, -144.00112915039063)},
    {"prop_container_ld_d", vector3(3585.554931640625, 5688.970703125, -0.31696462631225), vector3(-17.7917537689209, 0.08548635244369, 85.97616577148438)},
    {"prop_container_ld_d", vector3(3419.0, 6095.97998046875, 0.15363895893096), vector3(7.01449012756347, -1.62472188472747, 105.86767578125)},
    {"prop_container_ld_d", vector3(3428.6572265625, 6142.90869140625, -0.7840347290039), vector3(7.01449012756347, -1.62472164630889, 170.86767578125)},
    {"prop_container_ld_d", vector3(2834.426025390625, 6449.95654296875, -0.05905999243259), vector3(-1.23193442821502, 6.85115623474121, 65.82421875)},
    {"prop_container_ld_d", vector3(1901.6798095703126, 6685.61572265625, -0.58967864513397), vector3(-2.5405740737915, 81.2696304321289, 26.74523735046386)},
    {"prop_container_ld_d", vector3(1109.4439697265626, 6602.93505859375, 2.02862119674682), vector3(-2.5405740737915, 81.2696304321289, 26.74523735046386)},
    {"prop_container_ld_d", vector3(609.2357177734375, 6711.611328125, 2.02244615554809), vector3(173.04872131347657, 82.20191955566406, -8.003830909729)},
    {"prop_container_ld_d", vector3(39.74722290039062, 7233.658203125, 1.30858850479125), vector3(-103.26721954345703, -79.37976837158203, 166.93374633789063)},
    {"prop_container_ld_d", vector3(-37.43815612792969, 6914.490234375, 0.43325588107109), vector3(-103.26721954345703, -79.37976837158203, 166.93374633789063)},
    {"prop_container_ld_d", vector3(-512.726806640625, 6444.42724609375, 0.94303512573242), vector3(-148.93240356445313, -75.87421417236328, 121.66907501220703)},
    {"prop_container_ld_d", vector3(-668.2514038085938, 6178.87451171875, -0.23004356026649), vector3(-93.97901916503906, -76.89045715332031, -155.34825134277345)},
    {"prop_container_ld_d", vector3(-834.5869140625, 6039.00830078125, 0.35925734043121), vector3(-6.92098140716552, 0.90178608894348, -69.2238998413086)},
    {"prop_container_ld_d", vector3(-1003.447021484375, 6271.22509765625, -0.3706510066986), vector3(-1.92098200321197, 0.90178579092025, -69.22390747070313)},
    {"prop_container_ld_d", vector3(-921.6892700195313, 5634.30224609375, -0.36549341678619), vector3(3.07433676719665, -4.09540176391601, -69.05609130859375)},
    {"prop_container_ld_d", vector3(-1368.169921875, 5385.68994140625, -1.43494617938995), vector3(-17.42142868041992, -4.51182699203491, -3.85073328018188)},
    {"prop_container_ld_d", vector3(-2526.819580078125, 3989.2099609375, -1.05816555023193), vector3(-10.574312210083, -1.19773781299591, 21.26533317565918)},
    {"prop_container_ld_d", vector3(-2630.497802734375, 3592.645263671875, -0.2249042391777), vector3(5.21238231658935, 3.00624203681945, -168.57681274414063)},
    {"prop_container_ld_d", vector3(-3067.28564453125, 3443.455810546875, 1.20583868026733), vector3(69.21754455566406, 84.43147277832031, -99.72346496582031)},
    {"prop_container_ld_d", vector3(-2844.2470703125, 3057.83984375, 0.50100445747375), vector3(12.60652351379394, 80.59923553466797, 65.02188873291016)},
    {"prop_container_ld_d", vector3(-2653.989501953125, 2661.24462890625, 0.83989030122756), vector3(54.8290786743164, 85.13734436035156, 47.12189483642578)},
    {"prop_container_ld_d", vector3(-3167.239013671875, 1693.4521484375, 0.71378070116043), vector3(-105.56892395019531, 76.1256332397461, 16.42299079895019)},
    {"prop_container_ld_d", vector3(-3300.69091796875, 1017.607421875, 1.37774348258972), vector3(-105.56892395019531, 76.1256332397461, 16.42299079895019)},
    {"prop_container_ld_d", vector3(-2827.148193359375, -58.39247512817383, 1.79149150848388), vector3(56.73915481567383, 79.5053939819336, 34.11614227294922)},
    {"prop_container_ld_d", vector3(-2551.078857421875, -264.4520568847656, 1.43196272850036), vector3(-3.68756437301635, 76.23645782470703, 64.5450668334961)},
    {"prop_container_ld_d", vector3(-2184.381591796875, -469.1424255371094, 1.62166106700897), vector3(-167.98046875, -4.06095314025878, -44.2445182800293)},
    {"prop_container_ld_d", vector3(-2117.8369140625, -571.9413452148438, 2.2297077178955), vector3(-167.98046875, -4.06095504760742, -79.24451446533203)},
    {"prop_container_ld_d", vector3(-1384.9969482421876, -1648.123779296875, 2.94620156288146), vector3(175.2984161376953, 1.82687044143676, 69.6733627319336)},
    {"prop_container_ld_d", vector3(-1242.3515625, -1869.4854736328126, 1.94355130195617), vector3(175.2984161376953, 1.82687044143676, 69.6733627319336)},
    {"prop_container_ld_d", vector3(-1349.540283203125, -2069.404296875, 1.93167853355407), vector3(95.89185333251953, -80.15726470947266, 169.251953125)},
    {"prop_container_ld_d", vector3(-1644.824462890625, -2393.2685546875, 1.71398138999938), vector3(106.60308837890625, -84.98300170898438, 158.6207733154297)},
    {"prop_container_ld_d", vector3(-1993.76953125, -3035.303955078125, 1.64921736717224), vector3(106.60308837890625, -84.98300170898438, 158.6207733154297)},
    {"prop_container_ld_d", vector3(-1421.2073974609376, -3445.087890625, 1.59705638885498), vector3(106.6030044555664, -84.9830322265625, -176.37913513183595)},
    {"prop_container_ld_d", vector3(-1174.908203125, -3566.654052734375, 1.36865520477294), vector3(106.6030044555664, -84.9830322265625, -176.37913513183595)},
    {"prop_container_ld_d", vector3(-989.6912841796875, -3565.222412109375, 1.47622680664062), vector3(21.48336791992187, -89.68409729003906, -1.27331554889678)},
}

FW.RegisterServer("fw-misc:Server:SetStrandedContainerState", function(Source, State)
    ContainerState = State

    if State == 2 then
        local Player = FW.Functions.GetPlayer(Source)
        if Player == nil then return end
        Player.Functions.Notify("Probeer de deuren over een aantal minuten te openen!")

        Citizen.SetTimeout((1000 * 60) * math.random(5, 8), function()
            ContainerState = 3
        end)
    end
end)

FW.RegisterServer("fw-misc:Server:GiveContainerLoot", function(Source)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if ContainerState ~= 3 then
        return
    end

    local Loot = GetStrandedContainerLoot()
    for k, v in pairs(Loot) do
        Player.Functions.AddItem(v.Item, v.Amount, false, false, true, v.CustomType)
    end
end)

FW.Functions.CreateCallback("fw-misc:Server:GetStrandedContainerState", function(Source, Cb, NetId)
    Cb(ContainerState)
end)

FW.Functions.CreateCallback("fw-misc:Server:IsStrandedContainer", function(Source, Cb, NetId)
    Cb(NetworkGetNetworkIdFromEntity(Container) == NetId)
end)

Citizen.CreateThread(function()
    while true do

        Citizen.Wait(5000)

        local FoundContainer, ContainerData = GetRandomContainer()
        if not FoundContainer then
            goto Skip
        end

        SpawnStrandedContainer(ContainerData)
        
        Citizen.Wait((1000 * 60) * math.random(120, 300)) -- between every 90 and 120 minutes, wash up a container.


        ::Skip::
    end
end)

function GetRandomContainer()
    -- Cache all player coords.
    local PlayerCoords = {}

    for k, v in pairs(FW.GetPlayers()) do
        PlayerCoords[#PlayerCoords + 1] = GetEntityCoords(GetPlayerPed(v.ServerId))
    end

    -- Are there 25+ players online?
    if #PlayerCoords <= 25 then
        return false, nil
    end

    -- Go through containers and cache it if no one is nearby.
    local Containers = {}
    for k, v in pairs(WashedContainers) do
        local IsNearbyPlayer = false
        for i, j in pairs(PlayerCoords) do
            if j ~= nil and #(v[2] - j) <= 100 then
                IsNearbyPlayer = true
                break
            end
        end

        if not IsNearbyPlayer then
            Containers[#Containers + 1] = v
        end
    end

    -- Any containers available?
    if #Containers == 0 then
        return false, nil
    end

    -- Pick a random container.
    return true, Containers[math.random(#Containers)]
end

function SpawnStrandedContainer(ContainerData)
    if Container then
        while DoesEntityExist(Container) do
            DeleteEntity(Container)
            Citizen.Wait(1)
        end
    end

    Container = CreateObjectNoOffset(ContainerData[1], ContainerData[2].x, ContainerData[2].y, ContainerData[2].z, true, true, false)
    SetEntityRotation(Container, ContainerData[3].x, ContainerData[3].y, ContainerData[3].z)

    ContainerState = 0
    
    math.randomseed(os.time())
    local XOffset = math.random(150, 500) * (math.random() > 0.5 and -1 or 1)
    local YOffset = math.random(150, 500) * (math.random() > 0.5 and -1 or 1)
    ContainerType = GetContainerType()

    for k, v in pairs(FW.GetPlayers()) do
        local Player = FW.Functions.GetPlayer(v.ServerId)
        if Player and Player.Functions.HasEnoughOfItem('vpn', 1) then
            TriggerClientEvent("fw-misc:Client:SetStrandedContainerBlip", v.ServerId, ContainerData[2] + vector3(XOffset, YOffset, 0.0))
            TriggerClientEvent('fw-phone:Client:Mails:AddMail', v.ServerId, {
                From = "Anonymous",
                Subject = 'Aangespoelde container gevonden!',
                Msg = "Er zijn signalen van een mogelijk aangespoelde container gevonden met " .. TypeLabels[ContainerType] .. ", bekijk je map je om te zien waar de container ongeveer ligt..",
                Timestamp = os.time() * 1000
            })
        end
    end
end

function GetStrandedContainerLoot()
    local Retval = {}
    local HasWeapon = false
    local ItemsByName = {}

    for i = 1, math.random(8, 16), 1 do
        local Data = GetRandomStrandedItem()

        -- Does the player already have this item?
        if not Data.AllowMultiple and ItemsByName[Data.Item] then
            Data = GetRandomStrandedItem()
        end

        -- They got the same item twice, bad luck.
        if not Data.AllowMultiple and ItemsByName[Data.Item] then
            goto Skip
        end

        if Data.IsWeapon and HasWeapon then
            goto Skip
        end

        if Data.IsWeapon then HasWeapon = true end

        Data.Amount = Data.AllowMultiple and (ContainerType == "Materials" and math.random(15, 55) or math.random(1, 3)) or 1
        Retval[#Retval + 1] = Data

        ::Skip::
    end

    return Retval
end

function GetRandomStrandedItem()
    math.randomseed(os.time() + math.random(1, 100))

    local TotalChance = 0
    for _, Item in ipairs(Items[ContainerType]) do
        TotalChance = TotalChance + Item.Chance
    end

    local RandomValue = math.random() * TotalChance
    local CumulativeChance = 0

    for _, Item in ipairs(Items[ContainerType]) do
        CumulativeChance = CumulativeChance + Item.Chance
        if RandomValue <= CumulativeChance then
            return Item
        end
    end

    return false
end

function GetContainerType()
    math.randomseed(os.time() + math.random(1, 100))

    local Types = {
        { Type = "Materials", Chance = 0.8 },
        { Type = "Jewelery", Chance = 0.8 },
        { Type = "Weapons", Chance = 0.1 },
        { Type = "Misc", Chance = 0.5 }
    }

    local TotalChance = 0
    for k, v in ipairs(Types) do
        TotalChance = TotalChance + v.Chance
    end

    local RandomValue = math.random() * TotalChance
    local CumulativeChance = 0

    for k, v in ipairs(Types) do
        CumulativeChance = CumulativeChance + v.Chance
        if RandomValue <= CumulativeChance then
            return v.Type
        end
    end

    return false
end

AddEventHandler("onResourceStop", function()
    if Container then
        while DoesEntityExist(Container) do
            DeleteEntity(Container)
            Citizen.Wait(1)
        end
    end
end)