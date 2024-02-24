local EvidenceTypes = {'Blood', 'Bullet', 'Fingerprint'}
local Evidence, CurrentStatusLists = {}, {}

RegisterServerEvent('fw-police:Server:CreateEvidence')
AddEventHandler('fw-police:Server:CreateEvidence', function(Type, ExtraData)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local PlayerCoords = GetEntityCoords(GetPlayerPed(Source))
    if DoesEvidenceTypeExists(Type) then
        local Data = {}
        local EvidenceId = CreateEvidenceId(Type)
        if Type == 'Blood' then
            Data.BloodId = Player.PlayerData.metadata.slimecode -- not blood, idgaf.
            Data.BloodType = Player.PlayerData.metadata.bloodtype
        elseif Type == 'Fingerprint' then
            Data.FingerId = Player.PlayerData.metadata.fingerprint
        elseif Type == 'Bullet' then
            Data.Serial = ExtraData and ExtraData.Info ~= nil and ExtraData.Info.Serial
        end

        local Offset = DoesEntityExist(GetVehiclePedIsIn(GetPlayerPed(Source))) and -0.2 or 0.7 -- -0.2 turns into positive (-- = +)
        Evidence[EvidenceId] = {
            Type = Type,
            Data = Data,
            Serial = EvidenceId,
            Coords = PlayerCoords + vector3(math.random(-2, 2), math.random(-2, 2), -Offset)
        }

        TriggerClientEvent('fw-police:Client:SetEvidence', -1, EvidenceId, Evidence[EvidenceId])
    end
end)

RegisterServerEvent('fw-police:Server:GetTargetStatus')
AddEventHandler('fw-police:Server:GetTargetStatus', function(Target)
    local TPlayer = FW.Functions.GetPlayer(Target)
    if TPlayer == nil then return end

    if CurrentStatusLists[TPlayer.PlayerData.source] ~= nil and #CurrentStatusLists[TPlayer.PlayerData.source] > 0 then
        local TotalMessage, Count = '', 0
        for k, v in pairs(CurrentStatusLists[TPlayer.PlayerData.source]) do
            if v.Status ~= 'gunpowder' then
                Count = Count + 1
                TotalMessage = TotalMessage..'['..Count..'] Status: '..v.Text..'<br>'
            end
        end
        if TotalMessage ~= '' then
            TriggerClientEvent('chatMessage', source, "Status Controle", "error", TotalMessage)
        end
    end
end)

RegisterServerEvent('fw-police:Server:GSRResult')
AddEventHandler('fw-police:Server:GSRResult', function(Target)
    local TPlayer = FW.Functions.GetPlayer(Target)
    if TPlayer == nil then return end

    if CurrentStatusLists[TPlayer.PlayerData.source] ~= nil and HasStatus(TPlayer.PlayerData.source, 'gunpowder') then
        TriggerClientEvent('chatMessage', source, "GSR Resultaat - #" .. TPlayer.PlayerData.citizenid, "error", "Positief")
    else
        TriggerClientEvent('chatMessage', source, "GSR Resultaat - #" .. TPlayer.PlayerData.citizenid, "error", "Negatief")
    end
end)

RegisterServerEvent('fw-police:Server:SetStatus')
AddEventHandler('fw-police:Server:SetStatus', function(TargetList)
    local Player = FW.Functions.GetPlayer(source)
    if Player == nil then return end
    CurrentStatusLists[Player.PlayerData.source] = TargetList
end)

-- // Functions \\ --

function DoesEvidenceTypeExists(Type)
    for k, v in pairs(EvidenceTypes) do
        if v == Type then
            return true
        end
    end
    return false
end

function CreateEvidenceId(Type)
    local EvidenceType = 'FNGP'
    local RandomNumOne, RandomNumTwo = math.random(11111, 99999), math.random(11111, 99999)
    if Type == 'Blood' then
        EvidenceType = 'BLD'
    elseif Type == 'Bullet' then
        EvidenceType = 'BLT'
    end
    return RandomNumOne..'-'..EvidenceType..'-'..RandomNumTwo
end

function ClearEvidence(EvidenceId)
    Evidence[EvidenceId] = nil
    TriggerClientEvent('fw-police:Client:SetEvidence', -1, EvidenceId, nil)
end

function HasStatus(CitizenId, StatusName)
    for k, v in pairs(CurrentStatusLists[CitizenId]) do
        if v.Status == StatusName then
            return true
        end
    end
    return false
end

FW.RegisterServer("fw-police:Server:Receive:Evidence", function(Source, EvidenceData)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if #EvidenceData == 0 or not Player.Functions.RemoveItem('evidence', 1, false, true) then
        Player.Functions.Notify("Je hebt geen markeringen..", "error")
        TriggerClientEvent('fw-police:Client:Can:Collect:Again', Source)
        return 
    end

    for k, v in pairs(EvidenceData) do
        if v.Type == 'Bullet' then
            Player.Functions.AddItem('evidence-collected', 1, false, { Id = v.Serial, Serial = FW.Shared.EncryptString(v.Data.Serial), _IsDehashed = false, _EvidenceData = v.Data }, true, 'Bullet')
        elseif v.Type == 'Fingerprint' then
            Player.Functions.AddItem('evidence-collected', 1, false, { Id = v.Serial, Fingerprint = v.Data.FingerId, _EvidenceData = v.Data }, true, 'Finger')
        elseif v.Type == 'Blood' then
            Player.Functions.AddItem('evidence-collected', 1, false, { Id = v.Serial, BloodType = v.Data.BloodType, _EvidenceData = v.Data }, true, 'Blood')
        end
        ClearEvidence(v.Serial)
    end

    TriggerClientEvent('fw-police:Client:ResetCollectCooldown', Source)
end)

AddEventHandler('playerDropped', function(Reason)
    local Source = source
    if CurrentStatusLists[Source] ~= nil then
        CurrentStatusLists[Source] = nil
    end
end)