local IsRemovingFacewear = false

-- Outfits
RegisterNetEvent("fw-clothes:Client:OpenOutfits")
AddEventHandler("fw-clothes:Client:OpenOutfits", function(Forced, IsCommand)
    local PlayerData = FW.Functions.GetPlayerData()

    if IsCommand then
        local Hit, Pos, Vehicle = RayCastGamePlayCamera(5.0)
		if not Hit or Vehicle == -1 or GetEntityType(Vehicle) ~= 2 then
            Forced = false
        else
            local IsGov = exports['fw-vehicles']:IsPoliceVehicle(Vehicle)
            if not IsGov or (PlayerData.job.name ~= "police" and PlayerData.job.name ~= "ems") then
                Forced = false
            end
        end
    end

    if not Forced and IsPlayerAdmin() then
        Forced = true
    end

    if Forced or IsNearChangingRoom() then
        local Outfits = FW.SendCallback("fw-clothes:Server:GetPlayerOutfits")
        local ContextMenu = {
            {
                Title = "Outfit Opslaan",
                Icon = "plus",
                Data = { Event = "fw-clothes:Client:SaveOutfitPrompt", Forced = Forced }
            }
        }

        for k, v in pairs(Outfits) do
            table.insert(ContextMenu, {
                Title = ("(%s) %s"):format(v.Id, v.Title),
                Icon = "tshirt",
                CloseMenu = false,
                Data = { Event = 'fw-clothes:Client:LoadOutfit', IsPreview = true, Outfit = v.Outfit },
                SecondMenu = {
                    {
                        Title = "Aantrekken",
                        Icon = "check",
                        Data = { Event = "fw-clothes:Client:LoadOutfit", Outfit = v.Outfit, IsPreview = false }
                    },
                    {
                        Title = "Overschrijven",
                        Icon = "user-edit",
                        Data = { Event = "fw-clothes:Client:OverwriteOutfit", OutfitId = v.Id }
                    },
                    {
                        Title = "Verwijderen",
                        Icon = "trash",
                        Data = { Event = "fw-clothes:Server:DeleteOutfit", OutfitId = v.Id }
                    },
                }
            })
        end

        Citizen.Wait(50)
        FW.Functions.OpenMenu({
            MainMenuItems = ContextMenu,
            ReturnEvent = { Event = "fw-clothes:Client:CloseOutfits", Type = "Client", KeepCam = true },
            CloseEvent = { Event = "fw-clothes:Client:CloseOutfits", Type = "Client" },
        })
        CreateClothingCamera(true, false, 3)
    end
end)

RegisterNetEvent("fw-clothes:Client:CloseOutfits")
AddEventHandler("fw-clothes:Client:CloseOutfits", function(Data, IgnoreLoad)
    if not Data.KeepCam then
        CreateClothingCamera(false)
    end

    if not IgnoreLoad then
        LoadPedModel(Config.CurrentSkin.Model)
        LoadOutfit(PlayerPedId(), Config.CurrentSkin.Clothes)
    end
end)

RegisterNetEvent("fw-clothes:Client:LoadOutfit")
AddEventHandler("fw-clothes:Client:LoadOutfit", function(Data)
    if not Data.IsPreview then
        Config.CurrentSkin.Model = Data.Outfit.Model
        Config.CurrentSkin.Clothes = Data.Outfit.Clothes
        FW.TriggerServer("fw-clothes:Server:SetOutfit", Config.CurrentSkin)
        TriggerEvent('fw-misc:Client:Play:Audio', 'change-clothes')
        CreateClothingCamera(false)
    end

    LoadPedModel(Data.Outfit.Model)
    LoadOutfit(PlayerPedId(), Data.Outfit.Clothes)
end)

RegisterNetEvent("fw-clothes:Client:OverwriteOutfit")
AddEventHandler("fw-clothes:Client:OverwriteOutfit", function(Data)
    FW.TriggerServer("fw-clothes:Server:SavePlayerOutfit", nil, Config.CurrentSkin, Data.OutfitId)
end)

RegisterNetEvent("fw-clothes:Client:SaveOutfitPrompt")
AddEventHandler("fw-clothes:Client:SaveOutfitPrompt", function(Data)
    if not Data.Forced and not IsNearChangingRoom() then return end
    CreateClothingCamera(false)
    Citizen.Wait(10)

    local Result = exports['fw-ui']:CreateInput({
        { Name = "Name", Label = "Outfit Name", Icon = "fas fa-tshirt" }
    })

    if Result and Result.Name then
        FW.TriggerServer("fw-clothes:Server:SavePlayerOutfit", Result.Name, Config.CurrentSkin)
    end
end)

-- Facewear
RegisterNetEvent("fw-clothes:Client:ToggleFacewear")
AddEventHandler("fw-clothes:Client:ToggleFacewear", function(ComponentId, State, IsCommand, ItemInfo, ItemSlot)
    local TypeData = Config.ClothingTypes[ComponentId]
    if TypeData == nil then return end

    if ComponentId == 'Shoes' then
        Config.CurrentSkin.Clothes.Shoes[1] = State
        Config.CurrentSkin.Clothes.Shoes[2] = 0
        SetPedComponentVariation(PlayerPedId(), TypeData.Drawable, Config.CurrentSkin.Clothes[ComponentId][1], Config.CurrentSkin.Clothes[ComponentId][2], TypeData.ColorType or 0)
        FW.TriggerServer("fw-clothes:Server:SetOutfit", Config.CurrentSkin)
        return
    end

    if not State and Config.CurrentSkin.Clothes[ComponentId][1] == (TypeData.Prop ~= nil and -1 or 0) then
        return
    end

    if IsRemovingFacewear then return end
    IsRemovingFacewear = true

    local FacewearAnim = Config.FacewearAnimations[ComponentId]
    exports['fw-assets']:RequestAnimationDict(FacewearAnim[1])
    TaskPlayAnim(PlayerPedId(), FacewearAnim[1], FacewearAnim[2], 4.0, 3.0, GetAnimDuration(FacewearAnim[1], FacewearAnim[2]) * 1000, 49, 1.0, 0, 0, 0)
    Citizen.Wait(800)

    if ComponentId == 'Vest' and not IsCommand then
        return
    end

    if State then
        if ItemSlot then
            FW.TriggerServer("fw-clothes:Server:RemoveFacewear", ItemSlot)
        end

        Config.CurrentSkin.Clothes[ComponentId][1] = ItemInfo and ItemInfo.Prop or Config.CurrentSkin.Clothes[ComponentId][1]
        Config.CurrentSkin.Clothes[ComponentId][2] = ItemInfo and ItemInfo.Texture or Config.CurrentSkin.Clothes[ComponentId][2]

        if TypeData.Prop ~= nil then
            SetPedPropIndex(PlayerPedId(), TypeData.Prop, Config.CurrentSkin.Clothes[ComponentId][1], Config.CurrentSkin.Clothes[ComponentId][2], true)
        elseif TypeData.Drawable ~= nil then
            SetPedComponentVariation(PlayerPedId(), TypeData.Drawable, Config.CurrentSkin.Clothes[ComponentId][1], Config.CurrentSkin.Clothes[ComponentId][2], TypeData.ColorType or 0)
        end
    else
        if IsCommand then
            FW.TriggerServer("fw-clothes:Server:ReceiveFacewearItem", ComponentId, Config.CurrentSkin.Clothes[ComponentId])
        end

        if ComponentId ~= 'Vest' then
            Config.CurrentSkin.Clothes[ComponentId][1] = TypeData.Prop ~= nil and -1 or 0
            Config.CurrentSkin.Clothes[ComponentId][2] = 0
        end

        if TypeData.Prop ~= nil then
            ClearPedProp(PlayerPedId(), TypeData.Prop)
        elseif TypeData.Drawable ~= nil then
            SetPedComponentVariation(PlayerPedId(), TypeData.Drawable, 0, 0, TypeData.ColorType or 0)
        end
    end

    Citizen.Wait(ComponentId == 'Vest' and 1500 or ((GetAnimDuration(FacewearAnim[1], FacewearAnim[2]) * 1000) - 1000))
    ClearPedTasks(PlayerPedId())

    FW.TriggerServer("fw-clothes:Server:SetOutfit", Config.CurrentSkin)
    IsRemovingFacewear = false
end)

-- Functions
function IsNearChangingRoom()
    for k, v in pairs(Config.ChangeRooms) do
        local Distance = #(GetEntityCoords(PlayerPedId()) - v.Coords)
        if Distance < 4.0 then
            return true
        end
    end
    return false
end

function RayCastGamePlayCamera(Distance)
    local CameraRotation = GetGameplayCamRot()
    local CameraCoord = GetGameplayCamCoord()
    local Direction = RotationToDirection(CameraRotation)
    local Destination = {x = CameraCoord.x + Direction.x * Distance, y = CameraCoord.y + Direction.y * Distance, z = CameraCoord.z + Direction.z * Distance}
    local A, B, C, D, E = GetShapeTestResult(StartShapeTestRay(CameraCoord.x, CameraCoord.y, CameraCoord.z, Destination.x, Destination.y, Destination.z, -1, PlayerPedId(), 0))
    return B, C, E
end

function RotationToDirection(Rotation)
    local RotX, RotZ = math.rad(Rotation.x), math.rad(Rotation.z)
    local CosOfRotX = math.abs(math.cos(RotX))
    return vector3(-math.sin(RotZ) * CosOfRotX, math.cos(RotZ) * CosOfRotX, math.sin(RotX))
end