FW = exports['fw-core']:GetCoreObject()
LoggedIn = false

Citizen.CreateThread(function()
    InitZones()
end)

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(1250, function() 
        LoggedIn = true
    end) 
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

-- Code

RegisterNetEvent("fw-cityhall:Client:GiveLicense")
AddEventHandler("fw-cityhall:Client:GiveLicense", function(Data)
    local Licenses = {}
    for k, v in pairs(Config.Licenses) do
        Licenses[#Licenses + 1] = {
            Icon = false,
            Text = v,
        }
    end

    local Result = exports['fw-ui']:CreateInput({
        {
            Name = 'Cid',
            Label = 'BSN',
            Icon = 'fas fa-id-card-alt'
        },
        {
            Name = 'License',
            Label = 'Vergunning',
            Icon = 'fas fa-file-certificate',
            Choices = Licenses
        }
    })

    if Result.Cid and Result.License then
        TriggerServerEvent('fw-cityhall:Server:SetLicense', Result.Cid, Result.License:lower())
    end
end)

RegisterNetEvent("fw-cityhall:Client:CreateFinancial")
AddEventHandler("fw-cityhall:Client:CreateFinancial", function(Data)

    local Result = exports['fw-ui']:CreateInput({
        {
            Name = 'Cid',
            Label = 'BSN',
            Icon = 'fas fa-id-card-alt'
        },
        {
            Name = 'Name',
            Label = 'Rekening Naam',
            Icon = 'fas fa-heading'
        },
        {
            Name = 'Type',
            Label = 'Rekening Type',
            Icon = 'fas fa-university',
            Choices = {
                { Text = 'Spaarrekening' },
                { Text = 'Bedrijfsrekening' },
            }
        }
    })

    if Result.Cid and Result.Name and Result.Type then
        TriggerServerEvent('fw-cityhall:Server:CreateFinancial', Result)
    end
end)

RegisterNetEvent("fw-cityhall:Client:FinancialState")
AddEventHandler("fw-cityhall:Client:FinancialState", function(Data)
    local Result = exports['fw-ui']:CreateInput({
        {
            Name = 'AccountId',
            Label = 'Rekeningnummer',
            Icon = 'fas fa-university'
        },
        {
            Name = 'State',
            Label = 'Status',
            Icon = 'fas fa-power-off',
            Choices = {
                { Text = 'Activeren' },
                { Text = 'Deactiveren' },
            }
        }
    })

    if Result.AccountId and Result.State then
        TriggerServerEvent('fw-cityhall:Server:SetFinancialState', Result.AccountId, Result.State == 'Activeren')
    end
end)

RegisterNetEvent("fw-cityhall:Client:FinancialMonitorState")
AddEventHandler("fw-cityhall:Client:FinancialMonitorState", function(Data)
    local Result = exports['fw-ui']:CreateInput({
        {
            Name = 'AccountId',
            Label = 'Rekeningnummer',
            Icon = 'fas fa-university'
        },
        {
            Name = 'State',
            Label = 'Monitoren',
            Icon = 'fas fa-power-off',
            Choices = {
                { Text = 'true' },
                { Text = 'false' },
            }
        }
    })

    if Result.AccountId and Result.State then
        TriggerServerEvent('fw-cityhall:Server:SetFinancialMonitorState', Result.AccountId, Result.State == 'true')
    end
end)

RegisterNetEvent('fw-cityhall:client:lawyer:add:closest')
AddEventHandler('fw-cityhall:client:lawyer:add:closest', function()
    local Player, Distance = FW.Functions.GetClosestPlayer()
    if Player ~= -1 and Distance < 1.5 then
        local ServerId = Player
        TriggerServerEvent('fw-cityhall:lawyer:add', ServerId)
    else
        FW.Functions.Notify("Niemand in de buurt..", "error")
    end
end)

RegisterNetEvent('fw-cityhall:client:hamer', function()
    TriggerEvent("fw-misc:Client:PlaySoundEntity", 'state.gavel', NetworkGetNetworkIdFromEntity(PlayerPedId()), true, GetPlayerServerId(PlayerId()))
end)

RegisterNetEvent("fw-cityhall:Client:SubpoenaRecords")
AddEventHandler("fw-cityhall:Client:SubpoenaRecords", function()
    local PlayerJob = FW.Functions.GetPlayerData().job
    if PlayerJob.name ~= 'judge' then return end

    local Result = exports['fw-ui']:CreateInput({
        { Label = 'Telefoonnummer', Icon = 'fas fa-phone-alt', Name = 'Phone' },
    })

    TriggerServerEvent("fw-cityhall:Server:SubpoenaRecords", Result)
end)

RegisterNetEvent("fw-cityhall:Client:SubpoenaFinancials")
AddEventHandler("fw-cityhall:Client:SubpoenaFinancials", function()
    local PlayerJob = FW.Functions.GetPlayerData().job
    if PlayerJob.name ~= 'judge' then return end

    local Result = exports['fw-ui']:CreateInput({
        { Label = 'Rekeningnummer', Icon = 'fas fa-university', Name = 'AccountId' },
    })

    TriggerServerEvent("fw-cityhall:Server:SubpoenaFinancials", Result)
end)

RegisterNetEvent("fw-cityhall:Client:SendAnnouncement")
AddEventHandler("fw-cityhall:Client:SendAnnouncement", function()
    FW.Functions.OpenMenu({ MainMenuItems = {
        {
            Icon = 'bullhorn',
            Title = 'Staats Mededeling',
            Desc = '[De Staat van San Andreas] <text>',
            Data = {
                Event = 'fw-cityhall:Client:AnnouncementInput',
                Type = 'Client',
                AnnounceType = "De Staat van San Andreas"
            }
        },
        {
            Icon = 'exclamation-triangle',
            Title = 'Waarschuwing voor Openbare Veiligheid',
            Desc = '[Openbare Veiligheidswaarschuwing] <text>',
            Data = {
                Event = 'fw-cityhall:Client:AnnouncementInput',
                Type = 'Client',
                AnnounceType = "Openbare Veiligheidswaarschuwing"
            }
        },
        {
            Icon = 'gavel',
            Title = 'Rechtbank Mededeling',
            Desc = '[De Rechtbank] <text>',
            Data = {
                Event = 'fw-cityhall:Client:AnnouncementInput',
                Type = 'Client',
                AnnounceType = "De Rechtbank"
            }
        },
    }})
end)

RegisterNetEvent("fw-cityhall:Client:AnnouncementInput")
AddEventHandler("fw-cityhall:Client:AnnouncementInput", function(Data)
    Citizen.Wait(100)

    local Result = exports['fw-ui']:CreateInput({
        { Label = 'Tekst', Name = 'Text', ShowLength = true, MaxLength = 500 },
    })

    FW.TriggerServer("fw-cityhall:Server:SendAnnouncement", Data.AnnounceType, Result.Text)
end)

RegisterNetEvent("fw-cityhall:Client:RequestBankaccount")
AddEventHandler("fw-cityhall:Client:RequestBankaccount", function(Data)
    Citizen.Wait(100)

    local Result = exports['fw-ui']:CreateInput({
        { Label = 'BSN', Name = 'Cid', Icon = 'user' },
    })

    FW.TriggerServer("fw-cityhall:Server:RequestBankaccount", Result.Cid)
end)

exports("IsGov", function()
    local PlayerData = FW.Functions.GetPlayerData()
    return PlayerData.job.name == "police" or PlayerData.job.name == "judge"
end)