FW = exports['fw-core']:GetCoreObject()

FW.Commands.Add("dutyon", "Ga in dienst.", {}, false, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= 'ems' and Player.PlayerData.job.name ~= 'police' and Player.PlayerData.job.name ~= 'storesecurity' and Player.PlayerData.job.name ~= 'doc' then
        return Player.Functions.Notify("Ze herkennen je niet..", "error")
    end

    local JobsToMdw = {
        police = 'Police',
        ems = 'EMS',
        doc = 'DOC',
        storesecurity = 'Police',
    }
    
    TriggerEvent('fw-mdw:Server:SetDuty', {
        Source = Source,
        Duty = not Player.PlayerData.job.onduty,
        Job = JobsToMdw[Player.PlayerData.job.name]
    })
end)

function UUID()
    math.randomseed(os.time())
    local template ="xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string.gsub(template, "[xy]", function (c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format("%x", v)
    end)
end

function DeepCopyTable(Obj)
    if type(Obj) ~= 'table' then return Obj end
    local res = {}
    
    for k, v in pairs(Obj) do
        res[DeepCopyTable(k)] = DeepCopyTable(v)
    end

    return res
end

function MySplit(Input, Seperator)
    if Seperator == nil then Seperator = "%s" end
    local Retval = {}
    for Match in string.gmatch(Input, "([^"..Seperator.."]+)") do
        table.insert(Retval, Match)
    end
    return Retval
end

function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function IsDispatcher(Source)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then
        return false
    end

    return (Player.PlayerData.job.name == 'police' or Player.PlayerData.job.name ~= 'storesecurity' or Player.PlayerData.job.name == 'doc' or Player.PlayerData.job.name == 'ems') and Player.PlayerData.job.onduty
end