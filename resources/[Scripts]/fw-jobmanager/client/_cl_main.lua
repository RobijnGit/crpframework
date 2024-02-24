FW, LoggedIn = exports['fw-core']:GetCoreObject(), false

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(1000, function()
        FW.Functions.TriggerCallback("fw-jobmanager:Server:GetConfig", function(Result) Config = Result end)
        PlayerJob = FW.Functions.GetPlayerData().job
        LoggedIn = true

        InitFishing()
    end)
end)

RegisterNetEvent('fw-jobmanager:client:sync:config')
AddEventHandler('fw-jobmanager:client:sync:config', function() 
    FW.Functions.TriggerCallback("fw-jobmanager:Server:GetConfig", function(Result) Config = Result end)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
    TriggerEvent("fw-jobmanager:Client:SignOut")
end)

RegisterNetEvent('FW:Client:OnJobUpdate')
AddEventHandler('FW:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

-- Code
Jobs, RouteBlip = nil, nil

Citizen.CreateThread(function()
    while FW == nil do Citizen.Wait(4) end
    Citizen.SetTimeout(500, function()
        if Jobs == nil then
            Jobs = FW.SendCallback("fw-jobmanager:Server:GetJobs")
            SetupPeds()
        end
    end)
end)

-- RegisterCommand("job:signin", function(Source, Args, Raw)
--     TriggerEvent("fw-jobmanager:Client:SignIn", Args[1])
-- end)

function StartProgress(Duration, Text, CanCancel)
    local Promise = promise:new()

    FW.Functions.Progressbar("f", Text, Duration + math.random(100, 1000), false, CanCancel, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = false,
    }, {}, {}, {}, function() -- Done
        Promise:resolve(true)
    end, function()
        Promise:resolve(false)
    end)

    return Citizen.Await(Promise)
end

function SetupPeds()
    for k, v in pairs(Jobs) do
        exports['fw-ui']:AddEyeEntry("job_ped_" .. v.JobId  , {
            Type = 'Entity',
            EntityType = 'Ped',
            SpriteDistance = 10.0,
            Position = vector4(v.Coords.x, v.Coords.y, v.Coords.z, v.Heading),
            Model = v.PedModel,
            Scenario = v.Scenario,
            Anim = v.Anim,
            Props = v.Props,
            Options = {
                {
                    Name = 'sign_in',
                    Icon = 'fas fa-circle',
                    Label = 'Inklokken',
                    EventType = 'Client',
                    EventName = 'fw-jobmanager:Client:SignIn',
                    EventParams = v.JobId,
                    Enabled = function(Entity)
                        local CanSignIn = FW.SendCallback('fw-jobmanager:Server:CanSignIn', v.JobId)
                        if CanSignIn then
                            return not exports['fw-jobmanager']:IsAlreadyCheckedIn()
                        end
                    end,
                },
                {
                    Name = 'sign_off',
                    Icon = 'fas fa-circle',
                    Label = 'Uitklokken',
                    EventType = 'Client',
                    EventName = 'fw-jobmanager:Client:SignOut',
                    EventParams = {},
                    Enabled = function(Entity)
                        if exports['fw-jobmanager']:GetMyJob().CurrentJob == v.JobId then
                            return exports['fw-jobmanager']:IsAlreadyCheckedIn()
                        end

                        return false
                    end,
                },
                {
                    Name = 'get_paycheck',
                    Icon = 'fas fa-hand-holding-usd',
                    Label = 'Salaris Ophalen',
                    EventType = 'Server',
                    EventName = 'fw-jobmanager:Server:ReceivePaycheck',
                    EventParams = {},
                    Enabled = function(Entity)
                        local Paycheck = FW.SendCallback('fw-jobmanager:Server:GetPaycheck')
                        return Paycheck > 0
                    end,
                },

                -- Job releated options
                -- Weedruns:
                
            }
        })
    end
end

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", SetupPeds)

function SetRouteBlip(Text, Coords, WithoutBlip)
    if RouteBlip then
        RemoveBlip(RouteBlip)
    end

    if WithoutBlip then
        ClearGpsMultiRoute()
        StartGpsMultiRoute(9, true, true)
        for k, v in pairs(Coords) do
            AddPointToGpsMultiRoute(v.x, v.y, v.z)
        end
        SetGpsMultiRouteRender(true)
    else
        RouteBlip = AddBlipForCoord(Coords.x, Coords.y, Coords.z)
        SetBlipSprite(RouteBlip, 1)
        SetBlipColour(RouteBlip, 3)
        SetBlipScale(RouteBlip, 1.0)
        SetBlipRoute(RouteBlip, true)
        SetBlipRouteColour(RouteBlip, 3)
        SetBlipAsShortRange(RouteBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Text)
        EndTextCommandSetBlipName(RouteBlip)
    end
end

function RemoveRouteBlip()
    if RouteBlip then
        RemoveBlip(RouteBlip)
    end
    ClearGpsMultiRoute()
end

function IsWearingHandshoes()
    local armIndex = GetPedDrawableVariation(PlayerPedId(), 3)
    local model = GetEntityModel(PlayerPedId())
    if model == GetHashKey("mp_m_freemode_01") then
        if Config.MaleNoGloves[armIndex] ~= nil and Config.MaleNoGloves[armIndex] then
            return false
        end
    else
        if Config.FemaleNoGloves[armIndex] ~= nil and Config.FemaleNoGloves[armIndex] then
            return false
        end
    end
    return math.random() > 0.15
end

RegisterNetEvent("fw-inventory:Client:Cock")
AddEventHandler("fw-inventory:Client:Cock", function()
    if not MyJob.CurrentJob then
        return
    end

    local Job = FW.SendCallback("fw-jobmanager:Server:GetJobById", MyJob.CurrentJob)
    if Job.VPNRequired and not exports['fw-inventory']:HasEnoughOfItem('vpn', 1) then
        TriggerEvent('fw-jobmanager:Client:SignOut')
    end
end)