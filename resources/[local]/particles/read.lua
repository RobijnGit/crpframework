-- test script for list import
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

local keyword = 'firework'
local dicts, particleNames = read_particles("./particlesFxDump.txt", keyword)

for _,v in ipairs(dicts) do
    for _, vv in ipairs(particleNames[v]) do
        print(v.." : "..vv)
    end
end