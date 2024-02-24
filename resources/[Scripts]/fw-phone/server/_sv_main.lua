FW = exports['fw-core']:GetCoreObject()
SoundMuters = {}
IsNetworkEnabled = true

RegisterCommand("+setPhoneNetwork", function(source, args)
    if source ~= 0 then return end

    if args[1]:lower() == 'true' then
        IsNetworkEnabled = true
    else
        IsNetworkEnabled = false
    end

    TriggerClientEvent("fw-phone:Client:SetNetworkState", -1, IsNetworkEnabled)

    print("[PHONE]: Network Status set to " .. tostring(IsNetworkEnabled))
end)

RegisterNetEvent("fw-phone:Server:SetSoundState")
AddEventHandler("fw-phone:Server:SetSoundState", function(Toggle)
    local Source = source
    SoundMuters[Source] = Toggle
end)

FW.Functions.CreateCallback("fw-phone:Server:GetNetworkState", function(Source, Cb)
    Cb(IsNetworkEnabled)
end)

FW.Functions.CreateCallback("fw-phone:Server:Networks:IsNearNetwork", function(Source, Cb)
    local Coords = GetEntityCoords(GetPlayerPed(Source))
    if not IsNetworkEnabled then return Cb(false) end

    for k, v in ipairs(Config.Networks) do
        if #(v.Center - Coords) <= v.Size and v.Enabled(Source) then
            Cb(true)
            return
        end
    end

    Cb(false)
end)

FW.Functions.CreateCallback("fw-phone:Server:Networks:GetNetworks", function(Source, Cb)
    local Coords = GetEntityCoords(GetPlayerPed(Source))
    if not IsNetworkEnabled then return Cb({}) end

    local Retval = {}
    for k, v in ipairs(Config.Networks) do
        if #(v.Center - Coords) <= v.Size and v.Enabled(Source) then
            Retval[#Retval + 1] = v
        end
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-phone:Server:Networks:Connect", function(Source, Cb, Data)
    local Coords = GetEntityCoords(GetPlayerPed(Source))
    local Retval = { Success = false }

    if not Data.Network then
        return Cb(false)
    end

    for k, v in pairs(Config.Networks) do
        if #(v.Center - Coords) <= v.Size and v.Enabled(Source) then
            if v.Id == Data.Network and (not v.Password or v.Password == Data.Password) then
                Retval = { Success = true, Coords = v.Center, Size = v.Size }
            end
        end
    end

    Cb(Retval)
end)

exports("IsNetworkDisabled", function()
    return IsNetworkEnabled == false
end)