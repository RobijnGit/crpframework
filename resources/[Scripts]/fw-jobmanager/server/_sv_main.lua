FW = exports['fw-core']:GetCoreObject()

-- Code
CurrentCops = 0

function GetJobs()
    return Config.Jobs
end
exports("GetJobs", GetJobs)

FW.Functions.CreateCallback("fw-jobmanager:Server:GetJobs", function(Source, Cb)
    Cb(GetJobs())
end)

function DeepCopyTable(Obj)
    if type(Obj) ~= 'table' then return Obj end
    local res = {}
    
    for k, v in pairs(Obj) do
        res[DeepCopyTable(k)] = DeepCopyTable(v)
    end

    return res
end

function GetRandomFromArray(Array, Ignore, IgnoreCb)
    local AvailableOptions = {}

    for i, v in ipairs(Array) do
        local isIgnored = IgnoreCb ~= nil and not IgnoreCb(v)

        if not isIgnored then
            for k, ignoreValue in ipairs(Ignore) do
                if v == ignoreValue then
                    isIgnored = true
                    break
                end
            end
        end

        if not isIgnored then
            table.insert(AvailableOptions, v)
        end
    end

    if #AvailableOptions == 0 then
        return nil
    end

    
    local Result = AvailableOptions[math.random(1, #AvailableOptions)]
    return Result
end

-- Callbacks
FW.Functions.CreateCallback('fw-jobmanager:Server:GetConfig', function(Source, Cb)
    Cb(Config)
end)

-- Events
RegisterNetEvent("fw-police:SetCopCount")
AddEventHandler("fw-police:SetCopCount", function(Cops)
    CurrentCops = Cops
end)

AddEventHandler("onResourceStart", function(Resource)
    if Resource ~= GetCurrentResourceName() and Resource ~= "fw-phone" then return end
    Citizen.Wait(500)
    TriggerEvent("fw-phone:Server:RefreshJobs")
end)