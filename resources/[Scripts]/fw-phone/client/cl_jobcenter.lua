JobCenter = {
    ActivityTimer = 0
}

-- Functions
function JobCenter.SetJobCenterData()
    local MyJob = exports['fw-jobmanager']:GetMyJob()

    SendNUIMessage({
        Action = "SetJobManager",
        JobManager = MyJob
    })
end

function JobCenter.SetGroups(Groups)
    SendNUIMessage({
        Action = "SetJobCenterGroups",
        Groups = Groups
    })
end

-- Events
RegisterNetEvent("fw-phone:Client:SetJobData")
AddEventHandler("fw-phone:Client:SetJobData", function(Data)
    JobCenter.SetJobCenterData()
end)

RegisterNetEvent("fw-phone:Client:RefreshGroups")
AddEventHandler("fw-phone:Client:RefreshGroups", function(JobId)
    if CurrentApp ~= 'jobcenter' then return end

    local MyJob = exports['fw-jobmanager']:GetMyJob()
    if MyJob.CurrentJob ~= JobId then return end

    local Groups = FW.SendCallback("fw-jobmanager:Server:GetGroupsByJob", JobId)
    JobCenter.SetGroups(Groups)
end)

RegisterNetEvent("fw-phone:Client:SetActivityTimer")
AddEventHandler("fw-phone:Client:SetActivityTimer", function(Timer)
    JobCenter.ActivityTimer = Timer

    Citizen.CreateThread(function()
        while JobCenter.ActivityTimer > 0 do
            JobCenter.ActivityTimer = JobCenter.ActivityTimer - 1000
            Citizen.Wait(1000)
        end
    end)
end)

RegisterNetEvent("fw-jobmanager:Client:JobCleanup")
AddEventHandler("fw-jobmanager:Client:JobCleanup", function(Timer)
    JobCenter.ActivityTimer = 0
end)

-- NUI Callback
RegisterNUICallback("JobCenter/GetJobs", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:JobCenter:GetJobs")
    Cb(Result)
end)

RegisterNUICallback("JobCenter/GetJobGroups", function(Data, Cb)
    local MyJob = exports['fw-jobmanager']:GetMyJob()
    local Result = FW.SendCallback("fw-jobmanager:Server:GetGroupsByJob", MyJob.CurrentJob)
    Cb(Result)
end)

RegisterNUICallback("JobCenter/LocateJob", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:JobCenter:GetJobs")
    SetNewWaypoint(Result[Data.JobId].Coords.x, Result[Data.JobId].Coords.y)
    Cb("Ok")
end)

RegisterNUICallback("JobCenter/CheckOut", function(Data, Cb)
    TriggerEvent('fw-jobmanager:Client:SignOut')
    JobCenter.SetJobCenterData()
end)

RegisterNUICallback("JobCenter/CreateGroup", function(Data, Cb)
    Notification("jobcenter-create-group", "fas fa-people-carry", { "white", "rgb(144, 202, 249)" }, "Groep Aanmaken", "Even geduld...")
    Citizen.Wait(250)

    local MyJob = exports['fw-jobmanager']:GetMyJob()
    local Result = FW.SendCallback("fw-jobmanager:Server:CreateGroup", MyJob.CurrentJob)
    
    UpdateNotification("jobcenter-create-group", false, false, "Verzoek om te Joinen", "Verzoek geaccepteerd!", false)
    Cb(Result)
end)

RegisterNUICallback("JobCenter/RequestToJoin", function(Data, Cb)
    local MyJob = exports['fw-jobmanager']:GetMyJob()
    TriggerServerEvent("fw-jobmanager:Server:RequestToJoin", MyJob.CurrentJob, Data.GroupId)
    Cb("ok")
end)

RegisterNUICallback("JobCenter/DisbandGroup", function(Data, Cb)
    local MyJob = exports['fw-jobmanager']:GetMyJob()
    local Result = FW.SendCallback("fw-jobmanager:Server:DisbandGroup", MyJob.CurrentJob, MyJob.CurrentGroup.Id)
    Cb(Result)
end)

RegisterNUICallback("JobCenter/LeaveGroup", function(Data, Cb)
    local MyJob = exports['fw-jobmanager']:GetMyJob()
    local Result = FW.SendCallback("fw-jobmanager:Server:LeaveGroup", MyJob.CurrentJob, MyJob.CurrentGroup.Id)
    Cb(Result)
end)

RegisterNUICallback("JobCenter/RemoveFromGroup", function(Data, Cb)
    local MyJob = exports['fw-jobmanager']:GetMyJob()
    Data.GroupId = MyJob.CurrentGroup.Id
    local Result = FW.SendCallback("fw-jobmanager:Server:RemoveFromGroup", MyJob.CurrentJob, Data)
    Cb(Result)
end)

RegisterNUICallback("JobCenter/PromoteToLeader", function(Data, Cb)
    local MyJob = exports['fw-jobmanager']:GetMyJob()
    Data.GroupId = MyJob.CurrentGroup.Id
    local Result = FW.SendCallback("fw-jobmanager:Server:PromoteToLeader", MyJob.CurrentJob, Data)
    Cb(Result)
end)

RegisterNUICallback("JobCenter/Ready", function(Data, Cb)
    local MyJob = exports['fw-jobmanager']:GetMyJob()
    local Result = FW.SendCallback("fw-jobmanager:Server:Ready", MyJob.CurrentJob, MyJob.CurrentGroup.Id)
    Cb(Result)
end)

RegisterNUICallback("JobCenter/AbandonJob", function(Data, Cb)
    local MyJob = exports['fw-jobmanager']:GetMyJob()
    TriggerServerEvent('fw-jobmanager:Server:AbandonJob', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id)
end)

RegisterNUICallback("JobCenter/GetTaskActivity", function(Data, Cb)
    Cb(JobCenter.ActivityTimer)
end)