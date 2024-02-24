local DiscordServerBotToken = ''

local DiscordServerId = 728231206252052551
local DiscordRoles = {
    1128027923467735160, -- Whitelisted
    -- 1128027903930675220, -- PD
    -- 1128027906145255556, -- EMS
    -- 1137330048374943795, -- DOC
    -- 1128027893033869372, -- Staff
    -- 1128027896938774558, -- Developer
    -- 1138784383671742465, -- Tester
}

local PrioRoles = {
    [1128027896938774558] = 15, -- Developers
    [1128027909492326472] = 8, -- Mayor
}

function HasDiscordPrioRole(Source)
    local DiscordIdentifier = nil
    for k, v in pairs(GetPlayerIdentifiers(Source)) do
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            DiscordIdentifier = string.gsub(v, "discord:", "")
        end
    end 
    if DiscordIdentifier ~= nil then
        for k, v in pairs(PrioRoles) do
            if IsDiscordRolePresent(Source, k, tonumber(DiscordIdentifier)) then
                return true, v
            end
        end
        return false, 0
    else
        return false, 0
    end
end

function CheckDiscordRole(Source)
    local DiscordIdentifier = nil
    for k, v in pairs(GetPlayerIdentifiers(Source)) do
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            DiscordIdentifier = string.gsub(v, "discord:", "")
        end
    end 
    if DiscordIdentifier ~= nil then
        for k, v in pairs(DiscordRoles) do
            if IsDiscordRolePresent(Source, v, tonumber(DiscordIdentifier)) then
                return true
            end
        end
        return false
    else
        return false
    end
end
exports("CheckDiscordRole", CheckDiscordRole)

function IsDiscordRolePresent(Source, Role, DiscordIdentifier)
	local Endpoint = ("guilds/%s/members/%s"):format(DiscordServerId, DiscordIdentifier)
	local Member = DiscordRequest("GET", Endpoint, {})
	if Member.Code == 200 then
		local Data = json.decode(Member.Data)
		local Roles = Data.roles
        for k, v in pairs(Roles) do
            if tonumber(v) == tonumber(Role) then
                return true
            end
        end
        return false
	else
		return false
	end
end

function DiscordRequest(Method, Endpoint, Jsondata)
    local Promise = promise:new()
    PerformHttpRequest("https://discordapp.com/api/"..Endpoint, function(ErrorCode, ResultData, ResultHeaders)
		local Data = {Data = ResultData, Code = ErrorCode, Headers = ResultHeaders}
        Promise:resolve(Data)
    end, Method, #Jsondata > 0 and json.encode(Jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = "Bot "..DiscordServerBotToken})
    return Citizen.Await(Promise)
end