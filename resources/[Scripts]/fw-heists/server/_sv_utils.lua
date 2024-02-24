function table.merge(Table1, Table2)
    local Retval = {}
    
    for i = 1, #Table1 do
        table.insert(Retval, Table1[i])
    end
    
    for i = 1, #Table2 do
        table.insert(Retval, Table2[i])
    end
    
    return Retval
end

function table.shuffle(Table)
    local TableLength = #Table
    local Retval = {}

    for i = 1, TableLength do
        Retval[i] = Table[i]
    end

    -- Perform the Fisher-Yates shuffle on the copied table
    for i = TableLength, 2, -1 do
        local j = math.random(i)
        Retval[i], Retval[j] = Retval[j], Retval[i]
    end

    return Retval
end

function UUID()
    math.randomseed(os.time())
    local template ="xxx-4xxx-xx"
    return string.gsub(template, "[xy]", function (c)
        local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format("%x", v)
    end)
end