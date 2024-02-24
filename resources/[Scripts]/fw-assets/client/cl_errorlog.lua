local OriginalTrace = Citizen.Trace
local ErrorMatches = {
    "failure",
    "error",
    "not",
    "failed",
    "not safe", 
    "invalid",
    "cannot",
    ".lua", 
    ".js", 
    ".ts", 
    "server",
    "client",
    "attempt",
    "traceback",
    "stack",
    "function",
    "nil",
    "undefined"
}

function Citizen.Trace(...)
    OriginalTrace(...)

    if type(...) == "string" then
        local Args = string.lower(...)
        
        for _, Word in ipairs(ErrorMatches) do
            if string.find(Args, Word) then
                TriggerServerEvent('fw-assets:Server:ErrorLog', GetCurrentResourceName(), ...)
                return
            end
        end
    end
end