CurrentTaskId = false
MyJob = {
    CurrentJob = false,
    CurrentGroup = false,
}

RegisterNetEvent("fw-jobmanager:Client:SetupJob")
AddEventHandler("fw-jobmanager:Client:SetupJob", function(IsLeader, Data)
    CurrentTaskId = 1
end)

RegisterNetEvent("fw-jobmanager:Client:OnNextTask")
AddEventHandler("fw-jobmanager:Client:OnNextTask", function(IsLeader, TaskId)
    CurrentTaskId = TaskId
end)

RegisterNetEvent("fw-jobmanager:Client:JobCleanup")
AddEventHandler("fw-jobmanager:Client:JobCleanup", function(IsLeader, IsForced)
    CurrentTaskId = false
end)

RegisterNetEvent("fw-jobmanager:Client:SignIn")
AddEventHandler("fw-jobmanager:Client:SignIn", function(JobId)
    if MyJob.CurrentJob then
        return
    end

    local CanSignIn = FW.SendCallback("fw-jobmanager:Server:CanSignIn", JobId)
    if not CanSignIn then return end

    local Job = FW.SendCallback("fw-jobmanager:Server:GetJobById", JobId)
    MyJob.CurrentJob = JobId

    TriggerEvent("fw-phone:Client:Notification", "jobcenter-signin-" .. JobId, "fas fa-home", { "white", "rgb(38, 50, 56)" }, 'Uitzendbureau', "Ingeklokt als " .. Job.JobName)
    TriggerEvent("fw-phone:Client:SetJobData")
end)

RegisterNetEvent("fw-jobmanager:Client:SignOut")
AddEventHandler("fw-jobmanager:Client:SignOut", function()
    TriggerServerEvent("fw-jobmanager:Server:SignOut", MyJob.CurrentJob, MyJob.CurrentGroup and MyJob.CurrentGroup.Id or false)
    MyJob = { CurrentJob = false, CurrentGroup = false }
end)

RegisterNetEvent("fw-jobmanager:Client:SetGroupData")
AddEventHandler("fw-jobmanager:Client:SetGroupData", function(Data)
    MyJob.CurrentGroup = Data
    TriggerEvent("fw-phone:Client:SetJobData")
end)

function GetMyJob()
    return MyJob
end
exports("GetMyJob", GetMyJob)

function IsAlreadyCheckedIn()
    return MyJob.CurrentJob ~= false
end
exports("IsAlreadyCheckedIn", IsAlreadyCheckedIn)

function GetCurrentTaskId()
    return CurrentTaskId
end
exports("GetCurrentTaskId", GetCurrentTaskId)