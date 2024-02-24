JobCenter = {}
JobCenter.Groups = {} -- Table of all groups.
JobCenter.Users = {} -- Table of all users, with citizenid as index and groupid as value.

JobCenter.CidToName = {}
JobCenter.Paychecks = {}

JobCenter.OfferQueue = {}
JobCenter.ActiveQueues = {}
JobCenter.ActiveOffers = {}
JobCenter.ActiveJobs = {}

function GetJobs()
    return Config.Jobs
end
exports("GetJobs", GetJobs)

function CalculateExtraPaycheck(JobId)
    local SalaryRate = exports['fw-phone']:CalculateSalaryRate(JobId)
    if SalaryRate == 5 then
        return math.random(100, 150)
    elseif SalaryRate == 4 then
        return math.random(75, 100)
    elseif SalaryRate == 3 then
        return math.random(50, 75)
    elseif SalaryRate == 2 then
        return math.random(20, 50)
    elseif SalaryRate == 1 then
        return math.random(1, 20)
    end
end

function PickRandomName()
    return Config.FirstNames[math.random(1, #Config.FirstNames)]..' '..Config.LastNames[math.random(1, #Config.LastNames)]
end

function JobCenter.GetGroupByUser(Cid)
    return JobCenter.Users[Cid]
end
exports("GetGroupByUser", JobCenter.GetGroupByUser)

function JobCenter.GetGroup(JobId, GroupId)
    if JobId and GroupId then
        if JobCenter.Groups[JobId] and JobCenter.Groups[JobId][GroupId] then
            return JobCenter.Groups[JobId][GroupId]
        end
    end
    return nil
end
exports("GetGroup", JobCenter.GetGroup)

function JobCenter.GetGroupsByJob(JobId)
    return JobCenter.Groups[JobId]
end
exports("GetGroupsByJob", JobCenter.GetGroupsByJob)

function JobCenter.Signout(Source, JobId, GroupId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    JobCenter.Users[Player.PlayerData.citizenid] = nil

    if not GroupId then return end
    if JobCenter.Groups[JobId] == nil then return end
    if JobCenter.Groups[JobId][GroupId] == nil then return end

    for k, v in pairs(JobCenter.Groups[JobId][GroupId].Members) do
        if v.Cid == Player.PlayerData.citizenid then
            table.remove(JobCenter.Groups[JobId][GroupId].Members, k)
            TriggerClientEvent("fw-jobmanager:Client:SetGroupData", Player.PlayerData.source, false)
            break
        end
    end

    if #JobCenter.Groups[JobId][GroupId].Members == 0 then
        JobCenter.Groups[JobId][GroupId] = nil

        if Config.Jobs[JobId].OfferQueue then
            for k, v in pairs(JobCenter.OfferQueue[JobId]) do
                if v == GroupId then
                    table.remove(JobCenter.OfferQueue[JobId], k)
                end
            end
        end
    else
        for k, v in pairs(JobCenter.Groups[JobId][GroupId].Members) do
            local Member = FW.Functions.GetPlayerByCitizenId(v.Cid)
            if Member then
                TriggerClientEvent("fw-jobmanager:Client:SetGroupData", Member.PlayerData.source, JobCenter.Groups[JobId][GroupId])
            end
        end
    end

    TriggerEvent("fw-phone:Server:UpdateJobCounters", JobId, JobCenter.Groups[JobId])
    TriggerClientEvent("fw-phone:Client:RefreshGroups", -1, JobId)
end

-- Job Offers
function JobCenter.GenerateTasklist(JobId, GroupId, CustomTasks)
    local Tasks = CustomTasks and CustomTasks or DeepCopyTable(Config.JobTasks[JobId])
    local Data = {}

    if JobId == "sanitation" then
        local FirstZone = GetRandomFromArray(Config.Sanitation.Zones, {})
        if not FirstZone then return false end
        Tasks.Tasks[3].Title = (Tasks.Tasks[3].Title):format(FirstZone.Label)
        Data.FirstZone = FirstZone

        local SecondZone = GetRandomFromArray(Config.Sanitation.Zones, {FirstZone})
        if not SecondZone then return false end
        Tasks.Tasks[5].Title = (Tasks.Tasks[5].Title):format(SecondZone.Label)
        Data.SecondZone = SecondZone
    elseif JobId == "chopshop" then
        Data.Scrapyard = Config.ChopShop.Scrapyards[math.random(#Config.ChopShop.Scrapyards)]
    elseif JobId == "impound" then
        if #Config.ImpoundRequests > 0 then
            local RequestId = #Config.ImpoundRequests
            if Config.ImpoundRequests[RequestId].AlreadyTaken then
                RequestId = false
                for k, v in pairs(Config.ImpoundRequests) do
                    local Vehicle = NetworkGetEntityFromNetworkId(v.NetId)
                    if not v.AlreadyTaken and DoesEntityExist(Vehicle) then
                        RequestId = k
                        break
                    end
                end

                if not RequestId then
                    Data.Model = Config.Impound.Vehicles[math.random(1, #Config.Impound.Vehicles)]
                    Data.Coords = Config.Impound.Coords[math.random(1, #Config.Impound.Coords)]
                    Data.IsRequest = false
                    goto Skip
                end
            end

            Data.Model = Config.ImpoundRequests[RequestId].Model
            Data.Coords = Config.ImpoundRequests[RequestId].Coords
            Data.NetId = Config.ImpoundRequests[RequestId].NetId
            Data.RequestId = RequestId
            Data.IsRequest = true

            Config.ImpoundRequests[RequestId].AlreadyTaken = true
            ::Skip::
        else
            Data.Model = Config.Impound.Vehicles[math.random(1, #Config.Impound.Vehicles)]
            Data.Coords = Config.Impound.Coords[math.random(1, #Config.Impound.Coords)]
            Data.IsRequest = false
        end
    elseif JobId == "houses" then
        Data.House = GetRandomFromArray(Config.Houses.Houses, {}, function(Value) return Value.Available == true end)
        if not Data.House then return end
        Config.Houses.Houses[Data.House.Id].Available = false
        Config.Houses.Houses[Data.House.Id].GroupId = GroupId
        Data.Offsets = Config.Houses.Offsets[Data.House.Shell]

        Citizen.SetTimeout((1000 * 60) * 30, function()
            if Data.House and Data.House.Id then
                Config.Houses.Houses[Data.House.Id].Locked = true
                Config.Houses.Houses[Data.House.Id].Available = true
                Config.Houses.Houses[Data.House.Id].Alarm = true
                Config.Houses.Houses[Data.House.Id].Timer = 35
                Config.Houses.Houses[Data.House.Id].Loot = {}
                Config.Houses.Houses[Data.House.Id].GroupId = false
                TriggerClientEvent("fw-jobmanager:Client:Houses:SetData", -1, Data.House.Id, Config.Houses.Houses[Data.House.Id])
            end
        end)
    elseif JobId == "postop" then
        Data.Store = GetRandomFromArray(Config.DeliveryStores, {})
        if not Data.Store then return end
    elseif JobId == "fooddelivery" then
        Data.Foodchain = GetRandomFromArray(Config.FoodDelivery.Foodchains, {})
        if not Data.Foodchain then return end
        Data.House = GetRandomFromArray(Config.FoodDelivery.Deliveries, {})
        if not Data.House then return end
    elseif JobId == "oxy" then
        Data.FirstOxy = GetRandomFromArray(Config.Oxy, {}, function(Value) return Value.Available end)
        if not Data.FirstOxy then return end
        Data.SecondOxy = GetRandomFromArray(Config.Oxy, {Data.FirstOxy}, function(Value) return Value.Available end)
        if not Data.SecondOxy then return end
        Config.Oxy[Data.FirstOxy.Id].Available = false
        Config.Oxy[Data.SecondOxy.Id].Available = false

        Citizen.SetTimeout((1000 * 60) * 50, function()
            Config.Oxy[Data.FirstOxy.Id].Available = true
            Config.Oxy[Data.SecondOxy.Id].Available = true
        end)
    elseif JobId == "construction" then
        Data.ConstructionSite = GetRandomFromArray(Config.ConstructionSites, {}, function(Value) return Value.Available == true end)
        if not Data.ConstructionSite then return end
        Config.ConstructionSites[Data.ConstructionSite.Id].Available = false
        Tasks.Tasks[4].RequiredProgress = #Data.ConstructionSite.Objectives

        Citizen.SetTimeout((1000 * 60) * 50, function()
            Config.ConstructionSites[Data.ConstructionSite.Id].Available = true
        end)
    elseif JobId == "boosting" then
        Data = exports["fw-boosting"]:GetActiveContractByGroup(GroupId)
    end

    return Tasks, Data
end

function JobCenter.WaitForJobOffer(JobId, GroupId)
    local Group = JobCenter.Groups[JobId][GroupId]
    if Group == nil then return end
    if Group.State ~= 'Busy' then return end

    local Job = Config.Jobs[JobId]
    if Job == nil or Job.IgnoreQueue then return end

    local OfferId = FW.Shared.RandomStr(10)

    Citizen.SetTimeout((60 * 1000) * math.random(1, 3), function()
        local Group = JobCenter.Groups[JobId][GroupId]
        if Group == nil then return end
        if Group.State ~= 'Busy' then return end
        if Group.Tasks and #Group.Tasks > 0 then return end

        JobCenter.ActiveOffers[OfferId] = true

        local Player = FW.Functions.GetPlayerByCitizenId(Group.Members[1].Cid)
        if Player then
            TriggerClientEvent('fw-phone:Client:Notification', Player.PlayerData.source, "jobcenter-offer", "fas fa-people-carry", {"white", "rgb(144, 202, 249)"}, "Werkopdracht", Job.JobName, false, false, "fw-jobmanager:Server:StartJob", "", {
                OfferId = OfferId,
                JobId = JobId,
                GroupId = GroupId,
                HideOnAction = true,
            })

            Citizen.SetTimeout(10000, function()
                if JobCenter.ActiveOffers[OfferId] then
                    JobCenter.WaitForJobOffer(JobId, GroupId)
                end
            end)
        end
    end)
end

function JobCenter.SetupJob(JobId, GroupId, CustomTasks)
    local Group = JobCenter.Groups[JobId][GroupId]
    if Group == nil then return end

    local Tasks, Data = JobCenter.GenerateTasklist(JobId, GroupId, CustomTasks)

    if not Tasks then
        local Player = FW.Functions.GetPlayerByCitizenId(Group.Members[1].Cid)
        if Player == nil then return end
        TriggerClientEvent('fw-phone:Client:Notification', Player.PlayerData.source, "jobcenter-offer", "fas fa-people-carry", {"white", "rgb(144, 202, 249)"}, "Werkopdracht", "Je hebt deze keer de baan niet gekregen..")

        if Group.State == 'Busy' and not Config.Jobs[JobId].OfferQueue then
            JobCenter.WaitForJobOffer(JobId, GroupId)
        end
        return
    end

    Group.Activity = Tasks.Activity
    Group.Tasks = Tasks.Tasks

    local RandomId = FW.Shared.RandomStr(10)
    JobCenter.ActiveJobs[RandomId] = true
    Group.Activity.Id = RandomId

    for k, v in pairs(Group.Members) do
        local Player = FW.Functions.GetPlayerByCitizenId(v.Cid)
        if Player then
            TriggerClientEvent("fw-jobmanager:Client:SetGroupData", Player.PlayerData.source, Group)
            TriggerClientEvent('fw-phone:Client:SetActivityTimer', Player.PlayerData.source, Tasks.Activity.Timer)
            TriggerClientEvent('fw-jobmanager:Client:SetupJob', Player.PlayerData.source, k == 1, Tasks, Data)
            TriggerClientEvent("fw-phone:Client:Notification", Player.PlayerData.source, "jobcenter-task", "fas fa-people-carry", {"white", "rgb(144, 202, 249)"}, Tasks.Tasks[1].RequiredProgress > 1 and (("(%s/%s) Huidige Taak"):format(Tasks.Tasks[1].Progress, Tasks.Tasks[1].RequiredProgress)) or "Huidige Taak", Tasks.Tasks[1].Title, false, false, nil, nil, { Sticky = true })
        end
    end

    -- Stop the job after the time specified in the config
    Citizen.SetTimeout(Tasks.Activity.Timer, function()
        if JobCenter.ActiveJobs[RandomId] and Group ~= nil and Group.Members ~= nil and Group.Members[1] ~= nil then
            Group.Tasks = {}

            local Owner = FW.Functions.GetPlayerByCitizenId(Group.Members[1].Cid)
            if Owner then
                TriggerClientEvent('fw-phone:Client:Notification', Owner.PlayerData.source, "jobcenter-offer", "fas fa-home", {"white", "rgb(38, 50, 56)"}, "Werkopdracht", "De werkopdracht was niet voltooid.")
                if not Config.Jobs[JobId].OfferQueue then
                    JobCenter.WaitForJobOffer(JobId, GroupId)
                end
            end

            for k, v in pairs(Group.Members) do
                local Player = FW.Functions.GetPlayerByCitizenId(v.Cid)
                if Player then
                    TriggerClientEvent('fw-phone:Client:SetActivityTimer', Player.PlayerData.source, 0)
                    TriggerClientEvent('fw-jobmanager:Client:JobCleanup', Player.PlayerData.source, k == 1, true)
                end
            end
        end
    end)
end
exports("SetupJob", JobCenter.SetupJob)

function AddTaskProgress(JobId, GroupId, ActivityId, TaskId, Amount)
    local Group = JobCenter.Groups[JobId][GroupId]
    if Group == nil then return end

    local Task = Group.Tasks[TaskId]
    if Task == nil then return end

    if not JobCenter.ActiveJobs[ActivityId] then return end

    Task.Progress = Task.Progress + Amount
    if Task.Progress > Task.RequiredProgress then Task.Progress = Task.RequiredProgress end

    if Task.Progress >= Task.RequiredProgress then
        if Group.Tasks[TaskId + 1] == nil then
            JobCenter.ActiveJobs[ActivityId] = false
            local Owner = FW.Functions.GetPlayerByCitizenId(Group.Members[1].Cid)
            if Owner then
                TriggerClientEvent('fw-phone:Client:Notification', Owner.PlayerData.source, "jobcenter-offer", "fas fa-home", {"white", "rgb(38, 50, 56)"}, "Werkopdracht", "De opdracht is succesvol afgerond.")

                if Config.Jobs[JobId].BasePayment > 0 then
                    for k, v in pairs(Group.Members) do
                        local Player = FW.Functions.GetPlayerByCitizenId(v.Cid)
                        if Player then
                            if JobCenter.Paychecks[Player.PlayerData.citizenid] == nil then JobCenter.Paychecks[Player.PlayerData.citizenid] = 0 end
                            local HasBuff = exports['fw-hud']:DoesPlayerHaveBuff(Source, 'Salary')

                            local BasePayment = Config.Jobs[JobId].BasePayment * Config.Jobs[JobId].BaseIncreasement[#Group.Members]
                            BasePayment = BasePayment + CalculateExtraPaycheck(JobId)

                            if HasBuff then
                                BasePayment = BasePayment + math.random(100, 170)
                            end

                            JobCenter.Paychecks[Player.PlayerData.citizenid] = JobCenter.Paychecks[Player.PlayerData.citizenid] + BasePayment
                        end
                    end
                end

                if not Config.Jobs[JobId].OfferQueue then
                    JobCenter.WaitForJobOffer(JobId, GroupId)
                end
            end
        end

        for k, v in pairs(Group.Members) do
            local Player = FW.Functions.GetPlayerByCitizenId(v.Cid)
            if Player then
                TriggerClientEvent("fw-jobmanager:Client:SetGroupData", Player.PlayerData.source, Group)

                if Group.Tasks[TaskId + 1] then
                    TriggerClientEvent('fw-jobmanager:Client:OnNextTask', Player.PlayerData.source, k == 1, TaskId + 1)
                    Citizen.SetTimeout(500, function()
                        TriggerClientEvent("fw-phone:Client:Notification", Player.PlayerData.source, "jobcenter-task", "fas fa-people-carry", {"white", "rgb(144, 202, 249)"}, Group.Tasks[TaskId + 1].RequiredProgress > 1 and (("(%s/%s) Huidige Taak"):format(Group.Tasks[TaskId + 1].Progress, Group.Tasks[TaskId + 1].RequiredProgress)) or "Huidige Taak", Group.Tasks[TaskId + 1].Title, false, false, nil, nil, { Sticky = true })
                    end)
                else
                    Group.Activity = {}
                    Group.Tasks = {}

                    TriggerClientEvent('fw-phone:Client:RemoveNotification', Player.PlayerData.source, 'jobcenter-task')
                    TriggerClientEvent('fw-jobmanager:Client:JobCleanup', Player.PlayerData.source, k == 1, false)
                    TriggerClientEvent("fw-jobmanager:Client:SetGroupData", Player.PlayerData.source, Group)
                end
            end
        end
    else
        for k, v in pairs(Group.Members) do
            local Player = FW.Functions.GetPlayerByCitizenId(v.Cid)
            if Player then
                TriggerClientEvent("fw-phone:Client:UpdateNotification", Player.PlayerData.source, 'jobcenter-task', false, false, Group.Tasks[TaskId].RequiredProgress > 1 and (("(%s/%s) Huidige Taak"):format(Group.Tasks[TaskId].Progress, Group.Tasks[TaskId].RequiredProgress)) or "Huidige Taak", Group.Tasks[TaskId].Title, false)
                TriggerClientEvent("fw-jobmanager:Client:SetGroupData", Player.PlayerData.source, Group)
            end
        end
    end
end
exports("AddTaskProgress", AddTaskProgress)

RegisterNetEvent("fw-jobmanager:Server:ForceSetup")
AddEventHandler("fw-jobmanager:Server:ForceSetup", function(JobId, GroupId, CustomTasks)
    JobCenter.SetupJob(JobId, GroupId, CustomTasks)
end)

Citizen.CreateThread(function()
    for k, v in pairs(Config.Jobs) do
        if v.OfferQueue then
            JobCenter.OfferQueue[v.JobId] = {}
        end
    end

    while true do
        for _, Job in pairs(Config.Jobs) do
            if Job.OfferQueue and not Job.IgnoreQueue then
                JobCenter.ActiveQueues[Job.JobId] = true

                -- Send offer too all groups in this job
                if JobCenter.Groups[Job.JobId] then
                    for GroupId, Group in pairs(JobCenter.Groups[Job.JobId]) do
                        if #Group.Tasks == 0 and Group.State == 'Busy' then
                            local Player = FW.Functions.GetPlayerByCitizenId(Group.Members[1].Cid)
                            if Player then
                                TriggerClientEvent('fw-phone:Client:Notification', Player.PlayerData.source, "jobcenter-offer", "fas fa-people-carry", {"white", "rgb(144, 202, 249)"}, "Werkopdracht", Job.JobName, false, false, "fw-jobmanager:Server:JoinOfferQueue", "fw-jobmanager:Server:RejectOffer", {
                                    JobId = Job.JobId,
                                    GroupId = GroupId,
                                })
                            end
                        end
                    end
                end

                -- Wait 15 seconds so people can queue in
                Citizen.SetTimeout(15000, function()
                    JobCenter.ActiveQueues[Job.JobId] = false

                    if #JobCenter.OfferQueue[Job.JobId] > 0 then
                        for i = 1, #JobCenter.OfferQueue[Job.JobId] > 3 and 3 or 1, 1 do
                            -- Get random queuer
                            local RandomQueuer = math.random(1, #JobCenter.OfferQueue[Job.JobId])
                            local Queuer = JobCenter.OfferQueue[Job.JobId][RandomQueuer]

                            -- Remove queuer from queue, and give him the job
                            local IsJobAvailable = true
                            if Job.JobId == 'houses' then
                                if CurrentCops < Config.Houses.Cops then
                                    IsJobAvailable = false
                                    goto Skip
                                end

                                -- If there's a house available, then we'll be good to go.
                                for k, v in pairs(Config.Houses.Houses) do
                                    if v.Available then
                                        break; goto Skip
                                    end
                                end
                            elseif Job.JobId == 'oxy' then
                                if CurrentCops < Config.OxyDelivery.Cops then
                                    IsJobAvailable = false
                                    goto Skip
                                end

                                local AvailableOxys = 0
                                for k, v in pairs(Config.Oxy) do
                                    if v.Available then
                                        AvailableOxys = AvailableOxys + 1
                                        if AvailableOxys >= 2 then
                                            break; goto Skip
                                        end
                                    end
                                end
                            end

                            ::Skip::

                            if IsJobAvailable then
                                table.remove(JobCenter.OfferQueue[Job.JobId], RandomQueuer)
                                JobCenter.SetupJob(Job.JobId, Queuer)
                            end
                        end

                        -- Notify other queuers that they didn't get the job
                        for k, v in pairs(JobCenter.OfferQueue[Job.JobId]) do
                            local Group = JobCenter.Groups[Job.JobId][v]
                            if Group then
                                local Player = FW.Functions.GetPlayerByCitizenId(Group.Members[1].Cid)
                                if Player == nil then return end
                                TriggerClientEvent('fw-phone:Client:Notification', Player.PlayerData.source, "jobcenter-offer", "fas fa-people-carry", {"white", "rgb(144, 202, 249)"}, "Werkopdracht", "Je hebt deze keer de baan niet gekregen..")
                            end
                        end

                        JobCenter.OfferQueue[Job.JobId] = {}
                    end
                end)
            end
        end

        Citizen.Wait((60 * 1000) * math.random(2, 6))
    end
end)

RegisterNetEvent('fw-jobmanager:Server:StartJob', function(Data)
    local Source = source

    local SelectedJob = Config.Jobs[Data.JobId]
    if SelectedJob == nil then return end

    -- Cheater might try to start a job that is supposed to be queued for, but I wasn't born yesterday.
    if SelectedJob.OfferQueue then return end
    if SelectedJob.IgnoreQueue then return end

    local Group = JobCenter.Groups[Data.JobId][Data.GroupId]
    if Group == nil then return end

    if Group.State ~= 'Busy' then return end
    if #Group.Tasks > 0 then return end

    JobCenter.ActiveOffers[Data.OfferId] = false

    JobCenter.SetupJob(Data.JobId, Data.GroupId)
end)

RegisterNetEvent('fw-jobmanager:Server:RejectOffer', function(Data)
    local Source = source
    TriggerClientEvent("fw-phone:Client:RemoveNotification", Source, "jobcenter-offer")
end)

RegisterNetEvent('fw-jobmanager:Server:JoinOfferQueue', function(Data)
    local Source = source

    -- If player is too late with accepting the job offer, notify him that the job was expired.
    if not JobCenter.ActiveQueues[Data.JobId] then
        TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, "jobcenter-offer", false, false, false, "Werkopdracht verlopen..", true)
        return
    end

    TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, "jobcenter-offer", false, false, false, "Werkopdracht aangenomen...", true)

    table.insert(JobCenter.OfferQueue[Data.JobId], Data.GroupId)
end)

FW.RegisterServer('fw-jobmanager:Server:AddTaskProgress', function(Source, JobId, GroupId, ActivityId, TaskId, Amount)
    AddTaskProgress(JobId, GroupId, ActivityId, TaskId, Amount)
end)

RegisterNetEvent('fw-jobmanager:Server:AbandonJob', function(JobId, GroupId, ActivityId, Force)
    local Source = source

    local Group = JobCenter.Groups[JobId][GroupId]
    if Group == nil then return end

    if Group.State ~= 'Busy' then return end
    if #Group.Tasks == 0 then return end

    if not Force and Config.Jobs[JobId].PreventCancel then
        TriggerClientEvent('fw-phone:Client:Notification', Source, "jobcenter-offer", "fas fa-home", {"white", "rgb(38, 50, 56)"}, "Werkopdracht", "Werkopdracht niet annuleerbaar.")
        return
    end

    JobCenter.ActiveJobs[ActivityId] = false

    Group.Activity = {}
    Group.Tasks = {}

    local Owner = FW.Functions.GetPlayerByCitizenId(Group.Members[1].Cid)
    if Owner then
        TriggerClientEvent('fw-phone:Client:Notification', Owner.PlayerData.source, "jobcenter-offer", "fas fa-home", {"white", "rgb(38, 50, 56)"}, "Werkopdracht", "De opdracht was niet afgerond.")
        if not Config.Jobs[JobId].OfferQueue then
            JobCenter.WaitForJobOffer(JobId, GroupId)
        end
    end

    for k, v in pairs(Group.Members) do
        local Player = FW.Functions.GetPlayerByCitizenId(v.Cid)
        if Player then
            TriggerClientEvent('fw-phone:Client:RemoveNotification', Player.PlayerData.source, 'jobcenter-task')
            TriggerClientEvent("fw-jobmanager:Client:SetGroupData", Player.PlayerData.source, Group)
            TriggerClientEvent('fw-jobmanager:Client:JobCleanup', Player.PlayerData.source, k == 1, true)
            TriggerClientEvent('fw-phone:Client:SetActivityTimer', Player.PlayerData.source, 0)
        end
    end
end)

-- Events
RegisterNetEvent("fw-jobmanager:Server:SignOut")
AddEventHandler("fw-jobmanager:Server:SignOut", function(JobId, GroupId)
    local Source = source
    JobCenter.Signout(Source, JobId, GroupId)
end)

RegisterNetEvent("fw-jobmanager:Server:RequestToJoin")
AddEventHandler("fw-jobmanager:Server:RequestToJoin", function(JobId, GroupId)
    local Job = Config.Jobs[JobId]
    if Job == nil then return end

    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local HasVPN = Player.Functions.HasEnoughOfItem('vpn', 1)
    JobCenter.CidToName[Player.PlayerData.citizenid] = HasVPN and PickRandomName() or (Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname)

    local Group = JobCenter.Groups[JobId][GroupId]
    if Group == nil then return end

    local Owner = FW.Functions.GetPlayerByCitizenId(Group.Members[1].Cid)
    if Owner == nil then return end

    TriggerClientEvent('fw-phone:Client:Notification', Owner.PlayerData.source, "jobcenter-join-request-" .. Player.PlayerData.citizenid, "fas fa-people-carry", {"white", "rgb(144, 202, 249)"}, "Verzoek om te Joinen", JobCenter.CidToName[Player.PlayerData.citizenid], false, true, "fw-jobmanager:Server:AcceptJoinRequest", "", {
        JobId = JobId,
        GroupId = GroupId,
        Target = Player.PlayerData.citizenid,
        HideOnAction = true,
    })
end)

RegisterNetEvent("fw-jobmanager:Server:AcceptJoinRequest")
AddEventHandler("fw-jobmanager:Server:AcceptJoinRequest", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Target = FW.Functions.GetPlayerByCitizenId(Data.Target)
    if Target == nil then return end

    local HasVPN = Target.Functions.HasEnoughOfItem('vpn', 1)
    if JobCenter.Groups[Data.JobId][Data.GroupId] then
        if #JobCenter.Groups[Data.JobId][Data.GroupId].Members + 1 > Config.Jobs[Data.JobId].GroupSize then
            Player.Functions.Notify("Je kunt met deze baan maximaal " .. Config.Jobs[Data.JobId].GroupSize .. " leden in je groep hebben.", "error")
            return
        end

        if JobCenter.Users[Target.PlayerData.citizenid] then
            return
        end

        table.insert(JobCenter.Groups[Data.JobId][Data.GroupId].Members, {
            Cid = Target.PlayerData.citizenid,
            Name = HasVPN and JobCenter.CidToName[Target.PlayerData.citizenid] or (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname)
        })

        JobCenter.Users[Target.PlayerData.citizenid] = {JobId = Data.JobId, GroupId = Data.GroupId}

        for k, v in pairs(JobCenter.Groups[Data.JobId][Data.GroupId].Members) do
            local Member = FW.Functions.GetPlayerByCitizenId(v.Cid)
            if Member then
                TriggerClientEvent("fw-jobmanager:Client:SetGroupData", Member.PlayerData.source, JobCenter.Groups[Data.JobId][Data.GroupId])
            end
        end
        TriggerEvent("fw-phone:Server:UpdateJobCounters", Data.JobId, JobCenter.Groups[Data.JobId])
    end
end)

RegisterNetEvent("fw-jobmanager:Server:ReceivePaycheck")
AddEventHandler("fw-jobmanager:Server:ReceivePaycheck", function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if JobCenter.Paychecks[Player.PlayerData.citizenid] <= 0 then return end
    if exports['fw-financials']:AddMoneyToAccount('1001', '1', Player.PlayerData.charinfo.account, JobCenter.Paychecks[Player.PlayerData.citizenid], 'PAYCHECK', '') then
        TriggerClientEvent('fw-phone:Client:Notification', Player.PlayerData.source, "jobcenter-paycheck", "fas fa-home", {"white", "rgb(38, 50, 56)"}, "Werkopdracht", exports['fw-businesses']:NumberWithCommas(JobCenter.Paychecks[Player.PlayerData.citizenid]) .. ' is overgemaakt naar je bankrekening.')
        JobCenter.Paychecks[Player.PlayerData.citizenid] = 0
    end
end)

AddEventHandler("playerDropped", function(Reason)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if not Player then return end

    local UserData = JobCenter.Users[Player.PlayerData.citizenid]
    if not UserData then return end

    JobCenter.Signout(Source, UserData.JobId, UserData.GroupId)
end)

-- Callbacks
FW.Functions.CreateCallback("fw-jobmanager:Server:GetJobById", function(Source, Cb, JobId)
    Cb(Config.Jobs[JobId])
end)

FW.Functions.CreateCallback("fw-jobmanager:Server:GetGroupsByJob", function(Source, Cb, JobId)
    Cb(JobCenter.Groups[JobId])
end)

FW.Functions.CreateCallback("fw-jobmanager:Server:CanSignIn", function(Source, Cb, JobId)
    local Job = Config.Jobs[JobId]
    if Job == nil then return Cb(false) end

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return Cb(false) end

    local Retval = false

    if Job.VPNRequired then
        Retval = Player.Functions.HasEnoughOfItem('vpn', 1)
    else
        Retval = true
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-jobmanager:Server:CreateGroup", function(Source, Cb, JobId)
    local Job = Config.Jobs[JobId]
    if Job == nil then return Cb({Success = false, Msg = "Ongeldige Baan"}) end

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return Cb({Success = false, Msg = "Ongeldige Speler"}) end

    local HasVPN = Player.Functions.HasEnoughOfItem('vpn', 1)

    if JobCenter.Users[Player.PlayerData.citizenid] then
        return Cb({Success = false, Msg = "Je zit al in een groep."})
    end

    if JobCenter.Groups[JobId] == nil then JobCenter.Groups[JobId] = {} end

    local GroupId = #JobCenter.Groups[JobId] + 1
    JobCenter.Groups[JobId][GroupId] = {
        Id = GroupId,
        MaxSize = Config.Jobs[JobId].GroupSize,
        State = 'Idle',
        Tasks = {},
        Activity = false,
        Members = {
            {
                Cid = Player.PlayerData.citizenid,
                Name = HasVPN and PickRandomName() or (Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname)
            },
        },
    }

    JobCenter.Users[Player.PlayerData.citizenid] = {JobId = JobId, GroupId = GroupId}

    TriggerEvent("fw-phone:Server:UpdateJobCounters", JobId, JobCenter.Groups[JobId])
    TriggerClientEvent("fw-jobmanager:Client:SetGroupData", Source, JobCenter.Groups[JobId][GroupId])
    TriggerClientEvent("fw-phone:Client:RefreshGroups", -1, JobId)

    Cb({Success = true})
end)

FW.Functions.CreateCallback("fw-jobmanager:Server:DisbandGroup", function(Source, Cb, JobId, GroupId)
    local Job = Config.Jobs[JobId]
    if Job == nil then return Cb({Success = false, Msg = "Ongeldige Baan"}) end

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return Cb({Success = false, Msg = "Ongeldige Speler"}) end

    if JobCenter.Groups[JobId] == nil or JobCenter.Groups[JobId][GroupId] == nil then
        Cb({Success = false, Msg = "Ongeldige Groep"})
        return
    end

    if JobCenter.Users[Player.PlayerData.citizenid] and JobCenter.Users[Player.PlayerData.citizenid].GroupId ~= GroupId then
        Cb({Success = false, Msg = "Je zit niet in deze groep."})
        return
    end

    for k, v in pairs(JobCenter.Groups[JobId][GroupId].Members) do
        local Member = FW.Functions.GetPlayerByCitizenId(v.Cid)
        JobCenter.Users[v.Cid] = nil
        if Member then
            TriggerClientEvent("fw-jobmanager:Client:SetGroupData", Member.PlayerData.source, false)
        end
    end

    JobCenter.Groups[JobId][GroupId] = nil
    TriggerClientEvent("fw-phone:Client:RefreshGroups", -1, JobId)
    TriggerEvent("fw-phone:Server:UpdateJobCounters", JobId, JobCenter.Groups[JobId])

    Cb({Success = true})
end)

FW.Functions.CreateCallback("fw-jobmanager:Server:LeaveGroup", function(Source, Cb, JobId, GroupId)
    local Job = Config.Jobs[JobId]
    if Job == nil then return Cb({Success = false, Msg = "Ongeldige Baan"}) end

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return Cb({Success = false, Msg = "Ongeldige Speler"}) end

    if JobCenter.Groups[JobId] == nil or JobCenter.Groups[JobId][GroupId] == nil then
        Cb({Success = false, Msg = "Ongeldige Groep"})
        return
    end

    if JobCenter.Users[Player.PlayerData.citizenid] and JobCenter.Users[Player.PlayerData.citizenid].GroupId ~= GroupId then
        Cb({Success = false, Msg = "Je zit niet in deze groep."})
        return
    end

    JobCenter.Users[Player.PlayerData.citizenid] = false

    for k, v in pairs(JobCenter.Groups[JobId][GroupId].Members) do
        if v.Cid == Player.PlayerData.citizenid then
            table.remove(JobCenter.Groups[JobId][GroupId].Members, k)
            TriggerClientEvent("fw-jobmanager:Client:SetGroupData", Player.PlayerData.source, false)
            break
        end
    end

    for k, v in pairs(JobCenter.Groups[JobId][GroupId].Members) do
        local Member = FW.Functions.GetPlayerByCitizenId(v.Cid)
        if Member then
            TriggerClientEvent("fw-jobmanager:Client:SetGroupData", Member.PlayerData.source, JobCenter.Groups[JobId][GroupId])
        end
    end

    TriggerEvent("fw-phone:Server:UpdateJobCounters", JobId, JobCenter.Groups[JobId])
    TriggerClientEvent("fw-phone:Client:RefreshGroups", -1, JobId)

    Cb({Success = true})
end)

FW.Functions.CreateCallback("fw-jobmanager:Server:RemoveFromGroup", function(Source, Cb, JobId, Data)
    local Job = Config.Jobs[JobId]
    if Job == nil then Cb({Success = false, Msg = "Ongeldige Baan"}) return end

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then Cb({Success = false, Msg = "Ongeldige Speler"}) return end

    if tonumber(Data.Member) == nil then
        Cb({Success = false, Msg = "Ongeldige Speler"})
        return
    end

    local GroupId = Data.GroupId
    if JobCenter.Groups[JobId] == nil or JobCenter.Groups[JobId][GroupId] == nil then
        Cb({Success = false, Msg = "Ongeldige Groep"})
        return
    end

    if JobCenter.Groups[JobId][GroupId].Members[1].Cid ~= Player.PlayerData.citizenid then
        Cb({Success = false, Msg = "Denk het niet dud 😊"})
        return
    end

    if JobCenter.Groups[JobId][GroupId].Members[tonumber(Data.Member)] == nil then
        Cb({Success = false, Msg = "Ongeldige Speler"})
        return
    end

    local Member = FW.Functions.GetPlayerByCitizenId(JobCenter.Groups[JobId][GroupId].Members[tonumber(Data.Member)].Cid)
    JobCenter.Users[Member.PlayerData.citizenid] = nil
    TriggerClientEvent('fw-jobmanager:Client:SetGroupData', Member.PlayerData.source, false)

    table.remove(JobCenter.Groups[JobId][GroupId].Members, tonumber(Data.Member))
    TriggerClientEvent('fw-phone:Client:RefreshGroups', -1, JobId)

    for k, v in pairs(JobCenter.Groups[JobId][GroupId].Members) do
        local Member = FW.Functions.GetPlayerByCitizenId(v.Cid)
        if Member then
            TriggerClientEvent('fw-jobmanager:Client:SetGroupData', Member.PlayerData.source, JobCenter.Groups[JobId][GroupId])
        end
    end

    Cb({Success = true})
end)

FW.Functions.CreateCallback("fw-jobmanager:Server:PromoteToLeader", function(Source, Cb, JobId, Data)
    local Job = Config.Jobs[JobId]
    if Job == nil then Cb({Success = false, Msg = "Ongeldige Baan"}) return end

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then Cb({Success = false, Msg = "Ongeldige Speler"}) return end

    local GroupId = Data.GroupId
    if JobCenter.Groups[JobId] == nil or JobCenter.Groups[JobId][GroupId] == nil then
        Cb({Success = false, Msg = "Ongeldige Groep"})
        return
    end

    if JobCenter.Groups[JobId][GroupId].Members[1].Cid ~= Player.PlayerData.citizenid then
        Cb({Success = false, Msg = "Denk het niet dud 😊"})
        return
    end

    table.insert(JobCenter.Groups[JobId][GroupId].Members, 1, table.remove(JobCenter.Groups[JobId][GroupId].Members, tonumber(Data.Member)))
    for k, v in pairs(JobCenter.Groups[JobId][GroupId].Members) do
        local Member = FW.Functions.GetPlayerByCitizenId(v.Cid)
        if Member then
            TriggerClientEvent('fw-jobmanager:Client:SetGroupData', Member.PlayerData.source, JobCenter.Groups[JobId][GroupId])
        end
    end

    TriggerClientEvent('fw-phone:Client:RefreshGroups', -1, JobId)

    Cb({Success = true})
end)

FW.Functions.CreateCallback("fw-jobmanager:Server:Ready", function(Source, Cb, JobId, GroupId)
    local Job = Config.Jobs[JobId]
    if Job == nil then Cb({Success = false, Msg = "Ongeldige Baan"}) return end

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then Cb({Success = false, Msg = "Ongeldige Speler"}) return end

    if JobCenter.Groups[JobId] == nil or JobCenter.Groups[JobId][GroupId] == nil then
        Cb({Success = false, Msg = "Ongeldige Groep"})
        return
    end

    if JobCenter.Groups[JobId][GroupId].Members[1].Cid ~= Player.PlayerData.citizenid then
        Cb({Success = false, Msg = "Denk het niet dud 😊"})
        return
    end

    JobCenter.Groups[JobId][GroupId].State = JobCenter.Groups[JobId][GroupId].State == 'Idle' and 'Busy' or 'Idle'

    if JobCenter.Groups[JobId][GroupId].State == 'Busy' and not Job.OfferQueue then
        JobCenter.WaitForJobOffer(JobId, GroupId)
    end

    for k, v in pairs(JobCenter.Groups[JobId][GroupId].Members) do
        local Member = FW.Functions.GetPlayerByCitizenId(v.Cid)
        if Member then
            TriggerClientEvent('fw-jobmanager:Client:SetGroupData', Member.PlayerData.source, JobCenter.Groups[JobId][GroupId])
        end
    end

    TriggerClientEvent('fw-phone:Client:RefreshGroups', -1, JobId)

    Cb({Success = true})
end)

FW.Functions.CreateCallback("fw-jobmanager:Server:GetGroupCurrentTask", function(Source, Cb, JobId, GroupId)
    local Job = Config.Jobs[JobId]
    if Job == nil then return end

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if JobCenter.Groups[JobId] == nil or JobCenter.Groups[JobId][GroupId] == nil then return end

    local Group = JobCenter.Groups[JobId][GroupId]
    for k, v in pairs(Group.Tasks) do
        if v.Progress < v.RequiredProgress then
            Cb({
                TaskId = k,
                Title = v.Title,
                Progress = v.Progress,
                RequiredProgress = v.RequiredProgress
            })
            break
        end
    end

    Cb({})
end)

FW.Functions.CreateCallback("fw-jobmanager:Server:GetPaycheck", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Cb(JobCenter.Paychecks[Player.PlayerData.citizenid] or 0)
end)