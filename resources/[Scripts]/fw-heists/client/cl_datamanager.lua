DataManager = {}

function DataManager.Get(...)
    local Result = FW.SendCallback("fw-heists:Server:DataManager:Get", ...)
    return Result
end

function DataManager.Set(...)
    local Result = FW.SendCallback("fw-heists:Server:DataManager:Set", ...)
    return Result
end

function DataManager.SetTableValue(...)
    local Result = FW.SendCallback("fw-heists:Server:DataManager:SetTableValue", ...)
    return Result
end

function DataManager.GetTableValue(...)
    local Result = FW.SendCallback("fw-heists:Server:DataManager:GetTableValue", ...)
    return Result
end

function StartCoordsChecker(Center, Distance, OnExit)
    Citizen.CreateThread(function()
        while true do
            local MyCoords = GetEntityCoords(PlayerPedId())
            if #(Center - MyCoords) > Distance then
                OnExit()
                break
            end

            Citizen.Wait(1000)
        end
    end)
end