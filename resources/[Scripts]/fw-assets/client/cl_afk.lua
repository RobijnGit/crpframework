local isAdmin = 'user'
local secondsUntilKick = 1200
local prevPos, time = nil, nil

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    isAdmin = FW.SendCallback("fw-admin:Server:IsPlayerAdmin")
end)

-- Code
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)

        playerPed = PlayerPedId()
        if LoggedIn then
            if not isAdmin and not exports['fw-medical']:GetDeathStatus() and not exports['fw-mdw']:IsMdwOpen() and FW.Functions.GetPlayerData().metadata.division ~= "MCU" then
                currentPos = GetEntityCoords(playerPed, true)
                if prevPos ~= nil then
                    if currentPos == prevPos then
                        if time ~= nil then
                            if time > 0 then
                                if time == 60 then
                                    FW.Functions.Notify('Je bent AFK en wordt over ' .. math.ceil(time / 60) .. ' minuut gekickt!', 'error', 10000) 
                                elseif time == 30 then
                                    FW.Functions.Notify('Je bent AFK en wordt over ' .. time .. ' seconden gekickt!', 'error', 10000)
                                elseif time == 20 then
                                    FW.Functions.Notify('Je bent AFK en wordt over ' .. time .. ' seconden gekickt!', 'error', 10000)
                                elseif time == 10 then
                                    FW.Functions.Notify('Je bent AFK en wordt over ' .. time .. ' seconden gekickt!', 'error', 10000)
                                end
                                time = time - 5
                            else
                                FW.TriggerServer("fw-misc:Server:AFKKick")
                            end
                        else
                            time = secondsUntilKick
                        end
                    else
                        time = secondsUntilKick
                    end
                end
                prevPos = currentPos
            end
        end
    end
end)