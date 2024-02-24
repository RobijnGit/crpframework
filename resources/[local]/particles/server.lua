-- built and tested on linux, windows deals with string differently, please modify accroadingly

function read_particles(fileName, keyword)
    keyword = keyword or ''
    local dicts = {}
    local particleNames = {}
    print(fileName)
	local fin = io.open(fileName)
    for line in fin:lines()do
        if #line ~= 0 and line:sub(1,1) ~= '\r' and line:sub(1, 1) ~= '#' then
            if line:sub(1, 1) == '[' and line:sub(-1,-1) == ']' then
                if particleNames[dicts[#dicts]] == nil then
                    table.remove(dicts)
                end
                table.insert (dicts, line:sub(2,#line-1))
            else
                if string.find( line, keyword) then
                    if particleNames[dicts[#dicts]] == nil then
                        particleNames[dicts[#dicts]] = {}
                    end
                    table.insert(particleNames[dicts[#dicts]], line)
                end
            end
        end
    end
    if particleNames[dicts[#dicts]] == nil then
        table.remove(dicts)
    end
    fin:close()
    return dicts, particleNames
end

RegisterNetEvent("getParticlesData")

AddEventHandler("getParticlesData", function(keyword, scale)
    -- server log
    print("getParticlesData, Keyword: "..keyword.." Scale: "..scale)
    local particleTester = source
    -- Original Fx list: particlesFxDump.txt 
    -- Cherry-pick Fx list: cherry-pick.txt 
    local path = "resources/[local]/particles/particlesFxDump.txt"
    -- local path = "resources/[local]/particles/cherry-pick.txt"
    dicts, particleNames = read_particles(path, keyword)
    TriggerClientEvent("receivedParticlesData", particleTester, dicts, particleNames, scale)
end)