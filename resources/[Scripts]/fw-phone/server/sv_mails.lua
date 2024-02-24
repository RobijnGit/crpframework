RegisterNetEvent('fw-phone:Server:Mails:AddMail', function(From, Subject, Msg, Target)
    local Source = Target and tonumber(Target) or source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    TriggerClientEvent('fw-phone:Client:Mails:AddMail', Source, {
        From = From,
        Subject = Subject,
        Msg = Msg,
        Timestamp = os.time() * 1000
    })
end)

RegisterNetEvent("Admin:Server:SendMail")
AddEventHandler("Admin:Server:SendMail", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Target = FW.Functions.GetPlayer(tonumber(Data.player))
    if Target == nil then return end

    if not FW.Functions.HasPermission(Source, "admin") and not FW.Functions.HasPermission(Source, "god") then
        return print(source .. " tried to send a mail through admin menu but lacks permission.")
    end

    TriggerEvent('fw-phone:Server:Mails:AddMail', Data.From, Data.Subject, Data.Message, Target.PlayerData.source)
end)