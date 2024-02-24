FW = exports['fw-core']:GetCoreObject()
InClothesMenu, IsFree, SavedClothes, CreatingCharacter, CurrentTattooLayer = false, false, nil, false, {}

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    LoggedIn = true

    TriggerEvent("fw-clothes:Client:LoadSkin", nil)
    TriggerEvent('fw-assets:Client:Toggle:Items', false, true)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

-- Code

Citizen.CreateThread(function()
    InitZones()

    while true do
        Citizen.Wait(4)
        if LoggedIn then
            NearClothing = false
            local Coords = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Config.ChangeRooms) do
                local Distance = #(Coords - v.Coords)
                if Distance < 1.9 then
                    NearClothing = true
                    if not ShowingInteract then
                        ShowingInteract = true
                        exports['fw-ui']:ShowInteraction(v.Store and '[E] Kleding / [G] Outfits' or '[G] Outfits', 'primary')
                    end
                    if IsControlJustReleased(0, 38) and v.Store then
                        ClearPedTasksImmediately(PlayerPedId()) DisableAllControlActions(0)
                        OpenClothesMenu('Clothes')
                    end
                    if IsControlJustReleased(0, 58) then
                        TriggerEvent('fw-clothes:Client:OpenOutfits', false)
                    end
                end
            end
            if not NearClothing then
                if ShowingInteract then ShowingInteract = false exports['fw-ui']:HideInteraction() end
                Citizen.Wait(1000)
            end
        end
    end
end)

function IsFreemodeModel(Model)
    return Model == "mp_m_freemode_01" or Model == "mp_f_freemode_01"
end

function OpenClothesMenu(MenuType)
    exports['fw-ui']:SendUIMessage("Clothing", "SetComponentValues", {
        Values = GetMaxValues(),
        BlockedValues = GetBlockedValues(),
        PedId = GetPedNumber(),
        IsCustomPed = Config.CustomPeds[Config.CurrentSkin.Model] and Config.CurrentSkin.Model or false,
        CurrentSkin = Config.CurrentSkin.Clothes,
        CustomPeds = GetCustomPeds()
    })

    exports['fw-ui']:SendUIMessage("Clothing", "SetVisibility", {
        Visible = true,
        ClothingData = {},
        Type = MenuType
    })

    exports['fw-ui']:SetNuiFocus(true, true)
    exports['fw-ui']:SetNuiFocusKeepInput(true)

    SavedClothes = DeepCopyTable(Config.CurrentSkin)
    IsFree = MenuType == "Creation"
    InClothesMenu = true

    CurrentTattooLayer = {
        TattoosTorso = 0,
        TattoosHead = 0,
        TattoosLArm = 0,
        TattoosRArm = 0,
        TattoosLLeg = 0,
        TattoosRLeg = 0,
    }

    CreateClothingCamera(true, true)
end

function GetCustomPeds()
    local Cid = FW.Functions.GetPlayerData().citizenid
    local Retval = {}

    for k, v in pairs(Config.CustomPeds) do
        if IsModelInCdimage(k) and (IsPlayerAdmin() or v == Cid) then
            table.insert(Retval, k)
        end
    end

    return Retval
end

function GetPedNumber()
    local Gender = FW.Functions.GetPlayerData().charinfo.gender
    local Peds = Gender == 1 and Config.FemalePeds or Config.MalePeds

    for k, v in pairs(Peds) do
        if GetHashKey(v) == GetHashKey(Config.CurrentSkin.Model) then
            return k - 1
        end
    end

    return 0
end

function GetMaxValues()
    local Retval = {}

    local Gender = FW.Functions.GetPlayerData().charinfo.gender
    Retval.Peds = { MaxComps = Gender == 1 and #Config.FemalePeds or #Config.MalePeds, MaxTxts = 0 }

    local Ped = PlayerPedId()
    for k, v in pairs(Config.ClothingTypes) do
        Retval[k] = {}
        if v.Drawable ~= nil then
            Retval[k].MaxComps = GetNumberOfPedDrawableVariations(Ped, v.Drawable)
            Retval[k].MaxTxts = GetNumberOfPedTextureVariations(Ped, v.Drawable, GetPedDrawableVariation(Ped, v.Drawable)) - 1
        end

        if v.Prop ~= nil then
            Retval[k].MaxComps = GetNumberOfPedPropDrawableVariations(Ped, v.Prop) + 1
            Retval[k].MaxTxts = GetNumberOfPedPropTextureVariations(Ped, v.Prop, GetPedPropIndex(Ped, v.Prop)) - 1
        end

        if v.Overlay ~= nil then
            Retval[k].MaxComps = GetPedHeadOverlayNum(v.Overlay) - 1
            Retval[k].MaxTxts = 0 -- Color palette, no textures.
        end
    end

    local Tattoos = Config.Tattoos[Gender == 1 and "Female" or "Male"]

    Retval.TattoosTorso = { MaxComps = #Tattoos.Torso, MaxTxts = Config.MaxTattooLayers }
    Retval.TattoosHead = { MaxComps = #Tattoos.Head, MaxTxts = Config.MaxTattooLayers }
    Retval.TattoosLArm = { MaxComps = #Tattoos.LArm, MaxTxts = Config.MaxTattooLayers }
    Retval.TattoosRArm = { MaxComps = #Tattoos.RArm, MaxTxts = Config.MaxTattooLayers }
    Retval.TattoosLLeg = { MaxComps = #Tattoos.LLeg, MaxTxts = Config.MaxTattooLayers }
    Retval.TattoosRLeg = { MaxComps = #Tattoos.RLeg, MaxTxts = Config.MaxTattooLayers }

    Retval.FaceOne = { MaxComps = 46, MaxTxts = 46 }
    Retval.FaceTwo = { MaxComps = 46, MaxTxts = 46 }
    Retval.FaceThree = { MaxComps = 46, MaxTxts = 46 }
    Retval.FaceEyeColor = { MaxComps = 33, MaxTxts = 0 }
    Retval.Fade = { MaxComps = #Config.HairFades[Gender == 1 and "Female" or "Male"], MaxTxts = 0 }

    return Retval
end

function GetCurrentValues()
    local Retval = DeepCopyTable(Config.CurrentSkin.Clothes)
    local Ped = PlayerPedId()

    for k, v in pairs(Config.ClothingTypes) do
        if v.Drawable ~= nil then
            local Drawable = GetPedDrawableVariation(Ped, v.Drawable)
            local Texture = GetPedTextureVariation(Ped, v.Drawable)
            Retval[k] = { Drawable, Texture }
        end

        if v.Prop ~= nil then
            local Prop = GetPedPropIndex(Ped, v.Prop)
            local Texture = GetPedPropTextureIndex(Ped, v.Prop)
            Retval[k] = { Prop, Texture }
        end

        -- No getter natives, just setting to 0 for now.
        if v.Overlay ~= nil then
            Retval[k] = { 0, 0, 0, 0 }
        end
    end

    return Retval
end

function GetClothesPrice()
    if IsFree then return 0 end

    local Clothes = SavedClothes.Clothes
    local Retval = 0

    for k, v in pairs(Config.CurrentSkin.Clothes) do
        if type(v) == "table" then
            if k == "TattoosTorso" or k == "TattoosHead" or k == "TattoosLArm" or k == "TattoosRArm" or k == "TattoosLLeg" or k == "TattoosRLeg" then
                for i, j in pairs(v) do
                    if Clothes[k][j] ~= v[j] then
                        Retval = Retval + Config.ClothesPrice
                    end
                end
            end

            if Clothes[k][1] ~= v[1] then
                Retval = Retval + Config.ClothesPrice
            end
        end
    end

    return FW.Shared.CalculateTax("Clothes", Retval)
end

function GetBlockedValues()
    local BlockedNumbers, PlayerData = {}, FW.Functions.GetPlayerData()
    for k, v in pairs(Config.WhitelistedClothes[PlayerData.charinfo.gender == 1 and "Female" or "Male"]) do
        if PlayerData.job.name ~= k then
            for _, Clothes in pairs(v) do
                if BlockedNumbers[_] == nil then BlockedNumbers[_] = {} end
                for Clothing, ClothingNumber in pairs(Clothes) do
                    table.insert(BlockedNumbers[_], ClothingNumber)
                end
            end
        end
    end
    return BlockedNumbers
end

function LoadPedModel(Model)
    if GetEntityModel(PlayerPedId()) ~= GetHashKey(Model) then
        RequestModel(Model)
        while not HasModelLoaded(Model) do
            Citizen.Wait(1)
        end

        SetPlayerModel(PlayerId(), Model)

        Citizen.Wait(100)

        if LoggedIn then
            local PlayerData = FW.Functions.GetPlayerData()
            SetEntityMaxHealth(PlayerPedId(), 200)
            SetPedArmour(PlayerPedId(), PlayerData.metadata.armor)
            SetEntityHealth(PlayerPedId(), PlayerData.metadata.health)
            SetPlayerLockonRangeOverride(PlayerId(), 0.0)

            TriggerEvent('animations:client:set:walkstyle')
        end
    end
end

function LoadOutfit(Ped, Outfit)
    SetPedDefaultComponentVariation(Ped)
    Citizen.Wait(1)

    local Model = GetEntityModel(Ped)
    if Model == GetHashKey("mp_m_freemode_01") or Model == GetHashKey("mp_f_freemode_01") then
        SetPedHeadBlendData(Ped, Outfit.FaceOne[1], Outfit.FaceTwo[1], Outfit.FaceThree[1], Outfit.FaceOne[2], Outfit.FaceTwo[2], Outfit.FaceThree[2], Outfit.FaceMix / 100, Outfit.SkinMix / 100, Outfit.ThirdFaceMix / 100, false)
    end

    for ComponentId, ComponentData in pairs(Outfit) do
        local TypeData = Config.ClothingTypes[ComponentId]

        if ComponentId == 'FaceEyeColor' then
            SetPedEyeColor(Ped, ComponentData[1])
        elseif TypeData and TypeData.Drawable ~= nil then
            SetPedComponentVariation(Ped, TypeData.Drawable, ComponentData[1], ComponentData[2], TypeData.Palette or 0)

            if TypeData.Drawable == 2 then -- Hair
                SetPedHairColor(Ped, ComponentData[3], ComponentData[4])
            end
        elseif TypeData and TypeData.Prop ~= nil then
            if ComponentData[1] == -1 then
                ClearPedProp(Ped, TypeData.Prop)
            else
                SetPedPropIndex(Ped, TypeData.Prop, ComponentData[1], ComponentData[2], true)
            end
        elseif TypeData and TypeData.Overlay ~= nil then
            SetPedHeadOverlay(Ped, TypeData.Overlay, ComponentData[1], ComponentData[2] / 100)
            SetPedHeadOverlayColor(Ped, TypeData.Overlay, TypeData.ColorType or 0, ComponentData[3], ComponentData[4] or 0)
        elseif Config.FaceFeatureIds[ComponentId] ~= nil then
            for i, j in pairs(Config.FaceFeatureIds[ComponentId]) do
                SetPedFaceFeature(Ped, j, (ComponentData[i+1] + 0.0) / 100)
            end
        end
    end

    if Ped == PlayerPedId() then
        TriggerEvent("fw-assets:Client:Attach:Items")
    end

    Citizen.Wait(100)

    LoadFacialDecorations(Ped, {
        Head = Outfit.TattoosHead,
        Torso = Outfit.TattoosTorso,
        LArm = Outfit.TattoosLArm,
        RArm = Outfit.TattoosRArm,
        LLeg = Outfit.TattoosLLeg,
        RLeg = Outfit.TattoosRLeg,
        Fade = Outfit.Fade,
    })
end

function LoadFacialDecorations(Ped, FacialDecorations)
    ClearPedDecorationsLeaveScars(Ped)
    ClearPedDecorations(Ped)

    local Gender = GetEntityModel(Ped) == GetHashKey("mp_m_freemode_01") and "Male" or "Female"
    for TattooZone, Tattoos in pairs(FacialDecorations) do
        if TattooZone == "Fade" and Tattoos[1] ~= 0 then
            local FadeId = Tattoos[1]
            local HairFades = Gender == "Female" and Config.HairFades["Female"] or Config.HairFades["Male"]
            if HairFades[FadeId] then
                AddPedDecorationFromHashesInCorona(Ped, HairFades[FadeId][1], HairFades[FadeId][2])
            end
        elseif TattooZone ~= "Fade" then
            for i, j in pairs(Tattoos) do
                if j ~= 0 then
                    if Config.Tattoos[Gender][TattooZone] and Config.Tattoos[Gender][TattooZone][j] then
                        local TattooData = Config.Tattoos[Gender][TattooZone][j]
                        AddPedDecorationFromHashes(Ped, TattooData.Collection, TattooData.Name)
                    end
                end
            end
        end
    end
end

function IsPlayerAdmin()
    return FW.SendCallback("fw-admin:Server:IsPlayerAdmin")
end

RegisterNetEvent("fw-clothes:Client:LoadSkin")
AddEventHandler("fw-clothes:Client:LoadSkin", function(Data)
    if Data == nil then
        Data = FW.SendCallback("fw-clothes:Server:GetPlayerOutfit")
        Config.CurrentSkin = Data
    end

    if not Data.Ped or Data.Ped == PlayerPedId() then
        LoadPedModel(Data.Model)
        Citizen.Wait(250)
    end

    LoadOutfit(Data.Ped or PlayerPedId(), Data.Clothes)
end)

RegisterNetEvent("fw-clothes:Client:OpenClothesMenu")
AddEventHandler("fw-clothes:Client:OpenClothesMenu", OpenClothesMenu)

RegisterNetEvent("fw-clothes:Client:CreateCharacter")
AddEventHandler("fw-clothes:Client:CreateCharacter", function()
    local PlayerData = FW.Functions.GetPlayerData()
    local DefaultSkin = FW.SendCallback("fw-clothes:Server:GetDefaultClothes", PlayerData.charinfo.gender == 1 and "Female" or "Male")

    CreatingCharacter = true
    Config.CurrentSkin = DefaultSkin
    TriggerEvent("fw-clothes:Client:LoadSkin", DefaultSkin)

    SetEntityCoords(PlayerPedId(), -2166.71, 5183.51, 15.7)
    SetEntityHeading(PlayerPedId(), 222.54)

    Citizen.SetTimeout(500, function()
        DoScreenFadeIn(200)
        while not IsScreenFadedIn() do Citizen.Wait(10) end
        OpenClothesMenu('Creation')

        exports['fw-sync']:SetClientSync(false, {Time = 15, Weather = "EXTRASUNNY"})

        while CreatingCharacter do
            SetLocalPlayerVisibleLocally(true)
            Citizen.Wait(0)
        end

        exports['fw-sync']:SetClientSync(true)
    end)
end)

RegisterNetEvent("fw-clothes:Client:SetHairColor")
AddEventHandler("fw-clothes:Client:SetHairColor", function(ColorNumber)
    Config.CurrentSkin.Clothes.Hair[3] = ColorNumber
    SetPedHairColor(PlayerPedId(), ColorNumber, Config.CurrentSkin.Clothes.Hair[4])
    FW.TriggerServer("fw-clothes:Server:SetOutfit", Config.CurrentSkin)
end)

-- NUI callbacks

RegisterNUICallback("Clothing/GetClothesPrice", function(Data, Cb)
    Cb(GetClothesPrice())
end)

RegisterNUICallback("Clothing/CloseMenu", function(Data, Cb)
    local Price = GetClothesPrice()

    if Data.Pay then
        local Result = FW.SendCallback("fw-clothes:Server:PurchaseClothes", Data.Type, Price, Config.CurrentSkin)
        TriggerEvent("fw-clothes:Client:LoadSkin", nil)

        if not Result.Success then
            return FW.Functions.Notify(Result.Msg, "error")
        end
    elseif not Data.Pay then
        TriggerEvent("fw-clothes:Client:LoadSkin", nil)
    end

    exports['fw-ui']:SendUIMessage("Clothing", "SetVisibility", { Visible = false })
    exports['fw-ui']:SetNuiFocus(false, false)
    exports['fw-ui']:SetNuiFocusKeepInput(false)
    CreateClothingCamera(false)
    InClothesMenu, SavedClothes = false, nil

    if CreatingCharacter then
        TriggerEvent('fw-voice:Client:Mute:Self', false)

        DoScreenFadeOut(200)
        while not IsScreenFadedOut() do
            Citizen.Wait(10)
        end

        Citizen.SetTimeout(500, function()
            CreatingCharacter = false

            TriggerEvent('FW:Client:OnPlayerLoaded')
            Citizen.Wait(5000)
            if FW.Functions.GetPlayerData().metadata.islifer then
                TriggerEvent('fw-prison:Client:SetJail', true)
                TriggerServerEvent("fw-prison:Server:GiveStarterItems")
            else
                TriggerEvent('fw-apartment:Client:WakeUp', true)
                TriggerServerEvent("fw-characters:Server:GiveStarterItems")
            end
        end)
    end

    Cb("ok")
end)

RegisterNUICallback("Clothes/ToggleComponents", function(Data, Cb)
    local Ped = PlayerPedId()

    if Data.Type == "Hat" or Data.Type == "Glasses" then
        local SkinData = Config.CurrentSkin.Clothes[Data.Type]
        local TypeData = Config.ClothingTypes[Data.Type]
        if not TypeData.Prop then return end

        local CurrentProp = GetPedPropIndex(Ped, TypeData.Prop)
        if CurrentProp ~= SkinData[1] then
            SetPedPropIndex(Ped, TypeData.Prop, SkinData[1], SkinData[2], true)
        else
            ClearPedProp(Ped, TypeData.Prop)
        end
    elseif Data.Type == "Masks" or Data.Type == "Bags" then
        local SkinData = Config.CurrentSkin.Clothes[Data.Type]
        local TypeData = Config.ClothingTypes[Data.Type]
        if not TypeData.Drawable then return end

        local CurrentDrawable = GetPedDrawableVariation(Ped, TypeData.Drawable)
        if CurrentDrawable ~= SkinData[1] then
            SetPedComponentVariation(Ped, TypeData.Drawable, SkinData[1], SkinData[2], TypeData.Palette or 0)
        else
            SetPedComponentVariation(Ped, TypeData.Drawable, 0, 0, TypeData.Palette or 0)
        end
    elseif Data.Type == "Shirts" then
        local SkinData = Config.CurrentSkin.Clothes
        local TypeData = Config.ClothingTypes.Jacket
        if not TypeData.Drawable then return end

        local CurrentJacket = GetPedDrawableVariation(Ped, TypeData.Drawable)
        if CurrentJacket ~= SkinData.Jacket[1] then
            SetPedComponentVariation(Ped, Config.ClothingTypes.Jacket.Drawable, SkinData.Jacket[1], SkinData.Jacket[2], TypeData.Palette or 0)
            SetPedComponentVariation(Ped, Config.ClothingTypes.Undershirt.Drawable, SkinData.Undershirt[1], SkinData.Undershirt[2], TypeData.Palette or 0)
            SetPedComponentVariation(Ped, Config.ClothingTypes.Arms.Drawable, SkinData.Arms[1], SkinData.Arms[2], TypeData.Palette or 0)
            SetPedComponentVariation(Ped, Config.ClothingTypes.Vest.Drawable, SkinData.Vest[1], SkinData.Vest[2], TypeData.Palette or 0)
            SetPedComponentVariation(Ped, Config.ClothingTypes.Decals.Drawable, SkinData.Decals[1], SkinData.Decals[2], TypeData.Palette or 0)
        else
            SetPedComponentVariation(Ped, Config.ClothingTypes.Jacket.Drawable, 15, 0, TypeData.Palette or 0)
            SetPedComponentVariation(Ped, Config.ClothingTypes.Undershirt.Drawable, 15, 0, TypeData.Palette or 0)
            SetPedComponentVariation(Ped, Config.ClothingTypes.Arms.Drawable, 15, 0, TypeData.Palette or 0)
            SetPedComponentVariation(Ped, Config.ClothingTypes.Vest.Drawable, 0, 0, TypeData.Palette or 0)
            SetPedComponentVariation(Ped, Config.ClothingTypes.Decals.Drawable, 0, 0, TypeData.Palette or 0)
        end
    elseif Data.Type == "Pants" then
        local SkinData = Config.CurrentSkin.Clothes[Data.Type]
        local TypeData = Config.ClothingTypes[Data.Type]
        if not TypeData.Drawable then return end

        local CurrentDrawable = GetPedDrawableVariation(Ped, TypeData.Drawable)
        if CurrentDrawable ~= SkinData[1] then
            SetPedComponentVariation(Ped, TypeData.Drawable, SkinData[1], SkinData[2], TypeData.Palette or 0)
        else
            SetPedComponentVariation(Ped, TypeData.Drawable, IsPedMale(Ped) and 61 or 17, 0, TypeData.Palette or 0)
        end
    elseif Data.Type == "Shoes" then
        local SkinData = Config.CurrentSkin.Clothes[Data.Type]
        local TypeData = Config.ClothingTypes[Data.Type]
        if not TypeData.Drawable then return end

        local CurrentDrawable = GetPedDrawableVariation(Ped, TypeData.Drawable)
        if CurrentDrawable ~= SkinData[1] then
            SetPedComponentVariation(Ped, TypeData.Drawable, SkinData[1], SkinData[2], TypeData.Palette or 0)
        else
            SetPedComponentVariation(Ped, TypeData.Drawable, IsPedMale(Ped) and 34 or 35, 0, TypeData.Palette or 0)
        end
    end

    Cb("ok")
end)

RegisterNUICallback("Clothes/ClearTattoos", function(Data, Cb)
    Config.CurrentSkin.Clothes[Data.Zone] = { 0 }

    LoadFacialDecorations(PlayerPedId(), {
        Head = Config.CurrentSkin.Clothes.TattoosHead,
        Torso = Config.CurrentSkin.Clothes.TattoosTorso,
        LArm = Config.CurrentSkin.Clothes.TattoosLArm,
        RArm = Config.CurrentSkin.Clothes.TattoosRArm,
        LLeg = Config.CurrentSkin.Clothes.TattoosLLeg,
        RLeg = Config.CurrentSkin.Clothes.TattoosRLeg,
        Fade = Config.CurrentSkin.Clothes.Fade,
    })

    Cb("ok")
end)

RegisterNUICallback("Clothing/ProcessComponentChange", function(Data, Cb)
    local Ped = PlayerPedId()

    if Data.componentId == "TattoosTorso" or Data.componentId == "TattoosHead" or Data.componentId == "TattoosLArm" or Data.componentId == "TattoosRArm" or Data.componentId == "TattoosLLeg" or Data.componentId == "TattoosRLeg" then
        if Data.type == "Layer" then
            CurrentTattooLayer[Data.componentId] = Data.value
            return
        end

        Config.CurrentSkin.Clothes[Data.componentId][CurrentTattooLayer[Data.componentId]] = Data.value
        LoadFacialDecorations(Ped, {
            Head = Config.CurrentSkin.Clothes.TattoosHead,
            Torso = Config.CurrentSkin.Clothes.TattoosTorso,
            LArm = Config.CurrentSkin.Clothes.TattoosLArm,
            RArm = Config.CurrentSkin.Clothes.TattoosRArm,
            LLeg = Config.CurrentSkin.Clothes.TattoosLLeg,
            RLeg = Config.CurrentSkin.Clothes.TattoosRLeg,
            Fade = Config.CurrentSkin.Clothes.Fade,
        })

        Cb({ Success = true })
        return
    elseif Data.componentId == "Fade" then
        Config.CurrentSkin.Clothes[Data.componentId] = { Data.value }

        LoadFacialDecorations(Ped, {
            Head = Config.CurrentSkin.Clothes.TattoosHead,
            Torso = Config.CurrentSkin.Clothes.TattoosTorso,
            LArm = Config.CurrentSkin.Clothes.TattoosLArm,
            RArm = Config.CurrentSkin.Clothes.TattoosRArm,
            LLeg = Config.CurrentSkin.Clothes.TattoosLLeg,
            RLeg = Config.CurrentSkin.Clothes.TattoosRLeg,
            Fade = Config.CurrentSkin.Clothes.Fade,
        })

        Cb({ Success = true })
        return
    elseif Data.componentId == "Peds" then
        local Gender = FW.Functions.GetPlayerData().charinfo.gender
        local Model = Gender == 1 and Config.FemalePeds[Data.value + 1] or Config.MalePeds[Data.value + 1]

        LoadPedModel(Model)
        SetPedDefaultComponentVariation(PlayerPedId())

        Config.CurrentSkin.Model = Model

        -- Reset values and refresh max values.
        exports['fw-ui']:SendUIMessage("Clothing", "SetComponentValues", {
            Values = GetMaxValues(),
            PedId = Data.value,
            CurrentSkin = Model == SavedClothes.Model and SavedClothes.Clothes or GetCurrentValues(),
        })

        if Model == SavedClothes.Model then
            LoadOutfit(PlayerPedId(), SavedClothes.Clothes)
        end

        Cb({
            Success = true,
            Values = {
                MaxComps = Gender == 1 and #Config.FemalePeds or #Config.MalePeds,
                MaxTxts = 0
            }
        })

        return
    elseif Data.componentId == "FaceEyeColor" then
        SetPedEyeColor(PlayerPedId(), Data.value)
        Config.CurrentSkin.Clothes.FaceEyeColor[1] = Data.value
        return
    elseif Data.componentId == "FaceOne" or Data.componentId == "FaceTwo" or Data.componentId == "FaceThree" then
        if IsFreemodeModel(Config.CurrentSkin.Model) then
            local SkinData = Config.CurrentSkin.Clothes[Data.componentId]
            local IndexToChange = Data.type == "Drawable" and 1 or 2
            SkinData[IndexToChange] = Data.value

            local Clothes = Config.CurrentSkin.Clothes
            SetPedHeadBlendData(Ped, Clothes.FaceOne[1], Clothes.FaceTwo[1], Clothes.FaceThree[1], Clothes.FaceOne[2], Clothes.FaceTwo[2], Clothes.FaceThree[2], Clothes.FaceMix / 100, Clothes.SkinMix / 100, Clothes.ThirdFaceMix / 100, false)

            Cb({
                Success = true,
                Values = {
                    MaxComps = 46,
                    MaxTxts = 46
                }
            })
        else
            Cb({
                Success = false
            })
        end

        return
    elseif Data.componentId then
        local SkinData = Config.CurrentSkin.Clothes[Data.componentId]
        local IndexToChange = Data.type == "Drawable" and 1 or 2
        local TypeData = Config.ClothingTypes[Data.componentId]
        if not TypeData then return end

        if TypeData.Drawable ~= nil then
            SkinData[IndexToChange] = Data.value
            if IndexToChange == 1 then SkinData[2] = 0 end

            SetPedComponentVariation(Ped, TypeData.Drawable, SkinData[1], SkinData[2], TypeData.Palette or 0)

            Cb({
                Success = true,
                Values = {
                    MaxComps = GetNumberOfPedDrawableVariations(Ped, TypeData.Drawable),
                    MaxTxts = GetNumberOfPedTextureVariations(Ped, TypeData.Drawable, SkinData[1]) - 1
                }
            })

            return
        end

        if TypeData.Prop ~= nil then
            SkinData[IndexToChange] = Data.value
            if IndexToChange == 1 then SkinData[2] = 0 end

            if SkinData[1] == -1 then
                ClearPedProp(Ped, TypeData.Prop)
            else
                SetPedPropIndex(Ped, TypeData.Prop, SkinData[1], SkinData[2], true)
            end

            Cb({
                Success = true,
                Values = {
                    MaxComps = GetNumberOfPedPropDrawableVariations(Ped, TypeData.Prop) + 1,
                    MaxTxts = GetNumberOfPedPropTextureVariations(Ped, TypeData.Prop, GetPedPropIndex(Ped, TypeData.Prop)) - 1
                }
            })
            return
        end

        if TypeData.Overlay ~= nil then
            SkinData[IndexToChange] = Data.value
            local Opacity = SkinData[2] / 100
            SetPedHeadOverlay(Ped, TypeData.Overlay, SkinData[1], SkinData[2] / 100)

            Cb({
                Success = true,
                Values = {
                    MaxComps = GetPedHeadOverlayNum(TypeData.Overlay) - 1,
                    MaxTxts = 0 -- Color palette, no textures.
                }
            })
            return
        end
    elseif Data.paletteId then
        local SkinData = Config.CurrentSkin.Clothes[Data.paletteId]
        local TypeData = Config.ClothingTypes[Data.paletteId]
        local IndexToChange = Data.type == "Primary" and 3 or 4
        SkinData[IndexToChange] = Data.value

        if Data.paletteId == "Hair" then
            SetPedHairColor(Ped, SkinData[3], SkinData[4])
        else
            SetPedHeadOverlayColor(Ped, TypeData.Overlay, TypeData.ColorType or 0, SkinData[3], SkinData[4] or 0)
        end
    end

    Cb({Success = false})
end)

RegisterNUICallback("Clothing/ProcessSliderChange", function(Data, Cb)
    local Ped = PlayerPedId()
    local SkinData = Config.CurrentSkin.Clothes[Data.componentId]
    if SkinData == nil then
        return
    end

    if Data.valueId ~= nil then
        if SkinData[Data.valueId + 1] == Data.value then return end
        local TypeData = Config.ClothingTypes[Data.componentId]

        if TypeData and TypeData.Overlay ~= nil then
            SkinData[Data.valueId + 1] = Data.value
            SetPedHeadOverlay(Ped, TypeData.Overlay, SkinData[1], (Data.value + 0.0) / 100)
        else
            local FeatureId = Config.FaceFeatureIds[Data.componentId][Data.valueId]
            if FeatureId and FeatureId >= 0 then
                SetPedFaceFeature(Ped, FeatureId, (Data.value + 0.0) / 100)
                SkinData[Data.valueId + 1] = Data.value
            end
        end
    elseif Data.componentId == "FaceMix" or Data.componentId == "SkinMix" or Data.componentId == "ThirdFaceMix" then
        Config.CurrentSkin.Clothes[Data.componentId] = (Data.value + 0.0)

        if IsFreemodeModel(Config.CurrentSkin.Model) then
            local Clothes = Config.CurrentSkin.Clothes
            SetPedHeadBlendData(Ped, Clothes.FaceOne[1], Clothes.FaceTwo[1], Clothes.FaceThree[1], Clothes.FaceOne[2], Clothes.FaceTwo[2], Clothes.FaceThree[2], Clothes.FaceMix / 100, Clothes.SkinMix / 100, Clothes.ThirdFaceMix / 100, false)
        end
    end

    Cb({Success = false})
end)

RegisterNUICallback("Clothing/SetCustomPed", function(Data, Cb)
    local PlayerData = FW.Functions.GetPlayerData()
    local Cid = Config.CustomPeds[Data.Ped]

    if IsPlayerAdmin() or (Cid and Cid == PlayerData.CitizenId) then
        LoadPedModel(Data.Ped)
        SetPedDefaultComponentVariation(PlayerPedId())

        Config.CurrentSkin.Model = Data.Ped

        -- Reset values and refresh max values.
        exports['fw-ui']:SendUIMessage("Clothing", "SetComponentValues", {
            Values = GetMaxValues(),
            PedId = Data.value,
            CurrentSkin = Model == SavedClothes.Model and SavedClothes.Clothes or GetCurrentValues(),
        })

        if Model == SavedClothes.Model then
            LoadOutfit(PlayerPedId(), SavedClothes.Clothes)
        end
    end

    Cb(false)
end)

exports("IsMenuActive", function()
    return InClothesMenu
end)