local Cam = nil
local Vehicle = nil

local UndergroundShowroom = vector3(-41.36324, -1052.294, -42.50)
local UndergroundShowroomCar = {x = -37.26872, y = -1054.309, z = -43.37314, a = 32.1}

local FailedModels = {}

RegisterNetEvent("fw-businesses:Client:SpawnTempVehicle")
AddEventHandler("fw-businesses:Client:SpawnTempVehicle", function(Model)
    if Cam then
        TogglePdmCam(false)
    end

    if Vehicle then
        DeleteVehicle(Vehicle)
    end

    Citizen.Wait(10)

    if not IsModelValid(Model) then
        print("MODEL DID NOT EXIST.", Model)
        TriggerServerEvent("takeScreenshot", Model, true)
        table.insert(FailedModels, Model)
        return
    end

    FW.Functions.TriggerCallback('FW:server:spawn:vehicle', function(Veh)
        while not NetworkDoesEntityExistWithNetworkId(Veh) do Citizen.Wait(1000) end
        Vehicle = NetToVeh(Veh)

        SetVehicleOnGroundProperly(Vehicle)
        FreezeEntityPosition(Vehicle, true)
        SetEntityHeading(Vehicle, UndergroundShowroomCar.a)
        SetVehicleEngineOn(Vehicle, true, true, false)
        SetVehicleDirtLevel(Vehicle, 0.0)
        SetVehicleModKit(Vehicle, 0)
        SetEntityInvincible(Vehicle, true)
        SetEntityCollision(Vehicle, false, true)
        SetModelAsNoLongerNeeded(Model)

        TogglePdmCam(true, Model)

        TriggerServerEvent("takeScreenshot", Model)
    end, Model, UndergroundShowroomCar, false, nil)
end)

RegisterNetEvent("fw-businesses:Client:DeleteTempVehicle")
AddEventHandler("fw-businesses:Client:DeleteTempVehicle", function()
    DeleteVehicle(Vehicle)
    TogglePdmCam(false)
    Vehicle = nil
end)

function TogglePdmCam(Bool, Model)
    if Bool then
        local CamCoords = UndergroundShowroom

        Cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetFocusArea(CamCoords.x, CamCoords.y,CamCoords.z, 0.0, 0.0, 0.0)
        SetCamCoord(Cam, CamCoords.x, CamCoords.y, CamCoords.z)
        if ShopType == 'Tuner' then
            SetCamRot(Cam, -15.0, 0.0, 47.45)
        else
            SetCamRot(Cam, -15.0, 0.0, 252.063)
        end
        SetCamFov(Cam, CalculateCamPos(Model, 15.5) and 70.0 or 50.0)
        SetCamActive(Cam, true)
        RenderScriptCams(true, false, 1, true, true)
    else
        if Cam ~= nil then
            RenderScriptCams(false, false, 1, true, true)
            SetCamActive(Cam, false)
            DestroyCam(Cam, true)
            Cam = nil
        end
        SetFocusEntity(PlayerPedId())
    end
end

function CalculateCamPos(Model, LargeCamSize)
    local MinDim, MaxDim = GetModelDimensions(Model)
    local ModelSize = MaxDim - MinDim
    local ModelVolume = ModelSize.x * ModelSize.y * ModelSize.z
    return ModelVolume > LargeCamSize
end

RegisterCommand("getFailed", function()
    print(json.encode(FailedModels))
end)