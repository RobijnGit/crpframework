FW = exports['fw-core']:GetCoreObject()
FakePlateData, FlaggedPlates = {}, {}

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait((1000 * 60))
        TriggerEvent('fw-police:Server:UpdatePoliceCounter')
    end
end)

RegisterServerEvent('fw-police:Server:UpdatePoliceCounter')
AddEventHandler('fw-police:Server:UpdatePoliceCounter', function()
    local PoliceAmount = 0
    for k, v in pairs(FW.Functions.GetPlayers()) do
        local Player = FW.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                PoliceAmount = PoliceAmount + 1
            end
        end
    end
    TriggerClientEvent("fw-police:SetCopCount", -1, PoliceAmount)
    TriggerEvent("fw-police:SetCopCount", PoliceAmount)
end)

function TimeSince(Timestamp)
    local Difference = os.time() - Timestamp
    if Difference < 60 then
        return "zojuist"
    elseif Difference < 3600 then
        local minutes = math.floor(Difference / 60)
        return minutes .. (minutes == 1 and " minuut" or " minuten") .. " geleden"
    elseif Difference < 86400 then
        local hours = math.floor(Difference / 3600)
        return hours .. (hours == 1 and " uur" or " uren") .. " geleden"
    end
end

function ListContains(List, Value)
    for k, v in ipairs(List) do
        if v == Value then
            return true
        end
    end
    return false
end

-- Commands
FW.Commands.Add("cam", "Open een camera", {}, false, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    if (Player.PlayerData.job.name ~= "police" and Player.PlayerData.job.name ~= "storesecurity") or not Player.PlayerData.job.onduty then return end

    TriggerClientEvent("fw-police:Client:ShowCameraInput", Source)
end)

FW.Commands.Add({"911"}, "Stuur een melding naar hulpdiensten in een noodgeval", {
    { name = "Bericht", help = "Bericht die je wilt sturen naar de hulpdiensten" }
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Message = table.concat(Args, " ")

    if #exports['fw-mdw']:GetCurrentDispatchers() > 0 and (Player.PlayerData.job.name ~= 'police' and Player.PlayerData.job.name ~= 'storesecurity') then
        return Player.Functions.Notify("Er is een dispatcher aanwezig, gebruik /911c", "error")
    end

    if exports['fw-phone']:IsNetworkDisabled() then
        return Player.Functions.Notify("Geen internet toegang..", "error")
    end

    if Player.PlayerData.metadata.jailtime <= 0 and (not Player.Functions.HasEnoughOfItem("phone", 1) or Player.PlayerData.metadata['ishandcuffed']) then
        return Player.Functions.Notify("Je kan dit nu niet doen..", "error")
    end

    if #Message > 512 then return Player.Functions.Notify("Teveel karakters! (" .. #Message .. "/512)", "error") end

    for k, v in pairs(FW.GetPlayers()) do
        local Target = FW.Functions.GetPlayer(v.ServerId)
        if Target and (Target.PlayerData.job.name == 'police' or Target.PlayerData.job.name == 'storesecurity' or Target.PlayerData.job.name == 'ems') and Target.PlayerData.job.onduty then
            TriggerClientEvent('chatMessage', v.ServerId, ("911 | (%s) %s | %s # %s"):format(Source, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, Player.PlayerData.charinfo.phone), "error", Message)
        end
    end

    TriggerClientEvent("fw-police:Client:CallAnim", Source)
    TriggerClientEvent("fw-police:Client:SendAlert", Source, "(" .. Source ..") " .. Player.PlayerData.charinfo.phone .. " - " .. Message)
    TriggerEvent('fw-logs:Server:Log', 'police', '/911', ("User: [%s] - %s - %s %s\nMessage: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, Message), 'green')
end)


FW.Commands.Add("311", "Stuur een melding naar hulpdiensten zonder een noodgeval", {
    { name = "Bericht", help = "Bericht die je wilt sturen naar de hulpdiensten" }
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Message = table.concat(Args, " ")

    if Player.PlayerData.metadata.jailtime <= 0 and (not Player.Functions.HasEnoughOfItem("phone", 1) or Player.PlayerData.metadata['ishandcuffed']) then
        return Player.Functions.Notify("Je kan dit nu niet doen..", "error")
    end

    TriggerClientEvent("fw-police:Client:CallAnim", Source)

    for k, v in pairs(FW.GetPlayers()) do
        local Target = FW.Functions.GetPlayer(v.ServerId)
        if Target and (Target.PlayerData.job.name == 'police' or Target.PlayerData.job.name == 'storesecurity' or Target.PlayerData.job.name == 'ems') and Target.PlayerData.job.onduty then
            TriggerClientEvent('chatMessage', v.ServerId, ("311 | (%s) %s | %s # %s"):format(Source, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, Player.PlayerData.charinfo.phone), "warning", Message)
        end
    end

    TriggerEvent('fw-logs:Server:Log', 'police', '/311', ("User: [%s] - %s - %s %s\nMessage: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, Message), 'green')
end)

FW.Commands.Add("911c", "Bel met een dispatcher.", {}, true, function(Source)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if #exports['fw-mdw']:GetCurrentDispatchers() == 0 then
        return Player.Functions.Notify("Geen dispatcher aanwezig, gebruik /911", "error")
    end

    if exports['fw-phone']:IsNetworkDisabled() then
        return Player.Functions.Notify("Geen internet toegang..", "error")
    end

    if Player.PlayerData.metadata.jailtime <= 0 and (not Player.Functions.HasEnoughOfItem("phone", 1) or Player.PlayerData.metadata['ishandcuffed']) then
        return Player.Functions.Notify("Je kan dit nu niet doen..", "error")
    end

    local Phone = exports['fw-mdw']:GetAvailableDispatcher()
    if not Phone then
        return Player.Functions.Notify("De lijnen zijn bezet.. Probeer later nog een keer..", "error")
    end

    TriggerClientEvent('fw-misc:Client:DialPhone', Source, { CallerName = '911', CalleeName = '911', Phone = Phone })
end)

FW.Commands.Add("911a", "Stuur een anonieme melding naar hulpdiensten (met locatie!)", {
    { name = "Bericht", help = "Bericht die je wilt sturen naar de hulpdiensten" }
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Message = table.concat(Args, " ")

    if #exports['fw-mdw']:GetCurrentDispatchers() > 0 then
        return Player.Functions.Notify("Er is een dispatcher aanwezig, gebruik /911c", "error")
    end

    if Player.PlayerData.metadata.jailtime <= 0 and (not Player.Functions.HasEnoughOfItem("phone", 1) or Player.PlayerData.metadata['ishandcuffed']) then
        return Player.Functions.Notify("Je kan dit nu niet doen..", "error")
    end

    if #Message > 512 then return Player.Functions.Notify("Teveel karakters! (" .. #Message .. "/512)", "error") end

    for k, v in pairs(FW.GetPlayers()) do
        local Target = FW.Functions.GetPlayer(v.ServerId)
        if Target and (Target.PlayerData.job.name == 'police' or Target.PlayerData.job.name == 'storesecurity' or Target.PlayerData.job.name == 'ems') and Target.PlayerData.job.onduty then
            TriggerClientEvent('chatMessage', v.ServerId, ("911 | (%s) Anoniem"):format(Source, Player.PlayerData.charinfo.phone), "error", Message)
        end
    end

    TriggerClientEvent("fw-police:Client:CallAnim", Source)
    TriggerClientEvent("fw-police:Client:SendAlert", Source, "(" .. Source ..") Anoniem - " .. Message)
    TriggerEvent('fw-logs:Server:Log', 'police', '/911a', ("User: [%s] - %s - %s %s\nMessage: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, Message), 'red')
end)

FW.Commands.Add("911r", "Stuur een bericht terug naar een 911-melding", {
    {name="id", help="ID voor de reply"},
    {name="bericht", help="Bericht die je wilt sturen"}
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Target = FW.Functions.GetPlayer(tonumber(Args[1]))
    if Target == nil then return end

    if Player.PlayerData.job.name ~= "police" and Player.PlayerData.job.name ~= "storesecurity" and Player.PlayerData.job.name ~= "ems" then
        return
    end

    table.remove(Args, 1)
    local Message = table.concat(Args, " ")

    TriggerClientEvent("fw-police:Client:CallAnim", Source)
    TriggerClientEvent('chatMessage', Target.PlayerData.source, (Player.PlayerData.job.name == "ems" and "EMS" or "Politie") .. " - " ..Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, "error", Message)
    TriggerEvent('fw-logs:Server:Log', 'police', '/911r', ("User: [%s] - %s - %s %s\nTarget: %s\nMessage: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, Target.PlayerData.citizenid, Message), 'orange')
end)

FW.Commands.Add("311r", "Stuur een bericht terug naar een 311-melding", {
    {name="id", help="ID voor de reply"},
    {name="bericht", help="Bericht die je wilt sturen"}
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Target = FW.Functions.GetPlayer(tonumber(Args[1]))
    if Target == nil then return end

    if Player.PlayerData.job.name ~= "police" and Player.PlayerData.job.name ~= "storesecurity" and Player.PlayerData.job.name ~= "ems" then
        return
    end

    table.remove(Args, 1)
    local Message = table.concat(Args, " ")

    TriggerClientEvent("fw-police:Client:CallAnim", Source)
    TriggerClientEvent('chatMessage', Target.PlayerData.source, (Player.PlayerData.job.name == "ems" and "EMS" or "Politie") .. " - " ..Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, "orange", Message)
    TriggerEvent('fw-logs:Server:Log', 'police', '/311r', ("User: [%s] - %s - %s %s\nTarget: %s\nMessage: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, Target.PlayerData.citizenid, Message), 'orange')
end)

FW.Commands.Add("dispatch", "Stuur een melding als Dispatch.", {
    { name = "Bericht", help = "Bericht die je wilt sturen naar de hulpdiensten" }
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= "police" and Player.PlayerData.job.name ~= "storesecurity" and Player.PlayerData.job.name ~= "ems" then
        return
    end

    local Message = table.concat(Args, " ")

    if not Player.Functions.HasEnoughOfItem("phone", 1) or Player.PlayerData.metadata['ishandcuffed'] then
        return Player.Functions.Notify("Je kan dit nu niet doen..", "error")
    end

    TriggerClientEvent("fw-police:Client:CallAnim", Source)

    for k, v in pairs(FW.GetPlayers()) do
        local Target = FW.Functions.GetPlayer(v.ServerId)
        if Target and (Target.PlayerData.job.name == 'police' or Target.PlayerData.job.name == 'ems') and Target.PlayerData.job.onduty then
            TriggerClientEvent('chatMessage', v.ServerId, ("DISPATCH | (%s) %s | %s # %s"):format(Source, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, Player.PlayerData.charinfo.phone), "report", Message)
        end
    end

    TriggerEvent('fw-logs:Server:Log', 'police', '/dispatch', ("User: [%s] - %s - %s %s\nMessage: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, Message), 'green')
end)

FW.Commands.Add("runplate", "Controleer een kentekenplaat.", {
    { name = "Kenteken", help = "Het kentekennummber van het voertuig die je wilt controleren."}
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= 'police' then
        return
    end

    TriggerClientEvent("fw-police:Client:ScanVehPlate", Source, Args[1])
end)

FW.Commands.Add("flagplate", "Flag een kentekenplaat.", {}, false, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= 'police' then
        return
    end

    TriggerClientEvent("fw-police:Client:FlagPlate", Source)
end)

FW.Commands.Add("unflagplate", "Haal een flag weg van een kentekenplaat.", {
    { name = "Kenteken", help = "Het kentekennummber van het voertuig."}
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= 'police' then
        return
    end

    FlaggedPlates[Args[1]:upper()] = false
    Player.Functions.Notify("Unflagged " .. Args[1]:upper())
end)

FW.Commands.Add("callsign", "Verander je dienstnummer", {
    {name="Nummer", help="Dienstnummer"}
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if (Player.PlayerData.job.name ~= 'police' and Player.PlayerData.job.name ~= 'storesecurity' and Player.PlayerData.job.name ~= 'doc' and Player.PlayerData.job.name ~= 'ems') or not Player.PlayerData.job.onduty then
        return
    end

    local Callsign = Args[1]
    if not Callsign then
        return Player.Functions.Notify("Ongeldig roepnummer!", "error")
    end

    Player.Functions.SetMetaData("callsign", Callsign)
    Player.Functions.Notify('Roepnummer aangepast: ' .. Callsign, 'success')
    TriggerClientEvent("fw-police:Client:UpdateBlipName", Source)
    TriggerEvent("fw-mdw:Server:SetCallsign", Player.PlayerData.citizenid, Callsign)
end)

local Departments = { "UPD", "LSPD", "BCSO", "SDSO", "RANGER", "SASP" }
FW.Commands.Add("department", "Zet je PD department.", {
    {name="Department", help="UPD / LSPD / BCSO / SDSO / RANGER / SASP"}
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if (Player.PlayerData.job.name ~= 'police' and Player.PlayerData.job.name ~= 'ems') or not Player.PlayerData.job.onduty then
        return
    end

    local Department = Args[1]:upper()
    if not ListContains(Departments, Department) then
        return Player.Functions.Notify("Ongeldig department, beschikbare opties: " .. table.concat(Departments, ", "), "error")
    end

    Player.Functions.SetMetaData("department", Department)
    Player.Functions.Notify('Department aangepast: ' .. Department, 'success')
    TriggerClientEvent("fw-police:Client:UpdateBlipColor", Source)
end)

local Divisions = { "UPD", "LSPD", "BCSO", "RANGER", "SDSO", "SASP", "DISPATCH", "MCU", "HSPU" }
FW.Commands.Add("blipc", "Verander je blip kleur", {
    {name="Division", help="Naar welke divions kleur wil je het veranderen?"}
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if (Player.PlayerData.job.name ~= 'police' and Player.PlayerData.job.name ~= 'ems') or not Player.PlayerData.job.onduty then
        return
    end

    local Division = Args[1]:upper()
    if not ListContains(Divisions, Division) then
        return Player.Functions.Notify("Ongeldig department, beschikbare opties: " .. table.concat(Divisions, ", "), "error")
    end

    Player.Functions.SetMetaData("division", Division)
    Player.Functions.Notify('Department aangepast: ' .. Division, 'success')
    TriggerClientEvent("fw-police:Client:UpdateBlipColor", Source)
end)

local Certifications = { "STANDAARD", "INTERCEPTOR", "MOTORCYCLE", "UNMARKED", "AIRONE" }
FW.Commands.Add("setdutyvehicle", "Geef een werk certificatie aan een werknemer", {
    { name = "Id", help="Speler ID" },
    { name = "Vehicle", help = "STANDAARD / INTERCEPTOR / MOTORCYCLE / UNMARKED / AIRONE"},
    { name = "State", help = "True / False"}
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    local Target = FW.Functions.GetPlayer(tonumber(Args[1]))
    if Target == nil or Player == nil then
        return
    end

    if not Player.PlayerData.job.name == 'police' or not Player.PlayerData.metadata['ishighcommand'] then
        return
    end

    if not ListContains(Certifications, Args[2]:upper()) then
        return Player.Functions.Notify("Ongeldige certificatie, beschikbare opties: " .. table.concat(Certifications, ", "), "error")
    end

    if Args[3]:lower() == 'true' then
        Target.Functions.SetMetaDataTable("pd-vehicles", Args[2]:upper(), true)
        Target.Functions.Notify('Je hebt een certificatie ontvangen! ('..Args[2]:upper()..')', 'success')
        Player.Functions.Notify('Certificatie '..Args[2]:upper()..' gegeven aan ' .. Target.PlayerData.citizenid, 'success')
    else
        Target.Functions.SetMetaDataTable("pd-vehicles", Args[2]:upper(), false)
        Target.Functions.Notify('Je certificatie is afgenomen.. ('..Args[2]:upper()..')', 'error')
        Player.Functions.Notify('Certificatie '..Args[2]:upper()..' ontnomen van '..Target.PlayerData.citizenid, 'error')
    end
end)

FW.Commands.Add("bill", "Factuur uitschrijven", {
    { name = "id", help = "Speler ID"},
    { name = "geld", help = "Hoeveel"}
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local PlayerId, Amount = tonumber(Args[1]), tonumber(Args[2])
    if not PlayerId or PlayerId <= 0 then
        return Player.Functions.Notify("Ongeldige speler!", "error")
    end

    if not Amount or Amount <= 0 then
        return Player.Functions.Notify("Ongeldige bedrag!", "error")
    end

    local Target = FW.Functions.GetPlayer(tonumber(Args[1]))
    if Target == nil then return end

    if Player.PlayerData.job.name ~= 'police' then
        return
    end

    local TaxIncluded = FW.Shared.CalculateTax("Services", Amount)

    if exports['fw-financials']:RemoveMoneyFromAccount("1001", "4", Target.PlayerData.charinfo.account, TaxIncluded, 'FINE', '', true) then
        exports['fw-financials']:AddMoneyToAccount(Target.PlayerData.citizenid, Player.PlayerData.charinfo.account, "4", Amount, 'FINE', '')
        TriggerClientEvent('chatMessage', Target.PlayerData.source, "SYSTEM", "warning", "Je kreeg een boete van €" .. TaxIncluded .. "!")
        TriggerClientEvent('chatMessage', Source, "SYSTEM", "warning", "Je hebt een boete uitgeven van €" .. Amount .. "!")
        exports['fw-financials']:AddMoneyToAccount('1001', "1", "1", TaxIncluded - Amount, 'FINE', ('Services Tax. (Boete: %s)'):format(exports['fw-businesses']:NumberWithCommas(Amount))) -- Tax to the state
    end
end)

FW.Commands.Add("paylaw", "Betaal een advocaat", {
    { name = "id", help = "ID van een speler" },
    { name = "amount", help = "Hoeveel?"}
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local PlayerId, Amount = tonumber(Args[1]), tonumber(Args[2])
    if not PlayerId or PlayerId <= 0 then
        return Player.Functions.Notify("Ongeldige speler!", "error")
    end

    if not Amount or Amount <= 0 then
        return Player.Functions.Notify("Ongeldige bedrag!", "error")
    end

    local Target = FW.Functions.GetPlayer(tonumber(Args[1]))
    if Target == nil then return end
    if Player.PlayerData.job.name ~= "police" and Player.PlayerData.job.name ~= "judge" then
        return
    end

    if Target.PlayerData.job.name ~= "lawyer" and Target.PlayerData.job.name ~= "judge" then
        return Player.Functions.Notify('Persoon is geen advocaat of rechter!', "error")
    end

    if exports['fw-financials']:RemoveMoneyFromAccount(Player.PlayerData.citizenid, Target.PlayerData.charinfo.account, "1", Amount, 'PAYMENT', 'Advocaat vergoeding', true) then
        exports['fw-financials']:AddMoneyToAccount(Player.PlayerData.citizenid, "1", Target.PlayerData.charinfo.account, Amount, 'PAYMENT', 'Advocaat vergoeding.')
        TriggerClientEvent('chatMessage', Target.PlayerData.source, "SYSTEM", "warning", "Je hebt €"..Amount..",- ontvangen voor je diensten!")
        Player.Functions.Notify('Je hebt een advocaat betaald!')
    end
end)

FW.Commands.Add("paytow", "Betaal een impound worker", {
    { name = "id", help = "ID van een speler" },
    { name = "amount", help = "Hoeveel?"}
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local PlayerId, Amount = tonumber(Args[1]), tonumber(Args[2])
    if not PlayerId or PlayerId <= 0 then
        return Player.Functions.Notify("Ongeldige speler!", "error")
    end

    if not Amount or Amount <= 0 then
        return Player.Functions.Notify("Ongeldige bedrag!", "error")
    end

    local Target = FW.Functions.GetPlayer(tonumber(Args[1]))
    if Target == nil then return end
    if Player.PlayerData.job.name ~= "police" then
        return
    end

    if exports['fw-financials']:RemoveMoneyFromAccount(Player.PlayerData.citizenid, Target.PlayerData.charinfo.account, "4", Amount, 'PAYMENT', 'Impound Worker vergoeding', true) then
        exports['fw-financials']:AddMoneyToAccount(Player.PlayerData.citizenid, "4", Target.PlayerData.charinfo.account, Amount, 'PAYMENT', 'Impound Worker vergoeding.')
        TriggerClientEvent('chatMessage', Target.PlayerData.source, "SYSTEM", "warning", "Je hebt €"..Amount..",- ontvangen voor je diensten!")
        Player.Functions.Notify('Je hebt een impound worker betaald!')
    end
end)

FW.Commands.Add("tow", "Zie een lijst met actieve impound workers..", {}, false, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= "police" then
        return
    end

    local Groups = exports['fw-jobmanager']:GetGroupsByJob("impound")
    if not Groups or #Groups == 0 then
        return Player.Functions.Notify("Geen impound workers aanwezig..", "error")
    end

    local Data = {}

    for k, v in pairs(Groups) do
        local Target = FW.Functions.GetPlayerByCitizenId(v.Members[1].Cid)
        if Target then
            local State = 'Beschikbaar'
            if #v.Tasks > 0 then
                local CurrentTask = 0
                for TaskId, Task in pairs(v.Tasks) do
                    if Task.Progress >= Task.RequiredProgress then
                        CurrentTask = CurrentTask + 1
                    end
                end
                State = ("Bezig met taak: %s/%s"):format(CurrentTask, #v.Tasks)
            end

            Data[#Data + 1] = {
                Name = v.Members[1].Name,
                State = State,
                Phone = Target.PlayerData.charinfo.phone
            }
        end
    end

    TriggerClientEvent("fw-police:Client:OpenTowMenu", Source, Data)
end)

FW.Commands.Add("slimjim", "Slimjim een voertuig (Legaal voor PD)", {}, false, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)

    if Player == nil then return end

    if Player.PlayerData.job.name ~= "police" then
        return
    end

    TriggerClientEvent('fw-vehicles:Client:SlimJim', Source)
end)

-- Callbacks
FW.Functions.CreateCallback("fw-police:Server:IsPlayerHandcuffed", function(Source, Cb, TargetId)
    local Target = FW.Functions.GetPlayer(TargetId)
    if Target == nil then
        return Cb(false)
    end

    Cb({
        Cuffed = Target.PlayerData.metadata.ishandcuffed,
        Dead = Target.PlayerData.metadata.isdead
    })
end)

FW.Functions.CreateCallback("fw-police:Server:GetFingerprintResult", function(Source, Cb, TargetId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Target = FW.Functions.GetPlayer(TargetId)
    if Target == nil then return end

    if Player.PlayerData.job.name ~= 'police' and Player.PlayerData.job.name ~= 'storesecurity' then
        return
    end

    Cb(Target.PlayerData.metadata.fingerprint)
end)

FW.Functions.CreateCallback("fw-police:Server:GetCasingEvidence", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Items = exports['fw-inventory']:GetInventoryItems('ply-' .. Player.PlayerData.citizenid)
    local Retval = {}

    for k, v in pairs(Items) do
        if v and v.Item == 'evidence-collected' and v.CustomType == "Bullet" then
            Retval[#Retval + 1] = {
                Type = v.Info.Id,
                Slot = v.Slot,
                Serial = v.Info.Serial,
                IsDehashed = v.Info._IsDehashed
            }
            ::Skip::
        end
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-police:Server:GetVehicleData", function(Source, Cb, Plate)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `player_vehicles` WHERE `plate` = @Plate AND `vinscratched` = 0", { ['@Plate'] = Plate })
    if Result[1] == nil then
        if FakePlateData[Plate] then
            Cb(FakePlateData[Plate])
            return
        end

        FakePlateData[Plate] = {
            Flagged = false,
            Owner = Config.FirstNames[math.random(1, #Config.FirstNames)] .. ' ' .. Config.LastNames[math.random(1, #Config.LastNames)],
            Cid = math.random(58000, 999999),
            Phone = FW.Player.CreatePhoneNumber(),
            Model = 'Onbekend',
            Plate = Plate,
        }

        Cb(FakePlateData[Plate])
    else
        local Vehicle = Result[1]
        Cb({
            Flagged = FlaggedPlates[Plate],
            TimeSince = FlaggedPlates[Plate] and TimeSince(FlaggedPlates[Plate].Date) or 0,
            Owner = FW.Functions.GetPlayerCharName(Vehicle.citizenid),
            Cid = Vehicle.citizenid,
            Phone = FW.Functions.GetPlayerPhoneNumber(Vehicle.citizenid),
            Model = Vehicle.vehicle,
            Plate = Vehicle.plate
        })
    end
end)

FW.Functions.CreateCallback("fw-police:Server:GetEmployees", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Result = exports['ghmattimysql']:executeSync("SELECT `citizenid`, `job`, `metadata`, `charinfo`, `last_updated` FROM `players` WHERE `job` LIKE @Job", {
        ['@Job'] = '%' .. Data.Job .. '%',
    })

    local Retval = {}

    for k, v in pairs(Result) do
        local Job = json.decode(v.job)
        local CharInfo = json.decode(v.charinfo)
        local Metadata = json.decode(v.metadata)

        Retval[#Retval + 1] = {
            Cid = v.citizenid,
            Name = CharInfo.firstname .. " " .. CharInfo.lastname,
            Callsign = Metadata.callsign,
            Job = Job.label,
            Rank = Job.grade.name,
            Salary = FW.Shared.Jobs[Data.Job].grades[Job.grade.level] and FW.Shared.Jobs[Data.Job].grades[Job.grade.level].payment or Job.payment,
            Highcommand = Metadata.ishighcommand,
            LastSeen = os.date("%c", v.last_updated / 1000)
        }
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-police:Server:GetAccountId", function(Source, Cb, Data)
    if Data.Job == "police" then
        return Cb("4")
    elseif Data.Job == "ems" then
        return Cb("2")
    elseif Data.Job == "news" then
        return Cb("28746395")
    end
end)

FW.Functions.CreateCallback("fw-police:Server:GetFlaggedStatus", function(Source, Cb, Plate)
    Cb(FlaggedPlates[Plate:upper()])
end)

-- Events
FW.RegisterServer("fw-police:Server:CuffPlayer", function(Source, PlayerId, CuffState, IsHardcuff)
    TriggerClientEvent("fw-police:Client:DoCuff", PlayerId, Source, CuffState, IsHardcuff)
end)

FW.RegisterServer("fw-police:Server:SeatVehicle", function(Source, PlayerId, NetId, WarpInto, SeatId)
    TriggerClientEvent("fw-police:Client:SetInVehicle", PlayerId, NetId, WarpInto, SeatId)
end)

FW.RegisterServer("fw-police:Server:EscortPlayer", function(Source, PlayerId)
    TriggerClientEvent("fw-police:Server:DoEscort", PlayerId, Source)
end)

FW.RegisterServer("fw-police:Server:RemoveFaceWear", function(Source, TargetSource)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    if Player.PlayerData.job.name ~= 'police' then
        return
    end

    local Target = FW.Functions.GetPlayer(TargetSource)
    if Target == nil then return end

    TriggerClientEvent('fw-clothes:Client:ToggleFacewear', Target, 'Hat', false)
    Citizen.Wait(250)
    TriggerClientEvent('fw-clothes:Client:ToggleFacewear', Target, 'Masks', false)
    Citizen.Wait(250)
    TriggerClientEvent('fw-clothes:Client:ToggleFacewear', Target, 'Glasses', false)
end)

FW.RegisterServer("fw-police:Server:DehashSerial", function(Source, Data, Outcome)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Item = exports['fw-inventory']:GetInventoryItemBySlot('ply-' .. Player.PlayerData.citizenid, Data.Slot)
    if Item.Item ~= 'evidence-collected' then
        return Player.Functions.Notify("Je mist het bewijszakje..", "error")
    end

    if not Outcome then
        Player.Functions.Notify("Je bent gefaald en de kogelhuls was beschadigd..", "error")
    else
        local Chance = math.random(1, 100)
        if Chance >= 40 then
            Player.Functions.Notify("Gelukt! Je hebt het serienummer kunnen achterhalen!", "success")
            Player.Functions.SetItemKV('evidence-collected', Data.Slot, 'Serial', Item.Info._EvidenceData.Serial, Item.CustomType)
        else
            Player.Functions.Notify("De kogelhuls was te beschadigd en het was je niet gelukt..")
        end
    end

    Player.Functions.SetItemKV('evidence-collected', Data.Slot, '_IsDehashed', true, Item.CustomType)
end)

FW.RegisterServer("fw-police:Server:FlagPlate", function(Source, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= 'police' then
        return
    end

    FlaggedPlates[Data.Plate:upper()] = {
        Issuer = Player.PlayerData.metadata.callsign .. ' - ' .. Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        Reason = Data.Reason,
        Date = os.time()
    }

    Player.Functions.Notify("Flagged " .. Data.Plate:upper())
end)

FW.RegisterServer("fw-police:Server:PlaceSpikestrip", function(Source, Data)
    TriggerClientEvent("fw-police:Client:PlaceSpikestrips", -1, Data)
end)

FW.RegisterServer("fw-police:Server:HireEmployee", function(Source, Job, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= Job or not Player.PlayerData.metadata.ishighcommand then
        return Player.Functions.Notify("Jij kan dit niet..", "error")
    end

    local Target = FW.Functions.GetPlayerByCitizenId(Data.Cid)
    if Target == nil then return end

    Target.Functions.SetJob(Job, tostring(Data.Grade))
    Target.Functions.SetMetaData('ishighcommand', false)
    Target.Functions.Notify("Je bent aangenomen als " .. FW.Shared.Jobs[Job].label)
    Player.Functions.Notify("#" .. Data.Cid .. " aangenomen.")
end)

FW.RegisterServer("fw-police:Server:GrabTimeTrialsUsb", function(Source)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if (Player.PlayerData.job.name ~= "police" and Player.PlayerData.job.name ~= "ems") or not Player.PlayerData.metadata.ishighcommand then
        return Player.Functions.Notify("Jij kan dit niet..", "error")
    end

    Player.Functions.AddItem("racing-usb-pd", 1, false, nil, true)
end)

RegisterNetEvent("fw-police:Server:FireEmployee")
AddEventHandler("fw-police:Server:FireEmployee", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= Data.Job or not Player.PlayerData.metadata.ishighcommand then
        return Player.Functions.Notify("Jij kan dit niet..", "error")
    end

    local Target = FW.Functions.GetPlayerByCitizenId(Data.Cid)
    if Target then
        Target.Functions.SetJob('unemployed', '0')
        Target.Functions.Notify("Je bent ontslagen!", "error")
    else
        exports['ghmattimysql']:executeSync("UPDATE `players` SET `job` = @Job WHERE `citizenid` = @Cid", {
            ['@Cid'] = Data.Cid,
            ['@Job'] = json.encode({
                name = 'unemployed',
                label = 'werkloos',
                onduty = false,
                grade = {
                    name = 'Werkloos',
                    level = '0',
                    payment = 50
                }
            }),
        })
    end

    Player.Functions.Notify("#" .. Data.Cid .. " ontslagen.")

    TriggerClientEvent("fw-police:Client:ShowEmployeesList", Source, { Job = Data.Job })
end)

RegisterNetEvent("fw-police:Server:CheckBank")
AddEventHandler("fw-police:Server:CheckBank", function(TargetSrc)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Target = FW.Functions.GetPlayer(TargetSrc)
    if Target == nil then return end

    if Player.PlayerData.job.name ~= 'police' then
        return
    end

    TriggerClientEvent('chatMessage', Player.PlayerData.source, "Bankieren", "banking", exports['fw-businesses']:NumberWithCommas(exports['fw-financials']:GetAccountBalance(Target.PlayerData.charinfo.account)))
end)

RegisterNetEvent("fw-police:Server:SeizePossesions")
AddEventHandler("fw-police:Server:SeizePossesions", function(Target)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    if (Player.PlayerData.job.name ~= "police" and Player.PlayerData.job.name ~= "doc") or not Player.PlayerData.job.onduty then return Player.Functions.Notify("Alleen de Politie mag spulletjes van crimineeltjes afpakken..", "error") end

    local TPlayer = FW.Functions.GetPlayer(Target)
    if TPlayer == nil then return end

    exports['fw-inventory']:SetInventoryName('ply-' .. TPlayer.PlayerData.citizenid, 'jail-seize-' .. TPlayer.PlayerData.citizenid)
    TPlayer.Functions.RefreshInventory()
    TriggerClientEvent('chatMessage', TPlayer.PlayerData.source, "OMT", "warning", "Al je bezittingen zijn in beslag genomen, je kan deze ophalen bij de gevangenis.")
end)

RegisterNetEvent("fw-police:Server:SearchPlayer")
AddEventHandler("fw-police:Server:SearchPlayer", function(Target)
    local Source = source
    local TPlayer = FW.Functions.GetPlayer(Target)
    if TPlayer == nil then return end

    TPlayer.Functions.Notify("Je wordt gefouilleerd..")

    TriggerClientEvent('chatMessage', Source, "Cash", "warning", ("Persoon heeft %s cash op zak."):format(exports['fw-businesses']:NumberWithCommas(TPlayer.PlayerData.money.cash)))
end)