function GenerateNewDui(URL, Width, Height, DuiId)
    if Config.SavedDuiData[DuiId] ~= nil then return false end
    
    local DuiNumber = math.random(11111, 99999)
    local Width, Height = Width or 1920, Height or 1080
    local DuiSize = tostring(Width) .. 'x' .. tostring(Height)

    local GenerateDictName, GenerateTxtName = DuiSize..'-dict-'..tostring(DuiNumber), DuiSize..'-txt-'..tostring(DuiNumber)
    local URL = Config.DuiLinks[DuiId] ~= nil and Config.DuiLinks[DuiId] or URL

    local DuiObject, DictObject = CreateDui(URL, Width, Height), CreateRuntimeTxd(GenerateDictName)

    local DuiHandle = GetDuiHandle(DuiObject)
    local TxdObject = CreateRuntimeTextureFromDuiHandle(DictObject, GenerateTxtName, DuiHandle)
    local ReturnData = { ['DuiId'] = DuiId, ['DuiSize'] = DuiSize, ['DuiObject'] = DuiObject, ['DuiHandle'] = DuiHandle, ['DictObject'] = DictObject, ['TxdObject'] = TxdObject, ['TxdDictName'] = GenerateDictName, ['TxdName'] = GenerateTxtName, ['Width'] = Width, ['Height'] = Height, ['DuiUrl'] = URL }
    
    Config.DuiLinks[DuiId] = URL
    Config.SavedDuiData[DuiId] = ReturnData
    --TriggerServerEvent('fw-assets:Server:Set:Dui:Data', DuiId, ReturnData)
    return ReturnData
end
exports("GenerateNewDui", GenerateNewDui) 

function GetDuiData(DuiId)
    if Config.SavedDuiData[DuiId] ~= nil then
        return Config.SavedDuiData[DuiId]
    end
end
exports("GetDuiData", GetDuiData)

function ReleaseDui(DuiId)
    if Config.SavedDuiData[DuiId] ~= nil then
        local Settings = Config.SavedDuiData[DuiId]
        SetDuiUrl(Settings['DuiObject'], 'about:blank')
        DestroyDui(Settings['DuiObject'])
        Config.SavedDuiData[DuiId] = nil
    end
end
exports("ReleaseDui", ReleaseDui)

function DeactivateDui(DuiId)
    local Settings = Config.SavedDuiData[DuiId]
    if Settings == nil then return end

    SetDuiUrl(Settings['DuiObject'], 'about:blank')
end
exports("DeactivateDui", DeactivateDui) 

function ActivateDui(DuiId)
    if Config.SavedDuiData[DuiId] ~= nil then
        local Settings = Config.SavedDuiData[DuiId]
        SetDuiUrl(Settings['DuiObject'], Config.DuiLinks[DuiId])
    end
end
exports("ActivateDui", ActivateDui) 

-- // Events \\ --

RegisterNetEvent('fw-assets:client:set:dui:url')
AddEventHandler('fw-assets:client:set:dui:url', function(DuiId, URL)
    if Config.SavedDuiData[DuiId] ~= nil then
        local Settings = Config.SavedDuiData[DuiId]
        Config.DuiLinks[DuiId] = URL
        Settings['DuiUrl'] = URL
        SetDuiUrl(Settings['DuiObject'], URL)
    end
end)

RegisterNetEvent('fw-assets:client:set:dui:data')
AddEventHandler('fw-assets:client:set:dui:data', function(DuiId, DuiData)
    Config.DuiLinks[DuiId] = DuiData['DuiUrl']
    Config.SavedDuiData[DuiId] = DuiData
end)

RegisterNetEvent('fw-assets:client:change:dui:menu')
AddEventHandler('fw-assets:client:change:dui:menu', function(Data, Entity)
    local Result = exports['fw-ui']:CreateInput({
        { Label = 'URL', Icon = 'fas fa-heading', Name = 'Url' }
    })

    if Result then
        TriggerServerEvent('fw-assets:server:set:dui:url', Data.DuiId, Result.Url)
    end
end)

RegisterNetEvent('fw-assets:client:change:dui:url')
AddEventHandler('fw-assets:client:change:dui:url', function(DuiId)
    local TargetId = DuiId
    Citizen.SetTimeout(450, function()
        local Data = {Inputs = {{Name = 'first_input', Label = 'URL', Icon = 'fas fa-link'}}}
        exports['fw-ui']:CreateInput(Data, function(ReturnData)
            if ReturnData.Result['first_input'] ~= '' then
                TriggerServerEvent('fw-assets:Server:Set:Dui:Url', TargetId, ReturnData.Result['first_input'])
            end
        end)
    end)
end)