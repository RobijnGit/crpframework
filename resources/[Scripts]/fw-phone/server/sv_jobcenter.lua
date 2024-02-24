JobCenter = {}
JobCenter.Jobs = {}

function CalculateSalaryRate(Job)
    local EmployeeCount = JobCenter.Jobs[Job].EmployeeCount

    local SalaryRate = 5
    if EmployeeCount < 7 then
        SalaryRate = 5
    elseif EmployeeCount >= 7 and EmployeeCount < 10 then
        SalaryRate = 4
    elseif EmployeeCount >= 10 and EmployeeCount < 13 then
        SalaryRate = 3
    elseif EmployeeCount >= 13 and EmployeeCount < 15 then
        SalaryRate = 2
    else
        SalaryRate = 1
    end

    return SalaryRate
end
exports("CalculateSalaryRate", CalculateSalaryRate)

RegisterNetEvent('fw-phone:Server:RefreshJobs', function()
    JobCenter.Jobs = exports['fw-jobmanager']:GetJobs()

    for k, v in pairs(JobCenter.Jobs) do
        JobCenter.Jobs[k].SalaryRate = 5
        JobCenter.Jobs[k].GroupCount = 0
        JobCenter.Jobs[k].EmployeeCount = 0
    end

    TriggerClientEvent('fw-jobmanager:Client:SetupJobPeds', -1, JobCenter.Jobs)
end)

RegisterNetEvent('fw-phone:Server:UpdateJobCounters', function(Job, Groups)
    if JobCenter.Jobs[Job] == nil then return end

    JobCenter.Jobs[Job].GroupCount = #Groups
    JobCenter.Jobs[Job].EmployeeCount = 0

    for k, v in pairs(Groups) do
        JobCenter.Jobs[Job].EmployeeCount = JobCenter.Jobs[Job].EmployeeCount + #v.Members
    end
    
    JobCenter.Jobs[Job].SalaryRate = CalculateSalaryRate(Job)
end)

FW.Functions.CreateCallback("fw-phone:Server:JobCenter:GetJobs", function(Source, Cb)
    local Retval = {}

    for k, v in pairs(JobCenter.Jobs) do
        if not v.Hidden then
            Retval[#Retval + 1] = v
        end
    end

    Cb(Retval)
end)

function GetJobGroupCount(JobId)
    return JobCenter.Jobs[JobId].GroupCount
end
exports("GetJobGroupCount", GetJobGroupCount)