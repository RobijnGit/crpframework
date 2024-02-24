Config = Config or {}
Config.IdPrice = 500

Config.Licenses = {
    'Driver',
    'Hunting',
    -- 'Weapon',
    'Fishing',
    'Flying',
    'Business',
}

function DeepCopyTable(Obj)
    if type(Obj) ~= 'table' then return Obj end
    local res = {}
    
    for k, v in pairs(Obj) do
        res[DeepCopyTable(k)] = DeepCopyTable(v)
    end

    return res
end